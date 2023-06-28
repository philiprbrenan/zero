//-----------------------------------------------------------------------------
// Fpga test
// Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
//------------------------------------------------------------------------------
module fpga                                                                     // Run test programs
 (input  wire run,                                                              // Run - clock at lest once to allow code to be loaded
  output reg  finished,                                                         // Goes high when the program has finished
  output reg  success);                                                         // Goes high on finish if all the tests passed

  parameter integer MemoryElementWidth =  12;                                   // Memory element width

  parameter integer NArea          = 10;                                    // Size of each area on the heap
  parameter integer NArrays        =  200;                                      // Maximum number of arrays
  parameter integer NHeap          = 1000;                                      // Amount of heap memory
  parameter integer NLocal         = 1000;                                      // Size of local memory
  parameter integer NOut           =  200;                                      // Size of output area
  parameter integer NIn            =     0;                                     // Size of input area
  reg [MemoryElementWidth-1:0]   arraySizes[NArrays-1:0];                       // Size of each array
  reg [MemoryElementWidth-1:0]      heapMem[NHeap-1  :0];                       // Heap memory
  reg [MemoryElementWidth-1:0]     localMem[NLocal-1 :0];                       // Local memory
  reg [MemoryElementWidth-1:0]       outMem[NOut-1   :0];                       // Out channel
  reg [MemoryElementWidth-1:0]        inMem[NIn-1    :0];                       // In channel
  reg [MemoryElementWidth-1:0]  freedArrays[NArrays-1:0];                       // Freed arrays list implemented as a stack
  reg [MemoryElementWidth-1:0]   arrayShift[NArea-1  :0];                       // Array shift area

  integer inMemPos;                                                             // Current position in input channel
  integer outMemPos;                                                            // Position in output channel
  integer allocs;                                                               // Maximum number of array allocations in use at any one time
  integer freedArraysTop;                                                       // Position in freed arrays stack

  integer ip;                                                                   // Instruction pointer
  reg     clock;                                                                // Clock - has to be one bit wide for yosys
  integer steps;                                                                // Number of steps executed so far
  integer i, j;                                                                 // A useful counter

  always @(posedge run) begin                                                   // Initialize
    ip             = 0;
    clock          = 0;
    steps          = 0;
    finished       = 0;
    success        = 0;
    inMemPos       = 0;
    outMemPos      = 0;
    allocs         = 0;
    freedArraysTop = 0;
  end

  always @(clock) begin                                                         // Each instruction
    steps = steps + 1;
    case(ip)

          0 :
      begin                                                                     // label
              ip = 1;
      end

          1 :
      begin                                                                     // mov
              localMem[0 + 0] = 0;
              ip = 2;
      end

          2 :
      begin                                                                     // label
              ip = 3;
      end

          3 :
      begin                                                                     // jGe
              ip = localMem[0+0] >= 5 ? 67 : 4;
      end

          4 :
      begin                                                                     // label
              ip = 5;
      end

          5 :
      begin                                                                     // jTrue
              ip = localMem[0+0] != 0 ? 9 : 6;
      end

          6 :
      begin                                                                     // out
              outMem[outMemPos] = 1;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 7;
      end

          7 :
      begin                                                                     // label
              ip = 8;
      end

          8 :
      begin                                                                     // label
              ip = 9;
      end

          9 :
      begin                                                                     // label
              ip = 10;
      end

         10 :
      begin                                                                     // label
              ip = 11;
      end

         11 :
      begin                                                                     // jFalse
              ip = localMem[0+0] == 0 ? 15 : 12;
      end

         12 :
      begin                                                                     // out
              outMem[outMemPos] = 2;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 13;
      end

         13 :
      begin                                                                     // label
              ip = 14;
      end

         14 :
      begin                                                                     // label
              ip = 15;
      end

         15 :
      begin                                                                     // label
              ip = 16;
      end

         16 :
      begin                                                                     // label
              ip = 17;
      end

         17 :
      begin                                                                     // jTrue
              ip = localMem[0+0] != 0 ? 21 : 18;
      end

         18 :
      begin                                                                     // out
              outMem[outMemPos] = 3;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 19;
      end

         19 :
      begin                                                                     // label
              ip = 20;
      end

         20 :
      begin                                                                     // label
              ip = 21;
      end

         21 :
      begin                                                                     // label
              ip = 22;
      end

         22 :
      begin                                                                     // label
              ip = 23;
      end

         23 :
      begin                                                                     // jFalse
              ip = localMem[0+0] == 0 ? 27 : 24;
      end

         24 :
      begin                                                                     // out
              outMem[outMemPos] = 4;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 25;
      end

         25 :
      begin                                                                     // label
              ip = 26;
      end

         26 :
      begin                                                                     // label
              ip = 27;
      end

         27 :
      begin                                                                     // label
              ip = 28;
      end

         28 :
      begin                                                                     // label
              ip = 29;
      end

         29 :
      begin                                                                     // jEq
              ip = localMem[0+0] == 3 ? 33 : 30;
      end

         30 :
      begin                                                                     // out
              outMem[outMemPos] = 5;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 31;
      end

         31 :
      begin                                                                     // label
              ip = 32;
      end

         32 :
      begin                                                                     // label
              ip = 33;
      end

         33 :
      begin                                                                     // label
              ip = 34;
      end

         34 :
      begin                                                                     // label
              ip = 35;
      end

         35 :
      begin                                                                     // jNe
              ip = localMem[0+0] != 3 ? 39 : 36;
      end

         36 :
      begin                                                                     // out
              outMem[outMemPos] = 6;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 37;
      end

         37 :
      begin                                                                     // label
              ip = 38;
      end

         38 :
      begin                                                                     // label
              ip = 39;
      end

         39 :
      begin                                                                     // label
              ip = 40;
      end

         40 :
      begin                                                                     // label
              ip = 41;
      end

         41 :
      begin                                                                     // jLe
              ip = localMem[0+0] <= 3 ? 45 : 42;
      end

         42 :
      begin                                                                     // out
              outMem[outMemPos] = 7;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 43;
      end

         43 :
      begin                                                                     // label
              ip = 44;
      end

         44 :
      begin                                                                     // label
              ip = 45;
      end

         45 :
      begin                                                                     // label
              ip = 46;
      end

         46 :
      begin                                                                     // label
              ip = 47;
      end

         47 :
      begin                                                                     // jLt
              ip = localMem[0+0] <  3 ? 51 : 48;
      end

         48 :
      begin                                                                     // out
              outMem[outMemPos] = 8;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 49;
      end

         49 :
      begin                                                                     // label
              ip = 50;
      end

         50 :
      begin                                                                     // label
              ip = 51;
      end

         51 :
      begin                                                                     // label
              ip = 52;
      end

         52 :
      begin                                                                     // label
              ip = 53;
      end

         53 :
      begin                                                                     // jGe
              ip = localMem[0+0] >= 3 ? 57 : 54;
      end

         54 :
      begin                                                                     // out
              outMem[outMemPos] = 9;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 55;
      end

         55 :
      begin                                                                     // label
              ip = 56;
      end

         56 :
      begin                                                                     // label
              ip = 57;
      end

         57 :
      begin                                                                     // label
              ip = 58;
      end

         58 :
      begin                                                                     // label
              ip = 59;
      end

         59 :
      begin                                                                     // jGt
              ip = localMem[0+0] >  3 ? 63 : 60;
      end

         60 :
      begin                                                                     // out
              outMem[outMemPos] = 10;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 61;
      end

         61 :
      begin                                                                     // label
              ip = 62;
      end

         62 :
      begin                                                                     // label
              ip = 63;
      end

         63 :
      begin                                                                     // label
              ip = 64;
      end

         64 :
      begin                                                                     // label
              ip = 65;
      end

         65 :
      begin                                                                     // add
              localMem[0 + 0] = localMem[0+0] + 1;
              ip = 66;
      end

         66 :
      begin                                                                     // jmp
              ip = 2;
      end

         67 :
      begin                                                                     // label
              ip = 68;
      end
      default: begin
        success  = 1;
        success  = success && outMem[0] == 1;
        success  = success && outMem[1] == 3;
        success  = success && outMem[2] == 5;
        success  = success && outMem[3] == 9;
        success  = success && outMem[4] == 10;
        success  = success && outMem[5] == 2;
        success  = success && outMem[6] == 4;
        success  = success && outMem[7] == 5;
        success  = success && outMem[8] == 9;
        success  = success && outMem[9] == 10;
        success  = success && outMem[10] == 2;
        success  = success && outMem[11] == 4;
        success  = success && outMem[12] == 5;
        success  = success && outMem[13] == 9;
        success  = success && outMem[14] == 10;
        success  = success && outMem[15] == 2;
        success  = success && outMem[16] == 4;
        success  = success && outMem[17] == 6;
        success  = success && outMem[18] == 8;
        success  = success && outMem[19] == 10;
        success  = success && outMem[20] == 2;
        success  = success && outMem[21] == 4;
        success  = success && outMem[22] == 5;
        success  = success && outMem[23] == 7;
        success  = success && outMem[24] == 8;
        finished = 1;
      end
    endcase
    if (steps <=    256) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
  end
endmodule
