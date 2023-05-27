//-----------------------------------------------------------------------------
// Fpga test bed
//------------------------------------------------------------------------------
module fpga_tb;                                                                 // The cpu executes one step in the computation per input clock. We can also put values into memory and get values out again to test each program.
  fpga a();                                                                     // Instantiate
endmodule

module fpga;                                                                    // The cpu executes one step in the computation per input clock. We can also put values into memory and get values out again to test each program.
  parameter integer NInstructions = 2;                                          // Number of instrcutions in code
  parameter integer NHeap  = 1000;                                              // Amount of heap memory
  parameter integer NArea  =   10;                                              // Size of each area on the heap
  parameter integer NLocal = 1000;                                              // Size of local memory
  parameter integer NOut   = 1000;                                              // Size of output area
  reg[255:0] code[NInstructions];                                               // Code memory
  reg[ 32:0] heapMem [NHeap];                                                   // Heap memory
  reg[255:0] localMem[NLocal];                                                  // Local memory
  reg[ 32:0] outMem[NOut];                                                      // Out channel
  integer outMemPos;                                                            // Position in output channel

  task ok(integer test, string name);
    begin
      if (test == 0 || test == 1'bx || test == 1'bz) begin
        $display("Assertion %s FAILED", name);
        $stop;
      end
    end
  endtask

  task loadCode(); Mov1(); endtask
  task checkResults();
    begin
      ok(outMem[0] == 1, "Mov 1");
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

  wire [31: 0] source2Address  = source2[63:32];                                // Source2
  wire [15: 0] source2Area     = source2[31:16];
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

  wire [31: 0] source1Address  = source[63:32];                                 // Source
  wire [15: 0] source1Area     = source[31:16];
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

  wire [31: 0] targetAddress   = target[63:32];                                 // Target
  wire [15: 0] targetArea      = target[31:16];
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

  initial begin                                                                 // Limit run
    loadCode();                                                                 // Load the program
    $display("aaa");
    outMemPos = 0;
    for(ip = 0; ip >= 0 && ip < NInstructions; ++ip)                            // Each instruction
    begin
      //instruction = code[ip];
      #1;

      $display("targetAddress =%4x Area=%4x DAddress=%4x DArea=%4x Arena=%4x Delta=%4x Location=%4x",
        targetAddress, targetArea, targetDAddress, targetDArea, targetArena, targetDelta, targetLocation);

      $display("source1Address=%4x Area=%4x DAddress=%4x DArea=%4x Arena=%4x Delta=%4x Value   =%4x",
        source1Address, source1Area, source1DAddress, source1DArea, source1Arena, source1Delta, source1Value);

      $display("source2Address=%4x Area=%4x DAddress=%4x DArea=%4x Arena=%4x Delta=%4x Value   =%4x",
        source2Address, source2Area, source2DAddress, source2DArea, source2Arena, source2Delta, source2Value);

      executeInstruction();
      #100;
    end
    checkResults();                                                             // Check results
    $finish;
  end

  task Mov1();
    begin
//                   operator        target          source1         source2
//                   xxxxxxxx        Address AreaD D Address AreaD D Address AreaD D
//                   0         1         2         3         4         5         6
//                   0123456789012345678901234567890123456789012345678901234567890123
      code[   0] = 'h0000002200000000000000000000217f000000010000207f000000000000007f;  // my $a = Mov 1;
      code[   1] = 'h0000002600000000000000000000017f000000000000217f000000000000007f;  // Out $a;
    end
  endtask

  task mov();                                                                   // Mov
    begin
      $display("target=%x  source=%x", target, source);
      $display("%d(%d) = %d", targetLocation, targetArena, source1Value);
      case(targetArena)
        1: heapMem [targetLocation] = source1Value;
        2: localMem[targetLocation] = source1Value;
      endcase
    end
  endtask

  task out();                                                                   // Out
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
         0: begin;  $display("add");                                        end // add
         1: begin;  $display("array");                                      end // array
         2: begin;  $display("arrayCountGreater");                          end // arrayCountGreater
         3: begin;  $display("arrayCountLess");                             end // arrayCountLess
         4: begin;  $display("arrayDump");                                  end // arrayDump
         5: begin;  $display("arrayIndex");                                 end // arrayIndex
         6: begin;  $display("arraySize");                                  end // arraySize
         7: begin;  $display("assert");                                     end // assert
         8: begin;  $display("assertEq");                                   end // assertEq
         9: begin;  $display("assertFalse");                                end // assertFalse
        10: begin;  $display("assertGe");                                   end // assertGe
        11: begin;  $display("assertGt");                                   end // assertGt
        12: begin;  $display("assertLe");                                   end // assertLe
        13: begin;  $display("assertLt");                                   end // assertLt
        14: begin;  $display("assertNe");                                   end // assertNe
        15: begin;  $display("assertTrue");                                 end // assertTrue
        16: begin;  $display("call");                                       end // call
        17: begin;  $display("confess");                                    end // confess
        18: begin;  $display("dump");                                       end // dump
        19: begin;  $display("free");                                       end // free
        20: begin;  $display("in");                                         end // in
        21: begin;  $display("inSize");                                     end // inSize
        22: begin;  $display("jEq");                                        end // jEq
        23: begin;  $display("jFalse");                                     end // jFalse
        24: begin;  $display("jGe");                                        end // jGe
        25: begin;  $display("jGt");                                        end // jGt
        26: begin;  $display("jLe");                                        end // jLe
        27: begin;  $display("jLt");                                        end // jLt
        28: begin;  $display("jNe");                                        end // jNe
        29: begin;  $display("jTrue");                                      end // jTrue
        30: begin;  $display("jmp");                                        end // jmp
        31: begin;  $display("label");                                      end // label
        32: begin;  $display("loadAddress");                                end // loadAddress
        33: begin;  $display("loadArea");                                   end // loadArea
        34: begin;  $display("mov");  mov();                                end // mov
        35: begin;  $display("moveLong");                                   end // moveLong
        36: begin;  $display("nop");                                        end // nop
        37: begin;  $display("not");                                        end // not
        38: begin;  $display("out");  out();                                 end // out
        39: begin;  $display("parallelContinue");                           end // parallelContinue
        40: begin;  $display("parallelStart");                              end // parallelStart
        41: begin;  $display("parallelStop");                               end // parallelStop
        42: begin;  $display("paramsGet");                                  end // paramsGet
        43: begin;  $display("paramsPut");                                  end // paramsPut
        44: begin;  $display("pop");                                        end // pop
        45: begin;  $display("push");                                       end // push
        46: begin;  $display("random");                                     end // random
        47: begin;  $display("randomSeed");                                 end // randomSeed
        48: begin;  $display("resize");                                     end // resize
        49: begin;  $display("return");                                     end // return
        50: begin;  $display("returnGet");                                  end // returnGet
        51: begin;  $display("returnPut");                                  end // returnPut
        52: begin;  $display("shiftDown");                                  end // shiftDown
        53: begin;  $display("shiftLeft");                                  end // shiftLeft
        54: begin;  $display("shiftRight");                                 end // shiftRight
        55: begin;  $display("shiftUp");                                    end // shiftUp
        56: begin;  $display("subtract");                                   end // subtract
        57: begin;  $display("tally");                                      end // tally
        58: begin;  $display("trace");                                      end // trace
        59: begin;  $display("traceLabels");                                end // traceLabels
        60: begin;  $display("watch");                                      end // watch
      endcase
    end
  endtask

endmodule
