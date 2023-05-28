//-----------------------------------------------------------------------------
// Fpga implementation and testing of NWay Trees
// Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
//------------------------------------------------------------------------------
module fpga_tb;                                                                 // The cpu executes one step in the computation per input clock. We can also put values into memory and get values out again to test each program.
  fpga a();                                                                     // Instantiate
endmodule

module fpga;                                                                    // The cpu executes one step in the computation per input clock. We can also put values into memory and get values out again to test each program.
  parameter integer NInstructions = 2000;                                       // Number of instruction slots in code memory
  parameter integer NHeap  = 1000;                                              // Amount of heap memory
  parameter integer NArea  =   10;                                              // Size of each area on the heap
  parameter integer NLocal = 1000;                                              // Size of local memory
  parameter integer NOut   = 1000;                                              // Size of output area
  parameter integer NTests =    4;                                              // Number of test programs to run
  parameter integer NTestE =    6;                                              // Number of tests expected

  reg[255:0] code[NInstructions];                                               // Code memory
  reg[ 32:0] heapMem [NHeap];                                                   // Heap memory
  reg[255:0] localMem[NLocal];                                                  // Local memory
  reg[ 32:0] outMem[NOut];                                                      // Out channel

  integer NInstructionEnd;                                                      // Limit of instructions for the current program
  integer outMemPos;                                                            // Position in output channel
  integer test;                                                                 // Tests passed
  integer testsPassed;                                                          // Tests passed
  integer testsFailed;                                                          // Tests failed

  task ok(integer test, string name);                                           // Check a single test result
    begin
      if (test == 0 || test == 1'bx || test == 1'bz) begin
        $display("Assertion %s FAILED", name);
        testsFailed++;
      end
      else begin
        testsPassed++;
      end
    end
  endtask

  task loadCode();                                                              // Load code to be tested for test
    begin
      case(test)
        1: Mov_test();
        2: Add_test();
        3: Subtract_test();
        4: Not_test();
      endcase
    end
  endtask

  task checkResults();                                                          // Check results of test
    begin
      case(test)
        1: ok(outMem[0] == 1, "Mov 1");
        2: ok(outMem[0] == 5, "Add 1");
        3: ok(outMem[0] == 2, "Subtract 1");
        4: begin
          ok(outMem[0] == 3, "Not 1");
          ok(outMem[1] == 0, "Not 2");
          ok(outMem[2] == 1, "Not 3");
        end
      endcase
    end
  endtask

  wire clock;                                                                   // Clock
  integer ip = 0;                                                               // Instruction pointer
  integer i, j, p, q;
  wire [255:0] instruction = code[ip];
