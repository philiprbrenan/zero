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
              heapMem[localMem[0+0]*10 + 2] = 7;
              ip = 2;
      end

          2 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 3] = 0;
              ip = 3;
      end

          3 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 0] = 0;
              ip = 4;
      end

          4 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 1] = 0;
              ip = 5;
      end

          5 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1]] = 0;
              ip = 6;
      end

          6 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 0] = 0;
              ip = 7;
      end

          7 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 2] = 0;
              ip = 8;
      end

          8 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 2] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 2] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 2]] = 0;
              ip = 9;
      end

          9 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 4] = localMem[0+2];
              ip = 10;
      end

         10 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 3] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 3] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 3]] = 0;
              ip = 11;
      end

         11 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 5] = localMem[0+3];
              ip = 12;
      end

         12 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 6] = 0;
              ip = 13;
      end

         13 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 3] = localMem[0+0];
              ip = 14;
      end

         14 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 1] = heapMem[localMem[0+0]*10 + 1] + 1;
              ip = 15;
      end

         15 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 1] = heapMem[localMem[0+0]*10 + 1];
              ip = 16;
      end

         16 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 4] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 4] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 4]] = 0;
              ip = 17;
      end

         17 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 6] = localMem[0+4];
              ip = 18;
      end

         18 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 0] = 7;
              ip = 19;
      end

         19 :
      begin                                                                     // mov
              localMem[0 + 5] = heapMem[localMem[0+1]*10 + 4];
              ip = 20;
      end

         20 :
      begin                                                                     // mov
              heapMem[localMem[0+5]*10 + 0] = 10;
              ip = 21;
      end

         21 :
      begin                                                                     // mov
              localMem[0 + 6] = heapMem[localMem[0+1]*10 + 5];
              ip = 22;
      end

         22 :
      begin                                                                     // mov
              heapMem[localMem[0+6]*10 + 0] = 10;
              ip = 23;
      end

         23 :
      begin                                                                     // mov
              localMem[0 + 7] = heapMem[localMem[0+1]*10 + 6];
              ip = 24;
      end

         24 :
      begin                                                                     // mov
              heapMem[localMem[0+7]*10 + 0] = 5;
              ip = 25;
      end

         25 :
      begin                                                                     // mov
              localMem[0 + 8] = heapMem[localMem[0+1]*10 + 4];
              ip = 26;
      end

         26 :
      begin                                                                     // mov
              heapMem[localMem[0+8]*10 + 1] = 20;
              ip = 27;
      end

         27 :
      begin                                                                     // mov
              localMem[0 + 9] = heapMem[localMem[0+1]*10 + 5];
              ip = 28;
      end

         28 :
      begin                                                                     // mov
              heapMem[localMem[0+9]*10 + 1] = 20;
              ip = 29;
      end

         29 :
      begin                                                                     // mov
              localMem[0 + 10] = heapMem[localMem[0+1]*10 + 6];
              ip = 30;
      end

         30 :
      begin                                                                     // mov
              heapMem[localMem[0+10]*10 + 1] = 15;
              ip = 31;
      end

         31 :
      begin                                                                     // mov
              localMem[0 + 11] = heapMem[localMem[0+1]*10 + 4];
              ip = 32;
      end

         32 :
      begin                                                                     // mov
              heapMem[localMem[0+11]*10 + 2] = 30;
              ip = 33;
      end

         33 :
      begin                                                                     // mov
              localMem[0 + 12] = heapMem[localMem[0+1]*10 + 5];
              ip = 34;
      end

         34 :
      begin                                                                     // mov
              heapMem[localMem[0+12]*10 + 2] = 30;
              ip = 35;
      end

         35 :
      begin                                                                     // mov
              localMem[0 + 13] = heapMem[localMem[0+1]*10 + 6];
              ip = 36;
      end

         36 :
      begin                                                                     // mov
              heapMem[localMem[0+13]*10 + 2] = 25;
              ip = 37;
      end

         37 :
      begin                                                                     // mov
              localMem[0 + 14] = heapMem[localMem[0+1]*10 + 4];
              ip = 38;
      end

         38 :
      begin                                                                     // mov
              heapMem[localMem[0+14]*10 + 3] = 40;
              ip = 39;
      end

         39 :
      begin                                                                     // mov
              localMem[0 + 15] = heapMem[localMem[0+1]*10 + 5];
              ip = 40;
      end

         40 :
      begin                                                                     // mov
              heapMem[localMem[0+15]*10 + 3] = 40;
              ip = 41;
      end

         41 :
      begin                                                                     // mov
              localMem[0 + 16] = heapMem[localMem[0+1]*10 + 6];
              ip = 42;
      end

         42 :
      begin                                                                     // mov
              heapMem[localMem[0+16]*10 + 3] = 35;
              ip = 43;
      end

         43 :
      begin                                                                     // mov
              localMem[0 + 17] = heapMem[localMem[0+1]*10 + 4];
              ip = 44;
      end

         44 :
      begin                                                                     // mov
              heapMem[localMem[0+17]*10 + 4] = 50;
              ip = 45;
      end

         45 :
      begin                                                                     // mov
              localMem[0 + 18] = heapMem[localMem[0+1]*10 + 5];
              ip = 46;
      end

         46 :
      begin                                                                     // mov
              heapMem[localMem[0+18]*10 + 4] = 50;
              ip = 47;
      end

         47 :
      begin                                                                     // mov
              localMem[0 + 19] = heapMem[localMem[0+1]*10 + 6];
              ip = 48;
      end

         48 :
      begin                                                                     // mov
              heapMem[localMem[0+19]*10 + 4] = 45;
              ip = 49;
      end

         49 :
      begin                                                                     // mov
              localMem[0 + 20] = heapMem[localMem[0+1]*10 + 4];
              ip = 50;
      end

         50 :
      begin                                                                     // mov
              heapMem[localMem[0+20]*10 + 5] = 60;
              ip = 51;
      end

         51 :
      begin                                                                     // mov
              localMem[0 + 21] = heapMem[localMem[0+1]*10 + 5];
              ip = 52;
      end

         52 :
      begin                                                                     // mov
              heapMem[localMem[0+21]*10 + 5] = 60;
              ip = 53;
      end

         53 :
      begin                                                                     // mov
              localMem[0 + 22] = heapMem[localMem[0+1]*10 + 6];
              ip = 54;
      end

         54 :
      begin                                                                     // mov
              heapMem[localMem[0+22]*10 + 5] = 55;
              ip = 55;
      end

         55 :
      begin                                                                     // mov
              localMem[0 + 23] = heapMem[localMem[0+1]*10 + 4];
              ip = 56;
      end

         56 :
      begin                                                                     // mov
              heapMem[localMem[0+23]*10 + 6] = 70;
              ip = 57;
      end

         57 :
      begin                                                                     // mov
              localMem[0 + 24] = heapMem[localMem[0+1]*10 + 5];
              ip = 58;
      end

         58 :
      begin                                                                     // mov
              heapMem[localMem[0+24]*10 + 6] = 70;
              ip = 59;
      end

         59 :
      begin                                                                     // mov
              localMem[0 + 25] = heapMem[localMem[0+1]*10 + 6];
              ip = 60;
      end

         60 :
      begin                                                                     // mov
              heapMem[localMem[0+25]*10 + 6] = 65;
              ip = 61;
      end

         61 :
      begin                                                                     // mov
              localMem[0 + 26] = heapMem[localMem[0+1]*10 + 6];
              ip = 62;
      end

         62 :
      begin                                                                     // mov
              heapMem[localMem[0+26]*10 + 7] = 75;
              ip = 63;
      end

         63 :
      begin                                                                     // mov
              localMem[0 + 27] = heapMem[localMem[0+1]*10 + 4];
              ip = 64;
      end

         64 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+27] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > 2) begin
                  heapMem[NArea * localMem[0+27] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+27] + 2] = 26;                                    // Insert new value
              arraySizes[localMem[0+27]] = arraySizes[localMem[0+27]] + 1;                              // Increase array size
              ip = 65;
      end

         65 :
      begin                                                                     // mov
              localMem[0 + 28] = heapMem[localMem[0+1]*10 + 5];
              ip = 66;
      end

         66 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+28] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > 2) begin
                  heapMem[NArea * localMem[0+28] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+28] + 2] = 26;                                    // Insert new value
              arraySizes[localMem[0+28]] = arraySizes[localMem[0+28]] + 1;                              // Increase array size
              ip = 67;
      end

         67 :
      begin                                                                     // mov
              localMem[0 + 29] = heapMem[localMem[0+1]*10 + 6];
              ip = 68;
      end

         68 :
      begin                                                                     // add
              localMem[0 + 30] = 2 + 1;
              ip = 69;
      end

         69 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+29] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[30]) begin
                  heapMem[NArea * localMem[0+29] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+29] + localMem[30]] = 26;                                    // Insert new value
              arraySizes[localMem[0+29]] = arraySizes[localMem[0+29]] + 1;                              // Increase array size
              ip = 70;
      end

         70 :
      begin                                                                     // add
              heapMem[localMem[0+1]*10 + 0] = heapMem[localMem[0+1]*10 + 0] + 1;
              ip = 71;
      end
      default: begin
        success  = 1;
        finished = 1;
      end
    endcase
    if (steps <=     72) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
  end
endmodule
