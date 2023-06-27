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
  parameter integer NArrays        =   20;                                      // Maximum number of arrays
  parameter integer NHeap          =  100;                                      // Amount of heap memory
  parameter integer NLocal         =  600;                                      // Size of local memory
  parameter integer NOut           =  100;                                      // Size of output area
  parameter integer NFreedArrays   =   20;                                      // Freed arrays
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
              heapMem[localMem[0+0]*10 + 2] = 3;
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
      begin                                                                     // label
              ip = 6;
      end

          6 :
      begin                                                                     // subtract
              localMem[0 + 1] = 6 - 1;
              ip = 7;
      end

          7 :
      begin                                                                     // subtract
              localMem[0 + 2] = localMem[0+1] - 6;
              ip = 8;
      end

          8 :
      begin                                                                     // label
              ip = 9;
      end

          9 :
      begin                                                                     // jLt
              ip = localMem[0+1] <  0 ? 1062 : 10;
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
      begin                                                                     // label
              ip = 12;
      end

         12 :
      begin                                                                     // mov
              localMem[0 + 4] = heapMem[localMem[0+0]*10 + 3];
              ip = 13;
      end

         13 :
      begin                                                                     // jNe
              ip = localMem[0+4] != 0 ? 32 : 14;
      end

         14 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 5] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 5] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 5]] = 0;
              ip = 15;
      end

         15 :
      begin                                                                     // mov
              heapMem[localMem[0+5]*10 + 0] = 1;
              ip = 16;
      end

         16 :
      begin                                                                     // mov
              heapMem[localMem[0+5]*10 + 2] = 0;
              ip = 17;
      end

         17 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 6] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 6] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 6]] = 0;
              ip = 18;
      end

         18 :
      begin                                                                     // mov
              heapMem[localMem[0+5]*10 + 4] = localMem[0+6];
              ip = 19;
      end

         19 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 7] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 7] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 7]] = 0;
              ip = 20;
      end

         20 :
      begin                                                                     // mov
              heapMem[localMem[0+5]*10 + 5] = localMem[0+7];
              ip = 21;
      end

         21 :
      begin                                                                     // mov
              heapMem[localMem[0+5]*10 + 6] = 0;
              ip = 22;
      end

         22 :
      begin                                                                     // mov
              heapMem[localMem[0+5]*10 + 3] = localMem[0+0];
              ip = 23;
      end

         23 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 1] = heapMem[localMem[0+0]*10 + 1] + 1;
              ip = 24;
      end

         24 :
      begin                                                                     // mov
              heapMem[localMem[0+5]*10 + 1] = heapMem[localMem[0+0]*10 + 1];
              ip = 25;
      end

         25 :
      begin                                                                     // mov
              localMem[0 + 8] = heapMem[localMem[0+5]*10 + 4];
              ip = 26;
      end

         26 :
      begin                                                                     // mov
              heapMem[localMem[0+8]*10 + 0] = localMem[0+1];
              ip = 27;
      end

         27 :
      begin                                                                     // mov
              localMem[0 + 9] = heapMem[localMem[0+5]*10 + 5];
              ip = 28;
      end

         28 :
      begin                                                                     // mov
              heapMem[localMem[0+9]*10 + 0] = localMem[0+1];
              ip = 29;
      end

         29 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 30;
      end

         30 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 3] = localMem[0+5];
              ip = 31;
      end

         31 :
      begin                                                                     // jmp
              ip = 1057;
      end

         32 :
      begin                                                                     // label
              ip = 33;
      end

         33 :
      begin                                                                     // mov
              localMem[0 + 10] = heapMem[localMem[0+4]*10 + 0];
              ip = 34;
      end

         34 :
      begin                                                                     // mov
              localMem[0 + 11] = heapMem[localMem[0+0]*10 + 2];
              ip = 35;
      end

         35 :
      begin                                                                     // jGe
              ip = localMem[0+10] >= localMem[0+11] ? 68 : 36;
      end

         36 :
      begin                                                                     // mov
              localMem[0 + 12] = heapMem[localMem[0+4]*10 + 2];
              ip = 37;
      end

         37 :
      begin                                                                     // jNe
              ip = localMem[0+12] != 0 ? 67 : 38;
      end

         38 :
      begin                                                                     // not
              localMem[0 + 13] = !heapMem[localMem[0+4]*10 + 6];
              ip = 39;
      end

         39 :
      begin                                                                     // jEq
              ip = localMem[0+13] == 0 ? 66 : 40;
      end

         40 :
      begin                                                                     // mov
              localMem[0 + 14] = heapMem[localMem[0+4]*10 + 4];
              ip = 41;
      end

         41 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+14] * NArea + i] == localMem[0+1]) localMem[0 + 15] = i + 1;
              end
              ip = 42;
      end

         42 :
      begin                                                                     // jEq
              ip = localMem[0+15] == 0 ? 47 : 43;
      end

         43 :
      begin                                                                     // subtract
              localMem[0 + 15] = localMem[0+15] - 1;
              ip = 44;
      end

         44 :
      begin                                                                     // mov
              localMem[0 + 16] = heapMem[localMem[0+4]*10 + 5];
              ip = 45;
      end

         45 :
      begin                                                                     // mov
              heapMem[localMem[0+16]*10 + localMem[0+15]] = localMem[0+1];
              ip = 46;
      end

         46 :
      begin                                                                     // jmp
              ip = 1057;
      end

         47 :
      begin                                                                     // label
              ip = 48;
      end

         48 :
      begin                                                                     // arrayCountGreater
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+14] * NArea + i] > localMem[0+1]) j = j + 1;
              end
              localMem[0 + 17] = j;
              ip = 49;
      end

         49 :
      begin                                                                     // jNe
              ip = localMem[0+17] != 0 ? 57 : 50;
      end

         50 :
      begin                                                                     // mov
              localMem[0 + 18] = heapMem[localMem[0+4]*10 + 4];
              ip = 51;
      end

         51 :
      begin                                                                     // mov
              heapMem[localMem[0+18]*10 + localMem[0+10]] = localMem[0+1];
              ip = 52;
      end

         52 :
      begin                                                                     // mov
              localMem[0 + 19] = heapMem[localMem[0+4]*10 + 5];
              ip = 53;
      end

         53 :
      begin                                                                     // mov
              heapMem[localMem[0+19]*10 + localMem[0+10]] = localMem[0+1];
              ip = 54;
      end

         54 :
      begin                                                                     // add
              heapMem[localMem[0+4]*10 + 0] = localMem[0+10] + 1;
              ip = 55;
      end

         55 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 56;
      end

         56 :
      begin                                                                     // jmp
              ip = 1057;
      end

         57 :
      begin                                                                     // label
              ip = 58;
      end

         58 :
      begin                                                                     // arrayCountLess
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+14] * NArea + i] < localMem[0+1]) j = j + 1;
              end
              localMem[0 + 20] = j;
              ip = 59;
      end

         59 :
      begin                                                                     // mov
              localMem[0 + 21] = heapMem[localMem[0+4]*10 + 4];
              ip = 60;
      end

         60 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+21] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[20]) begin
                  heapMem[NArea * localMem[0+21] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+21] + localMem[20]] = localMem[0+1];                                    // Insert new value
              arraySizes[localMem[0+21]] = arraySizes[localMem[0+21]] + 1;                              // Increase array size
              ip = 61;
      end

         61 :
      begin                                                                     // mov
              localMem[0 + 22] = heapMem[localMem[0+4]*10 + 5];
              ip = 62;
      end

         62 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+22] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[20]) begin
                  heapMem[NArea * localMem[0+22] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+22] + localMem[20]] = localMem[0+1];                                    // Insert new value
              arraySizes[localMem[0+22]] = arraySizes[localMem[0+22]] + 1;                              // Increase array size
              ip = 63;
      end

         63 :
      begin                                                                     // add
              heapMem[localMem[0+4]*10 + 0] = heapMem[localMem[0+4]*10 + 0] + 1;
              ip = 64;
      end

         64 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 65;
      end

         65 :
      begin                                                                     // jmp
              ip = 1057;
      end

         66 :
      begin                                                                     // label
              ip = 67;
      end

         67 :
      begin                                                                     // label
              ip = 68;
      end

         68 :
      begin                                                                     // label
              ip = 69;
      end

         69 :
      begin                                                                     // mov
              localMem[0 + 23] = heapMem[localMem[0+0]*10 + 3];
              ip = 70;
      end

         70 :
      begin                                                                     // label
              ip = 71;
      end

         71 :
      begin                                                                     // mov
              localMem[0 + 25] = heapMem[localMem[0+23]*10 + 0];
              ip = 72;
      end

         72 :
      begin                                                                     // mov
              localMem[0 + 26] = heapMem[localMem[0+23]*10 + 3];
              ip = 73;
      end

         73 :
      begin                                                                     // mov
              localMem[0 + 27] = heapMem[localMem[0+26]*10 + 2];
              ip = 74;
      end

         74 :
      begin                                                                     // jLt
              ip = localMem[0+25] <  localMem[0+27] ? 294 : 75;
      end

         75 :
      begin                                                                     // mov
              localMem[0 + 28] = localMem[0+27];
              ip = 76;
      end

         76 :
      begin                                                                     // shiftRight
              localMem[0 + 28] = localMem[0+28] >> 1;
              ip = 77;
      end

         77 :
      begin                                                                     // add
              localMem[0 + 29] = localMem[0+28] + 1;
              ip = 78;
      end

         78 :
      begin                                                                     // mov
              localMem[0 + 30] = heapMem[localMem[0+23]*10 + 2];
              ip = 79;
      end

         79 :
      begin                                                                     // jEq
              ip = localMem[0+30] == 0 ? 176 : 80;
      end

         80 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 31] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 31] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 31]] = 0;
              ip = 81;
      end

         81 :
      begin                                                                     // mov
              heapMem[localMem[0+31]*10 + 0] = localMem[0+28];
              ip = 82;
      end

         82 :
      begin                                                                     // mov
              heapMem[localMem[0+31]*10 + 2] = 0;
              ip = 83;
      end

         83 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 32] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 32] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 32]] = 0;
              ip = 84;
      end

         84 :
      begin                                                                     // mov
              heapMem[localMem[0+31]*10 + 4] = localMem[0+32];
              ip = 85;
      end

         85 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 33] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 33] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 33]] = 0;
              ip = 86;
      end

         86 :
      begin                                                                     // mov
              heapMem[localMem[0+31]*10 + 5] = localMem[0+33];
              ip = 87;
      end

         87 :
      begin                                                                     // mov
              heapMem[localMem[0+31]*10 + 6] = 0;
              ip = 88;
      end

         88 :
      begin                                                                     // mov
              heapMem[localMem[0+31]*10 + 3] = localMem[0+26];
              ip = 89;
      end

         89 :
      begin                                                                     // add
              heapMem[localMem[0+26]*10 + 1] = heapMem[localMem[0+26]*10 + 1] + 1;
              ip = 90;
      end

         90 :
      begin                                                                     // mov
              heapMem[localMem[0+31]*10 + 1] = heapMem[localMem[0+26]*10 + 1];
              ip = 91;
      end

         91 :
      begin                                                                     // not
              localMem[0 + 34] = !heapMem[localMem[0+23]*10 + 6];
              ip = 92;
      end

         92 :
      begin                                                                     // jNe
              ip = localMem[0+34] != 0 ? 121 : 93;
      end

         93 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 35] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 35] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 35]] = 0;
              ip = 94;
      end

         94 :
      begin                                                                     // mov
              heapMem[localMem[0+31]*10 + 6] = localMem[0+35];
              ip = 95;
      end

         95 :
      begin                                                                     // mov
              localMem[0 + 36] = heapMem[localMem[0+23]*10 + 4];
              ip = 96;
      end

         96 :
      begin                                                                     // mov
              localMem[0 + 37] = heapMem[localMem[0+31]*10 + 4];
              ip = 97;
      end

         97 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+28]) begin
                  heapMem[NArea * localMem[0+37] + 0 + i] = heapMem[NArea * localMem[0+36] + localMem[29] + i];
                end
              end
              ip = 98;
      end

         98 :
      begin                                                                     // mov
              localMem[0 + 38] = heapMem[localMem[0+23]*10 + 5];
              ip = 99;
      end

         99 :
      begin                                                                     // mov
              localMem[0 + 39] = heapMem[localMem[0+31]*10 + 5];
              ip = 100;
      end

        100 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+28]) begin
                  heapMem[NArea * localMem[0+39] + 0 + i] = heapMem[NArea * localMem[0+38] + localMem[29] + i];
                end
              end
              ip = 101;
      end

        101 :
      begin                                                                     // mov
              localMem[0 + 40] = heapMem[localMem[0+23]*10 + 6];
              ip = 102;
      end

        102 :
      begin                                                                     // mov
              localMem[0 + 41] = heapMem[localMem[0+31]*10 + 6];
              ip = 103;
      end

        103 :
      begin                                                                     // add
              localMem[0 + 42] = localMem[0+28] + 1;
              ip = 104;
      end

        104 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+42]) begin
                  heapMem[NArea * localMem[0+41] + 0 + i] = heapMem[NArea * localMem[0+40] + localMem[29] + i];
                end
              end
              ip = 105;
      end

        105 :
      begin                                                                     // mov
              localMem[0 + 43] = heapMem[localMem[0+31]*10 + 0];
              ip = 106;
      end

        106 :
      begin                                                                     // add
              localMem[0 + 44] = localMem[0+43] + 1;
              ip = 107;
      end

        107 :
      begin                                                                     // mov
              localMem[0 + 45] = heapMem[localMem[0+31]*10 + 6];
              ip = 108;
      end

        108 :
      begin                                                                     // label
              ip = 109;
      end

        109 :
      begin                                                                     // mov
              localMem[0 + 46] = 0;
              ip = 110;
      end

        110 :
      begin                                                                     // label
              ip = 111;
      end

        111 :
      begin                                                                     // jGe
              ip = localMem[0+46] >= localMem[0+44] ? 117 : 112;
      end

        112 :
      begin                                                                     // mov
              localMem[0 + 47] = heapMem[localMem[0+45]*10 + localMem[0+46]];
              ip = 113;
      end

        113 :
      begin                                                                     // mov
              heapMem[localMem[0+47]*10 + 2] = localMem[0+31];
              ip = 114;
      end

        114 :
      begin                                                                     // label
              ip = 115;
      end

        115 :
      begin                                                                     // add
              localMem[0 + 46] = localMem[0+46] + 1;
              ip = 116;
      end

        116 :
      begin                                                                     // jmp
              ip = 110;
      end

        117 :
      begin                                                                     // label
              ip = 118;
      end

        118 :
      begin                                                                     // mov
              localMem[0 + 48] = heapMem[localMem[0+23]*10 + 6];
              ip = 119;
      end

        119 :
      begin                                                                     // resize
              arraySizes[localMem[0+48]] = localMem[0+29];
              ip = 120;
      end

        120 :
      begin                                                                     // jmp
              ip = 128;
      end

        121 :
      begin                                                                     // label
              ip = 122;
      end

        122 :
      begin                                                                     // mov
              localMem[0 + 49] = heapMem[localMem[0+23]*10 + 4];
              ip = 123;
      end

        123 :
      begin                                                                     // mov
              localMem[0 + 50] = heapMem[localMem[0+31]*10 + 4];
              ip = 124;
      end

        124 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+28]) begin
                  heapMem[NArea * localMem[0+50] + 0 + i] = heapMem[NArea * localMem[0+49] + localMem[29] + i];
                end
              end
              ip = 125;
      end

        125 :
      begin                                                                     // mov
              localMem[0 + 51] = heapMem[localMem[0+23]*10 + 5];
              ip = 126;
      end

        126 :
      begin                                                                     // mov
              localMem[0 + 52] = heapMem[localMem[0+31]*10 + 5];
              ip = 127;
      end

        127 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+28]) begin
                  heapMem[NArea * localMem[0+52] + 0 + i] = heapMem[NArea * localMem[0+51] + localMem[29] + i];
                end
              end
              ip = 128;
      end

        128 :
      begin                                                                     // label
              ip = 129;
      end

        129 :
      begin                                                                     // mov
              heapMem[localMem[0+23]*10 + 0] = localMem[0+28];
              ip = 130;
      end

        130 :
      begin                                                                     // mov
              heapMem[localMem[0+31]*10 + 2] = localMem[0+30];
              ip = 131;
      end

        131 :
      begin                                                                     // mov
              localMem[0 + 53] = heapMem[localMem[0+30]*10 + 0];
              ip = 132;
      end

        132 :
      begin                                                                     // mov
              localMem[0 + 54] = heapMem[localMem[0+30]*10 + 6];
              ip = 133;
      end

        133 :
      begin                                                                     // mov
              localMem[0 + 55] = heapMem[localMem[0+54]*10 + localMem[0+53]];
              ip = 134;
      end

        134 :
      begin                                                                     // jNe
              ip = localMem[0+55] != localMem[0+23] ? 153 : 135;
      end

        135 :
      begin                                                                     // mov
              localMem[0 + 56] = heapMem[localMem[0+23]*10 + 4];
              ip = 136;
      end

        136 :
      begin                                                                     // mov
              localMem[0 + 57] = heapMem[localMem[0+56]*10 + localMem[0+28]];
              ip = 137;
      end

        137 :
      begin                                                                     // mov
              localMem[0 + 58] = heapMem[localMem[0+30]*10 + 4];
              ip = 138;
      end

        138 :
      begin                                                                     // mov
              heapMem[localMem[0+58]*10 + localMem[0+53]] = localMem[0+57];
              ip = 139;
      end

        139 :
      begin                                                                     // mov
              localMem[0 + 59] = heapMem[localMem[0+23]*10 + 5];
              ip = 140;
      end

        140 :
      begin                                                                     // mov
              localMem[0 + 60] = heapMem[localMem[0+59]*10 + localMem[0+28]];
              ip = 141;
      end

        141 :
      begin                                                                     // mov
              localMem[0 + 61] = heapMem[localMem[0+30]*10 + 5];
              ip = 142;
      end

        142 :
      begin                                                                     // mov
              heapMem[localMem[0+61]*10 + localMem[0+53]] = localMem[0+60];
              ip = 143;
      end

        143 :
      begin                                                                     // mov
              localMem[0 + 62] = heapMem[localMem[0+23]*10 + 4];
              ip = 144;
      end

        144 :
      begin                                                                     // resize
              arraySizes[localMem[0+62]] = localMem[0+28];
              ip = 145;
      end

        145 :
      begin                                                                     // mov
              localMem[0 + 63] = heapMem[localMem[0+23]*10 + 5];
              ip = 146;
      end

        146 :
      begin                                                                     // resize
              arraySizes[localMem[0+63]] = localMem[0+28];
              ip = 147;
      end

        147 :
      begin                                                                     // add
              localMem[0 + 64] = localMem[0+53] + 1;
              ip = 148;
      end

        148 :
      begin                                                                     // mov
              heapMem[localMem[0+30]*10 + 0] = localMem[0+64];
              ip = 149;
      end

        149 :
      begin                                                                     // mov
              localMem[0 + 65] = heapMem[localMem[0+30]*10 + 6];
              ip = 150;
      end

        150 :
      begin                                                                     // mov
              heapMem[localMem[0+65]*10 + localMem[0+64]] = localMem[0+31];
              ip = 151;
      end

        151 :
      begin                                                                     // jmp
              ip = 291;
      end

        152 :
      begin                                                                     // jmp
              ip = 175;
      end

        153 :
      begin                                                                     // label
              ip = 154;
      end

        154 :
      begin                                                                     // assertNe
            ip = 155;
      end

        155 :
      begin                                                                     // mov
              localMem[0 + 66] = heapMem[localMem[0+30]*10 + 6];
              ip = 156;
      end

        156 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+66] * NArea + i] == localMem[0+23]) localMem[0 + 67] = i + 1;
              end
              ip = 157;
      end

        157 :
      begin                                                                     // subtract
              localMem[0 + 67] = localMem[0+67] - 1;
              ip = 158;
      end

        158 :
      begin                                                                     // mov
              localMem[0 + 68] = heapMem[localMem[0+23]*10 + 4];
              ip = 159;
      end

        159 :
      begin                                                                     // mov
              localMem[0 + 69] = heapMem[localMem[0+68]*10 + localMem[0+28]];
              ip = 160;
      end

        160 :
      begin                                                                     // mov
              localMem[0 + 70] = heapMem[localMem[0+23]*10 + 5];
              ip = 161;
      end

        161 :
      begin                                                                     // mov
              localMem[0 + 71] = heapMem[localMem[0+70]*10 + localMem[0+28]];
              ip = 162;
      end

        162 :
      begin                                                                     // mov
              localMem[0 + 72] = heapMem[localMem[0+23]*10 + 4];
              ip = 163;
      end

        163 :
      begin                                                                     // resize
              arraySizes[localMem[0+72]] = localMem[0+28];
              ip = 164;
      end

        164 :
      begin                                                                     // mov
              localMem[0 + 73] = heapMem[localMem[0+23]*10 + 5];
              ip = 165;
      end

        165 :
      begin                                                                     // resize
              arraySizes[localMem[0+73]] = localMem[0+28];
              ip = 166;
      end

        166 :
      begin                                                                     // mov
              localMem[0 + 74] = heapMem[localMem[0+30]*10 + 4];
              ip = 167;
      end

        167 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+74] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[67]) begin
                  heapMem[NArea * localMem[0+74] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+74] + localMem[67]] = localMem[0+69];                                    // Insert new value
              arraySizes[localMem[0+74]] = arraySizes[localMem[0+74]] + 1;                              // Increase array size
              ip = 168;
      end

        168 :
      begin                                                                     // mov
              localMem[0 + 75] = heapMem[localMem[0+30]*10 + 5];
              ip = 169;
      end

        169 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+75] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[67]) begin
                  heapMem[NArea * localMem[0+75] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+75] + localMem[67]] = localMem[0+71];                                    // Insert new value
              arraySizes[localMem[0+75]] = arraySizes[localMem[0+75]] + 1;                              // Increase array size
              ip = 170;
      end

        170 :
      begin                                                                     // mov
              localMem[0 + 76] = heapMem[localMem[0+30]*10 + 6];
              ip = 171;
      end

        171 :
      begin                                                                     // add
              localMem[0 + 77] = localMem[0+67] + 1;
              ip = 172;
      end

        172 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+76] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[77]) begin
                  heapMem[NArea * localMem[0+76] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+76] + localMem[77]] = localMem[0+31];                                    // Insert new value
              arraySizes[localMem[0+76]] = arraySizes[localMem[0+76]] + 1;                              // Increase array size
              ip = 173;
      end

        173 :
      begin                                                                     // add
              heapMem[localMem[0+30]*10 + 0] = heapMem[localMem[0+30]*10 + 0] + 1;
              ip = 174;
      end

        174 :
      begin                                                                     // jmp
              ip = 291;
      end

        175 :
      begin                                                                     // label
              ip = 176;
      end

        176 :
      begin                                                                     // label
              ip = 177;
      end

        177 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 78] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 78] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 78]] = 0;
              ip = 178;
      end

        178 :
      begin                                                                     // mov
              heapMem[localMem[0+78]*10 + 0] = localMem[0+28];
              ip = 179;
      end

        179 :
      begin                                                                     // mov
              heapMem[localMem[0+78]*10 + 2] = 0;
              ip = 180;
      end

        180 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 79] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 79] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 79]] = 0;
              ip = 181;
      end

        181 :
      begin                                                                     // mov
              heapMem[localMem[0+78]*10 + 4] = localMem[0+79];
              ip = 182;
      end

        182 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 80] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 80] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 80]] = 0;
              ip = 183;
      end

        183 :
      begin                                                                     // mov
              heapMem[localMem[0+78]*10 + 5] = localMem[0+80];
              ip = 184;
      end

        184 :
      begin                                                                     // mov
              heapMem[localMem[0+78]*10 + 6] = 0;
              ip = 185;
      end

        185 :
      begin                                                                     // mov
              heapMem[localMem[0+78]*10 + 3] = localMem[0+26];
              ip = 186;
      end

        186 :
      begin                                                                     // add
              heapMem[localMem[0+26]*10 + 1] = heapMem[localMem[0+26]*10 + 1] + 1;
              ip = 187;
      end

        187 :
      begin                                                                     // mov
              heapMem[localMem[0+78]*10 + 1] = heapMem[localMem[0+26]*10 + 1];
              ip = 188;
      end

        188 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 81] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 81] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 81]] = 0;
              ip = 189;
      end

        189 :
      begin                                                                     // mov
              heapMem[localMem[0+81]*10 + 0] = localMem[0+28];
              ip = 190;
      end

        190 :
      begin                                                                     // mov
              heapMem[localMem[0+81]*10 + 2] = 0;
              ip = 191;
      end

        191 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 82] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 82] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 82]] = 0;
              ip = 192;
      end

        192 :
      begin                                                                     // mov
              heapMem[localMem[0+81]*10 + 4] = localMem[0+82];
              ip = 193;
      end

        193 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 83] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 83] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 83]] = 0;
              ip = 194;
      end

        194 :
      begin                                                                     // mov
              heapMem[localMem[0+81]*10 + 5] = localMem[0+83];
              ip = 195;
      end

        195 :
      begin                                                                     // mov
              heapMem[localMem[0+81]*10 + 6] = 0;
              ip = 196;
      end

        196 :
      begin                                                                     // mov
              heapMem[localMem[0+81]*10 + 3] = localMem[0+26];
              ip = 197;
      end

        197 :
      begin                                                                     // add
              heapMem[localMem[0+26]*10 + 1] = heapMem[localMem[0+26]*10 + 1] + 1;
              ip = 198;
      end

        198 :
      begin                                                                     // mov
              heapMem[localMem[0+81]*10 + 1] = heapMem[localMem[0+26]*10 + 1];
              ip = 199;
      end

        199 :
      begin                                                                     // not
              localMem[0 + 84] = !heapMem[localMem[0+23]*10 + 6];
              ip = 200;
      end

        200 :
      begin                                                                     // jNe
              ip = localMem[0+84] != 0 ? 252 : 201;
      end

        201 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 85] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 85] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 85]] = 0;
              ip = 202;
      end

        202 :
      begin                                                                     // mov
              heapMem[localMem[0+78]*10 + 6] = localMem[0+85];
              ip = 203;
      end

        203 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 86] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 86] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 86]] = 0;
              ip = 204;
      end

        204 :
      begin                                                                     // mov
              heapMem[localMem[0+81]*10 + 6] = localMem[0+86];
              ip = 205;
      end

        205 :
      begin                                                                     // mov
              localMem[0 + 87] = heapMem[localMem[0+23]*10 + 4];
              ip = 206;
      end

        206 :
      begin                                                                     // mov
              localMem[0 + 88] = heapMem[localMem[0+78]*10 + 4];
              ip = 207;
      end

        207 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+28]) begin
                  heapMem[NArea * localMem[0+88] + 0 + i] = heapMem[NArea * localMem[0+87] + 0 + i];
                end
              end
              ip = 208;
      end

        208 :
      begin                                                                     // mov
              localMem[0 + 89] = heapMem[localMem[0+23]*10 + 5];
              ip = 209;
      end

        209 :
      begin                                                                     // mov
              localMem[0 + 90] = heapMem[localMem[0+78]*10 + 5];
              ip = 210;
      end

        210 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+28]) begin
                  heapMem[NArea * localMem[0+90] + 0 + i] = heapMem[NArea * localMem[0+89] + 0 + i];
                end
              end
              ip = 211;
      end

        211 :
      begin                                                                     // mov
              localMem[0 + 91] = heapMem[localMem[0+23]*10 + 6];
              ip = 212;
      end

        212 :
      begin                                                                     // mov
              localMem[0 + 92] = heapMem[localMem[0+78]*10 + 6];
              ip = 213;
      end

        213 :
      begin                                                                     // add
              localMem[0 + 93] = localMem[0+28] + 1;
              ip = 214;
      end

        214 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+93]) begin
                  heapMem[NArea * localMem[0+92] + 0 + i] = heapMem[NArea * localMem[0+91] + 0 + i];
                end
              end
              ip = 215;
      end

        215 :
      begin                                                                     // mov
              localMem[0 + 94] = heapMem[localMem[0+23]*10 + 4];
              ip = 216;
      end

        216 :
      begin                                                                     // mov
              localMem[0 + 95] = heapMem[localMem[0+81]*10 + 4];
              ip = 217;
      end

        217 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+28]) begin
                  heapMem[NArea * localMem[0+95] + 0 + i] = heapMem[NArea * localMem[0+94] + localMem[29] + i];
                end
              end
              ip = 218;
      end

        218 :
      begin                                                                     // mov
              localMem[0 + 96] = heapMem[localMem[0+23]*10 + 5];
              ip = 219;
      end

        219 :
      begin                                                                     // mov
              localMem[0 + 97] = heapMem[localMem[0+81]*10 + 5];
              ip = 220;
      end

        220 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+28]) begin
                  heapMem[NArea * localMem[0+97] + 0 + i] = heapMem[NArea * localMem[0+96] + localMem[29] + i];
                end
              end
              ip = 221;
      end

        221 :
      begin                                                                     // mov
              localMem[0 + 98] = heapMem[localMem[0+23]*10 + 6];
              ip = 222;
      end

        222 :
      begin                                                                     // mov
              localMem[0 + 99] = heapMem[localMem[0+81]*10 + 6];
              ip = 223;
      end

        223 :
      begin                                                                     // add
              localMem[0 + 100] = localMem[0+28] + 1;
              ip = 224;
      end

        224 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+100]) begin
                  heapMem[NArea * localMem[0+99] + 0 + i] = heapMem[NArea * localMem[0+98] + localMem[29] + i];
                end
              end
              ip = 225;
      end

        225 :
      begin                                                                     // mov
              localMem[0 + 101] = heapMem[localMem[0+78]*10 + 0];
              ip = 226;
      end

        226 :
      begin                                                                     // add
              localMem[0 + 102] = localMem[0+101] + 1;
              ip = 227;
      end

        227 :
      begin                                                                     // mov
              localMem[0 + 103] = heapMem[localMem[0+78]*10 + 6];
              ip = 228;
      end

        228 :
      begin                                                                     // label
              ip = 229;
      end

        229 :
      begin                                                                     // mov
              localMem[0 + 104] = 0;
              ip = 230;
      end

        230 :
      begin                                                                     // label
              ip = 231;
      end

        231 :
      begin                                                                     // jGe
              ip = localMem[0+104] >= localMem[0+102] ? 237 : 232;
      end

        232 :
      begin                                                                     // mov
              localMem[0 + 105] = heapMem[localMem[0+103]*10 + localMem[0+104]];
              ip = 233;
      end

        233 :
      begin                                                                     // mov
              heapMem[localMem[0+105]*10 + 2] = localMem[0+78];
              ip = 234;
      end

        234 :
      begin                                                                     // label
              ip = 235;
      end

        235 :
      begin                                                                     // add
              localMem[0 + 104] = localMem[0+104] + 1;
              ip = 236;
      end

        236 :
      begin                                                                     // jmp
              ip = 230;
      end

        237 :
      begin                                                                     // label
              ip = 238;
      end

        238 :
      begin                                                                     // mov
              localMem[0 + 106] = heapMem[localMem[0+81]*10 + 0];
              ip = 239;
      end

        239 :
      begin                                                                     // add
              localMem[0 + 107] = localMem[0+106] + 1;
              ip = 240;
      end

        240 :
      begin                                                                     // mov
              localMem[0 + 108] = heapMem[localMem[0+81]*10 + 6];
              ip = 241;
      end

        241 :
      begin                                                                     // label
              ip = 242;
      end

        242 :
      begin                                                                     // mov
              localMem[0 + 109] = 0;
              ip = 243;
      end

        243 :
      begin                                                                     // label
              ip = 244;
      end

        244 :
      begin                                                                     // jGe
              ip = localMem[0+109] >= localMem[0+107] ? 250 : 245;
      end

        245 :
      begin                                                                     // mov
              localMem[0 + 110] = heapMem[localMem[0+108]*10 + localMem[0+109]];
              ip = 246;
      end

        246 :
      begin                                                                     // mov
              heapMem[localMem[0+110]*10 + 2] = localMem[0+81];
              ip = 247;
      end

        247 :
      begin                                                                     // label
              ip = 248;
      end

        248 :
      begin                                                                     // add
              localMem[0 + 109] = localMem[0+109] + 1;
              ip = 249;
      end

        249 :
      begin                                                                     // jmp
              ip = 243;
      end

        250 :
      begin                                                                     // label
              ip = 251;
      end

        251 :
      begin                                                                     // jmp
              ip = 267;
      end

        252 :
      begin                                                                     // label
              ip = 253;
      end

        253 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 111] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 111] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 111]] = 0;
              ip = 254;
      end

        254 :
      begin                                                                     // mov
              heapMem[localMem[0+23]*10 + 6] = localMem[0+111];
              ip = 255;
      end

        255 :
      begin                                                                     // mov
              localMem[0 + 112] = heapMem[localMem[0+23]*10 + 4];
              ip = 256;
      end

        256 :
      begin                                                                     // mov
              localMem[0 + 113] = heapMem[localMem[0+78]*10 + 4];
              ip = 257;
      end

        257 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+28]) begin
                  heapMem[NArea * localMem[0+113] + 0 + i] = heapMem[NArea * localMem[0+112] + 0 + i];
                end
              end
              ip = 258;
      end

        258 :
      begin                                                                     // mov
              localMem[0 + 114] = heapMem[localMem[0+23]*10 + 5];
              ip = 259;
      end

        259 :
      begin                                                                     // mov
              localMem[0 + 115] = heapMem[localMem[0+78]*10 + 5];
              ip = 260;
      end

        260 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+28]) begin
                  heapMem[NArea * localMem[0+115] + 0 + i] = heapMem[NArea * localMem[0+114] + 0 + i];
                end
              end
              ip = 261;
      end

        261 :
      begin                                                                     // mov
              localMem[0 + 116] = heapMem[localMem[0+23]*10 + 4];
              ip = 262;
      end

        262 :
      begin                                                                     // mov
              localMem[0 + 117] = heapMem[localMem[0+81]*10 + 4];
              ip = 263;
      end

        263 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+28]) begin
                  heapMem[NArea * localMem[0+117] + 0 + i] = heapMem[NArea * localMem[0+116] + localMem[29] + i];
                end
              end
              ip = 264;
      end

        264 :
      begin                                                                     // mov
              localMem[0 + 118] = heapMem[localMem[0+23]*10 + 5];
              ip = 265;
      end

        265 :
      begin                                                                     // mov
              localMem[0 + 119] = heapMem[localMem[0+81]*10 + 5];
              ip = 266;
      end

        266 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+28]) begin
                  heapMem[NArea * localMem[0+119] + 0 + i] = heapMem[NArea * localMem[0+118] + localMem[29] + i];
                end
              end
              ip = 267;
      end

        267 :
      begin                                                                     // label
              ip = 268;
      end

        268 :
      begin                                                                     // mov
              heapMem[localMem[0+78]*10 + 2] = localMem[0+23];
              ip = 269;
      end

        269 :
      begin                                                                     // mov
              heapMem[localMem[0+81]*10 + 2] = localMem[0+23];
              ip = 270;
      end

        270 :
      begin                                                                     // mov
              localMem[0 + 120] = heapMem[localMem[0+23]*10 + 4];
              ip = 271;
      end

        271 :
      begin                                                                     // mov
              localMem[0 + 121] = heapMem[localMem[0+120]*10 + localMem[0+28]];
              ip = 272;
      end

        272 :
      begin                                                                     // mov
              localMem[0 + 122] = heapMem[localMem[0+23]*10 + 5];
              ip = 273;
      end

        273 :
      begin                                                                     // mov
              localMem[0 + 123] = heapMem[localMem[0+122]*10 + localMem[0+28]];
              ip = 274;
      end

        274 :
      begin                                                                     // mov
              localMem[0 + 124] = heapMem[localMem[0+23]*10 + 4];
              ip = 275;
      end

        275 :
      begin                                                                     // mov
              heapMem[localMem[0+124]*10 + 0] = localMem[0+121];
              ip = 276;
      end

        276 :
      begin                                                                     // mov
              localMem[0 + 125] = heapMem[localMem[0+23]*10 + 5];
              ip = 277;
      end

        277 :
      begin                                                                     // mov
              heapMem[localMem[0+125]*10 + 0] = localMem[0+123];
              ip = 278;
      end

        278 :
      begin                                                                     // mov
              localMem[0 + 126] = heapMem[localMem[0+23]*10 + 6];
              ip = 279;
      end

        279 :
      begin                                                                     // mov
              heapMem[localMem[0+126]*10 + 0] = localMem[0+78];
              ip = 280;
      end

        280 :
      begin                                                                     // mov
              localMem[0 + 127] = heapMem[localMem[0+23]*10 + 6];
              ip = 281;
      end

        281 :
      begin                                                                     // mov
              heapMem[localMem[0+127]*10 + 1] = localMem[0+81];
              ip = 282;
      end

        282 :
      begin                                                                     // mov
              heapMem[localMem[0+23]*10 + 0] = 1;
              ip = 283;
      end

        283 :
      begin                                                                     // mov
              localMem[0 + 128] = heapMem[localMem[0+23]*10 + 4];
              ip = 284;
      end

        284 :
      begin                                                                     // resize
              arraySizes[localMem[0+128]] = 1;
              ip = 285;
      end

        285 :
      begin                                                                     // mov
              localMem[0 + 129] = heapMem[localMem[0+23]*10 + 5];
              ip = 286;
      end

        286 :
      begin                                                                     // resize
              arraySizes[localMem[0+129]] = 1;
              ip = 287;
      end

        287 :
      begin                                                                     // mov
              localMem[0 + 130] = heapMem[localMem[0+23]*10 + 6];
              ip = 288;
      end

        288 :
      begin                                                                     // resize
              arraySizes[localMem[0+130]] = 2;
              ip = 289;
      end

        289 :
      begin                                                                     // jmp
              ip = 291;
      end

        290 :
      begin                                                                     // jmp
              ip = 296;
      end

        291 :
      begin                                                                     // label
              ip = 292;
      end

        292 :
      begin                                                                     // mov
              localMem[0 + 24] = 1;
              ip = 293;
      end

        293 :
      begin                                                                     // jmp
              ip = 296;
      end

        294 :
      begin                                                                     // label
              ip = 295;
      end

        295 :
      begin                                                                     // mov
              localMem[0 + 24] = 0;
              ip = 296;
      end

        296 :
      begin                                                                     // label
              ip = 297;
      end

        297 :
      begin                                                                     // label
              ip = 298;
      end

        298 :
      begin                                                                     // label
              ip = 299;
      end

        299 :
      begin                                                                     // mov
              localMem[0 + 131] = 0;
              ip = 300;
      end

        300 :
      begin                                                                     // label
              ip = 301;
      end

        301 :
      begin                                                                     // jGe
              ip = localMem[0+131] >= 99 ? 799 : 302;
      end

        302 :
      begin                                                                     // mov
              localMem[0 + 132] = heapMem[localMem[0+23]*10 + 0];
              ip = 303;
      end

        303 :
      begin                                                                     // subtract
              localMem[0 + 133] = localMem[0+132] - 1;
              ip = 304;
      end

        304 :
      begin                                                                     // mov
              localMem[0 + 134] = heapMem[localMem[0+23]*10 + 4];
              ip = 305;
      end

        305 :
      begin                                                                     // mov
              localMem[0 + 135] = heapMem[localMem[0+134]*10 + localMem[0+133]];
              ip = 306;
      end

        306 :
      begin                                                                     // jLe
              ip = localMem[0+1] <= localMem[0+135] ? 547 : 307;
      end

        307 :
      begin                                                                     // not
              localMem[0 + 136] = !heapMem[localMem[0+23]*10 + 6];
              ip = 308;
      end

        308 :
      begin                                                                     // jEq
              ip = localMem[0+136] == 0 ? 313 : 309;
      end

        309 :
      begin                                                                     // mov
              heapMem[localMem[0+3]*10 + 0] = localMem[0+23];
              ip = 310;
      end

        310 :
      begin                                                                     // mov
              heapMem[localMem[0+3]*10 + 1] = 2;
              ip = 311;
      end

        311 :
      begin                                                                     // subtract
              heapMem[localMem[0+3]*10 + 2] = localMem[0+132] - 1;
              ip = 312;
      end

        312 :
      begin                                                                     // jmp
              ip = 803;
      end

        313 :
      begin                                                                     // label
              ip = 314;
      end

        314 :
      begin                                                                     // mov
              localMem[0 + 137] = heapMem[localMem[0+23]*10 + 6];
              ip = 315;
      end

        315 :
      begin                                                                     // mov
              localMem[0 + 138] = heapMem[localMem[0+137]*10 + localMem[0+132]];
              ip = 316;
      end

        316 :
      begin                                                                     // label
              ip = 317;
      end

        317 :
      begin                                                                     // mov
              localMem[0 + 140] = heapMem[localMem[0+138]*10 + 0];
              ip = 318;
      end

        318 :
      begin                                                                     // mov
              localMem[0 + 141] = heapMem[localMem[0+138]*10 + 3];
              ip = 319;
      end

        319 :
      begin                                                                     // mov
              localMem[0 + 142] = heapMem[localMem[0+141]*10 + 2];
              ip = 320;
      end

        320 :
      begin                                                                     // jLt
              ip = localMem[0+140] <  localMem[0+142] ? 540 : 321;
      end

        321 :
      begin                                                                     // mov
              localMem[0 + 143] = localMem[0+142];
              ip = 322;
      end

        322 :
      begin                                                                     // shiftRight
              localMem[0 + 143] = localMem[0+143] >> 1;
              ip = 323;
      end

        323 :
      begin                                                                     // add
              localMem[0 + 144] = localMem[0+143] + 1;
              ip = 324;
      end

        324 :
      begin                                                                     // mov
              localMem[0 + 145] = heapMem[localMem[0+138]*10 + 2];
              ip = 325;
      end

        325 :
      begin                                                                     // jEq
              ip = localMem[0+145] == 0 ? 422 : 326;
      end

        326 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 146] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 146] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 146]] = 0;
              ip = 327;
      end

        327 :
      begin                                                                     // mov
              heapMem[localMem[0+146]*10 + 0] = localMem[0+143];
              ip = 328;
      end

        328 :
      begin                                                                     // mov
              heapMem[localMem[0+146]*10 + 2] = 0;
              ip = 329;
      end

        329 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 147] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 147] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 147]] = 0;
              ip = 330;
      end

        330 :
      begin                                                                     // mov
              heapMem[localMem[0+146]*10 + 4] = localMem[0+147];
              ip = 331;
      end

        331 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 148] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 148] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 148]] = 0;
              ip = 332;
      end

        332 :
      begin                                                                     // mov
              heapMem[localMem[0+146]*10 + 5] = localMem[0+148];
              ip = 333;
      end

        333 :
      begin                                                                     // mov
              heapMem[localMem[0+146]*10 + 6] = 0;
              ip = 334;
      end

        334 :
      begin                                                                     // mov
              heapMem[localMem[0+146]*10 + 3] = localMem[0+141];
              ip = 335;
      end

        335 :
      begin                                                                     // add
              heapMem[localMem[0+141]*10 + 1] = heapMem[localMem[0+141]*10 + 1] + 1;
              ip = 336;
      end

        336 :
      begin                                                                     // mov
              heapMem[localMem[0+146]*10 + 1] = heapMem[localMem[0+141]*10 + 1];
              ip = 337;
      end

        337 :
      begin                                                                     // not
              localMem[0 + 149] = !heapMem[localMem[0+138]*10 + 6];
              ip = 338;
      end

        338 :
      begin                                                                     // jNe
              ip = localMem[0+149] != 0 ? 367 : 339;
      end

        339 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 150] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 150] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 150]] = 0;
              ip = 340;
      end

        340 :
      begin                                                                     // mov
              heapMem[localMem[0+146]*10 + 6] = localMem[0+150];
              ip = 341;
      end

        341 :
      begin                                                                     // mov
              localMem[0 + 151] = heapMem[localMem[0+138]*10 + 4];
              ip = 342;
      end

        342 :
      begin                                                                     // mov
              localMem[0 + 152] = heapMem[localMem[0+146]*10 + 4];
              ip = 343;
      end

        343 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+143]) begin
                  heapMem[NArea * localMem[0+152] + 0 + i] = heapMem[NArea * localMem[0+151] + localMem[144] + i];
                end
              end
              ip = 344;
      end

        344 :
      begin                                                                     // mov
              localMem[0 + 153] = heapMem[localMem[0+138]*10 + 5];
              ip = 345;
      end

        345 :
      begin                                                                     // mov
              localMem[0 + 154] = heapMem[localMem[0+146]*10 + 5];
              ip = 346;
      end

        346 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+143]) begin
                  heapMem[NArea * localMem[0+154] + 0 + i] = heapMem[NArea * localMem[0+153] + localMem[144] + i];
                end
              end
              ip = 347;
      end

        347 :
      begin                                                                     // mov
              localMem[0 + 155] = heapMem[localMem[0+138]*10 + 6];
              ip = 348;
      end

        348 :
      begin                                                                     // mov
              localMem[0 + 156] = heapMem[localMem[0+146]*10 + 6];
              ip = 349;
      end

        349 :
      begin                                                                     // add
              localMem[0 + 157] = localMem[0+143] + 1;
              ip = 350;
      end

        350 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+157]) begin
                  heapMem[NArea * localMem[0+156] + 0 + i] = heapMem[NArea * localMem[0+155] + localMem[144] + i];
                end
              end
              ip = 351;
      end

        351 :
      begin                                                                     // mov
              localMem[0 + 158] = heapMem[localMem[0+146]*10 + 0];
              ip = 352;
      end

        352 :
      begin                                                                     // add
              localMem[0 + 159] = localMem[0+158] + 1;
              ip = 353;
      end

        353 :
      begin                                                                     // mov
              localMem[0 + 160] = heapMem[localMem[0+146]*10 + 6];
              ip = 354;
      end

        354 :
      begin                                                                     // label
              ip = 355;
      end

        355 :
      begin                                                                     // mov
              localMem[0 + 161] = 0;
              ip = 356;
      end

        356 :
      begin                                                                     // label
              ip = 357;
      end

        357 :
      begin                                                                     // jGe
              ip = localMem[0+161] >= localMem[0+159] ? 363 : 358;
      end

        358 :
      begin                                                                     // mov
              localMem[0 + 162] = heapMem[localMem[0+160]*10 + localMem[0+161]];
              ip = 359;
      end

        359 :
      begin                                                                     // mov
              heapMem[localMem[0+162]*10 + 2] = localMem[0+146];
              ip = 360;
      end

        360 :
      begin                                                                     // label
              ip = 361;
      end

        361 :
      begin                                                                     // add
              localMem[0 + 161] = localMem[0+161] + 1;
              ip = 362;
      end

        362 :
      begin                                                                     // jmp
              ip = 356;
      end

        363 :
      begin                                                                     // label
              ip = 364;
      end

        364 :
      begin                                                                     // mov
              localMem[0 + 163] = heapMem[localMem[0+138]*10 + 6];
              ip = 365;
      end

        365 :
      begin                                                                     // resize
              arraySizes[localMem[0+163]] = localMem[0+144];
              ip = 366;
      end

        366 :
      begin                                                                     // jmp
              ip = 374;
      end

        367 :
      begin                                                                     // label
              ip = 368;
      end

        368 :
      begin                                                                     // mov
              localMem[0 + 164] = heapMem[localMem[0+138]*10 + 4];
              ip = 369;
      end

        369 :
      begin                                                                     // mov
              localMem[0 + 165] = heapMem[localMem[0+146]*10 + 4];
              ip = 370;
      end

        370 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+143]) begin
                  heapMem[NArea * localMem[0+165] + 0 + i] = heapMem[NArea * localMem[0+164] + localMem[144] + i];
                end
              end
              ip = 371;
      end

        371 :
      begin                                                                     // mov
              localMem[0 + 166] = heapMem[localMem[0+138]*10 + 5];
              ip = 372;
      end

        372 :
      begin                                                                     // mov
              localMem[0 + 167] = heapMem[localMem[0+146]*10 + 5];
              ip = 373;
      end

        373 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+143]) begin
                  heapMem[NArea * localMem[0+167] + 0 + i] = heapMem[NArea * localMem[0+166] + localMem[144] + i];
                end
              end
              ip = 374;
      end

        374 :
      begin                                                                     // label
              ip = 375;
      end

        375 :
      begin                                                                     // mov
              heapMem[localMem[0+138]*10 + 0] = localMem[0+143];
              ip = 376;
      end

        376 :
      begin                                                                     // mov
              heapMem[localMem[0+146]*10 + 2] = localMem[0+145];
              ip = 377;
      end

        377 :
      begin                                                                     // mov
              localMem[0 + 168] = heapMem[localMem[0+145]*10 + 0];
              ip = 378;
      end

        378 :
      begin                                                                     // mov
              localMem[0 + 169] = heapMem[localMem[0+145]*10 + 6];
              ip = 379;
      end

        379 :
      begin                                                                     // mov
              localMem[0 + 170] = heapMem[localMem[0+169]*10 + localMem[0+168]];
              ip = 380;
      end

        380 :
      begin                                                                     // jNe
              ip = localMem[0+170] != localMem[0+138] ? 399 : 381;
      end

        381 :
      begin                                                                     // mov
              localMem[0 + 171] = heapMem[localMem[0+138]*10 + 4];
              ip = 382;
      end

        382 :
      begin                                                                     // mov
              localMem[0 + 172] = heapMem[localMem[0+171]*10 + localMem[0+143]];
              ip = 383;
      end

        383 :
      begin                                                                     // mov
              localMem[0 + 173] = heapMem[localMem[0+145]*10 + 4];
              ip = 384;
      end

        384 :
      begin                                                                     // mov
              heapMem[localMem[0+173]*10 + localMem[0+168]] = localMem[0+172];
              ip = 385;
      end

        385 :
      begin                                                                     // mov
              localMem[0 + 174] = heapMem[localMem[0+138]*10 + 5];
              ip = 386;
      end

        386 :
      begin                                                                     // mov
              localMem[0 + 175] = heapMem[localMem[0+174]*10 + localMem[0+143]];
              ip = 387;
      end

        387 :
      begin                                                                     // mov
              localMem[0 + 176] = heapMem[localMem[0+145]*10 + 5];
              ip = 388;
      end

        388 :
      begin                                                                     // mov
              heapMem[localMem[0+176]*10 + localMem[0+168]] = localMem[0+175];
              ip = 389;
      end

        389 :
      begin                                                                     // mov
              localMem[0 + 177] = heapMem[localMem[0+138]*10 + 4];
              ip = 390;
      end

        390 :
      begin                                                                     // resize
              arraySizes[localMem[0+177]] = localMem[0+143];
              ip = 391;
      end

        391 :
      begin                                                                     // mov
              localMem[0 + 178] = heapMem[localMem[0+138]*10 + 5];
              ip = 392;
      end

        392 :
      begin                                                                     // resize
              arraySizes[localMem[0+178]] = localMem[0+143];
              ip = 393;
      end

        393 :
      begin                                                                     // add
              localMem[0 + 179] = localMem[0+168] + 1;
              ip = 394;
      end

        394 :
      begin                                                                     // mov
              heapMem[localMem[0+145]*10 + 0] = localMem[0+179];
              ip = 395;
      end

        395 :
      begin                                                                     // mov
              localMem[0 + 180] = heapMem[localMem[0+145]*10 + 6];
              ip = 396;
      end

        396 :
      begin                                                                     // mov
              heapMem[localMem[0+180]*10 + localMem[0+179]] = localMem[0+146];
              ip = 397;
      end

        397 :
      begin                                                                     // jmp
              ip = 537;
      end

        398 :
      begin                                                                     // jmp
              ip = 421;
      end

        399 :
      begin                                                                     // label
              ip = 400;
      end

        400 :
      begin                                                                     // assertNe
            ip = 401;
      end

        401 :
      begin                                                                     // mov
              localMem[0 + 181] = heapMem[localMem[0+145]*10 + 6];
              ip = 402;
      end

        402 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+181] * NArea + i] == localMem[0+138]) localMem[0 + 182] = i + 1;
              end
              ip = 403;
      end

        403 :
      begin                                                                     // subtract
              localMem[0 + 182] = localMem[0+182] - 1;
              ip = 404;
      end

        404 :
      begin                                                                     // mov
              localMem[0 + 183] = heapMem[localMem[0+138]*10 + 4];
              ip = 405;
      end

        405 :
      begin                                                                     // mov
              localMem[0 + 184] = heapMem[localMem[0+183]*10 + localMem[0+143]];
              ip = 406;
      end

        406 :
      begin                                                                     // mov
              localMem[0 + 185] = heapMem[localMem[0+138]*10 + 5];
              ip = 407;
      end

        407 :
      begin                                                                     // mov
              localMem[0 + 186] = heapMem[localMem[0+185]*10 + localMem[0+143]];
              ip = 408;
      end

        408 :
      begin                                                                     // mov
              localMem[0 + 187] = heapMem[localMem[0+138]*10 + 4];
              ip = 409;
      end

        409 :
      begin                                                                     // resize
              arraySizes[localMem[0+187]] = localMem[0+143];
              ip = 410;
      end

        410 :
      begin                                                                     // mov
              localMem[0 + 188] = heapMem[localMem[0+138]*10 + 5];
              ip = 411;
      end

        411 :
      begin                                                                     // resize
              arraySizes[localMem[0+188]] = localMem[0+143];
              ip = 412;
      end

        412 :
      begin                                                                     // mov
              localMem[0 + 189] = heapMem[localMem[0+145]*10 + 4];
              ip = 413;
      end

        413 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+189] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[182]) begin
                  heapMem[NArea * localMem[0+189] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+189] + localMem[182]] = localMem[0+184];                                    // Insert new value
              arraySizes[localMem[0+189]] = arraySizes[localMem[0+189]] + 1;                              // Increase array size
              ip = 414;
      end

        414 :
      begin                                                                     // mov
              localMem[0 + 190] = heapMem[localMem[0+145]*10 + 5];
              ip = 415;
      end

        415 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+190] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[182]) begin
                  heapMem[NArea * localMem[0+190] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+190] + localMem[182]] = localMem[0+186];                                    // Insert new value
              arraySizes[localMem[0+190]] = arraySizes[localMem[0+190]] + 1;                              // Increase array size
              ip = 416;
      end

        416 :
      begin                                                                     // mov
              localMem[0 + 191] = heapMem[localMem[0+145]*10 + 6];
              ip = 417;
      end

        417 :
      begin                                                                     // add
              localMem[0 + 192] = localMem[0+182] + 1;
              ip = 418;
      end

        418 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+191] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[192]) begin
                  heapMem[NArea * localMem[0+191] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+191] + localMem[192]] = localMem[0+146];                                    // Insert new value
              arraySizes[localMem[0+191]] = arraySizes[localMem[0+191]] + 1;                              // Increase array size
              ip = 419;
      end

        419 :
      begin                                                                     // add
              heapMem[localMem[0+145]*10 + 0] = heapMem[localMem[0+145]*10 + 0] + 1;
              ip = 420;
      end

        420 :
      begin                                                                     // jmp
              ip = 537;
      end

        421 :
      begin                                                                     // label
              ip = 422;
      end

        422 :
      begin                                                                     // label
              ip = 423;
      end

        423 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 193] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 193] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 193]] = 0;
              ip = 424;
      end

        424 :
      begin                                                                     // mov
              heapMem[localMem[0+193]*10 + 0] = localMem[0+143];
              ip = 425;
      end

        425 :
      begin                                                                     // mov
              heapMem[localMem[0+193]*10 + 2] = 0;
              ip = 426;
      end

        426 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 194] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 194] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 194]] = 0;
              ip = 427;
      end

        427 :
      begin                                                                     // mov
              heapMem[localMem[0+193]*10 + 4] = localMem[0+194];
              ip = 428;
      end

        428 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 195] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 195] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 195]] = 0;
              ip = 429;
      end

        429 :
      begin                                                                     // mov
              heapMem[localMem[0+193]*10 + 5] = localMem[0+195];
              ip = 430;
      end

        430 :
      begin                                                                     // mov
              heapMem[localMem[0+193]*10 + 6] = 0;
              ip = 431;
      end

        431 :
      begin                                                                     // mov
              heapMem[localMem[0+193]*10 + 3] = localMem[0+141];
              ip = 432;
      end

        432 :
      begin                                                                     // add
              heapMem[localMem[0+141]*10 + 1] = heapMem[localMem[0+141]*10 + 1] + 1;
              ip = 433;
      end

        433 :
      begin                                                                     // mov
              heapMem[localMem[0+193]*10 + 1] = heapMem[localMem[0+141]*10 + 1];
              ip = 434;
      end

        434 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 196] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 196] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 196]] = 0;
              ip = 435;
      end

        435 :
      begin                                                                     // mov
              heapMem[localMem[0+196]*10 + 0] = localMem[0+143];
              ip = 436;
      end

        436 :
      begin                                                                     // mov
              heapMem[localMem[0+196]*10 + 2] = 0;
              ip = 437;
      end

        437 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 197] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 197] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 197]] = 0;
              ip = 438;
      end

        438 :
      begin                                                                     // mov
              heapMem[localMem[0+196]*10 + 4] = localMem[0+197];
              ip = 439;
      end

        439 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 198] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 198] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 198]] = 0;
              ip = 440;
      end

        440 :
      begin                                                                     // mov
              heapMem[localMem[0+196]*10 + 5] = localMem[0+198];
              ip = 441;
      end

        441 :
      begin                                                                     // mov
              heapMem[localMem[0+196]*10 + 6] = 0;
              ip = 442;
      end

        442 :
      begin                                                                     // mov
              heapMem[localMem[0+196]*10 + 3] = localMem[0+141];
              ip = 443;
      end

        443 :
      begin                                                                     // add
              heapMem[localMem[0+141]*10 + 1] = heapMem[localMem[0+141]*10 + 1] + 1;
              ip = 444;
      end

        444 :
      begin                                                                     // mov
              heapMem[localMem[0+196]*10 + 1] = heapMem[localMem[0+141]*10 + 1];
              ip = 445;
      end

        445 :
      begin                                                                     // not
              localMem[0 + 199] = !heapMem[localMem[0+138]*10 + 6];
              ip = 446;
      end

        446 :
      begin                                                                     // jNe
              ip = localMem[0+199] != 0 ? 498 : 447;
      end

        447 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 200] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 200] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 200]] = 0;
              ip = 448;
      end

        448 :
      begin                                                                     // mov
              heapMem[localMem[0+193]*10 + 6] = localMem[0+200];
              ip = 449;
      end

        449 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 201] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 201] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 201]] = 0;
              ip = 450;
      end

        450 :
      begin                                                                     // mov
              heapMem[localMem[0+196]*10 + 6] = localMem[0+201];
              ip = 451;
      end

        451 :
      begin                                                                     // mov
              localMem[0 + 202] = heapMem[localMem[0+138]*10 + 4];
              ip = 452;
      end

        452 :
      begin                                                                     // mov
              localMem[0 + 203] = heapMem[localMem[0+193]*10 + 4];
              ip = 453;
      end

        453 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+143]) begin
                  heapMem[NArea * localMem[0+203] + 0 + i] = heapMem[NArea * localMem[0+202] + 0 + i];
                end
              end
              ip = 454;
      end

        454 :
      begin                                                                     // mov
              localMem[0 + 204] = heapMem[localMem[0+138]*10 + 5];
              ip = 455;
      end

        455 :
      begin                                                                     // mov
              localMem[0 + 205] = heapMem[localMem[0+193]*10 + 5];
              ip = 456;
      end

        456 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+143]) begin
                  heapMem[NArea * localMem[0+205] + 0 + i] = heapMem[NArea * localMem[0+204] + 0 + i];
                end
              end
              ip = 457;
      end

        457 :
      begin                                                                     // mov
              localMem[0 + 206] = heapMem[localMem[0+138]*10 + 6];
              ip = 458;
      end

        458 :
      begin                                                                     // mov
              localMem[0 + 207] = heapMem[localMem[0+193]*10 + 6];
              ip = 459;
      end

        459 :
      begin                                                                     // add
              localMem[0 + 208] = localMem[0+143] + 1;
              ip = 460;
      end

        460 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+208]) begin
                  heapMem[NArea * localMem[0+207] + 0 + i] = heapMem[NArea * localMem[0+206] + 0 + i];
                end
              end
              ip = 461;
      end

        461 :
      begin                                                                     // mov
              localMem[0 + 209] = heapMem[localMem[0+138]*10 + 4];
              ip = 462;
      end

        462 :
      begin                                                                     // mov
              localMem[0 + 210] = heapMem[localMem[0+196]*10 + 4];
              ip = 463;
      end

        463 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+143]) begin
                  heapMem[NArea * localMem[0+210] + 0 + i] = heapMem[NArea * localMem[0+209] + localMem[144] + i];
                end
              end
              ip = 464;
      end

        464 :
      begin                                                                     // mov
              localMem[0 + 211] = heapMem[localMem[0+138]*10 + 5];
              ip = 465;
      end

        465 :
      begin                                                                     // mov
              localMem[0 + 212] = heapMem[localMem[0+196]*10 + 5];
              ip = 466;
      end

        466 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+143]) begin
                  heapMem[NArea * localMem[0+212] + 0 + i] = heapMem[NArea * localMem[0+211] + localMem[144] + i];
                end
              end
              ip = 467;
      end

        467 :
      begin                                                                     // mov
              localMem[0 + 213] = heapMem[localMem[0+138]*10 + 6];
              ip = 468;
      end

        468 :
      begin                                                                     // mov
              localMem[0 + 214] = heapMem[localMem[0+196]*10 + 6];
              ip = 469;
      end

        469 :
      begin                                                                     // add
              localMem[0 + 215] = localMem[0+143] + 1;
              ip = 470;
      end

        470 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+215]) begin
                  heapMem[NArea * localMem[0+214] + 0 + i] = heapMem[NArea * localMem[0+213] + localMem[144] + i];
                end
              end
              ip = 471;
      end

        471 :
      begin                                                                     // mov
              localMem[0 + 216] = heapMem[localMem[0+193]*10 + 0];
              ip = 472;
      end

        472 :
      begin                                                                     // add
              localMem[0 + 217] = localMem[0+216] + 1;
              ip = 473;
      end

        473 :
      begin                                                                     // mov
              localMem[0 + 218] = heapMem[localMem[0+193]*10 + 6];
              ip = 474;
      end

        474 :
      begin                                                                     // label
              ip = 475;
      end

        475 :
      begin                                                                     // mov
              localMem[0 + 219] = 0;
              ip = 476;
      end

        476 :
      begin                                                                     // label
              ip = 477;
      end

        477 :
      begin                                                                     // jGe
              ip = localMem[0+219] >= localMem[0+217] ? 483 : 478;
      end

        478 :
      begin                                                                     // mov
              localMem[0 + 220] = heapMem[localMem[0+218]*10 + localMem[0+219]];
              ip = 479;
      end

        479 :
      begin                                                                     // mov
              heapMem[localMem[0+220]*10 + 2] = localMem[0+193];
              ip = 480;
      end

        480 :
      begin                                                                     // label
              ip = 481;
      end

        481 :
      begin                                                                     // add
              localMem[0 + 219] = localMem[0+219] + 1;
              ip = 482;
      end

        482 :
      begin                                                                     // jmp
              ip = 476;
      end

        483 :
      begin                                                                     // label
              ip = 484;
      end

        484 :
      begin                                                                     // mov
              localMem[0 + 221] = heapMem[localMem[0+196]*10 + 0];
              ip = 485;
      end

        485 :
      begin                                                                     // add
              localMem[0 + 222] = localMem[0+221] + 1;
              ip = 486;
      end

        486 :
      begin                                                                     // mov
              localMem[0 + 223] = heapMem[localMem[0+196]*10 + 6];
              ip = 487;
      end

        487 :
      begin                                                                     // label
              ip = 488;
      end

        488 :
      begin                                                                     // mov
              localMem[0 + 224] = 0;
              ip = 489;
      end

        489 :
      begin                                                                     // label
              ip = 490;
      end

        490 :
      begin                                                                     // jGe
              ip = localMem[0+224] >= localMem[0+222] ? 496 : 491;
      end

        491 :
      begin                                                                     // mov
              localMem[0 + 225] = heapMem[localMem[0+223]*10 + localMem[0+224]];
              ip = 492;
      end

        492 :
      begin                                                                     // mov
              heapMem[localMem[0+225]*10 + 2] = localMem[0+196];
              ip = 493;
      end

        493 :
      begin                                                                     // label
              ip = 494;
      end

        494 :
      begin                                                                     // add
              localMem[0 + 224] = localMem[0+224] + 1;
              ip = 495;
      end

        495 :
      begin                                                                     // jmp
              ip = 489;
      end

        496 :
      begin                                                                     // label
              ip = 497;
      end

        497 :
      begin                                                                     // jmp
              ip = 513;
      end

        498 :
      begin                                                                     // label
              ip = 499;
      end

        499 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 226] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 226] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 226]] = 0;
              ip = 500;
      end

        500 :
      begin                                                                     // mov
              heapMem[localMem[0+138]*10 + 6] = localMem[0+226];
              ip = 501;
      end

        501 :
      begin                                                                     // mov
              localMem[0 + 227] = heapMem[localMem[0+138]*10 + 4];
              ip = 502;
      end

        502 :
      begin                                                                     // mov
              localMem[0 + 228] = heapMem[localMem[0+193]*10 + 4];
              ip = 503;
      end

        503 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+143]) begin
                  heapMem[NArea * localMem[0+228] + 0 + i] = heapMem[NArea * localMem[0+227] + 0 + i];
                end
              end
              ip = 504;
      end

        504 :
      begin                                                                     // mov
              localMem[0 + 229] = heapMem[localMem[0+138]*10 + 5];
              ip = 505;
      end

        505 :
      begin                                                                     // mov
              localMem[0 + 230] = heapMem[localMem[0+193]*10 + 5];
              ip = 506;
      end

        506 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+143]) begin
                  heapMem[NArea * localMem[0+230] + 0 + i] = heapMem[NArea * localMem[0+229] + 0 + i];
                end
              end
              ip = 507;
      end

        507 :
      begin                                                                     // mov
              localMem[0 + 231] = heapMem[localMem[0+138]*10 + 4];
              ip = 508;
      end

        508 :
      begin                                                                     // mov
              localMem[0 + 232] = heapMem[localMem[0+196]*10 + 4];
              ip = 509;
      end

        509 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+143]) begin
                  heapMem[NArea * localMem[0+232] + 0 + i] = heapMem[NArea * localMem[0+231] + localMem[144] + i];
                end
              end
              ip = 510;
      end

        510 :
      begin                                                                     // mov
              localMem[0 + 233] = heapMem[localMem[0+138]*10 + 5];
              ip = 511;
      end

        511 :
      begin                                                                     // mov
              localMem[0 + 234] = heapMem[localMem[0+196]*10 + 5];
              ip = 512;
      end

        512 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+143]) begin
                  heapMem[NArea * localMem[0+234] + 0 + i] = heapMem[NArea * localMem[0+233] + localMem[144] + i];
                end
              end
              ip = 513;
      end

        513 :
      begin                                                                     // label
              ip = 514;
      end

        514 :
      begin                                                                     // mov
              heapMem[localMem[0+193]*10 + 2] = localMem[0+138];
              ip = 515;
      end

        515 :
      begin                                                                     // mov
              heapMem[localMem[0+196]*10 + 2] = localMem[0+138];
              ip = 516;
      end

        516 :
      begin                                                                     // mov
              localMem[0 + 235] = heapMem[localMem[0+138]*10 + 4];
              ip = 517;
      end

        517 :
      begin                                                                     // mov
              localMem[0 + 236] = heapMem[localMem[0+235]*10 + localMem[0+143]];
              ip = 518;
      end

        518 :
      begin                                                                     // mov
              localMem[0 + 237] = heapMem[localMem[0+138]*10 + 5];
              ip = 519;
      end

        519 :
      begin                                                                     // mov
              localMem[0 + 238] = heapMem[localMem[0+237]*10 + localMem[0+143]];
              ip = 520;
      end

        520 :
      begin                                                                     // mov
              localMem[0 + 239] = heapMem[localMem[0+138]*10 + 4];
              ip = 521;
      end

        521 :
      begin                                                                     // mov
              heapMem[localMem[0+239]*10 + 0] = localMem[0+236];
              ip = 522;
      end

        522 :
      begin                                                                     // mov
              localMem[0 + 240] = heapMem[localMem[0+138]*10 + 5];
              ip = 523;
      end

        523 :
      begin                                                                     // mov
              heapMem[localMem[0+240]*10 + 0] = localMem[0+238];
              ip = 524;
      end

        524 :
      begin                                                                     // mov
              localMem[0 + 241] = heapMem[localMem[0+138]*10 + 6];
              ip = 525;
      end

        525 :
      begin                                                                     // mov
              heapMem[localMem[0+241]*10 + 0] = localMem[0+193];
              ip = 526;
      end

        526 :
      begin                                                                     // mov
              localMem[0 + 242] = heapMem[localMem[0+138]*10 + 6];
              ip = 527;
      end

        527 :
      begin                                                                     // mov
              heapMem[localMem[0+242]*10 + 1] = localMem[0+196];
              ip = 528;
      end

        528 :
      begin                                                                     // mov
              heapMem[localMem[0+138]*10 + 0] = 1;
              ip = 529;
      end

        529 :
      begin                                                                     // mov
              localMem[0 + 243] = heapMem[localMem[0+138]*10 + 4];
              ip = 530;
      end

        530 :
      begin                                                                     // resize
              arraySizes[localMem[0+243]] = 1;
              ip = 531;
      end

        531 :
      begin                                                                     // mov
              localMem[0 + 244] = heapMem[localMem[0+138]*10 + 5];
              ip = 532;
      end

        532 :
      begin                                                                     // resize
              arraySizes[localMem[0+244]] = 1;
              ip = 533;
      end

        533 :
      begin                                                                     // mov
              localMem[0 + 245] = heapMem[localMem[0+138]*10 + 6];
              ip = 534;
      end

        534 :
      begin                                                                     // resize
              arraySizes[localMem[0+245]] = 2;
              ip = 535;
      end

        535 :
      begin                                                                     // jmp
              ip = 537;
      end

        536 :
      begin                                                                     // jmp
              ip = 542;
      end

        537 :
      begin                                                                     // label
              ip = 538;
      end

        538 :
      begin                                                                     // mov
              localMem[0 + 139] = 1;
              ip = 539;
      end

        539 :
      begin                                                                     // jmp
              ip = 542;
      end

        540 :
      begin                                                                     // label
              ip = 541;
      end

        541 :
      begin                                                                     // mov
              localMem[0 + 139] = 0;
              ip = 542;
      end

        542 :
      begin                                                                     // label
              ip = 543;
      end

        543 :
      begin                                                                     // jNe
              ip = localMem[0+139] != 0 ? 545 : 544;
      end

        544 :
      begin                                                                     // mov
              localMem[0 + 23] = localMem[0+138];
              ip = 545;
      end

        545 :
      begin                                                                     // label
              ip = 546;
      end

        546 :
      begin                                                                     // jmp
              ip = 796;
      end

        547 :
      begin                                                                     // label
              ip = 548;
      end

        548 :
      begin                                                                     // mov
              localMem[0 + 246] = heapMem[localMem[0+23]*10 + 4];
              ip = 549;
      end

        549 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+246] * NArea + i] == localMem[0+1]) localMem[0 + 247] = i + 1;
              end
              ip = 550;
      end

        550 :
      begin                                                                     // jEq
              ip = localMem[0+247] == 0 ? 555 : 551;
      end

        551 :
      begin                                                                     // mov
              heapMem[localMem[0+3]*10 + 0] = localMem[0+23];
              ip = 552;
      end

        552 :
      begin                                                                     // mov
              heapMem[localMem[0+3]*10 + 1] = 1;
              ip = 553;
      end

        553 :
      begin                                                                     // subtract
              heapMem[localMem[0+3]*10 + 2] = localMem[0+247] - 1;
              ip = 554;
      end

        554 :
      begin                                                                     // jmp
              ip = 803;
      end

        555 :
      begin                                                                     // label
              ip = 556;
      end

        556 :
      begin                                                                     // arrayCountLess
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+246] * NArea + i] < localMem[0+1]) j = j + 1;
              end
              localMem[0 + 248] = j;
              ip = 557;
      end

        557 :
      begin                                                                     // not
              localMem[0 + 249] = !heapMem[localMem[0+23]*10 + 6];
              ip = 558;
      end

        558 :
      begin                                                                     // jEq
              ip = localMem[0+249] == 0 ? 563 : 559;
      end

        559 :
      begin                                                                     // mov
              heapMem[localMem[0+3]*10 + 0] = localMem[0+23];
              ip = 560;
      end

        560 :
      begin                                                                     // mov
              heapMem[localMem[0+3]*10 + 1] = 0;
              ip = 561;
      end

        561 :
      begin                                                                     // mov
              heapMem[localMem[0+3]*10 + 2] = localMem[0+248];
              ip = 562;
      end

        562 :
      begin                                                                     // jmp
              ip = 803;
      end

        563 :
      begin                                                                     // label
              ip = 564;
      end

        564 :
      begin                                                                     // mov
              localMem[0 + 250] = heapMem[localMem[0+23]*10 + 6];
              ip = 565;
      end

        565 :
      begin                                                                     // mov
              localMem[0 + 251] = heapMem[localMem[0+250]*10 + localMem[0+248]];
              ip = 566;
      end

        566 :
      begin                                                                     // label
              ip = 567;
      end

        567 :
      begin                                                                     // mov
              localMem[0 + 253] = heapMem[localMem[0+251]*10 + 0];
              ip = 568;
      end

        568 :
      begin                                                                     // mov
              localMem[0 + 254] = heapMem[localMem[0+251]*10 + 3];
              ip = 569;
      end

        569 :
      begin                                                                     // mov
              localMem[0 + 255] = heapMem[localMem[0+254]*10 + 2];
              ip = 570;
      end

        570 :
      begin                                                                     // jLt
              ip = localMem[0+253] <  localMem[0+255] ? 790 : 571;
      end

        571 :
      begin                                                                     // mov
              localMem[0 + 256] = localMem[0+255];
              ip = 572;
      end

        572 :
      begin                                                                     // shiftRight
              localMem[0 + 256] = localMem[0+256] >> 1;
              ip = 573;
      end

        573 :
      begin                                                                     // add
              localMem[0 + 257] = localMem[0+256] + 1;
              ip = 574;
      end

        574 :
      begin                                                                     // mov
              localMem[0 + 258] = heapMem[localMem[0+251]*10 + 2];
              ip = 575;
      end

        575 :
      begin                                                                     // jEq
              ip = localMem[0+258] == 0 ? 672 : 576;
      end

        576 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 259] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 259] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 259]] = 0;
              ip = 577;
      end

        577 :
      begin                                                                     // mov
              heapMem[localMem[0+259]*10 + 0] = localMem[0+256];
              ip = 578;
      end

        578 :
      begin                                                                     // mov
              heapMem[localMem[0+259]*10 + 2] = 0;
              ip = 579;
      end

        579 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 260] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 260] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 260]] = 0;
              ip = 580;
      end

        580 :
      begin                                                                     // mov
              heapMem[localMem[0+259]*10 + 4] = localMem[0+260];
              ip = 581;
      end

        581 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 261] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 261] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 261]] = 0;
              ip = 582;
      end

        582 :
      begin                                                                     // mov
              heapMem[localMem[0+259]*10 + 5] = localMem[0+261];
              ip = 583;
      end

        583 :
      begin                                                                     // mov
              heapMem[localMem[0+259]*10 + 6] = 0;
              ip = 584;
      end

        584 :
      begin                                                                     // mov
              heapMem[localMem[0+259]*10 + 3] = localMem[0+254];
              ip = 585;
      end

        585 :
      begin                                                                     // add
              heapMem[localMem[0+254]*10 + 1] = heapMem[localMem[0+254]*10 + 1] + 1;
              ip = 586;
      end

        586 :
      begin                                                                     // mov
              heapMem[localMem[0+259]*10 + 1] = heapMem[localMem[0+254]*10 + 1];
              ip = 587;
      end

        587 :
      begin                                                                     // not
              localMem[0 + 262] = !heapMem[localMem[0+251]*10 + 6];
              ip = 588;
      end

        588 :
      begin                                                                     // jNe
              ip = localMem[0+262] != 0 ? 617 : 589;
      end

        589 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 263] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 263] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 263]] = 0;
              ip = 590;
      end

        590 :
      begin                                                                     // mov
              heapMem[localMem[0+259]*10 + 6] = localMem[0+263];
              ip = 591;
      end

        591 :
      begin                                                                     // mov
              localMem[0 + 264] = heapMem[localMem[0+251]*10 + 4];
              ip = 592;
      end

        592 :
      begin                                                                     // mov
              localMem[0 + 265] = heapMem[localMem[0+259]*10 + 4];
              ip = 593;
      end

        593 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+256]) begin
                  heapMem[NArea * localMem[0+265] + 0 + i] = heapMem[NArea * localMem[0+264] + localMem[257] + i];
                end
              end
              ip = 594;
      end

        594 :
      begin                                                                     // mov
              localMem[0 + 266] = heapMem[localMem[0+251]*10 + 5];
              ip = 595;
      end

        595 :
      begin                                                                     // mov
              localMem[0 + 267] = heapMem[localMem[0+259]*10 + 5];
              ip = 596;
      end

        596 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+256]) begin
                  heapMem[NArea * localMem[0+267] + 0 + i] = heapMem[NArea * localMem[0+266] + localMem[257] + i];
                end
              end
              ip = 597;
      end

        597 :
      begin                                                                     // mov
              localMem[0 + 268] = heapMem[localMem[0+251]*10 + 6];
              ip = 598;
      end

        598 :
      begin                                                                     // mov
              localMem[0 + 269] = heapMem[localMem[0+259]*10 + 6];
              ip = 599;
      end

        599 :
      begin                                                                     // add
              localMem[0 + 270] = localMem[0+256] + 1;
              ip = 600;
      end

        600 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+270]) begin
                  heapMem[NArea * localMem[0+269] + 0 + i] = heapMem[NArea * localMem[0+268] + localMem[257] + i];
                end
              end
              ip = 601;
      end

        601 :
      begin                                                                     // mov
              localMem[0 + 271] = heapMem[localMem[0+259]*10 + 0];
              ip = 602;
      end

        602 :
      begin                                                                     // add
              localMem[0 + 272] = localMem[0+271] + 1;
              ip = 603;
      end

        603 :
      begin                                                                     // mov
              localMem[0 + 273] = heapMem[localMem[0+259]*10 + 6];
              ip = 604;
      end

        604 :
      begin                                                                     // label
              ip = 605;
      end

        605 :
      begin                                                                     // mov
              localMem[0 + 274] = 0;
              ip = 606;
      end

        606 :
      begin                                                                     // label
              ip = 607;
      end

        607 :
      begin                                                                     // jGe
              ip = localMem[0+274] >= localMem[0+272] ? 613 : 608;
      end

        608 :
      begin                                                                     // mov
              localMem[0 + 275] = heapMem[localMem[0+273]*10 + localMem[0+274]];
              ip = 609;
      end

        609 :
      begin                                                                     // mov
              heapMem[localMem[0+275]*10 + 2] = localMem[0+259];
              ip = 610;
      end

        610 :
      begin                                                                     // label
              ip = 611;
      end

        611 :
      begin                                                                     // add
              localMem[0 + 274] = localMem[0+274] + 1;
              ip = 612;
      end

        612 :
      begin                                                                     // jmp
              ip = 606;
      end

        613 :
      begin                                                                     // label
              ip = 614;
      end

        614 :
      begin                                                                     // mov
              localMem[0 + 276] = heapMem[localMem[0+251]*10 + 6];
              ip = 615;
      end

        615 :
      begin                                                                     // resize
              arraySizes[localMem[0+276]] = localMem[0+257];
              ip = 616;
      end

        616 :
      begin                                                                     // jmp
              ip = 624;
      end

        617 :
      begin                                                                     // label
              ip = 618;
      end

        618 :
      begin                                                                     // mov
              localMem[0 + 277] = heapMem[localMem[0+251]*10 + 4];
              ip = 619;
      end

        619 :
      begin                                                                     // mov
              localMem[0 + 278] = heapMem[localMem[0+259]*10 + 4];
              ip = 620;
      end

        620 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+256]) begin
                  heapMem[NArea * localMem[0+278] + 0 + i] = heapMem[NArea * localMem[0+277] + localMem[257] + i];
                end
              end
              ip = 621;
      end

        621 :
      begin                                                                     // mov
              localMem[0 + 279] = heapMem[localMem[0+251]*10 + 5];
              ip = 622;
      end

        622 :
      begin                                                                     // mov
              localMem[0 + 280] = heapMem[localMem[0+259]*10 + 5];
              ip = 623;
      end

        623 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+256]) begin
                  heapMem[NArea * localMem[0+280] + 0 + i] = heapMem[NArea * localMem[0+279] + localMem[257] + i];
                end
              end
              ip = 624;
      end

        624 :
      begin                                                                     // label
              ip = 625;
      end

        625 :
      begin                                                                     // mov
              heapMem[localMem[0+251]*10 + 0] = localMem[0+256];
              ip = 626;
      end

        626 :
      begin                                                                     // mov
              heapMem[localMem[0+259]*10 + 2] = localMem[0+258];
              ip = 627;
      end

        627 :
      begin                                                                     // mov
              localMem[0 + 281] = heapMem[localMem[0+258]*10 + 0];
              ip = 628;
      end

        628 :
      begin                                                                     // mov
              localMem[0 + 282] = heapMem[localMem[0+258]*10 + 6];
              ip = 629;
      end

        629 :
      begin                                                                     // mov
              localMem[0 + 283] = heapMem[localMem[0+282]*10 + localMem[0+281]];
              ip = 630;
      end

        630 :
      begin                                                                     // jNe
              ip = localMem[0+283] != localMem[0+251] ? 649 : 631;
      end

        631 :
      begin                                                                     // mov
              localMem[0 + 284] = heapMem[localMem[0+251]*10 + 4];
              ip = 632;
      end

        632 :
      begin                                                                     // mov
              localMem[0 + 285] = heapMem[localMem[0+284]*10 + localMem[0+256]];
              ip = 633;
      end

        633 :
      begin                                                                     // mov
              localMem[0 + 286] = heapMem[localMem[0+258]*10 + 4];
              ip = 634;
      end

        634 :
      begin                                                                     // mov
              heapMem[localMem[0+286]*10 + localMem[0+281]] = localMem[0+285];
              ip = 635;
      end

        635 :
      begin                                                                     // mov
              localMem[0 + 287] = heapMem[localMem[0+251]*10 + 5];
              ip = 636;
      end

        636 :
      begin                                                                     // mov
              localMem[0 + 288] = heapMem[localMem[0+287]*10 + localMem[0+256]];
              ip = 637;
      end

        637 :
      begin                                                                     // mov
              localMem[0 + 289] = heapMem[localMem[0+258]*10 + 5];
              ip = 638;
      end

        638 :
      begin                                                                     // mov
              heapMem[localMem[0+289]*10 + localMem[0+281]] = localMem[0+288];
              ip = 639;
      end

        639 :
      begin                                                                     // mov
              localMem[0 + 290] = heapMem[localMem[0+251]*10 + 4];
              ip = 640;
      end

        640 :
      begin                                                                     // resize
              arraySizes[localMem[0+290]] = localMem[0+256];
              ip = 641;
      end

        641 :
      begin                                                                     // mov
              localMem[0 + 291] = heapMem[localMem[0+251]*10 + 5];
              ip = 642;
      end

        642 :
      begin                                                                     // resize
              arraySizes[localMem[0+291]] = localMem[0+256];
              ip = 643;
      end

        643 :
      begin                                                                     // add
              localMem[0 + 292] = localMem[0+281] + 1;
              ip = 644;
      end

        644 :
      begin                                                                     // mov
              heapMem[localMem[0+258]*10 + 0] = localMem[0+292];
              ip = 645;
      end

        645 :
      begin                                                                     // mov
              localMem[0 + 293] = heapMem[localMem[0+258]*10 + 6];
              ip = 646;
      end

        646 :
      begin                                                                     // mov
              heapMem[localMem[0+293]*10 + localMem[0+292]] = localMem[0+259];
              ip = 647;
      end

        647 :
      begin                                                                     // jmp
              ip = 787;
      end

        648 :
      begin                                                                     // jmp
              ip = 671;
      end

        649 :
      begin                                                                     // label
              ip = 650;
      end

        650 :
      begin                                                                     // assertNe
            ip = 651;
      end

        651 :
      begin                                                                     // mov
              localMem[0 + 294] = heapMem[localMem[0+258]*10 + 6];
              ip = 652;
      end

        652 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+294] * NArea + i] == localMem[0+251]) localMem[0 + 295] = i + 1;
              end
              ip = 653;
      end

        653 :
      begin                                                                     // subtract
              localMem[0 + 295] = localMem[0+295] - 1;
              ip = 654;
      end

        654 :
      begin                                                                     // mov
              localMem[0 + 296] = heapMem[localMem[0+251]*10 + 4];
              ip = 655;
      end

        655 :
      begin                                                                     // mov
              localMem[0 + 297] = heapMem[localMem[0+296]*10 + localMem[0+256]];
              ip = 656;
      end

        656 :
      begin                                                                     // mov
              localMem[0 + 298] = heapMem[localMem[0+251]*10 + 5];
              ip = 657;
      end

        657 :
      begin                                                                     // mov
              localMem[0 + 299] = heapMem[localMem[0+298]*10 + localMem[0+256]];
              ip = 658;
      end

        658 :
      begin                                                                     // mov
              localMem[0 + 300] = heapMem[localMem[0+251]*10 + 4];
              ip = 659;
      end

        659 :
      begin                                                                     // resize
              arraySizes[localMem[0+300]] = localMem[0+256];
              ip = 660;
      end

        660 :
      begin                                                                     // mov
              localMem[0 + 301] = heapMem[localMem[0+251]*10 + 5];
              ip = 661;
      end

        661 :
      begin                                                                     // resize
              arraySizes[localMem[0+301]] = localMem[0+256];
              ip = 662;
      end

        662 :
      begin                                                                     // mov
              localMem[0 + 302] = heapMem[localMem[0+258]*10 + 4];
              ip = 663;
      end

        663 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+302] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[295]) begin
                  heapMem[NArea * localMem[0+302] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+302] + localMem[295]] = localMem[0+297];                                    // Insert new value
              arraySizes[localMem[0+302]] = arraySizes[localMem[0+302]] + 1;                              // Increase array size
              ip = 664;
      end

        664 :
      begin                                                                     // mov
              localMem[0 + 303] = heapMem[localMem[0+258]*10 + 5];
              ip = 665;
      end

        665 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+303] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[295]) begin
                  heapMem[NArea * localMem[0+303] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+303] + localMem[295]] = localMem[0+299];                                    // Insert new value
              arraySizes[localMem[0+303]] = arraySizes[localMem[0+303]] + 1;                              // Increase array size
              ip = 666;
      end

        666 :
      begin                                                                     // mov
              localMem[0 + 304] = heapMem[localMem[0+258]*10 + 6];
              ip = 667;
      end

        667 :
      begin                                                                     // add
              localMem[0 + 305] = localMem[0+295] + 1;
              ip = 668;
      end

        668 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+304] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[305]) begin
                  heapMem[NArea * localMem[0+304] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+304] + localMem[305]] = localMem[0+259];                                    // Insert new value
              arraySizes[localMem[0+304]] = arraySizes[localMem[0+304]] + 1;                              // Increase array size
              ip = 669;
      end

        669 :
      begin                                                                     // add
              heapMem[localMem[0+258]*10 + 0] = heapMem[localMem[0+258]*10 + 0] + 1;
              ip = 670;
      end

        670 :
      begin                                                                     // jmp
              ip = 787;
      end

        671 :
      begin                                                                     // label
              ip = 672;
      end

        672 :
      begin                                                                     // label
              ip = 673;
      end

        673 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 306] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 306] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 306]] = 0;
              ip = 674;
      end

        674 :
      begin                                                                     // mov
              heapMem[localMem[0+306]*10 + 0] = localMem[0+256];
              ip = 675;
      end

        675 :
      begin                                                                     // mov
              heapMem[localMem[0+306]*10 + 2] = 0;
              ip = 676;
      end

        676 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 307] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 307] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 307]] = 0;
              ip = 677;
      end

        677 :
      begin                                                                     // mov
              heapMem[localMem[0+306]*10 + 4] = localMem[0+307];
              ip = 678;
      end

        678 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 308] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 308] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 308]] = 0;
              ip = 679;
      end

        679 :
      begin                                                                     // mov
              heapMem[localMem[0+306]*10 + 5] = localMem[0+308];
              ip = 680;
      end

        680 :
      begin                                                                     // mov
              heapMem[localMem[0+306]*10 + 6] = 0;
              ip = 681;
      end

        681 :
      begin                                                                     // mov
              heapMem[localMem[0+306]*10 + 3] = localMem[0+254];
              ip = 682;
      end

        682 :
      begin                                                                     // add
              heapMem[localMem[0+254]*10 + 1] = heapMem[localMem[0+254]*10 + 1] + 1;
              ip = 683;
      end

        683 :
      begin                                                                     // mov
              heapMem[localMem[0+306]*10 + 1] = heapMem[localMem[0+254]*10 + 1];
              ip = 684;
      end

        684 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 309] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 309] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 309]] = 0;
              ip = 685;
      end

        685 :
      begin                                                                     // mov
              heapMem[localMem[0+309]*10 + 0] = localMem[0+256];
              ip = 686;
      end

        686 :
      begin                                                                     // mov
              heapMem[localMem[0+309]*10 + 2] = 0;
              ip = 687;
      end

        687 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 310] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 310] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 310]] = 0;
              ip = 688;
      end

        688 :
      begin                                                                     // mov
              heapMem[localMem[0+309]*10 + 4] = localMem[0+310];
              ip = 689;
      end

        689 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 311] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 311] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 311]] = 0;
              ip = 690;
      end

        690 :
      begin                                                                     // mov
              heapMem[localMem[0+309]*10 + 5] = localMem[0+311];
              ip = 691;
      end

        691 :
      begin                                                                     // mov
              heapMem[localMem[0+309]*10 + 6] = 0;
              ip = 692;
      end

        692 :
      begin                                                                     // mov
              heapMem[localMem[0+309]*10 + 3] = localMem[0+254];
              ip = 693;
      end

        693 :
      begin                                                                     // add
              heapMem[localMem[0+254]*10 + 1] = heapMem[localMem[0+254]*10 + 1] + 1;
              ip = 694;
      end

        694 :
      begin                                                                     // mov
              heapMem[localMem[0+309]*10 + 1] = heapMem[localMem[0+254]*10 + 1];
              ip = 695;
      end

        695 :
      begin                                                                     // not
              localMem[0 + 312] = !heapMem[localMem[0+251]*10 + 6];
              ip = 696;
      end

        696 :
      begin                                                                     // jNe
              ip = localMem[0+312] != 0 ? 748 : 697;
      end

        697 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 313] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 313] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 313]] = 0;
              ip = 698;
      end

        698 :
      begin                                                                     // mov
              heapMem[localMem[0+306]*10 + 6] = localMem[0+313];
              ip = 699;
      end

        699 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 314] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 314] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 314]] = 0;
              ip = 700;
      end

        700 :
      begin                                                                     // mov
              heapMem[localMem[0+309]*10 + 6] = localMem[0+314];
              ip = 701;
      end

        701 :
      begin                                                                     // mov
              localMem[0 + 315] = heapMem[localMem[0+251]*10 + 4];
              ip = 702;
      end

        702 :
      begin                                                                     // mov
              localMem[0 + 316] = heapMem[localMem[0+306]*10 + 4];
              ip = 703;
      end

        703 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+256]) begin
                  heapMem[NArea * localMem[0+316] + 0 + i] = heapMem[NArea * localMem[0+315] + 0 + i];
                end
              end
              ip = 704;
      end

        704 :
      begin                                                                     // mov
              localMem[0 + 317] = heapMem[localMem[0+251]*10 + 5];
              ip = 705;
      end

        705 :
      begin                                                                     // mov
              localMem[0 + 318] = heapMem[localMem[0+306]*10 + 5];
              ip = 706;
      end

        706 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+256]) begin
                  heapMem[NArea * localMem[0+318] + 0 + i] = heapMem[NArea * localMem[0+317] + 0 + i];
                end
              end
              ip = 707;
      end

        707 :
      begin                                                                     // mov
              localMem[0 + 319] = heapMem[localMem[0+251]*10 + 6];
              ip = 708;
      end

        708 :
      begin                                                                     // mov
              localMem[0 + 320] = heapMem[localMem[0+306]*10 + 6];
              ip = 709;
      end

        709 :
      begin                                                                     // add
              localMem[0 + 321] = localMem[0+256] + 1;
              ip = 710;
      end

        710 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+321]) begin
                  heapMem[NArea * localMem[0+320] + 0 + i] = heapMem[NArea * localMem[0+319] + 0 + i];
                end
              end
              ip = 711;
      end

        711 :
      begin                                                                     // mov
              localMem[0 + 322] = heapMem[localMem[0+251]*10 + 4];
              ip = 712;
      end

        712 :
      begin                                                                     // mov
              localMem[0 + 323] = heapMem[localMem[0+309]*10 + 4];
              ip = 713;
      end

        713 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+256]) begin
                  heapMem[NArea * localMem[0+323] + 0 + i] = heapMem[NArea * localMem[0+322] + localMem[257] + i];
                end
              end
              ip = 714;
      end

        714 :
      begin                                                                     // mov
              localMem[0 + 324] = heapMem[localMem[0+251]*10 + 5];
              ip = 715;
      end

        715 :
      begin                                                                     // mov
              localMem[0 + 325] = heapMem[localMem[0+309]*10 + 5];
              ip = 716;
      end

        716 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+256]) begin
                  heapMem[NArea * localMem[0+325] + 0 + i] = heapMem[NArea * localMem[0+324] + localMem[257] + i];
                end
              end
              ip = 717;
      end

        717 :
      begin                                                                     // mov
              localMem[0 + 326] = heapMem[localMem[0+251]*10 + 6];
              ip = 718;
      end

        718 :
      begin                                                                     // mov
              localMem[0 + 327] = heapMem[localMem[0+309]*10 + 6];
              ip = 719;
      end

        719 :
      begin                                                                     // add
              localMem[0 + 328] = localMem[0+256] + 1;
              ip = 720;
      end

        720 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+328]) begin
                  heapMem[NArea * localMem[0+327] + 0 + i] = heapMem[NArea * localMem[0+326] + localMem[257] + i];
                end
              end
              ip = 721;
      end

        721 :
      begin                                                                     // mov
              localMem[0 + 329] = heapMem[localMem[0+306]*10 + 0];
              ip = 722;
      end

        722 :
      begin                                                                     // add
              localMem[0 + 330] = localMem[0+329] + 1;
              ip = 723;
      end

        723 :
      begin                                                                     // mov
              localMem[0 + 331] = heapMem[localMem[0+306]*10 + 6];
              ip = 724;
      end

        724 :
      begin                                                                     // label
              ip = 725;
      end

        725 :
      begin                                                                     // mov
              localMem[0 + 332] = 0;
              ip = 726;
      end

        726 :
      begin                                                                     // label
              ip = 727;
      end

        727 :
      begin                                                                     // jGe
              ip = localMem[0+332] >= localMem[0+330] ? 733 : 728;
      end

        728 :
      begin                                                                     // mov
              localMem[0 + 333] = heapMem[localMem[0+331]*10 + localMem[0+332]];
              ip = 729;
      end

        729 :
      begin                                                                     // mov
              heapMem[localMem[0+333]*10 + 2] = localMem[0+306];
              ip = 730;
      end

        730 :
      begin                                                                     // label
              ip = 731;
      end

        731 :
      begin                                                                     // add
              localMem[0 + 332] = localMem[0+332] + 1;
              ip = 732;
      end

        732 :
      begin                                                                     // jmp
              ip = 726;
      end

        733 :
      begin                                                                     // label
              ip = 734;
      end

        734 :
      begin                                                                     // mov
              localMem[0 + 334] = heapMem[localMem[0+309]*10 + 0];
              ip = 735;
      end

        735 :
      begin                                                                     // add
              localMem[0 + 335] = localMem[0+334] + 1;
              ip = 736;
      end

        736 :
      begin                                                                     // mov
              localMem[0 + 336] = heapMem[localMem[0+309]*10 + 6];
              ip = 737;
      end

        737 :
      begin                                                                     // label
              ip = 738;
      end

        738 :
      begin                                                                     // mov
              localMem[0 + 337] = 0;
              ip = 739;
      end

        739 :
      begin                                                                     // label
              ip = 740;
      end

        740 :
      begin                                                                     // jGe
              ip = localMem[0+337] >= localMem[0+335] ? 746 : 741;
      end

        741 :
      begin                                                                     // mov
              localMem[0 + 338] = heapMem[localMem[0+336]*10 + localMem[0+337]];
              ip = 742;
      end

        742 :
      begin                                                                     // mov
              heapMem[localMem[0+338]*10 + 2] = localMem[0+309];
              ip = 743;
      end

        743 :
      begin                                                                     // label
              ip = 744;
      end

        744 :
      begin                                                                     // add
              localMem[0 + 337] = localMem[0+337] + 1;
              ip = 745;
      end

        745 :
      begin                                                                     // jmp
              ip = 739;
      end

        746 :
      begin                                                                     // label
              ip = 747;
      end

        747 :
      begin                                                                     // jmp
              ip = 763;
      end

        748 :
      begin                                                                     // label
              ip = 749;
      end

        749 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 339] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 339] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 339]] = 0;
              ip = 750;
      end

        750 :
      begin                                                                     // mov
              heapMem[localMem[0+251]*10 + 6] = localMem[0+339];
              ip = 751;
      end

        751 :
      begin                                                                     // mov
              localMem[0 + 340] = heapMem[localMem[0+251]*10 + 4];
              ip = 752;
      end

        752 :
      begin                                                                     // mov
              localMem[0 + 341] = heapMem[localMem[0+306]*10 + 4];
              ip = 753;
      end

        753 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+256]) begin
                  heapMem[NArea * localMem[0+341] + 0 + i] = heapMem[NArea * localMem[0+340] + 0 + i];
                end
              end
              ip = 754;
      end

        754 :
      begin                                                                     // mov
              localMem[0 + 342] = heapMem[localMem[0+251]*10 + 5];
              ip = 755;
      end

        755 :
      begin                                                                     // mov
              localMem[0 + 343] = heapMem[localMem[0+306]*10 + 5];
              ip = 756;
      end

        756 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+256]) begin
                  heapMem[NArea * localMem[0+343] + 0 + i] = heapMem[NArea * localMem[0+342] + 0 + i];
                end
              end
              ip = 757;
      end

        757 :
      begin                                                                     // mov
              localMem[0 + 344] = heapMem[localMem[0+251]*10 + 4];
              ip = 758;
      end

        758 :
      begin                                                                     // mov
              localMem[0 + 345] = heapMem[localMem[0+309]*10 + 4];
              ip = 759;
      end

        759 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+256]) begin
                  heapMem[NArea * localMem[0+345] + 0 + i] = heapMem[NArea * localMem[0+344] + localMem[257] + i];
                end
              end
              ip = 760;
      end

        760 :
      begin                                                                     // mov
              localMem[0 + 346] = heapMem[localMem[0+251]*10 + 5];
              ip = 761;
      end

        761 :
      begin                                                                     // mov
              localMem[0 + 347] = heapMem[localMem[0+309]*10 + 5];
              ip = 762;
      end

        762 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+256]) begin
                  heapMem[NArea * localMem[0+347] + 0 + i] = heapMem[NArea * localMem[0+346] + localMem[257] + i];
                end
              end
              ip = 763;
      end

        763 :
      begin                                                                     // label
              ip = 764;
      end

        764 :
      begin                                                                     // mov
              heapMem[localMem[0+306]*10 + 2] = localMem[0+251];
              ip = 765;
      end

        765 :
      begin                                                                     // mov
              heapMem[localMem[0+309]*10 + 2] = localMem[0+251];
              ip = 766;
      end

        766 :
      begin                                                                     // mov
              localMem[0 + 348] = heapMem[localMem[0+251]*10 + 4];
              ip = 767;
      end

        767 :
      begin                                                                     // mov
              localMem[0 + 349] = heapMem[localMem[0+348]*10 + localMem[0+256]];
              ip = 768;
      end

        768 :
      begin                                                                     // mov
              localMem[0 + 350] = heapMem[localMem[0+251]*10 + 5];
              ip = 769;
      end

        769 :
      begin                                                                     // mov
              localMem[0 + 351] = heapMem[localMem[0+350]*10 + localMem[0+256]];
              ip = 770;
      end

        770 :
      begin                                                                     // mov
              localMem[0 + 352] = heapMem[localMem[0+251]*10 + 4];
              ip = 771;
      end

        771 :
      begin                                                                     // mov
              heapMem[localMem[0+352]*10 + 0] = localMem[0+349];
              ip = 772;
      end

        772 :
      begin                                                                     // mov
              localMem[0 + 353] = heapMem[localMem[0+251]*10 + 5];
              ip = 773;
      end

        773 :
      begin                                                                     // mov
              heapMem[localMem[0+353]*10 + 0] = localMem[0+351];
              ip = 774;
      end

        774 :
      begin                                                                     // mov
              localMem[0 + 354] = heapMem[localMem[0+251]*10 + 6];
              ip = 775;
      end

        775 :
      begin                                                                     // mov
              heapMem[localMem[0+354]*10 + 0] = localMem[0+306];
              ip = 776;
      end

        776 :
      begin                                                                     // mov
              localMem[0 + 355] = heapMem[localMem[0+251]*10 + 6];
              ip = 777;
      end

        777 :
      begin                                                                     // mov
              heapMem[localMem[0+355]*10 + 1] = localMem[0+309];
              ip = 778;
      end

        778 :
      begin                                                                     // mov
              heapMem[localMem[0+251]*10 + 0] = 1;
              ip = 779;
      end

        779 :
      begin                                                                     // mov
              localMem[0 + 356] = heapMem[localMem[0+251]*10 + 4];
              ip = 780;
      end

        780 :
      begin                                                                     // resize
              arraySizes[localMem[0+356]] = 1;
              ip = 781;
      end

        781 :
      begin                                                                     // mov
              localMem[0 + 357] = heapMem[localMem[0+251]*10 + 5];
              ip = 782;
      end

        782 :
      begin                                                                     // resize
              arraySizes[localMem[0+357]] = 1;
              ip = 783;
      end

        783 :
      begin                                                                     // mov
              localMem[0 + 358] = heapMem[localMem[0+251]*10 + 6];
              ip = 784;
      end

        784 :
      begin                                                                     // resize
              arraySizes[localMem[0+358]] = 2;
              ip = 785;
      end

        785 :
      begin                                                                     // jmp
              ip = 787;
      end

        786 :
      begin                                                                     // jmp
              ip = 792;
      end

        787 :
      begin                                                                     // label
              ip = 788;
      end

        788 :
      begin                                                                     // mov
              localMem[0 + 252] = 1;
              ip = 789;
      end

        789 :
      begin                                                                     // jmp
              ip = 792;
      end

        790 :
      begin                                                                     // label
              ip = 791;
      end

        791 :
      begin                                                                     // mov
              localMem[0 + 252] = 0;
              ip = 792;
      end

        792 :
      begin                                                                     // label
              ip = 793;
      end

        793 :
      begin                                                                     // jNe
              ip = localMem[0+252] != 0 ? 795 : 794;
      end

        794 :
      begin                                                                     // mov
              localMem[0 + 23] = localMem[0+251];
              ip = 795;
      end

        795 :
      begin                                                                     // label
              ip = 796;
      end

        796 :
      begin                                                                     // label
              ip = 797;
      end

        797 :
      begin                                                                     // add
              localMem[0 + 131] = localMem[0+131] + 1;
              ip = 798;
      end

        798 :
      begin                                                                     // jmp
              ip = 300;
      end

        799 :
      begin                                                                     // label
              ip = 800;
      end

        800 :
      begin                                                                     // assert
            ip = 801;
      end

        801 :
      begin                                                                     // label
              ip = 802;
      end

        802 :
      begin                                                                     // label
              ip = 803;
      end

        803 :
      begin                                                                     // label
              ip = 804;
      end

        804 :
      begin                                                                     // mov
              localMem[0 + 359] = heapMem[localMem[0+3]*10 + 0];
              ip = 805;
      end

        805 :
      begin                                                                     // mov
              localMem[0 + 360] = heapMem[localMem[0+3]*10 + 1];
              ip = 806;
      end

        806 :
      begin                                                                     // mov
              localMem[0 + 361] = heapMem[localMem[0+3]*10 + 2];
              ip = 807;
      end

        807 :
      begin                                                                     // jNe
              ip = localMem[0+360] != 1 ? 811 : 808;
      end

        808 :
      begin                                                                     // mov
              localMem[0 + 362] = heapMem[localMem[0+359]*10 + 5];
              ip = 809;
      end

        809 :
      begin                                                                     // mov
              heapMem[localMem[0+362]*10 + localMem[0+361]] = localMem[0+1];
              ip = 810;
      end

        810 :
      begin                                                                     // jmp
              ip = 1057;
      end

        811 :
      begin                                                                     // label
              ip = 812;
      end

        812 :
      begin                                                                     // jNe
              ip = localMem[0+360] != 2 ? 820 : 813;
      end

        813 :
      begin                                                                     // add
              localMem[0 + 363] = localMem[0+361] + 1;
              ip = 814;
      end

        814 :
      begin                                                                     // mov
              localMem[0 + 364] = heapMem[localMem[0+359]*10 + 4];
              ip = 815;
      end

        815 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+364] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[363]) begin
                  heapMem[NArea * localMem[0+364] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+364] + localMem[363]] = localMem[0+1];                                    // Insert new value
              arraySizes[localMem[0+364]] = arraySizes[localMem[0+364]] + 1;                              // Increase array size
              ip = 816;
      end

        816 :
      begin                                                                     // mov
              localMem[0 + 365] = heapMem[localMem[0+359]*10 + 5];
              ip = 817;
      end

        817 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+365] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[363]) begin
                  heapMem[NArea * localMem[0+365] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+365] + localMem[363]] = localMem[0+1];                                    // Insert new value
              arraySizes[localMem[0+365]] = arraySizes[localMem[0+365]] + 1;                              // Increase array size
              ip = 818;
      end

        818 :
      begin                                                                     // add
              heapMem[localMem[0+359]*10 + 0] = heapMem[localMem[0+359]*10 + 0] + 1;
              ip = 819;
      end

        819 :
      begin                                                                     // jmp
              ip = 826;
      end

        820 :
      begin                                                                     // label
              ip = 821;
      end

        821 :
      begin                                                                     // mov
              localMem[0 + 366] = heapMem[localMem[0+359]*10 + 4];
              ip = 822;
      end

        822 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+366] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[361]) begin
                  heapMem[NArea * localMem[0+366] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+366] + localMem[361]] = localMem[0+1];                                    // Insert new value
              arraySizes[localMem[0+366]] = arraySizes[localMem[0+366]] + 1;                              // Increase array size
              ip = 823;
      end

        823 :
      begin                                                                     // mov
              localMem[0 + 367] = heapMem[localMem[0+359]*10 + 5];
              ip = 824;
      end

        824 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+367] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[361]) begin
                  heapMem[NArea * localMem[0+367] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+367] + localMem[361]] = localMem[0+1];                                    // Insert new value
              arraySizes[localMem[0+367]] = arraySizes[localMem[0+367]] + 1;                              // Increase array size
              ip = 825;
      end

        825 :
      begin                                                                     // add
              heapMem[localMem[0+359]*10 + 0] = heapMem[localMem[0+359]*10 + 0] + 1;
              ip = 826;
      end

        826 :
      begin                                                                     // label
              ip = 827;
      end

        827 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 828;
      end

        828 :
      begin                                                                     // label
              ip = 829;
      end

        829 :
      begin                                                                     // mov
              localMem[0 + 369] = heapMem[localMem[0+359]*10 + 0];
              ip = 830;
      end

        830 :
      begin                                                                     // mov
              localMem[0 + 370] = heapMem[localMem[0+359]*10 + 3];
              ip = 831;
      end

        831 :
      begin                                                                     // mov
              localMem[0 + 371] = heapMem[localMem[0+370]*10 + 2];
              ip = 832;
      end

        832 :
      begin                                                                     // jLt
              ip = localMem[0+369] <  localMem[0+371] ? 1052 : 833;
      end

        833 :
      begin                                                                     // mov
              localMem[0 + 372] = localMem[0+371];
              ip = 834;
      end

        834 :
      begin                                                                     // shiftRight
              localMem[0 + 372] = localMem[0+372] >> 1;
              ip = 835;
      end

        835 :
      begin                                                                     // add
              localMem[0 + 373] = localMem[0+372] + 1;
              ip = 836;
      end

        836 :
      begin                                                                     // mov
              localMem[0 + 374] = heapMem[localMem[0+359]*10 + 2];
              ip = 837;
      end

        837 :
      begin                                                                     // jEq
              ip = localMem[0+374] == 0 ? 934 : 838;
      end

        838 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 375] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 375] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 375]] = 0;
              ip = 839;
      end

        839 :
      begin                                                                     // mov
              heapMem[localMem[0+375]*10 + 0] = localMem[0+372];
              ip = 840;
      end

        840 :
      begin                                                                     // mov
              heapMem[localMem[0+375]*10 + 2] = 0;
              ip = 841;
      end

        841 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 376] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 376] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 376]] = 0;
              ip = 842;
      end

        842 :
      begin                                                                     // mov
              heapMem[localMem[0+375]*10 + 4] = localMem[0+376];
              ip = 843;
      end

        843 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 377] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 377] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 377]] = 0;
              ip = 844;
      end

        844 :
      begin                                                                     // mov
              heapMem[localMem[0+375]*10 + 5] = localMem[0+377];
              ip = 845;
      end

        845 :
      begin                                                                     // mov
              heapMem[localMem[0+375]*10 + 6] = 0;
              ip = 846;
      end

        846 :
      begin                                                                     // mov
              heapMem[localMem[0+375]*10 + 3] = localMem[0+370];
              ip = 847;
      end

        847 :
      begin                                                                     // add
              heapMem[localMem[0+370]*10 + 1] = heapMem[localMem[0+370]*10 + 1] + 1;
              ip = 848;
      end

        848 :
      begin                                                                     // mov
              heapMem[localMem[0+375]*10 + 1] = heapMem[localMem[0+370]*10 + 1];
              ip = 849;
      end

        849 :
      begin                                                                     // not
              localMem[0 + 378] = !heapMem[localMem[0+359]*10 + 6];
              ip = 850;
      end

        850 :
      begin                                                                     // jNe
              ip = localMem[0+378] != 0 ? 879 : 851;
      end

        851 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 379] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 379] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 379]] = 0;
              ip = 852;
      end

        852 :
      begin                                                                     // mov
              heapMem[localMem[0+375]*10 + 6] = localMem[0+379];
              ip = 853;
      end

        853 :
      begin                                                                     // mov
              localMem[0 + 380] = heapMem[localMem[0+359]*10 + 4];
              ip = 854;
      end

        854 :
      begin                                                                     // mov
              localMem[0 + 381] = heapMem[localMem[0+375]*10 + 4];
              ip = 855;
      end

        855 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+372]) begin
                  heapMem[NArea * localMem[0+381] + 0 + i] = heapMem[NArea * localMem[0+380] + localMem[373] + i];
                end
              end
              ip = 856;
      end

        856 :
      begin                                                                     // mov
              localMem[0 + 382] = heapMem[localMem[0+359]*10 + 5];
              ip = 857;
      end

        857 :
      begin                                                                     // mov
              localMem[0 + 383] = heapMem[localMem[0+375]*10 + 5];
              ip = 858;
      end

        858 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+372]) begin
                  heapMem[NArea * localMem[0+383] + 0 + i] = heapMem[NArea * localMem[0+382] + localMem[373] + i];
                end
              end
              ip = 859;
      end

        859 :
      begin                                                                     // mov
              localMem[0 + 384] = heapMem[localMem[0+359]*10 + 6];
              ip = 860;
      end

        860 :
      begin                                                                     // mov
              localMem[0 + 385] = heapMem[localMem[0+375]*10 + 6];
              ip = 861;
      end

        861 :
      begin                                                                     // add
              localMem[0 + 386] = localMem[0+372] + 1;
              ip = 862;
      end

        862 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+386]) begin
                  heapMem[NArea * localMem[0+385] + 0 + i] = heapMem[NArea * localMem[0+384] + localMem[373] + i];
                end
              end
              ip = 863;
      end

        863 :
      begin                                                                     // mov
              localMem[0 + 387] = heapMem[localMem[0+375]*10 + 0];
              ip = 864;
      end

        864 :
      begin                                                                     // add
              localMem[0 + 388] = localMem[0+387] + 1;
              ip = 865;
      end

        865 :
      begin                                                                     // mov
              localMem[0 + 389] = heapMem[localMem[0+375]*10 + 6];
              ip = 866;
      end

        866 :
      begin                                                                     // label
              ip = 867;
      end

        867 :
      begin                                                                     // mov
              localMem[0 + 390] = 0;
              ip = 868;
      end

        868 :
      begin                                                                     // label
              ip = 869;
      end

        869 :
      begin                                                                     // jGe
              ip = localMem[0+390] >= localMem[0+388] ? 875 : 870;
      end

        870 :
      begin                                                                     // mov
              localMem[0 + 391] = heapMem[localMem[0+389]*10 + localMem[0+390]];
              ip = 871;
      end

        871 :
      begin                                                                     // mov
              heapMem[localMem[0+391]*10 + 2] = localMem[0+375];
              ip = 872;
      end

        872 :
      begin                                                                     // label
              ip = 873;
      end

        873 :
      begin                                                                     // add
              localMem[0 + 390] = localMem[0+390] + 1;
              ip = 874;
      end

        874 :
      begin                                                                     // jmp
              ip = 868;
      end

        875 :
      begin                                                                     // label
              ip = 876;
      end

        876 :
      begin                                                                     // mov
              localMem[0 + 392] = heapMem[localMem[0+359]*10 + 6];
              ip = 877;
      end

        877 :
      begin                                                                     // resize
              arraySizes[localMem[0+392]] = localMem[0+373];
              ip = 878;
      end

        878 :
      begin                                                                     // jmp
              ip = 886;
      end

        879 :
      begin                                                                     // label
              ip = 880;
      end

        880 :
      begin                                                                     // mov
              localMem[0 + 393] = heapMem[localMem[0+359]*10 + 4];
              ip = 881;
      end

        881 :
      begin                                                                     // mov
              localMem[0 + 394] = heapMem[localMem[0+375]*10 + 4];
              ip = 882;
      end

        882 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+372]) begin
                  heapMem[NArea * localMem[0+394] + 0 + i] = heapMem[NArea * localMem[0+393] + localMem[373] + i];
                end
              end
              ip = 883;
      end

        883 :
      begin                                                                     // mov
              localMem[0 + 395] = heapMem[localMem[0+359]*10 + 5];
              ip = 884;
      end

        884 :
      begin                                                                     // mov
              localMem[0 + 396] = heapMem[localMem[0+375]*10 + 5];
              ip = 885;
      end

        885 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+372]) begin
                  heapMem[NArea * localMem[0+396] + 0 + i] = heapMem[NArea * localMem[0+395] + localMem[373] + i];
                end
              end
              ip = 886;
      end

        886 :
      begin                                                                     // label
              ip = 887;
      end

        887 :
      begin                                                                     // mov
              heapMem[localMem[0+359]*10 + 0] = localMem[0+372];
              ip = 888;
      end

        888 :
      begin                                                                     // mov
              heapMem[localMem[0+375]*10 + 2] = localMem[0+374];
              ip = 889;
      end

        889 :
      begin                                                                     // mov
              localMem[0 + 397] = heapMem[localMem[0+374]*10 + 0];
              ip = 890;
      end

        890 :
      begin                                                                     // mov
              localMem[0 + 398] = heapMem[localMem[0+374]*10 + 6];
              ip = 891;
      end

        891 :
      begin                                                                     // mov
              localMem[0 + 399] = heapMem[localMem[0+398]*10 + localMem[0+397]];
              ip = 892;
      end

        892 :
      begin                                                                     // jNe
              ip = localMem[0+399] != localMem[0+359] ? 911 : 893;
      end

        893 :
      begin                                                                     // mov
              localMem[0 + 400] = heapMem[localMem[0+359]*10 + 4];
              ip = 894;
      end

        894 :
      begin                                                                     // mov
              localMem[0 + 401] = heapMem[localMem[0+400]*10 + localMem[0+372]];
              ip = 895;
      end

        895 :
      begin                                                                     // mov
              localMem[0 + 402] = heapMem[localMem[0+374]*10 + 4];
              ip = 896;
      end

        896 :
      begin                                                                     // mov
              heapMem[localMem[0+402]*10 + localMem[0+397]] = localMem[0+401];
              ip = 897;
      end

        897 :
      begin                                                                     // mov
              localMem[0 + 403] = heapMem[localMem[0+359]*10 + 5];
              ip = 898;
      end

        898 :
      begin                                                                     // mov
              localMem[0 + 404] = heapMem[localMem[0+403]*10 + localMem[0+372]];
              ip = 899;
      end

        899 :
      begin                                                                     // mov
              localMem[0 + 405] = heapMem[localMem[0+374]*10 + 5];
              ip = 900;
      end

        900 :
      begin                                                                     // mov
              heapMem[localMem[0+405]*10 + localMem[0+397]] = localMem[0+404];
              ip = 901;
      end

        901 :
      begin                                                                     // mov
              localMem[0 + 406] = heapMem[localMem[0+359]*10 + 4];
              ip = 902;
      end

        902 :
      begin                                                                     // resize
              arraySizes[localMem[0+406]] = localMem[0+372];
              ip = 903;
      end

        903 :
      begin                                                                     // mov
              localMem[0 + 407] = heapMem[localMem[0+359]*10 + 5];
              ip = 904;
      end

        904 :
      begin                                                                     // resize
              arraySizes[localMem[0+407]] = localMem[0+372];
              ip = 905;
      end

        905 :
      begin                                                                     // add
              localMem[0 + 408] = localMem[0+397] + 1;
              ip = 906;
      end

        906 :
      begin                                                                     // mov
              heapMem[localMem[0+374]*10 + 0] = localMem[0+408];
              ip = 907;
      end

        907 :
      begin                                                                     // mov
              localMem[0 + 409] = heapMem[localMem[0+374]*10 + 6];
              ip = 908;
      end

        908 :
      begin                                                                     // mov
              heapMem[localMem[0+409]*10 + localMem[0+408]] = localMem[0+375];
              ip = 909;
      end

        909 :
      begin                                                                     // jmp
              ip = 1049;
      end

        910 :
      begin                                                                     // jmp
              ip = 933;
      end

        911 :
      begin                                                                     // label
              ip = 912;
      end

        912 :
      begin                                                                     // assertNe
            ip = 913;
      end

        913 :
      begin                                                                     // mov
              localMem[0 + 410] = heapMem[localMem[0+374]*10 + 6];
              ip = 914;
      end

        914 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+410] * NArea + i] == localMem[0+359]) localMem[0 + 411] = i + 1;
              end
              ip = 915;
      end

        915 :
      begin                                                                     // subtract
              localMem[0 + 411] = localMem[0+411] - 1;
              ip = 916;
      end

        916 :
      begin                                                                     // mov
              localMem[0 + 412] = heapMem[localMem[0+359]*10 + 4];
              ip = 917;
      end

        917 :
      begin                                                                     // mov
              localMem[0 + 413] = heapMem[localMem[0+412]*10 + localMem[0+372]];
              ip = 918;
      end

        918 :
      begin                                                                     // mov
              localMem[0 + 414] = heapMem[localMem[0+359]*10 + 5];
              ip = 919;
      end

        919 :
      begin                                                                     // mov
              localMem[0 + 415] = heapMem[localMem[0+414]*10 + localMem[0+372]];
              ip = 920;
      end

        920 :
      begin                                                                     // mov
              localMem[0 + 416] = heapMem[localMem[0+359]*10 + 4];
              ip = 921;
      end

        921 :
      begin                                                                     // resize
              arraySizes[localMem[0+416]] = localMem[0+372];
              ip = 922;
      end

        922 :
      begin                                                                     // mov
              localMem[0 + 417] = heapMem[localMem[0+359]*10 + 5];
              ip = 923;
      end

        923 :
      begin                                                                     // resize
              arraySizes[localMem[0+417]] = localMem[0+372];
              ip = 924;
      end

        924 :
      begin                                                                     // mov
              localMem[0 + 418] = heapMem[localMem[0+374]*10 + 4];
              ip = 925;
      end

        925 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+418] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[411]) begin
                  heapMem[NArea * localMem[0+418] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+418] + localMem[411]] = localMem[0+413];                                    // Insert new value
              arraySizes[localMem[0+418]] = arraySizes[localMem[0+418]] + 1;                              // Increase array size
              ip = 926;
      end

        926 :
      begin                                                                     // mov
              localMem[0 + 419] = heapMem[localMem[0+374]*10 + 5];
              ip = 927;
      end

        927 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+419] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[411]) begin
                  heapMem[NArea * localMem[0+419] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+419] + localMem[411]] = localMem[0+415];                                    // Insert new value
              arraySizes[localMem[0+419]] = arraySizes[localMem[0+419]] + 1;                              // Increase array size
              ip = 928;
      end

        928 :
      begin                                                                     // mov
              localMem[0 + 420] = heapMem[localMem[0+374]*10 + 6];
              ip = 929;
      end

        929 :
      begin                                                                     // add
              localMem[0 + 421] = localMem[0+411] + 1;
              ip = 930;
      end

        930 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+420] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[421]) begin
                  heapMem[NArea * localMem[0+420] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+420] + localMem[421]] = localMem[0+375];                                    // Insert new value
              arraySizes[localMem[0+420]] = arraySizes[localMem[0+420]] + 1;                              // Increase array size
              ip = 931;
      end

        931 :
      begin                                                                     // add
              heapMem[localMem[0+374]*10 + 0] = heapMem[localMem[0+374]*10 + 0] + 1;
              ip = 932;
      end

        932 :
      begin                                                                     // jmp
              ip = 1049;
      end

        933 :
      begin                                                                     // label
              ip = 934;
      end

        934 :
      begin                                                                     // label
              ip = 935;
      end

        935 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 422] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 422] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 422]] = 0;
              ip = 936;
      end

        936 :
      begin                                                                     // mov
              heapMem[localMem[0+422]*10 + 0] = localMem[0+372];
              ip = 937;
      end

        937 :
      begin                                                                     // mov
              heapMem[localMem[0+422]*10 + 2] = 0;
              ip = 938;
      end

        938 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 423] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 423] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 423]] = 0;
              ip = 939;
      end

        939 :
      begin                                                                     // mov
              heapMem[localMem[0+422]*10 + 4] = localMem[0+423];
              ip = 940;
      end

        940 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 424] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 424] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 424]] = 0;
              ip = 941;
      end

        941 :
      begin                                                                     // mov
              heapMem[localMem[0+422]*10 + 5] = localMem[0+424];
              ip = 942;
      end

        942 :
      begin                                                                     // mov
              heapMem[localMem[0+422]*10 + 6] = 0;
              ip = 943;
      end

        943 :
      begin                                                                     // mov
              heapMem[localMem[0+422]*10 + 3] = localMem[0+370];
              ip = 944;
      end

        944 :
      begin                                                                     // add
              heapMem[localMem[0+370]*10 + 1] = heapMem[localMem[0+370]*10 + 1] + 1;
              ip = 945;
      end

        945 :
      begin                                                                     // mov
              heapMem[localMem[0+422]*10 + 1] = heapMem[localMem[0+370]*10 + 1];
              ip = 946;
      end

        946 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 425] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 425] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 425]] = 0;
              ip = 947;
      end

        947 :
      begin                                                                     // mov
              heapMem[localMem[0+425]*10 + 0] = localMem[0+372];
              ip = 948;
      end

        948 :
      begin                                                                     // mov
              heapMem[localMem[0+425]*10 + 2] = 0;
              ip = 949;
      end

        949 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 426] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 426] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 426]] = 0;
              ip = 950;
      end

        950 :
      begin                                                                     // mov
              heapMem[localMem[0+425]*10 + 4] = localMem[0+426];
              ip = 951;
      end

        951 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 427] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 427] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 427]] = 0;
              ip = 952;
      end

        952 :
      begin                                                                     // mov
              heapMem[localMem[0+425]*10 + 5] = localMem[0+427];
              ip = 953;
      end

        953 :
      begin                                                                     // mov
              heapMem[localMem[0+425]*10 + 6] = 0;
              ip = 954;
      end

        954 :
      begin                                                                     // mov
              heapMem[localMem[0+425]*10 + 3] = localMem[0+370];
              ip = 955;
      end

        955 :
      begin                                                                     // add
              heapMem[localMem[0+370]*10 + 1] = heapMem[localMem[0+370]*10 + 1] + 1;
              ip = 956;
      end

        956 :
      begin                                                                     // mov
              heapMem[localMem[0+425]*10 + 1] = heapMem[localMem[0+370]*10 + 1];
              ip = 957;
      end

        957 :
      begin                                                                     // not
              localMem[0 + 428] = !heapMem[localMem[0+359]*10 + 6];
              ip = 958;
      end

        958 :
      begin                                                                     // jNe
              ip = localMem[0+428] != 0 ? 1010 : 959;
      end

        959 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 429] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 429] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 429]] = 0;
              ip = 960;
      end

        960 :
      begin                                                                     // mov
              heapMem[localMem[0+422]*10 + 6] = localMem[0+429];
              ip = 961;
      end

        961 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 430] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 430] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 430]] = 0;
              ip = 962;
      end

        962 :
      begin                                                                     // mov
              heapMem[localMem[0+425]*10 + 6] = localMem[0+430];
              ip = 963;
      end

        963 :
      begin                                                                     // mov
              localMem[0 + 431] = heapMem[localMem[0+359]*10 + 4];
              ip = 964;
      end

        964 :
      begin                                                                     // mov
              localMem[0 + 432] = heapMem[localMem[0+422]*10 + 4];
              ip = 965;
      end

        965 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+372]) begin
                  heapMem[NArea * localMem[0+432] + 0 + i] = heapMem[NArea * localMem[0+431] + 0 + i];
                end
              end
              ip = 966;
      end

        966 :
      begin                                                                     // mov
              localMem[0 + 433] = heapMem[localMem[0+359]*10 + 5];
              ip = 967;
      end

        967 :
      begin                                                                     // mov
              localMem[0 + 434] = heapMem[localMem[0+422]*10 + 5];
              ip = 968;
      end

        968 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+372]) begin
                  heapMem[NArea * localMem[0+434] + 0 + i] = heapMem[NArea * localMem[0+433] + 0 + i];
                end
              end
              ip = 969;
      end

        969 :
      begin                                                                     // mov
              localMem[0 + 435] = heapMem[localMem[0+359]*10 + 6];
              ip = 970;
      end

        970 :
      begin                                                                     // mov
              localMem[0 + 436] = heapMem[localMem[0+422]*10 + 6];
              ip = 971;
      end

        971 :
      begin                                                                     // add
              localMem[0 + 437] = localMem[0+372] + 1;
              ip = 972;
      end

        972 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+437]) begin
                  heapMem[NArea * localMem[0+436] + 0 + i] = heapMem[NArea * localMem[0+435] + 0 + i];
                end
              end
              ip = 973;
      end

        973 :
      begin                                                                     // mov
              localMem[0 + 438] = heapMem[localMem[0+359]*10 + 4];
              ip = 974;
      end

        974 :
      begin                                                                     // mov
              localMem[0 + 439] = heapMem[localMem[0+425]*10 + 4];
              ip = 975;
      end

        975 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+372]) begin
                  heapMem[NArea * localMem[0+439] + 0 + i] = heapMem[NArea * localMem[0+438] + localMem[373] + i];
                end
              end
              ip = 976;
      end

        976 :
      begin                                                                     // mov
              localMem[0 + 440] = heapMem[localMem[0+359]*10 + 5];
              ip = 977;
      end

        977 :
      begin                                                                     // mov
              localMem[0 + 441] = heapMem[localMem[0+425]*10 + 5];
              ip = 978;
      end

        978 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+372]) begin
                  heapMem[NArea * localMem[0+441] + 0 + i] = heapMem[NArea * localMem[0+440] + localMem[373] + i];
                end
              end
              ip = 979;
      end

        979 :
      begin                                                                     // mov
              localMem[0 + 442] = heapMem[localMem[0+359]*10 + 6];
              ip = 980;
      end

        980 :
      begin                                                                     // mov
              localMem[0 + 443] = heapMem[localMem[0+425]*10 + 6];
              ip = 981;
      end

        981 :
      begin                                                                     // add
              localMem[0 + 444] = localMem[0+372] + 1;
              ip = 982;
      end

        982 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+444]) begin
                  heapMem[NArea * localMem[0+443] + 0 + i] = heapMem[NArea * localMem[0+442] + localMem[373] + i];
                end
              end
              ip = 983;
      end

        983 :
      begin                                                                     // mov
              localMem[0 + 445] = heapMem[localMem[0+422]*10 + 0];
              ip = 984;
      end

        984 :
      begin                                                                     // add
              localMem[0 + 446] = localMem[0+445] + 1;
              ip = 985;
      end

        985 :
      begin                                                                     // mov
              localMem[0 + 447] = heapMem[localMem[0+422]*10 + 6];
              ip = 986;
      end

        986 :
      begin                                                                     // label
              ip = 987;
      end

        987 :
      begin                                                                     // mov
              localMem[0 + 448] = 0;
              ip = 988;
      end

        988 :
      begin                                                                     // label
              ip = 989;
      end

        989 :
      begin                                                                     // jGe
              ip = localMem[0+448] >= localMem[0+446] ? 995 : 990;
      end

        990 :
      begin                                                                     // mov
              localMem[0 + 449] = heapMem[localMem[0+447]*10 + localMem[0+448]];
              ip = 991;
      end

        991 :
      begin                                                                     // mov
              heapMem[localMem[0+449]*10 + 2] = localMem[0+422];
              ip = 992;
      end

        992 :
      begin                                                                     // label
              ip = 993;
      end

        993 :
      begin                                                                     // add
              localMem[0 + 448] = localMem[0+448] + 1;
              ip = 994;
      end

        994 :
      begin                                                                     // jmp
              ip = 988;
      end

        995 :
      begin                                                                     // label
              ip = 996;
      end

        996 :
      begin                                                                     // mov
              localMem[0 + 450] = heapMem[localMem[0+425]*10 + 0];
              ip = 997;
      end

        997 :
      begin                                                                     // add
              localMem[0 + 451] = localMem[0+450] + 1;
              ip = 998;
      end

        998 :
      begin                                                                     // mov
              localMem[0 + 452] = heapMem[localMem[0+425]*10 + 6];
              ip = 999;
      end

        999 :
      begin                                                                     // label
              ip = 1000;
      end

       1000 :
      begin                                                                     // mov
              localMem[0 + 453] = 0;
              ip = 1001;
      end

       1001 :
      begin                                                                     // label
              ip = 1002;
      end

       1002 :
      begin                                                                     // jGe
              ip = localMem[0+453] >= localMem[0+451] ? 1008 : 1003;
      end

       1003 :
      begin                                                                     // mov
              localMem[0 + 454] = heapMem[localMem[0+452]*10 + localMem[0+453]];
              ip = 1004;
      end

       1004 :
      begin                                                                     // mov
              heapMem[localMem[0+454]*10 + 2] = localMem[0+425];
              ip = 1005;
      end

       1005 :
      begin                                                                     // label
              ip = 1006;
      end

       1006 :
      begin                                                                     // add
              localMem[0 + 453] = localMem[0+453] + 1;
              ip = 1007;
      end

       1007 :
      begin                                                                     // jmp
              ip = 1001;
      end

       1008 :
      begin                                                                     // label
              ip = 1009;
      end

       1009 :
      begin                                                                     // jmp
              ip = 1025;
      end

       1010 :
      begin                                                                     // label
              ip = 1011;
      end

       1011 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 455] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 455] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 455]] = 0;
              ip = 1012;
      end

       1012 :
      begin                                                                     // mov
              heapMem[localMem[0+359]*10 + 6] = localMem[0+455];
              ip = 1013;
      end

       1013 :
      begin                                                                     // mov
              localMem[0 + 456] = heapMem[localMem[0+359]*10 + 4];
              ip = 1014;
      end

       1014 :
      begin                                                                     // mov
              localMem[0 + 457] = heapMem[localMem[0+422]*10 + 4];
              ip = 1015;
      end

       1015 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+372]) begin
                  heapMem[NArea * localMem[0+457] + 0 + i] = heapMem[NArea * localMem[0+456] + 0 + i];
                end
              end
              ip = 1016;
      end

       1016 :
      begin                                                                     // mov
              localMem[0 + 458] = heapMem[localMem[0+359]*10 + 5];
              ip = 1017;
      end

       1017 :
      begin                                                                     // mov
              localMem[0 + 459] = heapMem[localMem[0+422]*10 + 5];
              ip = 1018;
      end

       1018 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+372]) begin
                  heapMem[NArea * localMem[0+459] + 0 + i] = heapMem[NArea * localMem[0+458] + 0 + i];
                end
              end
              ip = 1019;
      end

       1019 :
      begin                                                                     // mov
              localMem[0 + 460] = heapMem[localMem[0+359]*10 + 4];
              ip = 1020;
      end

       1020 :
      begin                                                                     // mov
              localMem[0 + 461] = heapMem[localMem[0+425]*10 + 4];
              ip = 1021;
      end

       1021 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+372]) begin
                  heapMem[NArea * localMem[0+461] + 0 + i] = heapMem[NArea * localMem[0+460] + localMem[373] + i];
                end
              end
              ip = 1022;
      end

       1022 :
      begin                                                                     // mov
              localMem[0 + 462] = heapMem[localMem[0+359]*10 + 5];
              ip = 1023;
      end

       1023 :
      begin                                                                     // mov
              localMem[0 + 463] = heapMem[localMem[0+425]*10 + 5];
              ip = 1024;
      end

       1024 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+372]) begin
                  heapMem[NArea * localMem[0+463] + 0 + i] = heapMem[NArea * localMem[0+462] + localMem[373] + i];
                end
              end
              ip = 1025;
      end

       1025 :
      begin                                                                     // label
              ip = 1026;
      end

       1026 :
      begin                                                                     // mov
              heapMem[localMem[0+422]*10 + 2] = localMem[0+359];
              ip = 1027;
      end

       1027 :
      begin                                                                     // mov
              heapMem[localMem[0+425]*10 + 2] = localMem[0+359];
              ip = 1028;
      end

       1028 :
      begin                                                                     // mov
              localMem[0 + 464] = heapMem[localMem[0+359]*10 + 4];
              ip = 1029;
      end

       1029 :
      begin                                                                     // mov
              localMem[0 + 465] = heapMem[localMem[0+464]*10 + localMem[0+372]];
              ip = 1030;
      end

       1030 :
      begin                                                                     // mov
              localMem[0 + 466] = heapMem[localMem[0+359]*10 + 5];
              ip = 1031;
      end

       1031 :
      begin                                                                     // mov
              localMem[0 + 467] = heapMem[localMem[0+466]*10 + localMem[0+372]];
              ip = 1032;
      end

       1032 :
      begin                                                                     // mov
              localMem[0 + 468] = heapMem[localMem[0+359]*10 + 4];
              ip = 1033;
      end

       1033 :
      begin                                                                     // mov
              heapMem[localMem[0+468]*10 + 0] = localMem[0+465];
              ip = 1034;
      end

       1034 :
      begin                                                                     // mov
              localMem[0 + 469] = heapMem[localMem[0+359]*10 + 5];
              ip = 1035;
      end

       1035 :
      begin                                                                     // mov
              heapMem[localMem[0+469]*10 + 0] = localMem[0+467];
              ip = 1036;
      end

       1036 :
      begin                                                                     // mov
              localMem[0 + 470] = heapMem[localMem[0+359]*10 + 6];
              ip = 1037;
      end

       1037 :
      begin                                                                     // mov
              heapMem[localMem[0+470]*10 + 0] = localMem[0+422];
              ip = 1038;
      end

       1038 :
      begin                                                                     // mov
              localMem[0 + 471] = heapMem[localMem[0+359]*10 + 6];
              ip = 1039;
      end

       1039 :
      begin                                                                     // mov
              heapMem[localMem[0+471]*10 + 1] = localMem[0+425];
              ip = 1040;
      end

       1040 :
      begin                                                                     // mov
              heapMem[localMem[0+359]*10 + 0] = 1;
              ip = 1041;
      end

       1041 :
      begin                                                                     // mov
              localMem[0 + 472] = heapMem[localMem[0+359]*10 + 4];
              ip = 1042;
      end

       1042 :
      begin                                                                     // resize
              arraySizes[localMem[0+472]] = 1;
              ip = 1043;
      end

       1043 :
      begin                                                                     // mov
              localMem[0 + 473] = heapMem[localMem[0+359]*10 + 5];
              ip = 1044;
      end

       1044 :
      begin                                                                     // resize
              arraySizes[localMem[0+473]] = 1;
              ip = 1045;
      end

       1045 :
      begin                                                                     // mov
              localMem[0 + 474] = heapMem[localMem[0+359]*10 + 6];
              ip = 1046;
      end

       1046 :
      begin                                                                     // resize
              arraySizes[localMem[0+474]] = 2;
              ip = 1047;
      end

       1047 :
      begin                                                                     // jmp
              ip = 1049;
      end

       1048 :
      begin                                                                     // jmp
              ip = 1054;
      end

       1049 :
      begin                                                                     // label
              ip = 1050;
      end

       1050 :
      begin                                                                     // mov
              localMem[0 + 368] = 1;
              ip = 1051;
      end

       1051 :
      begin                                                                     // jmp
              ip = 1054;
      end

       1052 :
      begin                                                                     // label
              ip = 1053;
      end

       1053 :
      begin                                                                     // mov
              localMem[0 + 368] = 0;
              ip = 1054;
      end

       1054 :
      begin                                                                     // label
              ip = 1055;
      end

       1055 :
      begin                                                                     // label
              ip = 1056;
      end

       1056 :
      begin                                                                     // label
              ip = 1057;
      end

       1057 :
      begin                                                                     // label
              ip = 1058;
      end

       1058 :
      begin                                                                     // free
              freedArrays[freedArraysTop] = localMem[0+3];
              freedArraysTop = freedArraysTop + 1;
              ip = 1059;
      end

       1059 :
      begin                                                                     // label
              ip = 1060;
      end

       1060 :
      begin                                                                     // subtract
              localMem[0 + 1] = localMem[0+1] - 1;
              ip = 1061;
      end

       1061 :
      begin                                                                     // jmp
              ip = 8;
      end

       1062 :
      begin                                                                     // label
              ip = 1063;
      end

       1063 :
      begin                                                                     // mov
              localMem[0 + 475] = 1;
              ip = 1064;
      end

       1064 :
      begin                                                                     // shiftLeft
              localMem[0 + 475] = localMem[0+475] << 31;
              ip = 1065;
      end

       1065 :
      begin                                                                     // mov
              localMem[0 + 476] = heapMem[localMem[0+0]*10 + 3];
              ip = 1066;
      end

       1066 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 477] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 477] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 477]] = 0;
              ip = 1067;
      end

       1067 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 478] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 478] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 478]] = 0;
              ip = 1068;
      end

       1068 :
      begin                                                                     // jNe
              ip = localMem[0+476] != 0 ? 1073 : 1069;
      end

       1069 :
      begin                                                                     // mov
              heapMem[localMem[0+477]*10 + 0] = localMem[0+476];
              ip = 1070;
      end

       1070 :
      begin                                                                     // mov
              heapMem[localMem[0+477]*10 + 1] = 3;
              ip = 1071;
      end

       1071 :
      begin                                                                     // mov
              heapMem[localMem[0+477]*10 + 2] = 0;
              ip = 1072;
      end

       1072 :
      begin                                                                     // jmp
              ip = 1090;
      end

       1073 :
      begin                                                                     // label
              ip = 1074;
      end

       1074 :
      begin                                                                     // label
              ip = 1075;
      end

       1075 :
      begin                                                                     // mov
              localMem[0 + 479] = 0;
              ip = 1076;
      end

       1076 :
      begin                                                                     // label
              ip = 1077;
      end

       1077 :
      begin                                                                     // jGe
              ip = localMem[0+479] >= 99 ? 1086 : 1078;
      end

       1078 :
      begin                                                                     // not
              localMem[0 + 480] = !heapMem[localMem[0+476]*10 + 6];
              ip = 1079;
      end

       1079 :
      begin                                                                     // jTrue
              ip = localMem[0+480] != 0 ? 1086 : 1080;
      end

       1080 :
      begin                                                                     // mov
              localMem[0 + 481] = heapMem[localMem[0+476]*10 + 6];
              ip = 1081;
      end

       1081 :
      begin                                                                     // mov
              localMem[0 + 482] = heapMem[localMem[0+481]*10 + 0];
              ip = 1082;
      end

       1082 :
      begin                                                                     // mov
              localMem[0 + 476] = localMem[0+482];
              ip = 1083;
      end

       1083 :
      begin                                                                     // label
              ip = 1084;
      end

       1084 :
      begin                                                                     // add
              localMem[0 + 479] = localMem[0+479] + 1;
              ip = 1085;
      end

       1085 :
      begin                                                                     // jmp
              ip = 1076;
      end

       1086 :
      begin                                                                     // label
              ip = 1087;
      end

       1087 :
      begin                                                                     // mov
              heapMem[localMem[0+477]*10 + 0] = localMem[0+476];
              ip = 1088;
      end

       1088 :
      begin                                                                     // mov
              heapMem[localMem[0+477]*10 + 1] = 1;
              ip = 1089;
      end

       1089 :
      begin                                                                     // mov
              heapMem[localMem[0+477]*10 + 2] = 0;
              ip = 1090;
      end

       1090 :
      begin                                                                     // label
              ip = 1091;
      end

       1091 :
      begin                                                                     // label
              ip = 1092;
      end

       1092 :
      begin                                                                     // mov
              localMem[0 + 483] = heapMem[localMem[0+477]*10 + 1];
              ip = 1093;
      end

       1093 :
      begin                                                                     // jEq
              ip = localMem[0+483] == 3 ? 1176 : 1094;
      end

       1094 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 3) begin
                  heapMem[NArea * localMem[0+478] + 0 + i] = heapMem[NArea * localMem[0+477] + 0 + i];
                end
              end
              ip = 1095;
      end

       1095 :
      begin                                                                     // mov
              localMem[0 + 484] = heapMem[localMem[0+478]*10 + 0];
              ip = 1096;
      end

       1096 :
      begin                                                                     // mov
              localMem[0 + 485] = heapMem[localMem[0+478]*10 + 2];
              ip = 1097;
      end

       1097 :
      begin                                                                     // mov
              localMem[0 + 486] = heapMem[localMem[0+484]*10 + 4];
              ip = 1098;
      end

       1098 :
      begin                                                                     // mov
              localMem[0 + 487] = heapMem[localMem[0+486]*10 + localMem[0+485]];
              ip = 1099;
      end

       1099 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+487];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 1100;
      end

       1100 :
      begin                                                                     // label
              ip = 1101;
      end

       1101 :
      begin                                                                     // mov
              localMem[0 + 488] = heapMem[localMem[0+477]*10 + 0];
              ip = 1102;
      end

       1102 :
      begin                                                                     // not
              localMem[0 + 489] = !heapMem[localMem[0+488]*10 + 6];
              ip = 1103;
      end

       1103 :
      begin                                                                     // jEq
              ip = localMem[0+489] == 0 ? 1143 : 1104;
      end

       1104 :
      begin                                                                     // add
              localMem[0 + 490] = heapMem[localMem[0+477]*10 + 2] + 1;
              ip = 1105;
      end

       1105 :
      begin                                                                     // mov
              localMem[0 + 491] = heapMem[localMem[0+488]*10 + 0];
              ip = 1106;
      end

       1106 :
      begin                                                                     // jGe
              ip = localMem[0+490] >= localMem[0+491] ? 1111 : 1107;
      end

       1107 :
      begin                                                                     // mov
              heapMem[localMem[0+477]*10 + 0] = localMem[0+488];
              ip = 1108;
      end

       1108 :
      begin                                                                     // mov
              heapMem[localMem[0+477]*10 + 1] = 1;
              ip = 1109;
      end

       1109 :
      begin                                                                     // mov
              heapMem[localMem[0+477]*10 + 2] = localMem[0+490];
              ip = 1110;
      end

       1110 :
      begin                                                                     // jmp
              ip = 1172;
      end

       1111 :
      begin                                                                     // label
              ip = 1112;
      end

       1112 :
      begin                                                                     // mov
              localMem[0 + 492] = heapMem[localMem[0+488]*10 + 2];
              ip = 1113;
      end

       1113 :
      begin                                                                     // jEq
              ip = localMem[0+492] == 0 ? 1138 : 1114;
      end

       1114 :
      begin                                                                     // label
              ip = 1115;
      end

       1115 :
      begin                                                                     // mov
              localMem[0 + 493] = 0;
              ip = 1116;
      end

       1116 :
      begin                                                                     // label
              ip = 1117;
      end

       1117 :
      begin                                                                     // jGe
              ip = localMem[0+493] >= 99 ? 1137 : 1118;
      end

       1118 :
      begin                                                                     // mov
              localMem[0 + 494] = heapMem[localMem[0+492]*10 + 0];
              ip = 1119;
      end

       1119 :
      begin                                                                     // assertNe
            ip = 1120;
      end

       1120 :
      begin                                                                     // mov
              localMem[0 + 495] = heapMem[localMem[0+492]*10 + 6];
              ip = 1121;
      end

       1121 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+495] * NArea + i] == localMem[0+488]) localMem[0 + 496] = i + 1;
              end
              ip = 1122;
      end

       1122 :
      begin                                                                     // subtract
              localMem[0 + 496] = localMem[0+496] - 1;
              ip = 1123;
      end

       1123 :
      begin                                                                     // jNe
              ip = localMem[0+496] != localMem[0+494] ? 1128 : 1124;
      end

       1124 :
      begin                                                                     // mov
              localMem[0 + 488] = localMem[0+492];
              ip = 1125;
      end

       1125 :
      begin                                                                     // mov
              localMem[0 + 492] = heapMem[localMem[0+488]*10 + 2];
              ip = 1126;
      end

       1126 :
      begin                                                                     // jFalse
              ip = localMem[0+492] == 0 ? 1137 : 1127;
      end

       1127 :
      begin                                                                     // jmp
              ip = 1133;
      end

       1128 :
      begin                                                                     // label
              ip = 1129;
      end

       1129 :
      begin                                                                     // mov
              heapMem[localMem[0+477]*10 + 0] = localMem[0+492];
              ip = 1130;
      end

       1130 :
      begin                                                                     // mov
              heapMem[localMem[0+477]*10 + 1] = 1;
              ip = 1131;
      end

       1131 :
      begin                                                                     // mov
              heapMem[localMem[0+477]*10 + 2] = localMem[0+496];
              ip = 1132;
      end

       1132 :
      begin                                                                     // jmp
              ip = 1172;
      end

       1133 :
      begin                                                                     // label
              ip = 1134;
      end

       1134 :
      begin                                                                     // label
              ip = 1135;
      end

       1135 :
      begin                                                                     // add
              localMem[0 + 493] = localMem[0+493] + 1;
              ip = 1136;
      end

       1136 :
      begin                                                                     // jmp
              ip = 1116;
      end

       1137 :
      begin                                                                     // label
              ip = 1138;
      end

       1138 :
      begin                                                                     // label
              ip = 1139;
      end

       1139 :
      begin                                                                     // mov
              heapMem[localMem[0+477]*10 + 0] = localMem[0+488];
              ip = 1140;
      end

       1140 :
      begin                                                                     // mov
              heapMem[localMem[0+477]*10 + 1] = 3;
              ip = 1141;
      end

       1141 :
      begin                                                                     // mov
              heapMem[localMem[0+477]*10 + 2] = 0;
              ip = 1142;
      end

       1142 :
      begin                                                                     // jmp
              ip = 1172;
      end

       1143 :
      begin                                                                     // label
              ip = 1144;
      end

       1144 :
      begin                                                                     // add
              localMem[0 + 497] = heapMem[localMem[0+477]*10 + 2] + 1;
              ip = 1145;
      end

       1145 :
      begin                                                                     // mov
              localMem[0 + 498] = heapMem[localMem[0+488]*10 + 6];
              ip = 1146;
      end

       1146 :
      begin                                                                     // mov
              localMem[0 + 499] = heapMem[localMem[0+498]*10 + localMem[0+497]];
              ip = 1147;
      end

       1147 :
      begin                                                                     // jNe
              ip = localMem[0+499] != 0 ? 1152 : 1148;
      end

       1148 :
      begin                                                                     // mov
              heapMem[localMem[0+477]*10 + 0] = localMem[0+499];
              ip = 1149;
      end

       1149 :
      begin                                                                     // mov
              heapMem[localMem[0+477]*10 + 1] = 3;
              ip = 1150;
      end

       1150 :
      begin                                                                     // mov
              heapMem[localMem[0+477]*10 + 2] = 0;
              ip = 1151;
      end

       1151 :
      begin                                                                     // jmp
              ip = 1169;
      end

       1152 :
      begin                                                                     // label
              ip = 1153;
      end

       1153 :
      begin                                                                     // label
              ip = 1154;
      end

       1154 :
      begin                                                                     // mov
              localMem[0 + 500] = 0;
              ip = 1155;
      end

       1155 :
      begin                                                                     // label
              ip = 1156;
      end

       1156 :
      begin                                                                     // jGe
              ip = localMem[0+500] >= 99 ? 1165 : 1157;
      end

       1157 :
      begin                                                                     // not
              localMem[0 + 501] = !heapMem[localMem[0+499]*10 + 6];
              ip = 1158;
      end

       1158 :
      begin                                                                     // jTrue
              ip = localMem[0+501] != 0 ? 1165 : 1159;
      end

       1159 :
      begin                                                                     // mov
              localMem[0 + 502] = heapMem[localMem[0+499]*10 + 6];
              ip = 1160;
      end

       1160 :
      begin                                                                     // mov
              localMem[0 + 503] = heapMem[localMem[0+502]*10 + 0];
              ip = 1161;
      end

       1161 :
      begin                                                                     // mov
              localMem[0 + 499] = localMem[0+503];
              ip = 1162;
      end

       1162 :
      begin                                                                     // label
              ip = 1163;
      end

       1163 :
      begin                                                                     // add
              localMem[0 + 500] = localMem[0+500] + 1;
              ip = 1164;
      end

       1164 :
      begin                                                                     // jmp
              ip = 1155;
      end

       1165 :
      begin                                                                     // label
              ip = 1166;
      end

       1166 :
      begin                                                                     // mov
              heapMem[localMem[0+477]*10 + 0] = localMem[0+499];
              ip = 1167;
      end

       1167 :
      begin                                                                     // mov
              heapMem[localMem[0+477]*10 + 1] = 1;
              ip = 1168;
      end

       1168 :
      begin                                                                     // mov
              heapMem[localMem[0+477]*10 + 2] = 0;
              ip = 1169;
      end

       1169 :
      begin                                                                     // label
              ip = 1170;
      end

       1170 :
      begin                                                                     // label
              ip = 1171;
      end

       1171 :
      begin                                                                     // label
              ip = 1172;
      end

       1172 :
      begin                                                                     // label
              ip = 1173;
      end

       1173 :
      begin                                                                     // jmp
              ip = 1091;
      end

       1174 :
      begin                                                                     // label
              ip = 1175;
      end

       1175 :
      begin                                                                     // label
              ip = 1176;
      end

       1176 :
      begin                                                                     // label
              ip = 1177;
      end

       1177 :
      begin                                                                     // free
              freedArrays[freedArraysTop] = localMem[0+477];
              freedArraysTop = freedArraysTop + 1;
              ip = 1178;
      end

       1178 :
      begin                                                                     // free
              freedArrays[freedArraysTop] = localMem[0+478];
              freedArraysTop = freedArraysTop + 1;
              ip = 1179;
      end
      default: begin
        success  = 1;
        success  = success && outMem[0] == 0;
        success  = success && outMem[1] == 1;
        success  = success && outMem[2] == 2;
        success  = success && outMem[3] == 3;
        success  = success && outMem[4] == 4;
        success  = success && outMem[5] == 5;
        finished = 1;
      end
    endcase
    if (steps <=    793) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
  end
endmodule