//wire [31:0]  operator    = instruction[255:223];
  wire [31:0]  operator    = instruction[255:224];
  wire [63:0]  source2     = instruction[ 63:  0];
  wire [63:0]  source      = instruction[127: 64];
  wire [63:0]  target      = instruction[191:128];

  wire [31: 0] source2Area     = source2[63:32];                                // Source2
  wire [15: 0] source2Address  = source2[31:16];
  wire [ 2: 0] source2Arena    = source2[13:12];
  wire [ 2: 0] source2DArea    = source2[11:10];
  wire [ 2: 0] source2DAddress = source2[ 9: 8];
  wire [ 7: 0] source2Delta    = source2[ 7: 0] - 127;
  wire [31: 0] source2Value    =
    source2Arena      == 0 ? 0 :
    source2Arena      == 1 ?
     (source2DAddress == 0 ?  source2Address :
      source2DArea    == 0 && source2DAddress == 1 ? source2Delta + heapMem [source2Area*NArea           + source2Address]           :
      source2DArea    == 0 && source2DAddress == 2 ? source2Delta + heapMem [source2Area*NArea           + localMem[source2Address]] :
      source2DArea    == 1 && source2DAddress == 1 ? source2Delta + heapMem [localMem[source2Area]*NArea + source2Address]           :
      source2DArea    == 1 && source2DAddress == 2 ? source2Delta + heapMem [localMem[source2Area]*NArea + localMem[source2Address]] : 0) :
    source2Arena      == 2 ?                         source2Delta +
     (source2DAddress == 0 ?  source2Address :       source2Delta +
      source2DArea    == 0 && source2DAddress == 1 ? source2Delta + localMem[source2Area*NArea           + source2Address]           :
      source2DArea    == 0 && source2DAddress == 2 ? source2Delta + localMem[source2Area*NArea           + localMem[source2Address]] :
      source2DArea    == 1 && source2DAddress == 1 ? source2Delta + localMem[localMem[source2Area]*NArea + source2Address]           :
      source2DArea    == 1 && source2DAddress == 2 ? source2Delta + localMem[localMem[source2Area]*NArea + localMem[source2Address]] : 0) : 0;

  wire [31: 0] source1Area     = source[63:32];                                 // Source
  wire [15: 0] source1Address  = source[31:16];
  wire [ 2: 0] source1Arena    = source[13:12];
  wire [ 2: 0] source1DArea    = source[11:10];
  wire [ 2: 0] source1DAddress = source[ 9: 8];
  wire [ 7: 0] source1Delta    = source[ 7: 0] - 127;
  wire [31: 0] source1Value    =
    source1Arena      == 0 ? 0 :
    source1Arena      == 1 ?
     (source1DAddress == 0 ?  source1Address :
      source1DArea    == 0 && source1DAddress == 1 ? source1Delta + heapMem [source1Area*NArea           + source1Address]           :
      source1DArea    == 0 && source1DAddress == 2 ? source1Delta + heapMem [source1Area*NArea           + localMem[source1Address]] :
      source1DArea    == 1 && source1DAddress == 1 ? source1Delta + heapMem [localMem[source1Area]*NArea + source1Address]           :
      source1DArea    == 1 && source1DAddress == 2 ? source1Delta + heapMem [localMem[source1Area]*NArea + localMem[source1Address]] : 0) :
    source1Arena      == 2 ?
     (source1DAddress == 0 ?  source1Address :
      source1DArea    == 0 && source1DAddress == 1 ? source1Delta + localMem[source1Area*NArea           + source1Address]           :
      source1DArea    == 0 && source1DAddress == 2 ? source1Delta + localMem[source1Area*NArea           + localMem[source1Address]] :
      source1DArea    == 1 && source1DAddress == 1 ? source1Delta + localMem[localMem[source1Area]*NArea + source1Address]           :
      source1DArea    == 1 && source1DAddress == 2 ? source1Delta + localMem[localMem[source1Area]*NArea + localMem[source1Address]] : 0) : 0;

  wire [31: 0] targetArea      = target[63:32];                                 // Target
  wire [15: 0] targetAddress   = target[31:16];
  wire [ 2: 0] targetArena     = target[13:12];
  wire [ 2: 0] targetDArea     = target[11:10];
  wire [ 2: 0] targetDAddress  = target[ 9: 8];
  wire [ 7: 0] targetDelta     = target[ 7: 0] - 127;
  wire [31: 0] targetLocation  =
    targetArena      == 0 ? 0 :
    targetArena      == 1 ?
     (targetDAddress == 0 ?  targetAddress :
      targetDArea    == 0 && targetDAddress == 1 ? targetDelta + targetArea*NArea           + targetAddress           :
      targetDArea    == 0 && targetDAddress == 2 ? targetDelta + targetArea*NArea           + localMem[targetAddress] :
      targetDArea    == 1 && targetDAddress == 1 ? targetDelta + localMem[targetArea]*NArea + targetAddress           :
      targetDArea    == 1 && targetDAddress == 2 ? targetDelta + localMem[targetArea]*NArea + localMem[targetAddress] : 0) :
    targetArena      == 2 ?
     (targetDAddress == 0 ?  targetAddress :
      targetDArea    == 0 && targetDAddress == 1 ? targetDelta + targetArea*NArea           + targetAddress           :
      targetDArea    == 0 && targetDAddress == 2 ? targetDelta + targetArea*NArea           + localMem[targetAddress] :
      targetDArea    == 1 && targetDAddress == 1 ? targetDelta + localMem[targetArea]*NArea + targetAddress           :
      targetDArea    == 1 && targetDAddress == 2 ? targetDelta + localMem[targetArea]*NArea + localMem[targetAddress] : 0) : 0;

  initial begin                                                                 // Load, run confirm
    testsPassed = 0;                                                            // Start passed tests count
    for(test = 1; test <= NTests; ++test) begin                                 // Each test

      loadCode(test);                                                           // Load the program
      $display("Test %d", test);
      outMemPos = 0; for(i = 0; i < NOut; ++i) outMem[i] = 0;                   // Empty the output channel

      for(ip = 0; ip >= 0 && ip < NInstructionEnd; ++ip)                        // Each instruction
      begin
        #1                                                                      // Let the ip update its assigns
        $display("targetAddress =%4x Area=%4x DAddress=%4x DArea=%4x Arena=%4x Delta=%4x Location=%4x",
          targetAddress, targetArea, targetDAddress, targetDArea, targetArena, targetDelta, targetLocation);

        $display("source1Address=%4x Area=%4x DAddress=%4x DArea=%4x Arena=%4x Delta=%4x Value   =%4x",
          source1Address, source1Area, source1DAddress, source1DArea, source1Arena, source1Delta, source1Value);

        $display("source2Address=%4x Area=%4x DAddress=%4x DArea=%4x Arena=%4x Delta=%4x Value   =%4x",
          source2Address, source2Area, source2DAddress, source2DArea, source2Arena, source2Delta, source2Value);

        executeInstruction();
      end
      checkResults(test);                                                       // Check results
    end
    if (testsPassed == NTestE) begin                                             // Testing summary
       $display("All %1d tests passed successfully", NTestE);
    end
    else if (testsPassed > 0) begin
       $display("Passed %1d tests out of %d tests with no failures ", testsPassed, NTestE);
    end
    else if (testsPassed > 0 && testsFailed > 0) begin
       $display("Passed %1d tests, FAILED %1d tests out of %d tests", testsPassed, testsFailed, NTestE);
    end
    else if (testsFailed > 0) begin
       $display("FAILED %1d tests out of %d tests", testsFailed, NTestE);
    end
    else begin
       $display("No tests run");
    end
    $finish;
  end

