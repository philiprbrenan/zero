//-----------------------------------------------------------------------------
// Fpga implementation and testing of NWay Trees
// Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
//------------------------------------------------------------------------------
module fpga;                                                                    // Run test programs
  parameter integer NTestPrograms  =   15;                                      // Number of test programs to run
  parameter integer NTestsExpected =   54;                                      // Number of test passes expected
  parameter integer showInstructionDetails = 0;                                 // Show details of each instruction as it is executed

  parameter integer NSteps         = 200;                                       // Maximum number of instruction executions
  parameter integer NInstructions  = 2000;                                      // Number of instruction slots in code memory
  parameter integer NArea          =   10;                                      // Size of each area on the heap
  parameter integer NArrays        = 1000;                                      // Amount of heap memory
  parameter integer NHeap          = NArea*NArrays;                             // Amount of heap memory
  parameter integer NLocal         = 1000;                                      // Size of local memory
  parameter integer NOut           = 1000;                                      // Size of output area
  parameter integer NFreedArrays   = 1000;                                      // Size of output area

  reg signed [255:0] code[NInstructions];                                       // Code memory
  reg signed [ 32:0] arraySizes[NArrays];                                       // Size of each array
  reg signed [ 32:0] heapMem [NHeap];                                           // Heap memory
  reg signed [ 32:0] localMem[NLocal];                                          // Local memory
  reg signed [ 32:0] outMem[NOut];                                              // Out channel
  reg signed [ 32:0] freedArrays[NFreedArrays];                                 // Freed arrays list implemented as a stack
  reg signed [ 32:0] arrayShift[NArea];                                         // Array shift area

  integer signed nSteps;                                                        // Number of instructions executed
  integer signed NInstructionEnd;                                               // Limit of instructions for the current program
  integer signed outMemPos;                                                     // Position in output channel
  integer signed result;                                                        // Result of an instruction execution
  integer signed allocs;                                                        // Maximum number of array allocations in use at any one time
  integer signed freedArraysTop;                                                // Position in freed arrays stack
  integer signed test;                                                          // Tests passed
  integer signed testsPassed;                                                   // Tests passed
  integer signed testsFailed;                                                   // Tests failed
  integer signed i, j, k, l, m, n, o, p, q;                                     // Useful integers

//Tests
  task ok(integer signed test, string name);                                    // Check a single test result
    begin
      if (test == 1) begin
        testsPassed++;
      end
      else begin
        $display("Assertion %s FAILED", name);
        printMemory();
        testsFailed++;
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
        5: Array_test();
        6: Array_scans();
        7: Free_test();
        8: ShiftLeft_test();
        9: ShiftRight_test();
       10: Jeq_test();
       11: Shift_up_test();
       12: Shift_up_test_2();
       13: Push_test();
       14: Pop_test();
       15: Bubble_sort();
      endcase
    end
  endtask

  task printMemory();                                                           // Print memory so we now what to chec
    begin
      $display("          0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18   19   20   21   22   23   24   25   26   27   28   29   30   31   32");
      $write("Local:");
      for(i = 0; i < 32; ++i) begin
        $write(" %4d", localMem[i]);
      end
      $display("");
      $write("Heap: ");
      for(i = 0; i < 32; ++i) begin
        $write(" %4d", heapMem[i]);
      end
      $display("");
    end
  endtask

  task printOut();                                                              // Print the output channel
    begin
      $display("Out %d", outMemPos);
      $display("    0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18   19   20   21   22   23   24   25   26   27   28   29   30   31   32");
      for(i = 0; i < outMemPos; ++i) begin
        $write(" %4d", outMem[i]);
      end
      $display("");
    end
  endtask

  task checkResults();                                                          // Check results of test
    begin
      case(test)
        1: ok(outMem[0] == 1, "Mov 1");                                         // 1
        2: ok(outMem[0] == 5, "Add 1");                                         // 1
        3: ok(outMem[0] == 2, "Subtract 1");                                    // 1
        4: begin                                                                // 3
          ok(outMem[0] == 3, "Not 1.1");
          ok(outMem[1] == 0, "Not 1.2");
          ok(outMem[2] == 1, "Not 1.3");
        end
        5: begin                                                                // 4 => 10
          ok(localMem[0] ==  0, "Array 1.1");
          ok( heapMem[0] == 11, "Array 1.2");
          ok( heapMem[1] == 22, "Array 1.3");
          ok( arraySizes[0] == 2, "Array 1.4");
        end
        6: begin                                                                // 12 => 22
          ok(outMem[0] == 3, "scan 1.1"); ok(outMem[1] == 2, "scan 1.2"); ok(outMem[ 2] == 1, "scan 1.3"); ok(outMem[ 3] == 0, "scan 1.4");
          ok(outMem[4] == 3, "scan 2.1"); ok(outMem[5] == 2, "scan 2.2"); ok(outMem[ 6] == 1, "scan 2.3"); ok(outMem[ 7] == 0, "scan 2.4");
          ok(outMem[8] == 0, "scan 3.1"); ok(outMem[9] == 1, "scan 3.2"); ok(outMem[10] == 2, "scan 3.3"); ok(outMem[11] == 3, "scan 3.4");
        end
        7: begin                                                                // 3    => 25
          ok(outMem[0] == 0, "Free 1"); ok(outMem[1] == 0, "Free 2"); ok(outMem[2] == 0, "Free 3");
        end
        8: begin
          ok(localMem[0] == 2, "ShiftLeft");                                    // 1
        end
        9: begin
          ok(localMem[0] == 2, "ShiftRight");                                   // 1
        end
       10: begin
          ok(outMem[0] == 111, "Jeq_test 1");                                   // 1
          ok(outMem[1] == 333, "Jeq_test 2");                                   // 1 => 29
        end
       11: begin
          ok(arraySizes[0] ==  4, "ShiftUp 1 length");                          // 5 => 34
          ok(heapMem[0]    == 99, "ShiftUp 1 new");
          ok(heapMem[1]    ==  0, "ShiftUp 1 0");
          ok(heapMem[2]    ==  1, "ShiftUp 1 1");
          ok(heapMem[3]    ==  2, "ShiftUp 1 2");
        end
       12: begin
          ok(arraySizes[0] ==  4, "ShiftUp 2 length");                          // 5 => 39
          ok(heapMem[0]    ==  0, "ShiftUp 2 new");
          ok(heapMem[1]    ==  1, "ShiftUp 2 0");
          ok(heapMem[2]    == 99, "ShiftUp 2 1");
          ok(heapMem[3]    ==  2, "ShiftUp 2 2");
        end
       13: begin
          ok(arraySizes[0] ==  2, "Push 1 length");                             // 3 => 42
          ok(heapMem[0]    ==  1, "Push 1 1");
          ok(heapMem[1]    ==  2, "Push 1 2");
        end
       14: begin
          ok(arraySizes[0] ==  0, "Pop 1 length");                              // 3 => 45
          ok(outMem[0]     ==  2, "Pop 1.1");
          ok(outMem[1]     ==  1, "Pop 1.2");
        end
       15: begin
          ok(arraySizes[0] ==  8, "Bubble Sort length");                        // 9 => 54
          ok(heapMem[0]    ==  11, "Bubble Sort 1");
          ok(heapMem[1]    ==  22, "Bubble Sort 2");
          ok(heapMem[2]    ==  33, "Bubble Sort 3");
          ok(heapMem[3]    ==  44, "Bubble Sort 4");
          ok(heapMem[4]    ==  55, "Bubble Sort 5");
          ok(heapMem[5]    ==  66, "Bubble Sort 6");
          ok(heapMem[6]    ==  77, "Bubble Sort 7");
          ok(heapMem[7]    ==  88, "Bubble Sort 8");
        end
      endcase
    end
  endtask

