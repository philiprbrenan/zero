//-----------------------------------------------------------------------------
// Fpga implementation and testing of NWay Trees
// Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
//------------------------------------------------------------------------------
module fpga1                                                                    // Run test programs
 (input  wire loadCode,                                                         // Load code on positive edge
  input  wire clock,                                                            // Execute the next instruction
  output reg  finished,                                                         // Goes high when the program has finished
  output reg  success);                                                         // Goes high on finish if all the tests passed

  parameter integer InstructionNWidth  = 256;                                   // Number of bits in an instruction
  parameter integer MemoryElementWidth =  12;                                   // Memory width

  parameter integer NInstructions  = 1000;  // 40s                              // Number of instruction slots in code memory
  parameter integer NArea          =   10;  // 40s                              // Size of each area on the heap
  parameter integer NArrays        = 1000;  // long AAAA                        // Maximum number of arrays
  parameter integer NHeap          = 1000;  //NArea*NArrays;                    // Amount of heap memory
  parameter integer NLocal         = 1000;                                      // Size of local memory
  parameter integer NIn            = 1000;  // 40                               // Size of input area
  parameter integer NOut           = 1000;  // 40                               // Size of output area
  parameter integer NFreedArrays   = 1000;  // 40                               // Size of output area

  reg startable;                                                                // Goes high when the program has been loaded and we are ready to run
  reg signed [ InstructionNWidth-1:0]         code[NInstructions:0];            // Code memory
  reg signed [MemoryElementWidth-1:0] opExecCounts[NInstructions:0];            // Instruction execution counts
  reg signed [MemoryElementWidth-1:0]   arraySizes[NArrays      :0];            // Size of each array
  reg signed [MemoryElementWidth-1:0]      heapMem[NHeap        :0];            // Heap memory
  reg signed [MemoryElementWidth-1:0]     localMem[NLocal       :0];            // Local memory
  reg signed [MemoryElementWidth-1:0]       outMem[NOut         :0];            // Out channel
  reg signed [MemoryElementWidth-1:0]  freedArrays[NFreedArrays :0];            // Freed arrays list implemented as a stack
  reg signed [MemoryElementWidth-1:0]   arrayShift[NArea        :0];            // Array shift area

  integer signed  NInstructionEnd;                                              // Limit of instructions for the current program
  integer signed         inMemPos;                                              // Current position in input channel
  integer signed         inMemEnd;                                              // End of input channel, this is the next element that would have been added.
  integer signed        outMemPos;                                              // Position in output channel
  integer signed           result;                                              // Result of an instruction execution
  integer signed           allocs;                                              // Maximum number of array allocations in use at any one time
  integer signed   freedArraysTop;                                              // Position in freed arrays stack
  integer signed i, j, k, l, p, q;                                              // Useful integers

