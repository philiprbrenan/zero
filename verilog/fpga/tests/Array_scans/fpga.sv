//-----------------------------------------------------------------------------
// Fpga test
// Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
//------------------------------------------------------------------------------
module fpga                                                                     // Run test programs
 (input  wire run,                                                              // Run - clock at lest once to allow code to be loaded
  output reg  finished,                                                         // Goes high when the program has finished
  output reg  success);                                                         // Goes high on finish if all the tests passed

  parameter integer MemoryElementWidth =  12;                                   // Memory element width

  parameter integer NArea          =    4;                                      // Size of each area on the heap
  parameter integer NArrays        =   20;                                      // Maximum number of arrays
  parameter integer NHeap          =  100;                                      // Amount of heap memory
  parameter integer NLocal         =  100;                                      // Size of local memory
  parameter integer NOut           =  100;                                      // Size of output area
  parameter integer NFreedArrays   =   20;                                      // Size of output area
  parameter integer NIn            =     0;                                     // Size of input area
  reg [MemoryElementWidth-1:0]   arraySizes[NArrays-1      :0];                 // Size of each array
  reg [MemoryElementWidth-1:0]      heapMem[NHeap-1        :0];                 // Heap memory
  reg [MemoryElementWidth-1:0]     localMem[NLocal-1       :0];                 // Local memory
  reg [MemoryElementWidth-1:0]       outMem[NOut-1         :0];                 // Out channel
  reg [MemoryElementWidth-1:0]        inMem[NIn-1          :0];                 // In channel
  reg [MemoryElementWidth-1:0]  freedArrays[NFreedArrays-1 :0];                 // Freed arrays list implemented as a stack
  reg [MemoryElementWidth-1:0]   arrayShift[NArea-1        :0];                 // Array shift area

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
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 0] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 0] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 0]] = 0;
              ip = 1;
      end

          1 :
      begin                                                                     // mov
              heapMem[0 + localMem[0+0]*10 + 0] = 10;
              ip = 2;
      end

          2 :
      begin                                                                     // mov
              heapMem[0 + localMem[0+0]*10 + 1] = 20;
              ip = 3;
      end

          3 :
      begin                                                                     // mov
              heapMem[0 + localMem[0+0]*10 + 2] = 30;
              ip = 4;
      end

          4 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+0] * NArea + i] == 30) localMem[0 + 1] = i + 1;
              end
              ip = 5;
      end

          5 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+1];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 6;
      end

          6 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+0] * NArea + i] == 20) localMem[0 + 2] = i + 1;
              end
              ip = 7;
      end

          7 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+2];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 8;
      end

          8 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+0] * NArea + i] == 10) localMem[0 + 3] = i + 1;
              end
              ip = 9;
      end

          9 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+3];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 10;
      end

         10 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+0] * NArea + i] == 15) localMem[0 + 4] = i + 1;
              end
              ip = 11;
      end

         11 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+4];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 12;
      end

         12 :
      begin                                                                     // arrayCountLess
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+0] * NArea + i] < 35) j = j + 1;
              end
              localMem[0 + 5] = j;
              ip = 13;
      end

         13 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+5];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 14;
      end

         14 :
      begin                                                                     // arrayCountLess
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+0] * NArea + i] < 25) j = j + 1;
              end
              localMem[0 + 6] = j;
              ip = 15;
      end

         15 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+6];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 16;
      end

         16 :
      begin                                                                     // arrayCountLess
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+0] * NArea + i] < 15) j = j + 1;
              end
              localMem[0 + 7] = j;
              ip = 17;
      end

         17 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+7];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 18;
      end

         18 :
      begin                                                                     // arrayCountLess
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+0] * NArea + i] < 5) j = j + 1;
              end
              localMem[0 + 8] = j;
              ip = 19;
      end

         19 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+8];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 20;
      end

         20 :
      begin                                                                     // arrayCountGreater
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+0] * NArea + i] > 35) j = j + 1;
              end
              localMem[0 + 9] = j;
              ip = 21;
      end

         21 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+9];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 22;
      end

         22 :
      begin                                                                     // arrayCountGreater
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+0] * NArea + i] > 25) j = j + 1;
              end
              localMem[0 + 10] = j;
              ip = 23;
      end

         23 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+10];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 24;
      end

         24 :
      begin                                                                     // arrayCountGreater
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+0] * NArea + i] > 15) j = j + 1;
              end
              localMem[0 + 11] = j;
              ip = 25;
      end

         25 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+11];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 26;
      end

         26 :
      begin                                                                     // arrayCountGreater
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+0] * NArea + i] > 5) j = j + 1;
              end
              localMem[0 + 12] = j;
              ip = 27;
      end

         27 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+12];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 28;
      end
      default: begin
        success  = 1;
        success  = success && outMem[0] == 3;
        success  = success && outMem[1] == 2;
        success  = success && outMem[2] == 1;
        success  = success && outMem[3] == 0;
        success  = success && outMem[4] == 3;
        success  = success && outMem[5] == 2;
        success  = success && outMem[6] == 1;
        success  = success && outMem[7] == 0;
        success  = success && outMem[8] == 0;
        success  = success && outMem[9] == 1;
        success  = success && outMem[10] == 2;
        success  = success && outMem[11] == 3;
        finished = 1;
      end
    endcase
    if (steps <=     29) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
  end
endmodule