//Instructions
  integer ip = 0;                                                               // Instruction pointer
  integer r1, r2, r3, r4, r5, r6, r7, r8;                                       // Intermediate array results

  wire signed [255:0] instruction = code[ip];
//wire signed [31:0]  operator    = instruction[255:223];
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

//Execute
  initial begin                                                                 // Load, run confirm
    testsPassed = 0;                                                            // Passed tests
    testsFailed = 0;                                                            // Failed tests
    for(test = 1; test <= NTestPrograms; ++test) begin                          // Run the tests from bewest to oldest
//if (test == 15) begin
      allocs         = 0;                                                       // Largest number of arrays in use at any one time so far
      freedArraysTop = 0;                                                       // Start freed arrays stack
      loadCode();                                                               // Load the program
      $display("Test %d", test);
      outMemPos = 0;                                                            // Output channel position
      nSteps    = 1;                                                            // Number of instructions executed
      for(i = 0; i < NOut;   ++i)   outMem[i] = 'bx;                            // Reset the output channel
      for(i = 0; i < NHeap;  ++i)  heapMem[i] = 'bx;                            // Reset heap memory
      for(i = 0; i < NLocal; ++i) localMem[i] = 'bx;                            // Reset local memory

      for(ip = 0; ip >= 0 && ip < NInstructionEnd; ++ip)                        // Each instruction
      begin
        #1;                                                                     // Let the ip update its assigns
        if (showInstructionDetails) printInstruction();                         // Print Instruction details

        executeInstruction();
        //$display("%5d  %4d  %8s  %4d", nSteps, ip, lastInstruction, result);
        //printMemory();
        if (nSteps++ > NSteps) begin                                            // Count instructions executed
          $display("Out of instructions after %d steps", NSteps);
          printMemory();
          $finish;
        end
      end
      checkResults();                                                           // Check results
//end
    end
    if (testsPassed > 0 && testsFailed > 0) begin
       $display("Passed %1d tests, FAILED %1d tests out of %d tests", testsPassed, testsFailed, NTestsExpected);
    end
    else if (testsFailed > 0) begin
       $display("FAILED %1d tests out of %1d tests", testsFailed, NTestsExpected);
    end
    else if (testsPassed > 0 && testsPassed != NTestsExpected) begin
       $display("Passed %1d tests out of %1d tests with no failures ", testsPassed, NTestsExpected);
    end
    else if (testsPassed == NTestsExpected) begin                               // Testing summary
       $display("All %1d tests passed successfully in %1d programs", NTestsExpected, NTestPrograms);
    end
    else begin
       $display("No tests run passed: %1d, failed: %1d, expected %1d, programs: %1d", testsPassed, testsFailed, NTestsExpected, NTestPrograms);
    end
    $finish;
  end

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