//Layout of each instruction

  integer ip = 0;                                                               // Instruction pointer
  integer r1, r2, r3, r4, r5, r6, r7, r8;                                       // Intermediate array results

  wire signed [255:0] instruction = code[ip];
  wire signed [31:0]  operator    = instruction[255:224];
  wire signed [63:0]  source2     = instruction[ 63:  0];
  wire signed [63:0]  source      = instruction[127: 64];
  wire signed [63:0]  target      = instruction[191:128];

  wire signed [31: 0] source2Area     = source2[63:32];                         // Source 2
  wire signed [15: 0] source2Address  = source2[31:16];
  wire signed [ 2: 0] source2Arena    = source2[13:12];
  wire signed [ 2: 0] source2DArea    = source2[11:10];
  wire signed [ 2: 0] source2DAddress = source2[ 9: 8];
  wire signed [ 7: 0] source2Delta    = source2[ 7: 0];
  wire signed [31: 0] source2Value    =                                         // Source 2 as value
    source2Arena      == 0 ? 0 :
    source2Arena      == 1 ?
     (                        source2DAddress == 0 ? source2Address :
      source2DArea    == 0 && source2DAddress == 1 ? heapMem [source2Delta + source2Area*NArea           + source2Address]           :
      source2DArea    == 0 && source2DAddress == 2 ? heapMem [source2Delta + source2Area*NArea           + localMem[source2Address]] :
      source2DArea    == 1 && source2DAddress == 1 ? heapMem [source2Delta + localMem[source2Area]*NArea + source2Address]           :
      source2DArea    == 1 && source2DAddress == 2 ? heapMem [source2Delta + localMem[source2Area]*NArea + localMem[source2Address]] : 0) :
    source2Arena      == 2 ?
     (source2DAddress == 0 ? source2Address :
      source2DAddress == 1 ? localMem[source2Delta + source2Address]           :
      source2DAddress == 2 ? localMem[source2Delta + localMem[source2Address]] : 0) : 0;

  wire signed [31: 0] source1Area     = source[63:32];                          // Source 1
  wire signed [15: 0] source1Address  = source[31:16];
  wire signed [ 2: 0] source1Arena    = source[13:12];
  wire signed [ 2: 0] source1DArea    = source[11:10];
  wire signed [ 2: 0] source1DAddress = source[ 9: 8];
  wire signed [ 7: 0] source1Delta    = source[ 7: 0];
  wire signed [31: 0] source1Value    =                                         // Source 1 as value
    source1Arena      == 0 ? 0 :
    source1Arena      == 1 ?
     (                        source1DAddress == 0 ? source1Address :
      source1DArea    == 0 && source1DAddress == 1 ? heapMem [source1Delta + source1Area*NArea           + source1Address]           :
      source1DArea    == 0 && source1DAddress == 2 ? heapMem [source1Delta + source1Area*NArea           + localMem[source1Address]] :
      source1DArea    == 1 && source1DAddress == 1 ? heapMem [source1Delta + localMem[source1Area]*NArea + source1Address]           :
      source1DArea    == 1 && source1DAddress == 2 ? heapMem [source1Delta + localMem[source1Area]*NArea + localMem[source1Address]] : 0) :
    source1Arena      == 2 ?
     (source1DAddress == 0 ? source1Address :
      source1DAddress == 1 ? localMem[source1Delta + source1Address]           :
      source1DAddress == 2 ? localMem[source1Delta + localMem[source1Address]] : 0) : 0;
  wire signed [31: 0] sourceLocation  =                                         // Source 1 as a location
    source1Arena      == 0 ? 0 :
    source1Arena      == 1 ?
     (                        source1DAddress == 0 ? source1Address :
      source1DArea    == 0 && source1DAddress == 1 ? source1Delta + source1Area*NArea           + source1Address           :
      source1DArea    == 0 && source1DAddress == 2 ? source1Delta + source1Area*NArea           + localMem[source1Address] :
      source1DArea    == 1 && source1DAddress == 1 ? source1Delta + localMem[source1Area]*NArea + source1Address           :
      source1DArea    == 1 && source1DAddress == 2 ? source1Delta + localMem[source1Area]*NArea + localMem[source1Address] : 0) :
    source1Arena      == 2 ?
     (source1DAddress == 0 ? source1Address :
      source1DAddress == 1 ? source1Delta + localMem[source1Address]           :
      source1DAddress == 2 ? source1Delta + localMem[localMem[source1Address]] : 0) : 0;

  wire signed [31: 0] targetArea      = target[63:32];                          // Target
  wire signed [15: 0] targetAddress   = target[31:16];
  wire signed [ 2: 0] targetArena     = target[13:12];
  wire signed [ 2: 0] targetDArea     = target[11:10];
  wire signed [ 2: 0] targetDAddress  = target[ 9: 8];
  wire signed [ 7: 0] targetDelta     = target[ 7: 0];
  wire signed [31: 0] targetLocation  =                                         // Target as a location
    targetArena      == 0 ? 0 :                                                 // Invalid
    targetArena      == 1 ?                                                     // Heap
     (targetDArea    == 0 && targetDAddress == 1 ? targetDelta + targetArea*NArea           + targetAddress           :
      targetDArea    == 0 && targetDAddress == 2 ? targetDelta + targetArea*NArea           + localMem[targetAddress] :
      targetDArea    == 1 && targetDAddress == 1 ? targetDelta + localMem[targetArea]*NArea + targetAddress           :
      targetDArea    == 1 && targetDAddress == 2 ? targetDelta + localMem[targetArea]*NArea + localMem[targetAddress] : 0) :
    targetArena      == 2 ?                                                     // Local
     (targetDAddress == 1 ?  targetDelta + targetAddress           :
      targetDAddress == 2 ?  targetDelta + localMem[targetAddress] : 0) : 0;

  wire signed [31: 0] targetIndex  =                                            // Target index within array
    targetArena      == 1 ?                                                     // Heap
     (targetDAddress == 1 ? targetDelta + targetAddress           :
      targetDAddress == 2 ? targetDelta + localMem[targetAddress] : 0)  : 0;

  wire signed [31: 0] targetLocationArea =                                      // Number of array containing target
      targetArena    == 1 && targetDArea == 0 ? targetArea :
      targetArena    == 1 && targetDArea == 1 ? localMem[targetArea]    : 0;

  wire signed [31: 0] targetValue    =                                          // Target as value
    targetArena      == 0 ? 0 :
    targetArena      == 1 ?
     (                       targetDAddress == 0 ? targetAddress :
      targetDArea    == 0 && targetDAddress == 1 ? heapMem [targetDelta + targetArea*NArea           + targetAddress]           :
      targetDArea    == 0 && targetDAddress == 2 ? heapMem [targetDelta + targetArea*NArea           + localMem[targetAddress]] :
      targetDArea    == 1 && targetDAddress == 1 ? heapMem [targetDelta + localMem[targetArea]*NArea + targetAddress]           :
      targetDArea    == 1 && targetDAddress == 2 ? heapMem [targetDelta + localMem[targetArea]*NArea + localMem[targetAddress]] : 0) :
    targetArena      == 2 ?
     (targetDAddress == 0 ? targetAddress :
      targetDAddress == 1 ? localMem[targetDelta + targetAddress]           :
      targetDAddress == 2 ? localMem[targetDelta + localMem[targetAddress]] : 0) : 0;

  task printInstruction();                                                      // Print an instruction
    begin;
      $display("targetAddress =%4x Area=%4x DAddress=%4x DArea=%4x Arena=%4x Delta=%4x Location=%4x value=%4x",
        targetAddress, targetArea, targetDAddress, targetDArea, targetArena, targetDelta, targetLocation, targetValue);

      $display("source1Address=%4x Area=%4x DAddress=%4x DArea=%4x Arena=%4x Delta=%4x Value   =%4x",
        source1Address, source1Area, source1DAddress, source1DArea, source1Arena, source1Delta, source1Value);

      $display("source2Address=%4x Area=%4x DAddress=%4x DArea=%4x Arena=%4x Delta=%4x Value   =%4x",
        source2Address, source2Area, source2DAddress, source2DArea, source2Arena, source2Delta, source2Value);
    end
  endtask

  task initializeMemory();                                                      // Initialize memory so we start in a known state
    begin;
      allocs         = 0;                                                       // Largest number of arrays in use at any one time so far
      freedArraysTop = 0;                                                       // Start freed arrays stack
      outMemPos      = 0;                                                       // Output channel position
      for(i = 0; i < NOut;          i = i + 1)       outMem[i] = 'bx;           // Reset the output channel
      for(i = 0; i < NHeap;         i = i + 1)      heapMem[i] = 'bx;           // Reset heap memory
      for(i = 0; i < NLocal;        i = i + 1)     localMem[i] = 'bx;           // Reset local memory
      for(i = 0; i < NArrays;       i = i + 1)   arraySizes[i] =  0;            // Set array sizes
      for(i = 0; i < NInstructions; i = i + 1) opExecCounts[i] =  0;            // Set operator counts
    end
  endtask