// Instruction implementations

  task print_instruction();                                                     // Print the details of an instruction
    begin
      $display("target=%x  source=%x source2=%x", target, source, source2);
      $display("%d(%d) = %d + %d", targetLocation, targetArena, source1Value, source2Value);
    end
  endtask

  task add_instruction();                                                       // Add
    begin
      print_instruction();
      case(targetArena)
        1: heapMem [targetLocation] = source1Value + source2Value;
        2: localMem[targetLocation] = source1Value + source2Value;
      endcase
    end
  endtask

  task mov_instruction();                                                       // Mov
    begin
      print_instruction();
      case(targetArena)
        1: heapMem [targetLocation] = source1Value;
        2: localMem[targetLocation] = source1Value;
      endcase
    end
  endtask


  task not_instruction();                                                       // Not
    begin
      print_instruction();
      case(targetArena)
        1: heapMem [targetLocation] = source1Value ? 0 : 1;
        2: localMem[targetLocation] = source1Value ? 0 : 1;
      endcase
    end
  endtask

  task subtract_instruction();                                                  // Subtract
    begin
      print_instruction();
      case(targetArena)
        1: heapMem [targetLocation] = source1Value - source2Value;
        2: localMem[targetLocation] = source1Value - source2Value;
      endcase
    end
  endtask

  task out_instruction();                                                       // Out
    begin
      $display("source=%x", source1Value);
      $display("value: %d", source1Value);
      outMem[outMemPos++] = source1Value;
      $display("res: %d", outMem[0]);
    end
  endtask

  task executeInstruction();                                                    // Execute an instruction
    begin
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
  task array_instruction();
    begin                                                                       // array
     $display("array");
    end
  endtask
  task arrayCountGreater_instruction();
    begin                                                                       // arrayCountGreater
     $display("arrayCountGreater");
    end
  endtask
  task arrayCountLess_instruction();
    begin                                                                       // arrayCountLess
     $display("arrayCountLess");
    end
  endtask
  task arrayDump_instruction();
    begin                                                                       // arrayDump
     $display("arrayDump");
    end
  endtask
  task arrayIndex_instruction();
    begin                                                                       // arrayIndex
     $display("arrayIndex");
    end
  endtask
  task arraySize_instruction();
    begin                                                                       // arraySize
     $display("arraySize");
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
     $display("assertNe");
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
  task free_instruction();
    begin                                                                       // free
     $display("free");
    end
  endtask
  task in_instruction();
    begin                                                                       // in
     $display("in");
    end
  endtask
  task inSize_instruction();
    begin                                                                       // inSize
     $display("inSize");
    end
  endtask
  task jEq_instruction();
    begin                                                                       // jEq
     $display("jEq");
    end
  endtask
  task jFalse_instruction();
    begin                                                                       // jFalse
     $display("jFalse");
    end
  endtask
  task jGe_instruction();
    begin                                                                       // jGe
     $display("jGe");
    end
  endtask
  task jGt_instruction();
    begin                                                                       // jGt
     $display("jGt");
    end
  endtask
  task jLe_instruction();
    begin                                                                       // jLe
     $display("jLe");
    end
  endtask
  task jLt_instruction();
    begin                                                                       // jLt
     $display("jLt");
    end
  endtask
  task jNe_instruction();
    begin                                                                       // jNe
     $display("jNe");
    end
  endtask
  task jTrue_instruction();
    begin                                                                       // jTrue
     $display("jTrue");
    end
  endtask
  task jmp_instruction();
    begin                                                                       // jmp
     $display("jmp");
    end
  endtask
  task label_instruction();
    begin                                                                       // label
     $display("label");
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
  task moveLong_instruction();
    begin                                                                       // moveLong
     $display("moveLong");
    end
  endtask
  task nop_instruction();
    begin                                                                       // nop
     $display("nop");
    end
  endtask
  task parallelContinue_instruction();
    begin                                                                       // parallelContinue
     $display("parallelContinue");
    end
  endtask
  task parallelStart_instruction();
    begin                                                                       // parallelStart
     $display("parallelStart");
    end
  endtask
  task parallelStop_instruction();
    begin                                                                       // parallelStop
     $display("parallelStop");
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
  task pop_instruction();
    begin                                                                       // pop
     $display("pop");
    end
  endtask
  task push_instruction();
    begin                                                                       // push
     $display("push");
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
  task resize_instruction();
    begin                                                                       // resize
     $display("resize");
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
  task shiftLeft_instruction();
    begin                                                                       // shiftLeft
     $display("shiftLeft");
    end
  endtask
  task shiftRight_instruction();
    begin                                                                       // shiftRight
     $display("shiftRight");
    end
  endtask
  task shiftUp_instruction();
    begin                                                                       // shiftUp
     $display("shiftUp");
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