//Programs
  task Mov_test();                                                              // Load program 'Mov_test' into code memory
    begin
      NInstructionEnd = 6;
      code[   0] = 'h0000002200000000000000000000210000000000000120000000000000000000;
      code[   1] = 'h0000002200000000000000000001210000000000000220000000000000000000;
      code[   2] = 'h0000002200000000000000000002210000000000000320000000000000000000;
      code[   3] = 'h0000002600000000000000000000010000000000000021000000000000000000;
      code[   4] = 'h0000002600000000000000000000010000000000000121000000000000000000;
      code[   5] = 'h0000002600000000000000000000010000000000000221000000000000000000;
    end
  endtask

  task Add_test();                                                              // Load program 'Add_test' into code memory    begin
    begin
      NInstructionEnd = 2;
      code[   0] = 'h0000000000000000000000000000210000000000000320000000000000022000;
      code[   1] = 'h0000002600000000000000000000010000000000000021000000000000000000;
    end
  endtask

  task Not_test();                                                              // Load program 'Not_test' into code memory
    begin
      NInstructionEnd = 6;
      code[   0] = 'h0000002200000000000000000000210000000000000320000000000000000000;
      code[   1] = 'h0000002500000000000000000001210000000000000021000000000000000000;
      code[   2] = 'h0000002500000000000000000002210000000000000121000000000000000000;
      code[   3] = 'h0000002600000000000000000000010000000000000021000000000000000000;
      code[   4] = 'h0000002600000000000000000000010000000000000121000000000000000000;
      code[   5] = 'h0000002600000000000000000000010000000000000221000000000000000000;
    end
  endtask

  task Subtract_test();                                                         // Load program 'Subtract_test' into code memory
    begin
      NInstructionEnd = 2;
      code[   0] = 'h0000003800000000000000000000210000000000000420000000000000022000;
      code[   1] = 'h0000002600000000000000000000010000000000000021000000000000000000;
    end
  endtask

  task Array_test();                                                            // Load program 'Array_test' into code memory
    begin
      NInstructionEnd = 3;
      code[   0] = 'h0000000100000000000000000000210000000000000320000000000000000000;
      code[   1] = 'h0000002200000000000000000000150000000000000b20000000000000000000;
      code[   2] = 'h0000002200000000000000000001150000000000001620000000000000000000;
    end
  endtask
                                                                                // Load program 'Array_scans' into code memory
  task Array_scans();
    begin
      NInstructionEnd = 28;
      code[   0] = 'h0000000100000000000000000000210000000000000320000000000000000000;
      code[   1] = 'h0000002200000000000000000000150000000000000a20000000000000000000;
      code[   2] = 'h0000002200000000000000000001150000000000001420000000000000000000;
      code[   3] = 'h0000002200000000000000000002150000000000001e20000000000000000000;
      code[   4] = 'h00000005000000000000000000012100000000000000210000000000001e2000;
      code[   5] = 'h0000002600000000000000000000010000000000000121000000000000000000;
      code[   6] = 'h0000000500000000000000000002210000000000000021000000000000142000;
      code[   7] = 'h0000002600000000000000000000010000000000000221000000000000000000;
      code[   8] = 'h00000005000000000000000000032100000000000000210000000000000a2000;
      code[   9] = 'h0000002600000000000000000000010000000000000321000000000000000000;
      code[  10] = 'h00000005000000000000000000042100000000000000210000000000000f2000;
      code[  11] = 'h0000002600000000000000000000010000000000000421000000000000000000;
      code[  12] = 'h0000000300000000000000000005210000000000000021000000000000232000;
      code[  13] = 'h0000002600000000000000000000010000000000000521000000000000000000;
      code[  14] = 'h0000000300000000000000000006210000000000000021000000000000192000;
      code[  15] = 'h0000002600000000000000000000010000000000000621000000000000000000;
      code[  16] = 'h00000003000000000000000000072100000000000000210000000000000f2000;
      code[  17] = 'h0000002600000000000000000000010000000000000721000000000000000000;
      code[  18] = 'h0000000300000000000000000008210000000000000021000000000000052000;
      code[  19] = 'h0000002600000000000000000000010000000000000821000000000000000000;
      code[  20] = 'h0000000200000000000000000009210000000000000021000000000000232000;
      code[  21] = 'h0000002600000000000000000000010000000000000921000000000000000000;
      code[  22] = 'h000000020000000000000000000a210000000000000021000000000000192000;
      code[  23] = 'h0000002600000000000000000000010000000000000a21000000000000000000;
      code[  24] = 'h000000020000000000000000000b2100000000000000210000000000000f2000;
      code[  25] = 'h0000002600000000000000000000010000000000000b21000000000000000000;
      code[  26] = 'h000000020000000000000000000c210000000000000021000000000000052000;
      code[  27] = 'h0000002600000000000000000000010000000000000c21000000000000000000;
    end
  endtask

  task Free_test();
    begin
      NInstructionEnd = 9;
      code[   0] = 'h0000000100000000000000000000217f000000000003207f000000000000007f;
      code[   1] = 'h0000002600000000000000000000017f000000000000217f000000000000007f;
      code[   2] = 'h0000001300000000000000000000217f000000000003207f000000000000007f;
      code[   3] = 'h0000000100000000000000000001217f000000000004207f000000000000007f;
      code[   4] = 'h0000002600000000000000000000017f000000000001217f000000000000007f;
      code[   5] = 'h0000001300000000000000000001217f000000000004207f000000000000007f;
      code[   6] = 'h0000000100000000000000000002217f000000000005207f000000000000007f;
      code[   7] = 'h0000002600000000000000000000017f000000000002217f000000000000007f;
      code[   8] = 'h0000001300000000000000000002217f000000000005207f000000000000007f;
    end
  endtask
                                                                                // Load program 'ShiftLeft_test' into code memory
  task ShiftLeft_test();
    begin
      NInstructionEnd = 3;
      code[   0] = 'h0000002200000000000000000000210000000000000120000000000000000000;
      code[   1] = 'h0000003500000000000000000000210000000000000021000000000000000000;
      code[   2] = 'h0000002600000000000000000000010000000000000021000000000000000000;
    end
  endtask
                                                                                // Load program 'ShiftRight_test' into code memory
  task ShiftRight_test();
    begin
      NInstructionEnd = 3;
      code[   0] = 'h0000002200000000000000000000210000000000000120000000000000000000;
      code[   1] = 'h0000003500000000000000000000210000000000000021000000000000000000;
      code[   2] = 'h0000002600000000000000000000010000000000000021000000000000000000;
    end
  endtask

  task Jeq_test();
    begin
      NInstructionEnd = 12;
      code[   0] = 'h0000001f00000000000000000000010000000000000120000000000000000000;
      code[   1] = 'h0000002200000000000000000000210000000000000120000000000000000000;
      code[   2] = 'h0000002200000000000000000001210000000000000220000000000000000000;
      code[   3] = 'h0000001600000000000000050002210000000000000021000000000000012100;
      code[   4] = 'h0000002600000000000000000000010000000000006f20000000000000000000;
      code[   5] = 'h0000001600000000000000030002210000000000000021000000000000002100;
      code[   6] = 'h000000260000000000000000000001000000000000de20000000000000000000;
      code[   7] = 'h0000001e00000000000000040004210000000000000000000000000000000000;
      code[   8] = 'h0000001f00000000000000000000010000000000000220000000000000000000;
      code[   9] = 'h0000002600000000000000000000010000000000014d20000000000000000000;
      code[  10] = 'h0000001f00000000000000000000010000000000000320000000000000000000;
      code[  11] = 'h0000001f00000000000000000000010000000000000420000000000000000000;
    end
  endtask
                                                                                // Load program 'Shift_up_test' into code memory
  task Shift_up_test();
    begin
      NInstructionEnd = 5;
      code[   0] = 'h0000000100000000000000000000210000000000000320000000000000000000;
      code[   1] = 'h0000002200000000000000000000150000000000000020000000000000000000;
      code[   2] = 'h0000002200000000000000000001150000000000000120000000000000000000;
      code[   3] = 'h0000002200000000000000000002150000000000000220000000000000000000;
      code[   4] = 'h0000003700000000000000000000150000000000006320000000000000000000;
    end
  endtask
                                                                                // Load program 'Shift_up_test_2' into code memory
  task Shift_up_test_2();
    begin
      NInstructionEnd = 5;
      code[   0] = 'h0000000100000000000000000000210000000000000320000000000000000000;
      code[   1] = 'h0000002200000000000000000000150000000000000020000000000000000000;
      code[   2] = 'h0000002200000000000000000001150000000000000120000000000000000000;
      code[   3] = 'h0000002200000000000000000002150000000000000220000000000000000000;
      code[   4] = 'h0000003700000000000000000002150000000000006320000000000000000000;
    end
  endtask

  task Push_test();
    begin
      NInstructionEnd = 3;
      code[   0] = 'h0000000100000000000000000000210000000000000320000000000000000000;
      code[   1] = 'h0000002d00000000000000000000210000000000000120000000000000032000;
      code[   2] = 'h0000002d00000000000000000000210000000000000220000000000000032000;
    end
  endtask

  task Pop_test();
    begin
      NInstructionEnd = 7;
      code[   0] = 'h0000000100000000000000000000210000000000000320000000000000000000;
      code[   1] = 'h0000002d00000000000000000000210000000000000120000000000000032000;
      code[   2] = 'h0000002d00000000000000000000210000000000000220000000000000032000;
      code[   3] = 'h0000002c00000000000000000001210000000000000021000000000000032000;
      code[   4] = 'h0000002c00000000000000000002210000000000000021000000000000032000;
      code[   5] = 'h0000002600000000000000000000010000000000000121000000000000000000;
      code[   6] = 'h0000002600000000000000000000010000000000000221000000000000000000;
    end
  endtask
                                                                                // Load program 'Bubble_sort' into code memory
  task Bubble_sort();
    begin
      NInstructionEnd = 44;
      code[   0] = 'h0000000100000000000000000000210000000000000320000000000000000000;
      code[   1] = 'h0000002d00000000000000000000210000000000002120000000000000032000;
      code[   2] = 'h0000002d00000000000000000000210000000000000b20000000000000032000;
      code[   3] = 'h0000002d00000000000000000000210000000000001620000000000000032000;
      code[   4] = 'h0000002d00000000000000000000210000000000002c20000000000000032000;
      code[   5] = 'h0000002d00000000000000000000210000000000004d20000000000000032000;
      code[   6] = 'h0000002d00000000000000000000210000000000003720000000000000032000;
      code[   7] = 'h0000002d00000000000000000000210000000000004220000000000000032000;
      code[   8] = 'h0000002d00000000000000000000210000000000005820000000000000032000;
      code[   9] = 'h0000000600000000000000000001210000000000000021000000000000032000;
      code[  10] = 'h0000001f00000000000000000000010000000000000120000000000000000000;
      code[  11] = 'h0000002200000000000000000002210000000000000020000000000000000000;
      code[  12] = 'h0000001f00000000000000000000010000000000000220000000000000000000;
      code[  13] = 'h0000001800000000000000160004210000000000000221000000000000012100;
      code[  14] = 'h0000003800000000000000000003210000000000000121000000000000022100;
      code[  15] = 'h0000002200000000000000000004210000000000000020000000000000000000;
      code[  16] = 'h0000001f00000000000000000000010000000000000520000000000000000000;
      code[  17] = 'h0000002200000000000000000005210000000000000120000000000000000000;
      code[  18] = 'h0000001f00000000000000000000010000000000000620000000000000000000;
      code[  19] = 'h00000018000000000000000b0008210000000000000521000000000000032100;
      code[  20] = 'h0000002200000000000000000006210000000000000516000000000000000000;
      code[  21] = 'h0000002200000000000000000007210000000000000516ff0000000000000000;
      code[  22] = 'h0000001800000000000000040009210000000000000621000000000000072100;
      code[  23] = 'h000000220000000000000000000516ff00000000000621000000000000000000;
      code[  24] = 'h0000002200000000000000000005160000000000000721000000000000000000;
      code[  25] = 'h0000000000000000000000000004210000000000000421000000000000012000;
      code[  26] = 'h0000001f00000000000000000000010000000000000920000000000000000000;
      code[  27] = 'h0000001f00000000000000000000010000000000000720000000000000000000;
      code[  28] = 'h0000000000000000000000000005210000000000000521000000000000012000;
      code[  29] = 'h0000001e00000000fffffff50006210000000000000000000000000000000000;
      code[  30] = 'h0000001f00000000000000000000010000000000000820000000000000000000;
      code[  31] = 'h0000001700000000000000040004210000000000000421000000000000000000;
      code[  32] = 'h0000001f00000000000000000000010000000000000320000000000000000000;
      code[  33] = 'h0000000000000000000000000002210000000000000221000000000000012000;
      code[  34] = 'h0000001e00000000ffffffea0002210000000000000000000000000000000000;
      code[  35] = 'h0000001f00000000000000000000010000000000000420000000000000000000;
      code[  36] = 'h0000002600000000000000000000010000000000000015000000000000000000;
      code[  37] = 'h0000002600000000000000000000010000000000000115000000000000000000;
      code[  38] = 'h0000002600000000000000000000010000000000000215000000000000000000;
      code[  39] = 'h0000002600000000000000000000010000000000000315000000000000000000;
      code[  40] = 'h0000002600000000000000000000010000000000000415000000000000000000;
      code[  41] = 'h0000002600000000000000000000010000000000000515000000000000000000;
      code[  42] = 'h0000002600000000000000000000010000000000000615000000000000000000;
      code[  43] = 'h0000002600000000000000000000010000000000000715000000000000000000;
    end
  endtask