// Execute each test progam

  always @(posedge loadCode) begin                                              // Load code
    startable  = 0;
    ip         = 0;
    finished   = 0;
    success    = 0;
    Add_test();
    initializeMemory();
    startable = 1;
  end

  always @(posedge clock) begin                                                 // Execute instruction
    if (startable) begin
      if (ip >= 0 && ip < NInstructionEnd) begin                                // Ip in range
        executeInstruction();
        ip = ip + 1;
      end
      else begin;                                                               // Finished
        finished = 1;
      end
    end
  end

  always @(posedge finished) begin                                              // Evaluate results of program execution
    success = outMem[0] == 5;
  end

//Single instruction execution

  task executeInstruction();                                                    // Execute an instruction
    begin
      result = 'bx;
      case(operator)
         0: begin; add_instruction();                                       end // add_instruction
         1: begin; array_instruction();                                     end // array_instruction
         2: begin; arrayCountGreater_instruction();                         end // arrayCountGreater_instruction
         3: begin; arrayCountLess_instruction();                            end // arrayCountLess_instruction
         4: begin; arrayDump_instruction();                                 end // arrayDump_instruction
         5: begin; arrayIndex_instruction();                                end // arrayIndex_instruction
         6: begin; arraySize_instruction();                                 end // arraySize_instruction
         7: begin; assert_instruction();                                    end // assert_instruction
         8: begin; assertEq_instruction();                                  end // assertEq_instruction
         9: begin; assertFalse_instruction();                               end // assertFalse_instruction
        10: begin; assertGe_instruction();                                  end // assertGe_instruction
        11: begin; assertGt_instruction();                                  end // assertGt_instruction
        12: begin; assertLe_instruction();                                  end // assertLe_instruction
        13: begin; assertLt_instruction();                                  end // assertLt_instruction
        14: begin; assertNe_instruction();                                  end // assertNe_instruction
        15: begin; assertTrue_instruction();                                end // assertTrue_instruction
        16: begin; call_instruction();                                      end // call_instruction
        17: begin; confess_instruction();                                   end // confess_instruction
        18: begin; dump_instruction();                                      end // dump_instruction
        19: begin; free_instruction();                                      end // free_instruction
        20: begin; in_instruction();                                        end // in_instruction
        21: begin; inSize_instruction();                                    end // inSize_instruction
        22: begin; jEq_instruction();                                       end // jEq_instruction
        23: begin; jFalse_instruction();                                    end // jFalse_instruction
        24: begin; jGe_instruction();                                       end // jGe_instruction
        25: begin; jGt_instruction();                                       end // jGt_instruction
        26: begin; jLe_instruction();                                       end // jLe_instruction
        27: begin; jLt_instruction();                                       end // jLt_instruction
        28: begin; jNe_instruction();                                       end // jNe_instruction
        29: begin; jTrue_instruction();                                     end // jTrue_instruction
        30: begin; jmp_instruction();                                       end // jmp_instruction
        31: begin; label_instruction();                                     end // label_instruction
        32: begin; loadAddress_instruction();                               end // loadAddress_instruction
        33: begin; loadArea_instruction();                                  end // loadArea_instruction
        34: begin; mov_instruction();                                       end // mov_instruction
        35: begin; moveLong_instruction();                                  end // moveLong_instruction
        36: begin; nop_instruction();                                       end // nop_instruction
        37: begin; not_instruction();                                       end // not_instruction
        38: begin; out_instruction();                                       end // out_instruction
        39: begin; parallelContinue_instruction();                          end // parallelContinue_instruction
        40: begin; parallelStart_instruction();                             end // parallelStart_instruction
        41: begin; parallelStop_instruction();                              end // parallelStop_instruction
        42: begin; paramsGet_instruction();                                 end // paramsGet_instruction
        43: begin; paramsPut_instruction();                                 end // paramsPut_instruction
        44: begin; pop_instruction();                                       end // pop_instruction
        45: begin; push_instruction();                                      end // push_instruction
        46: begin; random_instruction();                                    end // random_instruction
        47: begin; randomSeed_instruction();                                end // randomSeed_instruction
        48: begin; resize_instruction();                                    end // resize_instruction
        49: begin; return_instruction();                                    end // return_instruction
        50: begin; returnGet_instruction();                                 end // returnGet_instruction
        51: begin; returnPut_instruction();                                 end // returnPut_instruction
        52: begin; shiftDown_instruction();                                 end // shiftDown_instruction
        53: begin; shiftLeft_instruction();                                 end // shiftLeft_instruction
        54: begin; shiftRight_instruction();                                end // shiftRight_instruction
        55: begin; shiftUp_instruction();                                   end // shiftUp_instruction
        56: begin; subtract_instruction();                                  end // subtract_instruction
        57: begin; tally_instruction();                                     end // tally_instruction
        58: begin; trace_instruction();                                     end // trace_instruction
        59: begin; traceLabels_instruction();                               end // traceLabels_instruction
        60: begin; watch_instruction();                                     end // watch_instruction
      endcase
    end
  endtask
  task arrayDump_instruction();
    begin                                                                       // arrayDump
     $display("arrayDump");
    end
  endtask
  task assert_instruction();
    begin                                                                       // assert
     $display("assert");
    end
  endtask
  task assertEq_instruction();
    begin                                                                       // assertEq
     $display("assertEq");
    end
  endtask
  task assertFalse_instruction();
    begin                                                                       // assertFalse
     $display("assertFalse");
    end
  endtask
  task assertGe_instruction();
    begin                                                                       // assertGe
     $display("assertGe");
    end
  endtask
  task assertGt_instruction();
    begin                                                                       // assertGt
     $display("assertGt");
    end
  endtask
  task assertLe_instruction();
    begin                                                                       // assertLe
     $display("assertLe");
    end
  endtask
  task assertLt_instruction();
    begin                                                                       // assertLt
     $display("assertLt");
    end
  endtask
  task assertNe_instruction();
    begin                                                                       // assertNe
    //$display("assertNe");
    end
  endtask
  task assertTrue_instruction();
    begin                                                                       // assertTrue
     $display("assertTrue");
    end
  endtask
  task call_instruction();
    begin                                                                       // call
     $display("call");
    end
  endtask
  task confess_instruction();
    begin                                                                       // confess
     $display("confess");
    end
  endtask
  task dump_instruction();
    begin                                                                       // dump
     $display("dump");
    end
  endtask
  task label_instruction();
    begin                                                                       // label
    end
  endtask
  task loadAddress_instruction();
    begin                                                                       // loadAddress
     $display("loadAddress");
    end
  endtask
  task loadArea_instruction();
    begin                                                                       // loadArea
     $display("loadArea");
    end
  endtask
  task nop_instruction();
    begin                                                                       // nop
     $display("nop");
    end
  endtask
  task parallelContinue_instruction();
    begin                                                                       // parallelContinue
    //$display("parallelContinue");
    end
  endtask
  task parallelStart_instruction();
    begin                                                                       // parallelStart
    //$display("parallelStart");
    end
  endtask
  task parallelStop_instruction();
    begin                                                                       // parallelStop
    // $display("parallelStop");
    end
  endtask
  task paramsGet_instruction();
    begin                                                                       // paramsGet
     $display("paramsGet");
    end
  endtask
  task paramsPut_instruction();
    begin                                                                       // paramsPut
     $display("paramsPut");
    end
  endtask
  task random_instruction();
    begin                                                                       // random
     $display("random");
    end
  endtask
  task randomSeed_instruction();
    begin                                                                       // randomSeed
     $display("randomSeed");
    end
  endtask
  task return_instruction();
    begin                                                                       // return
     $display("return");
    end
  endtask
  task returnGet_instruction();
    begin                                                                       // returnGet
     $display("returnGet");
    end
  endtask
  task returnPut_instruction();
    begin                                                                       // returnPut
     $display("returnPut");
    end
  endtask
  task shiftDown_instruction();
    begin                                                                       // shiftDown
     $display("shiftDown");
    end
  endtask
  task tally_instruction();
    begin                                                                       // tally
     $display("tally");
    end
  endtask
  task trace_instruction();
    begin                                                                       // trace
     $display("trace");
    end
  endtask
  task traceLabels_instruction();
    begin                                                                       // traceLabels
     $display("traceLabels");
    end
  endtask
  task watch_instruction();
    begin                                                                       // watch
     $display("watch");
    end
  endtask