// Tests
  task Mov_test();                                                              // Load program 'Mov_test' into code memory
    begin
      NInstructionEnd = 2;
      code[   0] = 'h0000002200000000000000000000217f000000000001207f000000000000007f;
      code[   1] = 'h0000002600000000000000000000017f000000000000217f000000000000007f;
    end
  endtask

  task Add_test();                                                              // Load program 'Add_test' into code memory    begin
    begin
      NInstructionEnd = 2;
      code[   0] = 'h0000000000000000000000000000217f000000000003207f000000000002207f;
      code[   1] = 'h0000002600000000000000000000017f000000000000217f000000000000007f;
    end
  endtask

  task Not_test();                                                              // Load program 'Not_test' into code memory
    begin
      NInstructionEnd = 6;
      code[   0] = 'h0000002200000000000000000000217f000000000003207f000000000000007f;
      code[   1] = 'h0000002500000000000000000001217f000000000000217f000000000000007f;
      code[   2] = 'h0000002500000000000000000002217f000000000001217f000000000000007f;
      code[   3] = 'h0000002600000000000000000000017f000000000000217f000000000000007f;
      code[   4] = 'h0000002600000000000000000000017f000000000001217f000000000000007f;
      code[   5] = 'h0000002600000000000000000000017f000000000002217f000000000000007f;
    end
  endtask

  task Subtract_test();                                                         // Load program 'Subtract_test' into code memory
    begin
      NInstructionEnd = 2;
      code[   0] = 'h0000003800000000000000000000217f000000000004207f000000000002207f;
      code[   1] = 'h0000002600000000000000000000017f000000000000217f000000000000007f;
    end
  endtask
endmodule