// Instruction memory access functions

  task setMemory();                                                             // Set the target memory location updating the containing array size if necessary
    begin
      case(targetArena)
        1: fork                                                                 // Update array
          heapMem[targetLocation] = result;
          arraySizes[targetLocationArea]  =
          arraySizes[targetLocationArea] >  targetIndex ?
          arraySizes[targetLocationArea]  : targetIndex + 1;
        join
        2: localMem[targetLocation] = result;                                   // Local memory
      endcase
    end
  endtask

// Instruction implementations

  task add_instruction();                                                       // Add
    begin
      result = source1Value + source2Value;
      //$display("%4d = Add %d(%d), %d, %d", result, targetLocation, targetArena, source1Value, source2Value);
      setMemory();
    end
  endtask

  task array_instruction();                                                     // Array
    begin
      if (freedArraysTop > 0) begin                                             // Reuse an array
        result = freedArrays[--freedArraysTop];
        //$display("%4d(%4d) = Array reuse", targetLocation, result);

      end
      else begin
        result = allocs++;                                                      // Array zero means undefined
        //$display("%4d(%4d) = Array new",   targetLocation, result);
      end

      arraySizes[targetLocationArea] = 0;                                       // Zero array length
      setMemory();                                                              // Save address of array
    end
  endtask

  task free_instruction();
    begin                                                                       // Free
      freedArrays[freedArraysTop++] = targetValue;
      arraySizes[targetValue] = 0;                                              // Zero array length
    end
  endtask

  task mov_instruction();                                                       // Mov
    begin
      result = source1Value;
      //$display("%4d = Mov %d(%d), %d", result, targetLocation, targetArena, source1Value);
      setMemory();                                                              // Save result in target
    end
  endtask


  task not_instruction();                                                       // Not
    begin
      result = source1Value ? 0 : 1;
      setMemory();                                                              // Save result in target
    end
  endtask

  task resize_instruction();                                                    // Resize
    begin
      result = source1Value;
      p = localMem[targetLocation];
      fork
        heapMem[p * NArea] = result;
        q = heapMem[p * NArea];
      join
    end
  endtask

  task subtract_instruction();                                                  // Subtract
    begin
      result = source1Value - source2Value;
      setMemory();                                                              // Save result in target
    end
  endtask

  task out_instruction();                                                       // Out
    begin
      outMem[outMemPos++] = source1Value;
    end
  endtask

  task arrayIndex_instruction();
    begin                                                                       // ArrayIndex
      fork
        q = source1Value * NArea;                                               // Array location
        p = arraySizes[source1Value];                                           // Length of array
        result = 0;
      join
      case(p)                                                                   // Arrays can be dynamic but only up to a fixed size so that we can unroll the loop that finds an element
        1:
            begin if (heapMem[q+0] == source2Value) result = 1; end
        2:
          fork
            begin if (heapMem[q+0] == source2Value) result = 1; end
            begin if (heapMem[q+1] == source2Value) result = 2; end
          join
        3:
          fork
            begin if (heapMem[q+0] == source2Value) result = 1; end
            begin if (heapMem[q+1] == source2Value) result = 2; end
            begin if (heapMem[q+2] == source2Value) result = 3; end
          join
        4:
          fork
            begin if (heapMem[q+0] == source2Value) result = 1; end
            begin if (heapMem[q+1] == source2Value) result = 2; end
            begin if (heapMem[q+2] == source2Value) result = 3; end
            begin if (heapMem[q+3] == source2Value) result = 4; end
          join
        5:
          fork
            begin if (heapMem[q+0] == source2Value) result = 1; end
            begin if (heapMem[q+1] == source2Value) result = 2; end
            begin if (heapMem[q+2] == source2Value) result = 3; end
            begin if (heapMem[q+3] == source2Value) result = 4; end
            begin if (heapMem[q+4] == source2Value) result = 5; end
          join
        6:
          fork
            begin if (heapMem[q+0] == source2Value) result = 1; end
            begin if (heapMem[q+1] == source2Value) result = 2; end
            begin if (heapMem[q+2] == source2Value) result = 3; end
            begin if (heapMem[q+3] == source2Value) result = 4; end
            begin if (heapMem[q+4] == source2Value) result = 5; end
            begin if (heapMem[q+5] == source2Value) result = 6; end
          join
        7:
          fork
            begin if (heapMem[q+0] == source2Value) result = 1; end
            begin if (heapMem[q+1] == source2Value) result = 2; end
            begin if (heapMem[q+2] == source2Value) result = 3; end
            begin if (heapMem[q+3] == source2Value) result = 4; end
            begin if (heapMem[q+4] == source2Value) result = 5; end
            begin if (heapMem[q+5] == source2Value) result = 6; end
            begin if (heapMem[q+6] == source2Value) result = 7; end
          join
      endcase
      setMemory();
    end
  endtask

  task arrayCountGreater_instruction();
    begin                                                                       // ArrayIndex
      //$display("arrayIndex");
      //printMemory();
      //printInstruction();
      fork
        q = source1Value * NArea;                                               // Array location
        p = arraySizes[source1Value];                                           // Length of array
        result = 0;
        r1 = 0; r2 = 0; r3 = 0; r4 = 0; r5 = 0; r6 = 0; r7 = 0; r8 = 0;
      join;
      case(p)                                                                   // Arrays can be dynamic but only up to a fixed size so that we can unroll the loop that finds an element
        1:
            begin if (heapMem[q+0] > source2Value) r1 = 1; end
        2:
          fork
            begin if (heapMem[q+0] > source2Value) r1 = 1; end
            begin if (heapMem[q+1] > source2Value) r2 = 1; end
          join
        3:
          fork
            begin if (heapMem[q+0] > source2Value) r1 = 1; end
            begin if (heapMem[q+1] > source2Value) r2 = 1; end
            begin if (heapMem[q+2] > source2Value) r3 = 1; end
          join
        4:
          fork
            begin if (heapMem[q+0] > source2Value) r1 = 1; end
            begin if (heapMem[q+1] > source2Value) r2 = 1; end
            begin if (heapMem[q+2] > source2Value) r3 = 1; end
            begin if (heapMem[q+3] > source2Value) r4 = 1; end
          join
        5:
          fork
            begin if (heapMem[q+0] > source2Value) r1 = 1; end
            begin if (heapMem[q+1] > source2Value) r2 = 1; end
            begin if (heapMem[q+2] > source2Value) r3 = 1; end
            begin if (heapMem[q+3] > source2Value) r4 = 1; end
            begin if (heapMem[q+4] > source2Value) r5 = 1; end
          join
        6:
          fork
            begin if (heapMem[q+0] > source2Value) r1 = 1; end
            begin if (heapMem[q+1] > source2Value) r2 = 1; end
            begin if (heapMem[q+2] > source2Value) r3 = 1; end
            begin if (heapMem[q+3] > source2Value) r4 = 1; end
            begin if (heapMem[q+4] > source2Value) r5 = 1; end
            begin if (heapMem[q+5] > source2Value) r6 = 1; end
          join
        7:
          fork
            begin if (heapMem[q+0] > source2Value) r1 = 1; end
            begin if (heapMem[q+1] > source2Value) r2 = 1; end
            begin if (heapMem[q+2] > source2Value) r3 = 1; end
            begin if (heapMem[q+3] > source2Value) r4 = 1; end
            begin if (heapMem[q+4] > source2Value) r5 = 1; end
            begin if (heapMem[q+5] > source2Value) r6 = 1; end
            begin if (heapMem[q+6] > source2Value) r7 = 1; end
          join
      endcase
      result = r1 + r2 + r3 + r4 + r5 + r6 + r7 + r8;
      setMemory();
    end
  endtask

  task arrayCountLess_instruction();
    begin                                                                       // ArrayIndex
      fork
        q = source1Value * NArea;                                               // Array location
        p = arraySizes[source1Value];                                           // Length of array
        result = 0;
        r1 = 0; r2 = 0; r3 = 0; r4 = 0; r5 = 0; r6 = 0; r7 = 0; r8 = 0;
      join
      case(p)                                                                   // Arrays can be dynamic but only up to a fixed size so that we can unroll the loop that finds an element
        1:
            begin if (heapMem[q+0] < source2Value) r1 = 1; end
        2:
          fork
            begin if (heapMem[q+0] < source2Value) r1 = 1; end
            begin if (heapMem[q+1] < source2Value) r2 = 1; end
          join
        3:
          fork
            begin if (heapMem[q+0] < source2Value) r1 = 1; end
            begin if (heapMem[q+1] < source2Value) r2 = 1; end
            begin if (heapMem[q+2] < source2Value) r3 = 1; end
          join
        4:
          fork
            begin if (heapMem[q+0] < source2Value) r1 = 1; end
            begin if (heapMem[q+1] < source2Value) r2 = 1; end
            begin if (heapMem[q+2] < source2Value) r3 = 1; end
            begin if (heapMem[q+3] < source2Value) r4 = 1; end
          join
        5:
          fork
            begin if (heapMem[q+0] < source2Value) r1 = 1; end
            begin if (heapMem[q+1] < source2Value) r2 = 1; end
            begin if (heapMem[q+2] < source2Value) r3 = 1; end
            begin if (heapMem[q+3] < source2Value) r4 = 1; end
            begin if (heapMem[q+4] < source2Value) r5 = 1; end
          join
        6:
          fork
            begin if (heapMem[q+0] < source2Value) r1 = 1; end
            begin if (heapMem[q+1] < source2Value) r2 = 1; end
            begin if (heapMem[q+2] < source2Value) r3 = 1; end
            begin if (heapMem[q+3] < source2Value) r4 = 1; end
            begin if (heapMem[q+4] < source2Value) r5 = 1; end
            begin if (heapMem[q+5] < source2Value) r6 = 1; end
          join
        7:
          fork
            begin if (heapMem[q+0] < source2Value) r1 = 1; end
            begin if (heapMem[q+1] < source2Value) r2 = 1; end
            begin if (heapMem[q+2] < source2Value) r3 = 1; end
            begin if (heapMem[q+3] < source2Value) r4 = 1; end
            begin if (heapMem[q+4] < source2Value) r5 = 1; end
            begin if (heapMem[q+5] < source2Value) r6 = 1; end
            begin if (heapMem[q+6] < source2Value) r7 = 1; end
          join
      endcase
      result = r1 + r2 + r3 + r4 + r5 + r6 + r7 + r8;
      setMemory();
    end
  endtask

  task shiftLeft_instruction();
    begin                                                                       // shiftLeft
      result = targetValue << source1Value;
      setMemory();
    end
  endtask

  task shiftRight_instruction();
    begin                                                                       // shiftLeft
      result = targetValue >> source1Value;
      setMemory();
    end
  endtask

  task jEq_instruction();
    begin                                                                       // Jeq
      if (source1Value == source2Value) begin
        ip += targetArea;
      end
    end
  endtask

  task jFalse_instruction();
    begin                                                                       // jFalse
      if (source1Value == 0) begin
        ip += targetArea;
      end
    end
  endtask

  task jGe_instruction();
    begin                                                                       // jGe
      if (source1Value >= source2Value) begin
        ip += targetArea ;
      end
    end
  endtask

  task jGt_instruction();
    begin                                                                       // jGt
      if (source1Value >  source2Value) begin
        ip += targetArea;
      end
    end
  endtask

  task jLe_instruction();
    begin                                                                       // jLe
      if (source1Value <= source2Value) begin
        ip += targetArea;
      end
    end
  endtask

  task jLt_instruction();
    begin                                                                       // jLt
      if (source1Value <  source2Value) begin
        ip += targetArea;
      end
    end
  endtask

  task jNe_instruction();
    begin                                                                       // jNe
      if (source1Value != source2Value) begin
        ip += targetArea;
      end
    end
  endtask

  task jTrue_instruction();
    begin                                                                       // jTrue
      if (source1Value != 0) begin
        ip += targetArea;
      end
    end
  endtask

  task jmp_instruction();
    begin                                                                       // jmp
      ip += targetArea;
    end
  endtask

  task push_instruction();                                                      // push
    begin
      p = arraySizes[targetValue];
      if (p + 1 < NArea) begin
        heapMem[p] = source1Value;
        arraySizes[targetValue] = p + 1;
        result = source1Value;
      end
    end
  endtask

  task pop_instruction();                                                       // pop
    begin
      p = arraySizes[source1Value];
      if (p > 0) begin
        p--;
        arraySizes[source1Value] = p;
        result = heapMem[p];
        setMemory();
        result = source1Value;
      end
    end
  endtask

  task arraySize_instruction();
    begin                                                                       // arraySize
      result = arraySizes[source1Value];
      setMemory();
    end
  endtask
                                                                                // Shift up an array inporallel by forst copyign evbery element in parallel then copying back just the elements we need into their new positions
  task shiftUp_instruction();
    begin
      if (targetIndex < NArea) begin
        p = targetLocationArea * NArea;                                         // Array Start
        case(NArea)                                                             // shiftUp
          10: begin
            fork
              arraySizes[targetLocationArea] = arraySizes[targetLocationArea] + 1;// New size of array
              arrayShift[0] = heapMem[p + 0];                                   // Move data into staging area
              arrayShift[1] = heapMem[p + 1];
              arrayShift[2] = heapMem[p + 2];
              arrayShift[3] = heapMem[p + 3];
              arrayShift[4] = heapMem[p + 4];
              arrayShift[5] = heapMem[p + 5];
              arrayShift[6] = heapMem[p + 6];
              arrayShift[7] = heapMem[p + 7];
              arrayShift[8] = heapMem[p + 8];
              arrayShift[9] = heapMem[p + 9];
            join
            case(targetIndex)                                                   // Destage data into one position higher
              0: fork
                heapMem[p + 0] = source1Value;
                heapMem[p + 1] = arrayShift[0];
                heapMem[p + 2] = arrayShift[1];
                heapMem[p + 3] = arrayShift[2];
                heapMem[p + 4] = arrayShift[3];
                heapMem[p + 5] = arrayShift[4];
                heapMem[p + 6] = arrayShift[5];
                heapMem[p + 7] = arrayShift[6];
                heapMem[p + 8] = arrayShift[7];
                heapMem[p + 9] = arrayShift[8];
              join
              1: fork
                heapMem[p + 1] = source1Value;
                heapMem[p + 2] = arrayShift[1];
                heapMem[p + 3] = arrayShift[2];
                heapMem[p + 4] = arrayShift[3];
                heapMem[p + 5] = arrayShift[4];
                heapMem[p + 6] = arrayShift[5];
                heapMem[p + 7] = arrayShift[6];
                heapMem[p + 8] = arrayShift[7];
                heapMem[p + 9] = arrayShift[8];
              join
              2: fork
                heapMem[p + 2] = source1Value;
                heapMem[p + 3] = arrayShift[2];
                heapMem[p + 4] = arrayShift[3];
                heapMem[p + 5] = arrayShift[4];
                heapMem[p + 6] = arrayShift[5];
                heapMem[p + 7] = arrayShift[6];
                heapMem[p + 8] = arrayShift[7];
                heapMem[p + 9] = arrayShift[8];
              join
              3: fork
                heapMem[p + 3] = source1Value;
                heapMem[p + 4] = arrayShift[3];
                heapMem[p + 5] = arrayShift[4];
                heapMem[p + 6] = arrayShift[5];
                heapMem[p + 7] = arrayShift[6];
                heapMem[p + 8] = arrayShift[7];
                heapMem[p + 9] = arrayShift[8];
              join
              4: fork
                heapMem[p + 4] = source1Value;
                heapMem[p + 5] = arrayShift[4];
                heapMem[p + 6] = arrayShift[5];
                heapMem[p + 7] = arrayShift[6];
                heapMem[p + 8] = arrayShift[7];
                heapMem[p + 9] = arrayShift[8];
              join
              5: fork
                heapMem[p + 5] = source1Value;
                heapMem[p + 6] = arrayShift[5];
                heapMem[p + 7] = arrayShift[6];
                heapMem[p + 8] = arrayShift[7];
                heapMem[p + 9] = arrayShift[8];
              join
              6: fork
                heapMem[p + 6] = source1Value;
                heapMem[p + 7] = arrayShift[6];
                heapMem[p + 8] = arrayShift[7];
                heapMem[p + 9] = arrayShift[8];
              join
              7: fork
                heapMem[p + 7] = source1Value;
                heapMem[p + 8] = arrayShift[7];
                heapMem[p + 9] = arrayShift[8];
              join
              8: fork
                heapMem[p + 8] = source1Value;
                heapMem[p + 9] = arrayShift[8];
              join
              9: fork
                heapMem[p + 9] = source1Value;
              join
            endcase
          end
        endcase
      end
    end
  endtask

endmodule