//Programs to execute as tests

  task Add_test();                                                              // Load program 'Add_test' into code memory    begin
    begin
      NInstructionEnd = 2;
      code[   0] = 'h0000000000000000000000000000210000000000000320000000000000022000;
      code[   1] = 'h0000002600000000000000000000010000000000000021000000000000000000;
    end
  endtask

//Memory access functions for instruction execution

  reg signed [MemoryElementWidth-1:0] targetArraySize1 = 0;
  reg signed [MemoryElementWidth-1:0] targetArraySize2 = 0;

  task setMemory();                                                             // Set the target memory location updating the containing array size if necessary
    begin
      case(targetArena)
        1: begin                                                                // Update array
          heapMem[targetLocation] = result;
// The next line makes place and route very slow    AAAA
          //arraySizes[targetLocationArea]  =
          //arraySizes[targetLocationArea] >  targetIndex ?
          //arraySizes[targetLocationArea]  : targetIndex + 1;

          targetArraySize1 = arraySizes[targetLocationArea];
          targetArraySize2 = targetArraySize1 > targetIndex ? targetArraySize1 : targetIndex + 1;
          arraySizes[targetLocationArea] = targetArraySize2;
        end
        2: localMem[targetLocation] = result;                                   // Local memory
      endcase
    end
  endtask

//Implementation of each instruction

  task add_instruction();                                                       // Add
    begin
      result = source1Value + source2Value;
      setMemory();
    end
  endtask

  task array_instruction();                                                     // Array
    begin
      if (freedArraysTop > 0) begin                                             // Reuse an array
        freedArraysTop = freedArraysTop - 1;
        result = freedArrays[freedArraysTop];
      end
      else begin
        result = allocs;                                                        // Array zero means undefined
        allocs = allocs + 1;                                                    // Array zero means undefined
      end

      arraySizes[targetLocationArea] = 0;                                       // Zero array length
      setMemory();                                                              // Save address of array
    end
  endtask

  task free_instruction();
    begin                                                                       // Free
      //freedArrays[freedArraysTop] = targetValue;
      //freedArraysTop = freedArraysTop + 1;
      //arraySizes[targetValue] = 0;                                              // Zero array length
    end
  endtask

  task mov_instruction();                                                       // Mov
    begin
      //result = source1Value;
      ////$display("%4d = Mov %d(%d), %d", result, targetLocation, targetArena, source1Value);
      //setMemory();                                                              // Save result in target
    end
  endtask


  task not_instruction();                                                       // Not
    begin
      //result = source1Value ? 0 : 1;
      //setMemory();                                                              // Save result in target
    end
  endtask

  task resize_instruction();                                                    // Resize
    begin
      //result = source1Value;
      //arraySizes[targetLocationArea] = result;
    end
  endtask

  task subtract_instruction();                                                  // Subtract
    begin
      //result = source1Value - source2Value;
      //setMemory();                                                              // Save result in target
    end
  endtask

  task out_instruction();                                                       // Out
    begin
      outMem[outMemPos] = source1Value;
      outMemPos = outMemPos + 1;
//$display("Out %d",source1Value);
    end
  endtask

  task arrayIndex_instruction();
    begin                                                                       // ArrayIndex
      //begin
      //  q = source1Value * NArea;                                               // Array location
      //  p = arraySizes[source1Value];                                           // Length of array
      //  result = 0;
      //end
      //case(p)                                                                   // Arrays can be dynamic but only up to a fixed size so that we can unroll the loop that finds an element
      //  1:
      //      begin if (heapMem[q+0] == source2Value) result = 1; end
      //  2:
      //    begin
      //      begin if (heapMem[q+0] == source2Value) result = 1; end
      //      begin if (heapMem[q+1] == source2Value) result = 2; end
      //    end
      //  3:
      //    begin
      //      begin if (heapMem[q+0] == source2Value) result = 1; end
      //      begin if (heapMem[q+1] == source2Value) result = 2; end
      //      begin if (heapMem[q+2] == source2Value) result = 3; end
      //    end
      //  4:
      //    begin
      //      begin if (heapMem[q+0] == source2Value) result = 1; end
      //      begin if (heapMem[q+1] == source2Value) result = 2; end
      //      begin if (heapMem[q+2] == source2Value) result = 3; end
      //      begin if (heapMem[q+3] == source2Value) result = 4; end
      //    end
      //  5:
      //    begin
      //      begin if (heapMem[q+0] == source2Value) result = 1; end
      //      begin if (heapMem[q+1] == source2Value) result = 2; end
      //      begin if (heapMem[q+2] == source2Value) result = 3; end
      //      begin if (heapMem[q+3] == source2Value) result = 4; end
      //      begin if (heapMem[q+4] == source2Value) result = 5; end
      //    end
      //  6:
      //    begin
      //      begin if (heapMem[q+0] == source2Value) result = 1; end
      //      begin if (heapMem[q+1] == source2Value) result = 2; end
      //      begin if (heapMem[q+2] == source2Value) result = 3; end
      //      begin if (heapMem[q+3] == source2Value) result = 4; end
      //      begin if (heapMem[q+4] == source2Value) result = 5; end
      //      begin if (heapMem[q+5] == source2Value) result = 6; end
      //    end
      //  7:
      //    begin
      //      begin if (heapMem[q+0] == source2Value) result = 1; end
      //      begin if (heapMem[q+1] == source2Value) result = 2; end
      //      begin if (heapMem[q+2] == source2Value) result = 3; end
      //      begin if (heapMem[q+3] == source2Value) result = 4; end
      //      begin if (heapMem[q+4] == source2Value) result = 5; end
      //      begin if (heapMem[q+5] == source2Value) result = 6; end
      //      begin if (heapMem[q+6] == source2Value) result = 7; end
      //    end
      //endcase
      //setMemory();
    end
  endtask

  task arrayCountGreater_instruction();
    begin                                                                       // ArrayIndex
      //begin
      //  q = source1Value * NArea;                                               // Array location
      //  p = arraySizes[source1Value];                                           // Length of array
      //  result = 0;
      //  r1 = 0; r2 = 0; r3 = 0; r4 = 0; r5 = 0; r6 = 0; r7 = 0; r8 = 0;
      //end;
      //case(p)                                                                   // Arrays can be dynamic but only up to a fixed size so that we can unroll the loop that finds an element
      //  1:
      //      begin if (heapMem[q+0] > source2Value) r1 = 1; end
      //  2:
      //    begin
      //      begin if (heapMem[q+0] > source2Value) r1 = 1; end
      //      begin if (heapMem[q+1] > source2Value) r2 = 1; end
      //    end
      //  3:
      //    begin
      //      begin if (heapMem[q+0] > source2Value) r1 = 1; end
      //      begin if (heapMem[q+1] > source2Value) r2 = 1; end
      //      begin if (heapMem[q+2] > source2Value) r3 = 1; end
      //    end
      //  4:
      //    begin
      //      begin if (heapMem[q+0] > source2Value) r1 = 1; end
      //      begin if (heapMem[q+1] > source2Value) r2 = 1; end
      //      begin if (heapMem[q+2] > source2Value) r3 = 1; end
      //      begin if (heapMem[q+3] > source2Value) r4 = 1; end
      //    end
      //  5:
      //    begin
      //      begin if (heapMem[q+0] > source2Value) r1 = 1; end
      //      begin if (heapMem[q+1] > source2Value) r2 = 1; end
      //      begin if (heapMem[q+2] > source2Value) r3 = 1; end
      //      begin if (heapMem[q+3] > source2Value) r4 = 1; end
      //      begin if (heapMem[q+4] > source2Value) r5 = 1; end
      //    end
      //  6:
      //    begin
      //      begin if (heapMem[q+0] > source2Value) r1 = 1; end
      //      begin if (heapMem[q+1] > source2Value) r2 = 1; end
      //      begin if (heapMem[q+2] > source2Value) r3 = 1; end
      //      begin if (heapMem[q+3] > source2Value) r4 = 1; end
      //      begin if (heapMem[q+4] > source2Value) r5 = 1; end
      //      begin if (heapMem[q+5] > source2Value) r6 = 1; end
      //    end
      //  7:
      //    begin
      //      begin if (heapMem[q+0] > source2Value) r1 = 1; end
      //      begin if (heapMem[q+1] > source2Value) r2 = 1; end
      //      begin if (heapMem[q+2] > source2Value) r3 = 1; end
      //      begin if (heapMem[q+3] > source2Value) r4 = 1; end
      //      begin if (heapMem[q+4] > source2Value) r5 = 1; end
      //      begin if (heapMem[q+5] > source2Value) r6 = 1; end
      //      begin if (heapMem[q+6] > source2Value) r7 = 1; end
      //    end
      //endcase
      //result = r1 + r2 + r3 + r4 + r5 + r6 + r7 + r8;
      //setMemory();
    end
  endtask

  task arrayCountLess_instruction();
    begin                                                                       // ArrayIndex
      //begin
      //  q = source1Value * NArea;                                               // Array location
      //  p = arraySizes[source1Value];                                           // Length of array
      //  result = 0;
      //  r1 = 0; r2 = 0; r3 = 0; r4 = 0; r5 = 0; r6 = 0; r7 = 0; r8 = 0;
      //end
      //case(p)                                                                   // Arrays can be dynamic but only up to a fixed size so that we can unroll the loop that finds an element
      //  1:
      //      begin if (heapMem[q+0] < source2Value) r1 = 1; end
      //  2:
      //    begin
      //      begin if (heapMem[q+0] < source2Value) r1 = 1; end
      //      begin if (heapMem[q+1] < source2Value) r2 = 1; end
      //    end
      //  3:
      //    begin
      //      begin if (heapMem[q+0] < source2Value) r1 = 1; end
      //      begin if (heapMem[q+1] < source2Value) r2 = 1; end
      //      begin if (heapMem[q+2] < source2Value) r3 = 1; end
      //    end
      //  4:
      //    begin
      //      begin if (heapMem[q+0] < source2Value) r1 = 1; end
      //      begin if (heapMem[q+1] < source2Value) r2 = 1; end
      //      begin if (heapMem[q+2] < source2Value) r3 = 1; end
      //      begin if (heapMem[q+3] < source2Value) r4 = 1; end
      //    end
      //  5:
      //    begin
      //      begin if (heapMem[q+0] < source2Value) r1 = 1; end
      //      begin if (heapMem[q+1] < source2Value) r2 = 1; end
      //      begin if (heapMem[q+2] < source2Value) r3 = 1; end
      //      begin if (heapMem[q+3] < source2Value) r4 = 1; end
      //      begin if (heapMem[q+4] < source2Value) r5 = 1; end
      //    end
      //  6:
      //    begin
      //      begin if (heapMem[q+0] < source2Value) r1 = 1; end
      //      begin if (heapMem[q+1] < source2Value) r2 = 1; end
      //      begin if (heapMem[q+2] < source2Value) r3 = 1; end
      //      begin if (heapMem[q+3] < source2Value) r4 = 1; end
      //      begin if (heapMem[q+4] < source2Value) r5 = 1; end
      //      begin if (heapMem[q+5] < source2Value) r6 = 1; end
      //    end
      //  7:
      //    begin
      //      begin if (heapMem[q+0] < source2Value) r1 = 1; end
      //      begin if (heapMem[q+1] < source2Value) r2 = 1; end
      //      begin if (heapMem[q+2] < source2Value) r3 = 1; end
      //      begin if (heapMem[q+3] < source2Value) r4 = 1; end
      //      begin if (heapMem[q+4] < source2Value) r5 = 1; end
      //      begin if (heapMem[q+5] < source2Value) r6 = 1; end
      //      begin if (heapMem[q+6] < source2Value) r7 = 1; end
      //    end
      //endcase
      //result = r1 + r2 + r3 + r4 + r5 + r6 + r7 + r8;
      //setMemory();
    end
  endtask

  task shiftLeft_instruction();
    begin                                                                       // shiftLeft
      //result = targetValue << source1Value;
      //setMemory();
    end
  endtask

  task shiftRight_instruction();
    begin                                                                       // shiftLeft
      //result = targetValue >> source1Value;
      //setMemory();
    end
  endtask

  task jEq_instruction();
    begin                                                                       // Jeq
      if (source1Value == source2Value) begin
        ip = ip + targetArea - 1;
      end
    end
  endtask

  task jFalse_instruction();
    begin                                                                       // jFalse
      if (source1Value == 0) begin
        ip = ip + targetArea - 1;
      end
    end
  endtask

  task jGe_instruction();
    begin                                                                       // jGe
      if (source1Value >= source2Value) begin
        ip = ip + targetArea - 1;
      end
    end
  endtask

  task jGt_instruction();
    begin                                                                       // jGt
      if (source1Value >  source2Value) begin
        ip = ip + targetArea - 1;
      end
    end
  endtask

  task jLe_instruction();
    begin                                                                       // jLe
      if (source1Value <= source2Value) begin
        ip = ip + targetArea - 1;
      end
    end
  endtask

  task jLt_instruction();
    begin                                                                       // jLt
      if (source1Value <  source2Value) begin
        ip = ip + targetArea - 1;
      end
    end
  endtask

  task jNe_instruction();
    begin                                                                       // jNe
      if (source1Value != source2Value) begin
        ip = ip + targetArea - 1;
      end
    end
  endtask

  task jTrue_instruction();
    begin                                                                       // jTrue
      if (source1Value != 0) begin
        ip = ip + targetArea - 1;
      end
    end
  endtask

  task jmp_instruction();
    begin                                                                       // jmp
      ip = ip + targetArea - 1;
    end
  endtask

  task push_instruction();                                                      // push
    begin
    //  p = arraySizes[targetValue];
    //  if (p + 1 < NArea) begin
    //    heapMem[p] = source1Value;
    //    arraySizes[targetValue] = p + 1;
    //    result = source1Value;
    //  end
    end
  endtask

  task pop_instruction();                                                       // pop
    begin
    //  p = arraySizes[source1Value];
    //  if (p > 0) begin
    //    p = p - 1;
    //    arraySizes[source1Value] = p;
    //    result = heapMem[p];
    //    setMemory();
    //    result = source1Value;
    //  end
    end
  endtask

  task arraySize_instruction();
    begin                                                                       // arraySize
    //  result = arraySizes[source1Value];
    //  setMemory();
    end
  endtask
                                                                                // Shift up an array in parallel by first copying every element in parallel then copying back just the elements we need into their new positions
  task shiftUp_instruction();
    begin
      //if (targetIndex < NArea) begin
      //  p = targetLocationArea * NArea;                                         // Array Start
      //  begin
      //    arraySizes[targetLocationArea] = arraySizes[targetLocationArea] + 1;  // New size of array
      //    if (NArea > 0) arrayShift[0] = heapMem[p + 0];                        // Move data into staging area
      //    if (NArea > 1) arrayShift[1] = heapMem[p + 1];
      //    if (NArea > 2) arrayShift[2] = heapMem[p + 2];
      //    if (NArea > 3) arrayShift[3] = heapMem[p + 3];
      //    if (NArea > 4) arrayShift[4] = heapMem[p + 4];
      //    if (NArea > 5) arrayShift[5] = heapMem[p + 5];
      //    if (NArea > 6) arrayShift[6] = heapMem[p + 6];
      //    if (NArea > 7) arrayShift[7] = heapMem[p + 7];
      //    if (NArea > 8) arrayShift[8] = heapMem[p + 8];
      //    if (NArea > 9) arrayShift[9] = heapMem[p + 9];
      //  end
      //  case(targetIndex)                                                       // Destage data into one position higher
      //    0: begin
      //      if (NArea > 0) heapMem[p + 0] = source1Value;
      //      if (NArea > 1) heapMem[p + 1] = arrayShift[0];
      //      if (NArea > 2) heapMem[p + 2] = arrayShift[1];
      //      if (NArea > 3) heapMem[p + 3] = arrayShift[2];
      //      if (NArea > 4) heapMem[p + 4] = arrayShift[3];
      //      if (NArea > 5) heapMem[p + 5] = arrayShift[4];
      //      if (NArea > 6) heapMem[p + 6] = arrayShift[5];
      //      if (NArea > 7) heapMem[p + 7] = arrayShift[6];
      //      if (NArea > 8) heapMem[p + 8] = arrayShift[7];
      //      if (NArea > 9) heapMem[p + 9] = arrayShift[8];
      //    end
      //    1: begin
      //      if (NArea > 1) heapMem[p + 1] = source1Value;
      //      if (NArea > 2) heapMem[p + 2] = arrayShift[1];
      //      if (NArea > 3) heapMem[p + 3] = arrayShift[2];
      //      if (NArea > 4) heapMem[p + 4] = arrayShift[3];
      //      if (NArea > 5) heapMem[p + 5] = arrayShift[4];
      //      if (NArea > 6) heapMem[p + 6] = arrayShift[5];
      //      if (NArea > 7) heapMem[p + 7] = arrayShift[6];
      //      if (NArea > 8) heapMem[p + 8] = arrayShift[7];
      //      if (NArea > 9) heapMem[p + 9] = arrayShift[8];
      //    end
      //    2: begin
      //      if (NArea > 2) heapMem[p + 2] = source1Value;
      //      if (NArea > 3) heapMem[p + 3] = arrayShift[2];
      //      if (NArea > 4) heapMem[p + 4] = arrayShift[3];
      //      if (NArea > 5) heapMem[p + 5] = arrayShift[4];
      //      if (NArea > 6) heapMem[p + 6] = arrayShift[5];
      //      if (NArea > 7) heapMem[p + 7] = arrayShift[6];
      //      if (NArea > 8) heapMem[p + 8] = arrayShift[7];
      //      if (NArea > 9) heapMem[p + 9] = arrayShift[8];
      //    end
      //    3: begin
      //      if (NArea > 3) heapMem[p + 3] = source1Value;
      //      if (NArea > 4) heapMem[p + 4] = arrayShift[3];
      //      if (NArea > 5) heapMem[p + 5] = arrayShift[4];
      //      if (NArea > 6) heapMem[p + 6] = arrayShift[5];
      //      if (NArea > 7) heapMem[p + 7] = arrayShift[6];
      //      if (NArea > 8) heapMem[p + 8] = arrayShift[7];
      //      if (NArea > 9) heapMem[p + 9] = arrayShift[8];
      //    end
      //    4: begin
      //      if (NArea > 4) heapMem[p + 4] = source1Value;
      //      if (NArea > 5) heapMem[p + 5] = arrayShift[4];
      //      if (NArea > 6) heapMem[p + 6] = arrayShift[5];
      //      if (NArea > 7) heapMem[p + 7] = arrayShift[6];
      //      if (NArea > 8) heapMem[p + 8] = arrayShift[7];
      //      if (NArea > 9) heapMem[p + 9] = arrayShift[8];
      //    end
      //    5: begin
      //      if (NArea > 5) heapMem[p + 5] = source1Value;
      //      if (NArea > 6) heapMem[p + 6] = arrayShift[5];
      //      if (NArea > 7) heapMem[p + 7] = arrayShift[6];
      //      if (NArea > 8) heapMem[p + 8] = arrayShift[7];
      //      if (NArea > 9) heapMem[p + 9] = arrayShift[8];
      //    end
      //    6: begin
      //      if (NArea > 6) heapMem[p + 6] = source1Value;
      //      if (NArea > 7) heapMem[p + 7] = arrayShift[6];
      //      if (NArea > 8) heapMem[p + 8] = arrayShift[7];
      //      if (NArea > 9) heapMem[p + 9] = arrayShift[8];
      //    end
      //    7: begin
      //      if (NArea > 7) heapMem[p + 7] = source1Value;
      //      if (NArea > 8) heapMem[p + 8] = arrayShift[7];
      //      if (NArea > 9) heapMem[p + 9] = arrayShift[8];
      //    end
      //    8: begin
      //      if (NArea > 8) heapMem[p + 8] = source1Value;
      //      if (NArea > 9) heapMem[p + 9] = arrayShift[8];
      //    end
      //    9: begin
      //      if (NArea > 9) heapMem[p + 9] = source1Value;
      //    end
      //  endcase
      //end
    end
  endtask

  integer signed ml_i, ml_l, ml_q, ml_p, ml_n;

  task moveLong_instruction();
    begin                                                                       // moveLong
      //ml_l = source2Value;
      //ml_q = targetLocation;
      //ml_p = sourceLocation;
      //ml_n = targetLocationArea;
      //for(ml_i = 0; ml_i < ml_l; ml_i = ml_i + 1) begin
      //  heapMem[ml_q+ml_i] = heapMem[ml_p+ml_i];
      //  if (targetIndex+ml_i + 1 > arraySizes[ml_n]) begin
      //    arraySizes[ml_n] = targetIndex+ml_i+1;
      //  end
      //end
    end
  endtask

  task in_instruction();
    begin                                                                       // in
     //result = 0;
     //setMemory();
     //inMemPos = inMemPos + 1;
    end
  endtask

  task inSize_instruction();
    begin                                                                       // inSize
     //result = inMemEnd - inMemPos;
     //setMemory();
    end
  endtask
endmodule
