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
      begin                                                                     // label
              ip = 7;
      end

          7 :
      begin                                                                     // mov
              localMem[0 + 2] = heapMem[localMem[0+0]*10 + 3];
              ip = 8;
      end

          8 :
      begin                                                                     // jNe
              ip = localMem[0+2] != 0 ? 27 : 9;
      end

          9 :
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
              ip = 10;
      end

         10 :
      begin                                                                     // mov
              heapMem[localMem[0+3]*10 + 0] = 1;
              ip = 11;
      end

         11 :
      begin                                                                     // mov
              heapMem[localMem[0+3]*10 + 2] = 0;
              ip = 12;
      end

         12 :
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
              ip = 13;
      end

         13 :
      begin                                                                     // mov
              heapMem[localMem[0+3]*10 + 4] = localMem[0+4];
              ip = 14;
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
              heapMem[localMem[0+3]*10 + 5] = localMem[0+5];
              ip = 16;
      end

         16 :
      begin                                                                     // mov
              heapMem[localMem[0+3]*10 + 6] = 0;
              ip = 17;
      end

         17 :
      begin                                                                     // mov
              heapMem[localMem[0+3]*10 + 3] = localMem[0+0];
              ip = 18;
      end

         18 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 1] = heapMem[localMem[0+0]*10 + 1] + 1;
              ip = 19;
      end

         19 :
      begin                                                                     // mov
              heapMem[localMem[0+3]*10 + 1] = heapMem[localMem[0+0]*10 + 1];
              ip = 20;
      end

         20 :
      begin                                                                     // mov
              localMem[0 + 6] = heapMem[localMem[0+3]*10 + 4];
              ip = 21;
      end

         21 :
      begin                                                                     // mov
              heapMem[localMem[0+6]*10 + 0] = 1;
              ip = 22;
      end

         22 :
      begin                                                                     // mov
              localMem[0 + 7] = heapMem[localMem[0+3]*10 + 5];
              ip = 23;
      end

         23 :
      begin                                                                     // mov
              heapMem[localMem[0+7]*10 + 0] = 11;
              ip = 24;
      end

         24 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 25;
      end

         25 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 3] = localMem[0+3];
              ip = 26;
      end

         26 :
      begin                                                                     // jmp
              ip = 1052;
      end

         27 :
      begin                                                                     // label
              ip = 28;
      end

         28 :
      begin                                                                     // mov
              localMem[0 + 8] = heapMem[localMem[0+2]*10 + 0];
              ip = 29;
      end

         29 :
      begin                                                                     // mov
              localMem[0 + 9] = heapMem[localMem[0+0]*10 + 2];
              ip = 30;
      end

         30 :
      begin                                                                     // jGe
              ip = localMem[0+8] >= localMem[0+9] ? 63 : 31;
      end

         31 :
      begin                                                                     // mov
              localMem[0 + 10] = heapMem[localMem[0+2]*10 + 2];
              ip = 32;
      end

         32 :
      begin                                                                     // jNe
              ip = localMem[0+10] != 0 ? 62 : 33;
      end

         33 :
      begin                                                                     // not
              localMem[0 + 11] = !heapMem[localMem[0+2]*10 + 6];
              ip = 34;
      end

         34 :
      begin                                                                     // jEq
              ip = localMem[0+11] == 0 ? 61 : 35;
      end

         35 :
      begin                                                                     // mov
              localMem[0 + 12] = heapMem[localMem[0+2]*10 + 4];
              ip = 36;
      end

         36 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+12] * NArea + i] == 1) localMem[0 + 13] = i + 1;
              end
              ip = 37;
      end

         37 :
      begin                                                                     // jEq
              ip = localMem[0+13] == 0 ? 42 : 38;
      end

         38 :
      begin                                                                     // subtract
              localMem[0 + 13] = localMem[0+13] - 1;
              ip = 39;
      end

         39 :
      begin                                                                     // mov
              localMem[0 + 14] = heapMem[localMem[0+2]*10 + 5];
              ip = 40;
      end

         40 :
      begin                                                                     // mov
              heapMem[localMem[0+14]*10 + localMem[0+13]] = 11;
              ip = 41;
      end

         41 :
      begin                                                                     // jmp
              ip = 1052;
      end

         42 :
      begin                                                                     // label
              ip = 43;
      end

         43 :
      begin                                                                     // arrayCountGreater
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+12] * NArea + i] > 1) j = j + 1;
              end
              localMem[0 + 15] = j;
              ip = 44;
      end

         44 :
      begin                                                                     // jNe
              ip = localMem[0+15] != 0 ? 52 : 45;
      end

         45 :
      begin                                                                     // mov
              localMem[0 + 16] = heapMem[localMem[0+2]*10 + 4];
              ip = 46;
      end

         46 :
      begin                                                                     // mov
              heapMem[localMem[0+16]*10 + localMem[0+8]] = 1;
              ip = 47;
      end

         47 :
      begin                                                                     // mov
              localMem[0 + 17] = heapMem[localMem[0+2]*10 + 5];
              ip = 48;
      end

         48 :
      begin                                                                     // mov
              heapMem[localMem[0+17]*10 + localMem[0+8]] = 11;
              ip = 49;
      end

         49 :
      begin                                                                     // add
              heapMem[localMem[0+2]*10 + 0] = localMem[0+8] + 1;
              ip = 50;
      end

         50 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 51;
      end

         51 :
      begin                                                                     // jmp
              ip = 1052;
      end

         52 :
      begin                                                                     // label
              ip = 53;
      end

         53 :
      begin                                                                     // arrayCountLess
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+12] * NArea + i] < 1) j = j + 1;
              end
              localMem[0 + 18] = j;
              ip = 54;
      end

         54 :
      begin                                                                     // mov
              localMem[0 + 19] = heapMem[localMem[0+2]*10 + 4];
              ip = 55;
      end

         55 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+19] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[18]) begin
                  heapMem[NArea * localMem[0+19] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+19] + localMem[18]] = 1;                                    // Insert new value
              arraySizes[localMem[0+19]] = arraySizes[localMem[0+19]] + 1;                              // Increase array size
              ip = 56;
      end

         56 :
      begin                                                                     // mov
              localMem[0 + 20] = heapMem[localMem[0+2]*10 + 5];
              ip = 57;
      end

         57 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+20] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[18]) begin
                  heapMem[NArea * localMem[0+20] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+20] + localMem[18]] = 11;                                    // Insert new value
              arraySizes[localMem[0+20]] = arraySizes[localMem[0+20]] + 1;                              // Increase array size
              ip = 58;
      end

         58 :
      begin                                                                     // add
              heapMem[localMem[0+2]*10 + 0] = heapMem[localMem[0+2]*10 + 0] + 1;
              ip = 59;
      end

         59 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 60;
      end

         60 :
      begin                                                                     // jmp
              ip = 1052;
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
      begin                                                                     // mov
              localMem[0 + 21] = heapMem[localMem[0+0]*10 + 3];
              ip = 65;
      end

         65 :
      begin                                                                     // label
              ip = 66;
      end

         66 :
      begin                                                                     // mov
              localMem[0 + 23] = heapMem[localMem[0+21]*10 + 0];
              ip = 67;
      end

         67 :
      begin                                                                     // mov
              localMem[0 + 24] = heapMem[localMem[0+21]*10 + 3];
              ip = 68;
      end

         68 :
      begin                                                                     // mov
              localMem[0 + 25] = heapMem[localMem[0+24]*10 + 2];
              ip = 69;
      end

         69 :
      begin                                                                     // jLt
              ip = localMem[0+23] <  localMem[0+25] ? 289 : 70;
      end

         70 :
      begin                                                                     // mov
              localMem[0 + 26] = localMem[0+25];
              ip = 71;
      end

         71 :
      begin                                                                     // shiftRight
              localMem[0 + 26] = localMem[0+26] >> 1;
              ip = 72;
      end

         72 :
      begin                                                                     // add
              localMem[0 + 27] = localMem[0+26] + 1;
              ip = 73;
      end

         73 :
      begin                                                                     // mov
              localMem[0 + 28] = heapMem[localMem[0+21]*10 + 2];
              ip = 74;
      end

         74 :
      begin                                                                     // jEq
              ip = localMem[0+28] == 0 ? 171 : 75;
      end

         75 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 29] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 29] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 29]] = 0;
              ip = 76;
      end

         76 :
      begin                                                                     // mov
              heapMem[localMem[0+29]*10 + 0] = localMem[0+26];
              ip = 77;
      end

         77 :
      begin                                                                     // mov
              heapMem[localMem[0+29]*10 + 2] = 0;
              ip = 78;
      end

         78 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 30] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 30] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 30]] = 0;
              ip = 79;
      end

         79 :
      begin                                                                     // mov
              heapMem[localMem[0+29]*10 + 4] = localMem[0+30];
              ip = 80;
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
              heapMem[localMem[0+29]*10 + 5] = localMem[0+31];
              ip = 82;
      end

         82 :
      begin                                                                     // mov
              heapMem[localMem[0+29]*10 + 6] = 0;
              ip = 83;
      end

         83 :
      begin                                                                     // mov
              heapMem[localMem[0+29]*10 + 3] = localMem[0+24];
              ip = 84;
      end

         84 :
      begin                                                                     // add
              heapMem[localMem[0+24]*10 + 1] = heapMem[localMem[0+24]*10 + 1] + 1;
              ip = 85;
      end

         85 :
      begin                                                                     // mov
              heapMem[localMem[0+29]*10 + 1] = heapMem[localMem[0+24]*10 + 1];
              ip = 86;
      end

         86 :
      begin                                                                     // not
              localMem[0 + 32] = !heapMem[localMem[0+21]*10 + 6];
              ip = 87;
      end

         87 :
      begin                                                                     // jNe
              ip = localMem[0+32] != 0 ? 116 : 88;
      end

         88 :
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
              ip = 89;
      end

         89 :
      begin                                                                     // mov
              heapMem[localMem[0+29]*10 + 6] = localMem[0+33];
              ip = 90;
      end

         90 :
      begin                                                                     // mov
              localMem[0 + 34] = heapMem[localMem[0+21]*10 + 4];
              ip = 91;
      end

         91 :
      begin                                                                     // mov
              localMem[0 + 35] = heapMem[localMem[0+29]*10 + 4];
              ip = 92;
      end

         92 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+26]) begin
                  heapMem[NArea * localMem[0+35] + 0 + i] = heapMem[NArea * localMem[0+34] + localMem[27] + i];
                end
              end
              ip = 93;
      end

         93 :
      begin                                                                     // mov
              localMem[0 + 36] = heapMem[localMem[0+21]*10 + 5];
              ip = 94;
      end

         94 :
      begin                                                                     // mov
              localMem[0 + 37] = heapMem[localMem[0+29]*10 + 5];
              ip = 95;
      end

         95 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+26]) begin
                  heapMem[NArea * localMem[0+37] + 0 + i] = heapMem[NArea * localMem[0+36] + localMem[27] + i];
                end
              end
              ip = 96;
      end

         96 :
      begin                                                                     // mov
              localMem[0 + 38] = heapMem[localMem[0+21]*10 + 6];
              ip = 97;
      end

         97 :
      begin                                                                     // mov
              localMem[0 + 39] = heapMem[localMem[0+29]*10 + 6];
              ip = 98;
      end

         98 :
      begin                                                                     // add
              localMem[0 + 40] = localMem[0+26] + 1;
              ip = 99;
      end

         99 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+40]) begin
                  heapMem[NArea * localMem[0+39] + 0 + i] = heapMem[NArea * localMem[0+38] + localMem[27] + i];
                end
              end
              ip = 100;
      end

        100 :
      begin                                                                     // mov
              localMem[0 + 41] = heapMem[localMem[0+29]*10 + 0];
              ip = 101;
      end

        101 :
      begin                                                                     // add
              localMem[0 + 42] = localMem[0+41] + 1;
              ip = 102;
      end

        102 :
      begin                                                                     // mov
              localMem[0 + 43] = heapMem[localMem[0+29]*10 + 6];
              ip = 103;
      end

        103 :
      begin                                                                     // label
              ip = 104;
      end

        104 :
      begin                                                                     // mov
              localMem[0 + 44] = 0;
              ip = 105;
      end

        105 :
      begin                                                                     // label
              ip = 106;
      end

        106 :
      begin                                                                     // jGe
              ip = localMem[0+44] >= localMem[0+42] ? 112 : 107;
      end

        107 :
      begin                                                                     // mov
              localMem[0 + 45] = heapMem[localMem[0+43]*10 + localMem[0+44]];
              ip = 108;
      end

        108 :
      begin                                                                     // mov
              heapMem[localMem[0+45]*10 + 2] = localMem[0+29];
              ip = 109;
      end

        109 :
      begin                                                                     // label
              ip = 110;
      end

        110 :
      begin                                                                     // add
              localMem[0 + 44] = localMem[0+44] + 1;
              ip = 111;
      end

        111 :
      begin                                                                     // jmp
              ip = 105;
      end

        112 :
      begin                                                                     // label
              ip = 113;
      end

        113 :
      begin                                                                     // mov
              localMem[0 + 46] = heapMem[localMem[0+21]*10 + 6];
              ip = 114;
      end

        114 :
      begin                                                                     // resize
              arraySizes[localMem[0+46]] = localMem[0+27];
              ip = 115;
      end

        115 :
      begin                                                                     // jmp
              ip = 123;
      end

        116 :
      begin                                                                     // label
              ip = 117;
      end

        117 :
      begin                                                                     // mov
              localMem[0 + 47] = heapMem[localMem[0+21]*10 + 4];
              ip = 118;
      end

        118 :
      begin                                                                     // mov
              localMem[0 + 48] = heapMem[localMem[0+29]*10 + 4];
              ip = 119;
      end

        119 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+26]) begin
                  heapMem[NArea * localMem[0+48] + 0 + i] = heapMem[NArea * localMem[0+47] + localMem[27] + i];
                end
              end
              ip = 120;
      end

        120 :
      begin                                                                     // mov
              localMem[0 + 49] = heapMem[localMem[0+21]*10 + 5];
              ip = 121;
      end

        121 :
      begin                                                                     // mov
              localMem[0 + 50] = heapMem[localMem[0+29]*10 + 5];
              ip = 122;
      end

        122 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+26]) begin
                  heapMem[NArea * localMem[0+50] + 0 + i] = heapMem[NArea * localMem[0+49] + localMem[27] + i];
                end
              end
              ip = 123;
      end

        123 :
      begin                                                                     // label
              ip = 124;
      end

        124 :
      begin                                                                     // mov
              heapMem[localMem[0+21]*10 + 0] = localMem[0+26];
              ip = 125;
      end

        125 :
      begin                                                                     // mov
              heapMem[localMem[0+29]*10 + 2] = localMem[0+28];
              ip = 126;
      end

        126 :
      begin                                                                     // mov
              localMem[0 + 51] = heapMem[localMem[0+28]*10 + 0];
              ip = 127;
      end

        127 :
      begin                                                                     // mov
              localMem[0 + 52] = heapMem[localMem[0+28]*10 + 6];
              ip = 128;
      end

        128 :
      begin                                                                     // mov
              localMem[0 + 53] = heapMem[localMem[0+52]*10 + localMem[0+51]];
              ip = 129;
      end

        129 :
      begin                                                                     // jNe
              ip = localMem[0+53] != localMem[0+21] ? 148 : 130;
      end

        130 :
      begin                                                                     // mov
              localMem[0 + 54] = heapMem[localMem[0+21]*10 + 4];
              ip = 131;
      end

        131 :
      begin                                                                     // mov
              localMem[0 + 55] = heapMem[localMem[0+54]*10 + localMem[0+26]];
              ip = 132;
      end

        132 :
      begin                                                                     // mov
              localMem[0 + 56] = heapMem[localMem[0+28]*10 + 4];
              ip = 133;
      end

        133 :
      begin                                                                     // mov
              heapMem[localMem[0+56]*10 + localMem[0+51]] = localMem[0+55];
              ip = 134;
      end

        134 :
      begin                                                                     // mov
              localMem[0 + 57] = heapMem[localMem[0+21]*10 + 5];
              ip = 135;
      end

        135 :
      begin                                                                     // mov
              localMem[0 + 58] = heapMem[localMem[0+57]*10 + localMem[0+26]];
              ip = 136;
      end

        136 :
      begin                                                                     // mov
              localMem[0 + 59] = heapMem[localMem[0+28]*10 + 5];
              ip = 137;
      end

        137 :
      begin                                                                     // mov
              heapMem[localMem[0+59]*10 + localMem[0+51]] = localMem[0+58];
              ip = 138;
      end

        138 :
      begin                                                                     // mov
              localMem[0 + 60] = heapMem[localMem[0+21]*10 + 4];
              ip = 139;
      end

        139 :
      begin                                                                     // resize
              arraySizes[localMem[0+60]] = localMem[0+26];
              ip = 140;
      end

        140 :
      begin                                                                     // mov
              localMem[0 + 61] = heapMem[localMem[0+21]*10 + 5];
              ip = 141;
      end

        141 :
      begin                                                                     // resize
              arraySizes[localMem[0+61]] = localMem[0+26];
              ip = 142;
      end

        142 :
      begin                                                                     // add
              localMem[0 + 62] = localMem[0+51] + 1;
              ip = 143;
      end

        143 :
      begin                                                                     // mov
              heapMem[localMem[0+28]*10 + 0] = localMem[0+62];
              ip = 144;
      end

        144 :
      begin                                                                     // mov
              localMem[0 + 63] = heapMem[localMem[0+28]*10 + 6];
              ip = 145;
      end

        145 :
      begin                                                                     // mov
              heapMem[localMem[0+63]*10 + localMem[0+62]] = localMem[0+29];
              ip = 146;
      end

        146 :
      begin                                                                     // jmp
              ip = 286;
      end

        147 :
      begin                                                                     // jmp
              ip = 170;
      end

        148 :
      begin                                                                     // label
              ip = 149;
      end

        149 :
      begin                                                                     // assertNe
            ip = 150;
      end

        150 :
      begin                                                                     // mov
              localMem[0 + 64] = heapMem[localMem[0+28]*10 + 6];
              ip = 151;
      end

        151 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+64] * NArea + i] == localMem[0+21]) localMem[0 + 65] = i + 1;
              end
              ip = 152;
      end

        152 :
      begin                                                                     // subtract
              localMem[0 + 65] = localMem[0+65] - 1;
              ip = 153;
      end

        153 :
      begin                                                                     // mov
              localMem[0 + 66] = heapMem[localMem[0+21]*10 + 4];
              ip = 154;
      end

        154 :
      begin                                                                     // mov
              localMem[0 + 67] = heapMem[localMem[0+66]*10 + localMem[0+26]];
              ip = 155;
      end

        155 :
      begin                                                                     // mov
              localMem[0 + 68] = heapMem[localMem[0+21]*10 + 5];
              ip = 156;
      end

        156 :
      begin                                                                     // mov
              localMem[0 + 69] = heapMem[localMem[0+68]*10 + localMem[0+26]];
              ip = 157;
      end

        157 :
      begin                                                                     // mov
              localMem[0 + 70] = heapMem[localMem[0+21]*10 + 4];
              ip = 158;
      end

        158 :
      begin                                                                     // resize
              arraySizes[localMem[0+70]] = localMem[0+26];
              ip = 159;
      end

        159 :
      begin                                                                     // mov
              localMem[0 + 71] = heapMem[localMem[0+21]*10 + 5];
              ip = 160;
      end

        160 :
      begin                                                                     // resize
              arraySizes[localMem[0+71]] = localMem[0+26];
              ip = 161;
      end

        161 :
      begin                                                                     // mov
              localMem[0 + 72] = heapMem[localMem[0+28]*10 + 4];
              ip = 162;
      end

        162 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+72] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[65]) begin
                  heapMem[NArea * localMem[0+72] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+72] + localMem[65]] = localMem[0+67];                                    // Insert new value
              arraySizes[localMem[0+72]] = arraySizes[localMem[0+72]] + 1;                              // Increase array size
              ip = 163;
      end

        163 :
      begin                                                                     // mov
              localMem[0 + 73] = heapMem[localMem[0+28]*10 + 5];
              ip = 164;
      end

        164 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+73] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[65]) begin
                  heapMem[NArea * localMem[0+73] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+73] + localMem[65]] = localMem[0+69];                                    // Insert new value
              arraySizes[localMem[0+73]] = arraySizes[localMem[0+73]] + 1;                              // Increase array size
              ip = 165;
      end

        165 :
      begin                                                                     // mov
              localMem[0 + 74] = heapMem[localMem[0+28]*10 + 6];
              ip = 166;
      end

        166 :
      begin                                                                     // add
              localMem[0 + 75] = localMem[0+65] + 1;
              ip = 167;
      end

        167 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+74] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[75]) begin
                  heapMem[NArea * localMem[0+74] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+74] + localMem[75]] = localMem[0+29];                                    // Insert new value
              arraySizes[localMem[0+74]] = arraySizes[localMem[0+74]] + 1;                              // Increase array size
              ip = 168;
      end

        168 :
      begin                                                                     // add
              heapMem[localMem[0+28]*10 + 0] = heapMem[localMem[0+28]*10 + 0] + 1;
              ip = 169;
      end

        169 :
      begin                                                                     // jmp
              ip = 286;
      end

        170 :
      begin                                                                     // label
              ip = 171;
      end

        171 :
      begin                                                                     // label
              ip = 172;
      end

        172 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 76] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 76] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 76]] = 0;
              ip = 173;
      end

        173 :
      begin                                                                     // mov
              heapMem[localMem[0+76]*10 + 0] = localMem[0+26];
              ip = 174;
      end

        174 :
      begin                                                                     // mov
              heapMem[localMem[0+76]*10 + 2] = 0;
              ip = 175;
      end

        175 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 77] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 77] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 77]] = 0;
              ip = 176;
      end

        176 :
      begin                                                                     // mov
              heapMem[localMem[0+76]*10 + 4] = localMem[0+77];
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
              heapMem[localMem[0+76]*10 + 5] = localMem[0+78];
              ip = 179;
      end

        179 :
      begin                                                                     // mov
              heapMem[localMem[0+76]*10 + 6] = 0;
              ip = 180;
      end

        180 :
      begin                                                                     // mov
              heapMem[localMem[0+76]*10 + 3] = localMem[0+24];
              ip = 181;
      end

        181 :
      begin                                                                     // add
              heapMem[localMem[0+24]*10 + 1] = heapMem[localMem[0+24]*10 + 1] + 1;
              ip = 182;
      end

        182 :
      begin                                                                     // mov
              heapMem[localMem[0+76]*10 + 1] = heapMem[localMem[0+24]*10 + 1];
              ip = 183;
      end

        183 :
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
              ip = 184;
      end

        184 :
      begin                                                                     // mov
              heapMem[localMem[0+79]*10 + 0] = localMem[0+26];
              ip = 185;
      end

        185 :
      begin                                                                     // mov
              heapMem[localMem[0+79]*10 + 2] = 0;
              ip = 186;
      end

        186 :
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
              ip = 187;
      end

        187 :
      begin                                                                     // mov
              heapMem[localMem[0+79]*10 + 4] = localMem[0+80];
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
              heapMem[localMem[0+79]*10 + 5] = localMem[0+81];
              ip = 190;
      end

        190 :
      begin                                                                     // mov
              heapMem[localMem[0+79]*10 + 6] = 0;
              ip = 191;
      end

        191 :
      begin                                                                     // mov
              heapMem[localMem[0+79]*10 + 3] = localMem[0+24];
              ip = 192;
      end

        192 :
      begin                                                                     // add
              heapMem[localMem[0+24]*10 + 1] = heapMem[localMem[0+24]*10 + 1] + 1;
              ip = 193;
      end

        193 :
      begin                                                                     // mov
              heapMem[localMem[0+79]*10 + 1] = heapMem[localMem[0+24]*10 + 1];
              ip = 194;
      end

        194 :
      begin                                                                     // not
              localMem[0 + 82] = !heapMem[localMem[0+21]*10 + 6];
              ip = 195;
      end

        195 :
      begin                                                                     // jNe
              ip = localMem[0+82] != 0 ? 247 : 196;
      end

        196 :
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
              ip = 197;
      end

        197 :
      begin                                                                     // mov
              heapMem[localMem[0+76]*10 + 6] = localMem[0+83];
              ip = 198;
      end

        198 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 84] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 84] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 84]] = 0;
              ip = 199;
      end

        199 :
      begin                                                                     // mov
              heapMem[localMem[0+79]*10 + 6] = localMem[0+84];
              ip = 200;
      end

        200 :
      begin                                                                     // mov
              localMem[0 + 85] = heapMem[localMem[0+21]*10 + 4];
              ip = 201;
      end

        201 :
      begin                                                                     // mov
              localMem[0 + 86] = heapMem[localMem[0+76]*10 + 4];
              ip = 202;
      end

        202 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+26]) begin
                  heapMem[NArea * localMem[0+86] + 0 + i] = heapMem[NArea * localMem[0+85] + 0 + i];
                end
              end
              ip = 203;
      end

        203 :
      begin                                                                     // mov
              localMem[0 + 87] = heapMem[localMem[0+21]*10 + 5];
              ip = 204;
      end

        204 :
      begin                                                                     // mov
              localMem[0 + 88] = heapMem[localMem[0+76]*10 + 5];
              ip = 205;
      end

        205 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+26]) begin
                  heapMem[NArea * localMem[0+88] + 0 + i] = heapMem[NArea * localMem[0+87] + 0 + i];
                end
              end
              ip = 206;
      end

        206 :
      begin                                                                     // mov
              localMem[0 + 89] = heapMem[localMem[0+21]*10 + 6];
              ip = 207;
      end

        207 :
      begin                                                                     // mov
              localMem[0 + 90] = heapMem[localMem[0+76]*10 + 6];
              ip = 208;
      end

        208 :
      begin                                                                     // add
              localMem[0 + 91] = localMem[0+26] + 1;
              ip = 209;
      end

        209 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+91]) begin
                  heapMem[NArea * localMem[0+90] + 0 + i] = heapMem[NArea * localMem[0+89] + 0 + i];
                end
              end
              ip = 210;
      end

        210 :
      begin                                                                     // mov
              localMem[0 + 92] = heapMem[localMem[0+21]*10 + 4];
              ip = 211;
      end

        211 :
      begin                                                                     // mov
              localMem[0 + 93] = heapMem[localMem[0+79]*10 + 4];
              ip = 212;
      end

        212 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+26]) begin
                  heapMem[NArea * localMem[0+93] + 0 + i] = heapMem[NArea * localMem[0+92] + localMem[27] + i];
                end
              end
              ip = 213;
      end

        213 :
      begin                                                                     // mov
              localMem[0 + 94] = heapMem[localMem[0+21]*10 + 5];
              ip = 214;
      end

        214 :
      begin                                                                     // mov
              localMem[0 + 95] = heapMem[localMem[0+79]*10 + 5];
              ip = 215;
      end

        215 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+26]) begin
                  heapMem[NArea * localMem[0+95] + 0 + i] = heapMem[NArea * localMem[0+94] + localMem[27] + i];
                end
              end
              ip = 216;
      end

        216 :
      begin                                                                     // mov
              localMem[0 + 96] = heapMem[localMem[0+21]*10 + 6];
              ip = 217;
      end

        217 :
      begin                                                                     // mov
              localMem[0 + 97] = heapMem[localMem[0+79]*10 + 6];
              ip = 218;
      end

        218 :
      begin                                                                     // add
              localMem[0 + 98] = localMem[0+26] + 1;
              ip = 219;
      end

        219 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+98]) begin
                  heapMem[NArea * localMem[0+97] + 0 + i] = heapMem[NArea * localMem[0+96] + localMem[27] + i];
                end
              end
              ip = 220;
      end

        220 :
      begin                                                                     // mov
              localMem[0 + 99] = heapMem[localMem[0+76]*10 + 0];
              ip = 221;
      end

        221 :
      begin                                                                     // add
              localMem[0 + 100] = localMem[0+99] + 1;
              ip = 222;
      end

        222 :
      begin                                                                     // mov
              localMem[0 + 101] = heapMem[localMem[0+76]*10 + 6];
              ip = 223;
      end

        223 :
      begin                                                                     // label
              ip = 224;
      end

        224 :
      begin                                                                     // mov
              localMem[0 + 102] = 0;
              ip = 225;
      end

        225 :
      begin                                                                     // label
              ip = 226;
      end

        226 :
      begin                                                                     // jGe
              ip = localMem[0+102] >= localMem[0+100] ? 232 : 227;
      end

        227 :
      begin                                                                     // mov
              localMem[0 + 103] = heapMem[localMem[0+101]*10 + localMem[0+102]];
              ip = 228;
      end

        228 :
      begin                                                                     // mov
              heapMem[localMem[0+103]*10 + 2] = localMem[0+76];
              ip = 229;
      end

        229 :
      begin                                                                     // label
              ip = 230;
      end

        230 :
      begin                                                                     // add
              localMem[0 + 102] = localMem[0+102] + 1;
              ip = 231;
      end

        231 :
      begin                                                                     // jmp
              ip = 225;
      end

        232 :
      begin                                                                     // label
              ip = 233;
      end

        233 :
      begin                                                                     // mov
              localMem[0 + 104] = heapMem[localMem[0+79]*10 + 0];
              ip = 234;
      end

        234 :
      begin                                                                     // add
              localMem[0 + 105] = localMem[0+104] + 1;
              ip = 235;
      end

        235 :
      begin                                                                     // mov
              localMem[0 + 106] = heapMem[localMem[0+79]*10 + 6];
              ip = 236;
      end

        236 :
      begin                                                                     // label
              ip = 237;
      end

        237 :
      begin                                                                     // mov
              localMem[0 + 107] = 0;
              ip = 238;
      end

        238 :
      begin                                                                     // label
              ip = 239;
      end

        239 :
      begin                                                                     // jGe
              ip = localMem[0+107] >= localMem[0+105] ? 245 : 240;
      end

        240 :
      begin                                                                     // mov
              localMem[0 + 108] = heapMem[localMem[0+106]*10 + localMem[0+107]];
              ip = 241;
      end

        241 :
      begin                                                                     // mov
              heapMem[localMem[0+108]*10 + 2] = localMem[0+79];
              ip = 242;
      end

        242 :
      begin                                                                     // label
              ip = 243;
      end

        243 :
      begin                                                                     // add
              localMem[0 + 107] = localMem[0+107] + 1;
              ip = 244;
      end

        244 :
      begin                                                                     // jmp
              ip = 238;
      end

        245 :
      begin                                                                     // label
              ip = 246;
      end

        246 :
      begin                                                                     // jmp
              ip = 262;
      end

        247 :
      begin                                                                     // label
              ip = 248;
      end

        248 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 109] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 109] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 109]] = 0;
              ip = 249;
      end

        249 :
      begin                                                                     // mov
              heapMem[localMem[0+21]*10 + 6] = localMem[0+109];
              ip = 250;
      end

        250 :
      begin                                                                     // mov
              localMem[0 + 110] = heapMem[localMem[0+21]*10 + 4];
              ip = 251;
      end

        251 :
      begin                                                                     // mov
              localMem[0 + 111] = heapMem[localMem[0+76]*10 + 4];
              ip = 252;
      end

        252 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+26]) begin
                  heapMem[NArea * localMem[0+111] + 0 + i] = heapMem[NArea * localMem[0+110] + 0 + i];
                end
              end
              ip = 253;
      end

        253 :
      begin                                                                     // mov
              localMem[0 + 112] = heapMem[localMem[0+21]*10 + 5];
              ip = 254;
      end

        254 :
      begin                                                                     // mov
              localMem[0 + 113] = heapMem[localMem[0+76]*10 + 5];
              ip = 255;
      end

        255 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+26]) begin
                  heapMem[NArea * localMem[0+113] + 0 + i] = heapMem[NArea * localMem[0+112] + 0 + i];
                end
              end
              ip = 256;
      end

        256 :
      begin                                                                     // mov
              localMem[0 + 114] = heapMem[localMem[0+21]*10 + 4];
              ip = 257;
      end

        257 :
      begin                                                                     // mov
              localMem[0 + 115] = heapMem[localMem[0+79]*10 + 4];
              ip = 258;
      end

        258 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+26]) begin
                  heapMem[NArea * localMem[0+115] + 0 + i] = heapMem[NArea * localMem[0+114] + localMem[27] + i];
                end
              end
              ip = 259;
      end

        259 :
      begin                                                                     // mov
              localMem[0 + 116] = heapMem[localMem[0+21]*10 + 5];
              ip = 260;
      end

        260 :
      begin                                                                     // mov
              localMem[0 + 117] = heapMem[localMem[0+79]*10 + 5];
              ip = 261;
      end

        261 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+26]) begin
                  heapMem[NArea * localMem[0+117] + 0 + i] = heapMem[NArea * localMem[0+116] + localMem[27] + i];
                end
              end
              ip = 262;
      end

        262 :
      begin                                                                     // label
              ip = 263;
      end

        263 :
      begin                                                                     // mov
              heapMem[localMem[0+76]*10 + 2] = localMem[0+21];
              ip = 264;
      end

        264 :
      begin                                                                     // mov
              heapMem[localMem[0+79]*10 + 2] = localMem[0+21];
              ip = 265;
      end

        265 :
      begin                                                                     // mov
              localMem[0 + 118] = heapMem[localMem[0+21]*10 + 4];
              ip = 266;
      end

        266 :
      begin                                                                     // mov
              localMem[0 + 119] = heapMem[localMem[0+118]*10 + localMem[0+26]];
              ip = 267;
      end

        267 :
      begin                                                                     // mov
              localMem[0 + 120] = heapMem[localMem[0+21]*10 + 5];
              ip = 268;
      end

        268 :
      begin                                                                     // mov
              localMem[0 + 121] = heapMem[localMem[0+120]*10 + localMem[0+26]];
              ip = 269;
      end

        269 :
      begin                                                                     // mov
              localMem[0 + 122] = heapMem[localMem[0+21]*10 + 4];
              ip = 270;
      end

        270 :
      begin                                                                     // mov
              heapMem[localMem[0+122]*10 + 0] = localMem[0+119];
              ip = 271;
      end

        271 :
      begin                                                                     // mov
              localMem[0 + 123] = heapMem[localMem[0+21]*10 + 5];
              ip = 272;
      end

        272 :
      begin                                                                     // mov
              heapMem[localMem[0+123]*10 + 0] = localMem[0+121];
              ip = 273;
      end

        273 :
      begin                                                                     // mov
              localMem[0 + 124] = heapMem[localMem[0+21]*10 + 6];
              ip = 274;
      end

        274 :
      begin                                                                     // mov
              heapMem[localMem[0+124]*10 + 0] = localMem[0+76];
              ip = 275;
      end

        275 :
      begin                                                                     // mov
              localMem[0 + 125] = heapMem[localMem[0+21]*10 + 6];
              ip = 276;
      end

        276 :
      begin                                                                     // mov
              heapMem[localMem[0+125]*10 + 1] = localMem[0+79];
              ip = 277;
      end

        277 :
      begin                                                                     // mov
              heapMem[localMem[0+21]*10 + 0] = 1;
              ip = 278;
      end

        278 :
      begin                                                                     // mov
              localMem[0 + 126] = heapMem[localMem[0+21]*10 + 4];
              ip = 279;
      end

        279 :
      begin                                                                     // resize
              arraySizes[localMem[0+126]] = 1;
              ip = 280;
      end

        280 :
      begin                                                                     // mov
              localMem[0 + 127] = heapMem[localMem[0+21]*10 + 5];
              ip = 281;
      end

        281 :
      begin                                                                     // resize
              arraySizes[localMem[0+127]] = 1;
              ip = 282;
      end

        282 :
      begin                                                                     // mov
              localMem[0 + 128] = heapMem[localMem[0+21]*10 + 6];
              ip = 283;
      end

        283 :
      begin                                                                     // resize
              arraySizes[localMem[0+128]] = 2;
              ip = 284;
      end

        284 :
      begin                                                                     // jmp
              ip = 286;
      end

        285 :
      begin                                                                     // jmp
              ip = 291;
      end

        286 :
      begin                                                                     // label
              ip = 287;
      end

        287 :
      begin                                                                     // mov
              localMem[0 + 22] = 1;
              ip = 288;
      end

        288 :
      begin                                                                     // jmp
              ip = 291;
      end

        289 :
      begin                                                                     // label
              ip = 290;
      end

        290 :
      begin                                                                     // mov
              localMem[0 + 22] = 0;
              ip = 291;
      end

        291 :
      begin                                                                     // label
              ip = 292;
      end

        292 :
      begin                                                                     // label
              ip = 293;
      end

        293 :
      begin                                                                     // label
              ip = 294;
      end

        294 :
      begin                                                                     // mov
              localMem[0 + 129] = 0;
              ip = 295;
      end

        295 :
      begin                                                                     // label
              ip = 296;
      end

        296 :
      begin                                                                     // jGe
              ip = localMem[0+129] >= 99 ? 794 : 297;
      end

        297 :
      begin                                                                     // mov
              localMem[0 + 130] = heapMem[localMem[0+21]*10 + 0];
              ip = 298;
      end

        298 :
      begin                                                                     // subtract
              localMem[0 + 131] = localMem[0+130] - 1;
              ip = 299;
      end

        299 :
      begin                                                                     // mov
              localMem[0 + 132] = heapMem[localMem[0+21]*10 + 4];
              ip = 300;
      end

        300 :
      begin                                                                     // mov
              localMem[0 + 133] = heapMem[localMem[0+132]*10 + localMem[0+131]];
              ip = 301;
      end

        301 :
      begin                                                                     // jLe
              ip = 1 <= localMem[0+133] ? 542 : 302;
      end

        302 :
      begin                                                                     // not
              localMem[0 + 134] = !heapMem[localMem[0+21]*10 + 6];
              ip = 303;
      end

        303 :
      begin                                                                     // jEq
              ip = localMem[0+134] == 0 ? 308 : 304;
      end

        304 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 0] = localMem[0+21];
              ip = 305;
      end

        305 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 1] = 2;
              ip = 306;
      end

        306 :
      begin                                                                     // subtract
              heapMem[localMem[0+1]*10 + 2] = localMem[0+130] - 1;
              ip = 307;
      end

        307 :
      begin                                                                     // jmp
              ip = 798;
      end

        308 :
      begin                                                                     // label
              ip = 309;
      end

        309 :
      begin                                                                     // mov
              localMem[0 + 135] = heapMem[localMem[0+21]*10 + 6];
              ip = 310;
      end

        310 :
      begin                                                                     // mov
              localMem[0 + 136] = heapMem[localMem[0+135]*10 + localMem[0+130]];
              ip = 311;
      end

        311 :
      begin                                                                     // label
              ip = 312;
      end

        312 :
      begin                                                                     // mov
              localMem[0 + 138] = heapMem[localMem[0+136]*10 + 0];
              ip = 313;
      end

        313 :
      begin                                                                     // mov
              localMem[0 + 139] = heapMem[localMem[0+136]*10 + 3];
              ip = 314;
      end

        314 :
      begin                                                                     // mov
              localMem[0 + 140] = heapMem[localMem[0+139]*10 + 2];
              ip = 315;
      end

        315 :
      begin                                                                     // jLt
              ip = localMem[0+138] <  localMem[0+140] ? 535 : 316;
      end

        316 :
      begin                                                                     // mov
              localMem[0 + 141] = localMem[0+140];
              ip = 317;
      end

        317 :
      begin                                                                     // shiftRight
              localMem[0 + 141] = localMem[0+141] >> 1;
              ip = 318;
      end

        318 :
      begin                                                                     // add
              localMem[0 + 142] = localMem[0+141] + 1;
              ip = 319;
      end

        319 :
      begin                                                                     // mov
              localMem[0 + 143] = heapMem[localMem[0+136]*10 + 2];
              ip = 320;
      end

        320 :
      begin                                                                     // jEq
              ip = localMem[0+143] == 0 ? 417 : 321;
      end

        321 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 144] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 144] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 144]] = 0;
              ip = 322;
      end

        322 :
      begin                                                                     // mov
              heapMem[localMem[0+144]*10 + 0] = localMem[0+141];
              ip = 323;
      end

        323 :
      begin                                                                     // mov
              heapMem[localMem[0+144]*10 + 2] = 0;
              ip = 324;
      end

        324 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 145] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 145] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 145]] = 0;
              ip = 325;
      end

        325 :
      begin                                                                     // mov
              heapMem[localMem[0+144]*10 + 4] = localMem[0+145];
              ip = 326;
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
              heapMem[localMem[0+144]*10 + 5] = localMem[0+146];
              ip = 328;
      end

        328 :
      begin                                                                     // mov
              heapMem[localMem[0+144]*10 + 6] = 0;
              ip = 329;
      end

        329 :
      begin                                                                     // mov
              heapMem[localMem[0+144]*10 + 3] = localMem[0+139];
              ip = 330;
      end

        330 :
      begin                                                                     // add
              heapMem[localMem[0+139]*10 + 1] = heapMem[localMem[0+139]*10 + 1] + 1;
              ip = 331;
      end

        331 :
      begin                                                                     // mov
              heapMem[localMem[0+144]*10 + 1] = heapMem[localMem[0+139]*10 + 1];
              ip = 332;
      end

        332 :
      begin                                                                     // not
              localMem[0 + 147] = !heapMem[localMem[0+136]*10 + 6];
              ip = 333;
      end

        333 :
      begin                                                                     // jNe
              ip = localMem[0+147] != 0 ? 362 : 334;
      end

        334 :
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
              ip = 335;
      end

        335 :
      begin                                                                     // mov
              heapMem[localMem[0+144]*10 + 6] = localMem[0+148];
              ip = 336;
      end

        336 :
      begin                                                                     // mov
              localMem[0 + 149] = heapMem[localMem[0+136]*10 + 4];
              ip = 337;
      end

        337 :
      begin                                                                     // mov
              localMem[0 + 150] = heapMem[localMem[0+144]*10 + 4];
              ip = 338;
      end

        338 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+141]) begin
                  heapMem[NArea * localMem[0+150] + 0 + i] = heapMem[NArea * localMem[0+149] + localMem[142] + i];
                end
              end
              ip = 339;
      end

        339 :
      begin                                                                     // mov
              localMem[0 + 151] = heapMem[localMem[0+136]*10 + 5];
              ip = 340;
      end

        340 :
      begin                                                                     // mov
              localMem[0 + 152] = heapMem[localMem[0+144]*10 + 5];
              ip = 341;
      end

        341 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+141]) begin
                  heapMem[NArea * localMem[0+152] + 0 + i] = heapMem[NArea * localMem[0+151] + localMem[142] + i];
                end
              end
              ip = 342;
      end

        342 :
      begin                                                                     // mov
              localMem[0 + 153] = heapMem[localMem[0+136]*10 + 6];
              ip = 343;
      end

        343 :
      begin                                                                     // mov
              localMem[0 + 154] = heapMem[localMem[0+144]*10 + 6];
              ip = 344;
      end

        344 :
      begin                                                                     // add
              localMem[0 + 155] = localMem[0+141] + 1;
              ip = 345;
      end

        345 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+155]) begin
                  heapMem[NArea * localMem[0+154] + 0 + i] = heapMem[NArea * localMem[0+153] + localMem[142] + i];
                end
              end
              ip = 346;
      end

        346 :
      begin                                                                     // mov
              localMem[0 + 156] = heapMem[localMem[0+144]*10 + 0];
              ip = 347;
      end

        347 :
      begin                                                                     // add
              localMem[0 + 157] = localMem[0+156] + 1;
              ip = 348;
      end

        348 :
      begin                                                                     // mov
              localMem[0 + 158] = heapMem[localMem[0+144]*10 + 6];
              ip = 349;
      end

        349 :
      begin                                                                     // label
              ip = 350;
      end

        350 :
      begin                                                                     // mov
              localMem[0 + 159] = 0;
              ip = 351;
      end

        351 :
      begin                                                                     // label
              ip = 352;
      end

        352 :
      begin                                                                     // jGe
              ip = localMem[0+159] >= localMem[0+157] ? 358 : 353;
      end

        353 :
      begin                                                                     // mov
              localMem[0 + 160] = heapMem[localMem[0+158]*10 + localMem[0+159]];
              ip = 354;
      end

        354 :
      begin                                                                     // mov
              heapMem[localMem[0+160]*10 + 2] = localMem[0+144];
              ip = 355;
      end

        355 :
      begin                                                                     // label
              ip = 356;
      end

        356 :
      begin                                                                     // add
              localMem[0 + 159] = localMem[0+159] + 1;
              ip = 357;
      end

        357 :
      begin                                                                     // jmp
              ip = 351;
      end

        358 :
      begin                                                                     // label
              ip = 359;
      end

        359 :
      begin                                                                     // mov
              localMem[0 + 161] = heapMem[localMem[0+136]*10 + 6];
              ip = 360;
      end

        360 :
      begin                                                                     // resize
              arraySizes[localMem[0+161]] = localMem[0+142];
              ip = 361;
      end

        361 :
      begin                                                                     // jmp
              ip = 369;
      end

        362 :
      begin                                                                     // label
              ip = 363;
      end

        363 :
      begin                                                                     // mov
              localMem[0 + 162] = heapMem[localMem[0+136]*10 + 4];
              ip = 364;
      end

        364 :
      begin                                                                     // mov
              localMem[0 + 163] = heapMem[localMem[0+144]*10 + 4];
              ip = 365;
      end

        365 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+141]) begin
                  heapMem[NArea * localMem[0+163] + 0 + i] = heapMem[NArea * localMem[0+162] + localMem[142] + i];
                end
              end
              ip = 366;
      end

        366 :
      begin                                                                     // mov
              localMem[0 + 164] = heapMem[localMem[0+136]*10 + 5];
              ip = 367;
      end

        367 :
      begin                                                                     // mov
              localMem[0 + 165] = heapMem[localMem[0+144]*10 + 5];
              ip = 368;
      end

        368 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+141]) begin
                  heapMem[NArea * localMem[0+165] + 0 + i] = heapMem[NArea * localMem[0+164] + localMem[142] + i];
                end
              end
              ip = 369;
      end

        369 :
      begin                                                                     // label
              ip = 370;
      end

        370 :
      begin                                                                     // mov
              heapMem[localMem[0+136]*10 + 0] = localMem[0+141];
              ip = 371;
      end

        371 :
      begin                                                                     // mov
              heapMem[localMem[0+144]*10 + 2] = localMem[0+143];
              ip = 372;
      end

        372 :
      begin                                                                     // mov
              localMem[0 + 166] = heapMem[localMem[0+143]*10 + 0];
              ip = 373;
      end

        373 :
      begin                                                                     // mov
              localMem[0 + 167] = heapMem[localMem[0+143]*10 + 6];
              ip = 374;
      end

        374 :
      begin                                                                     // mov
              localMem[0 + 168] = heapMem[localMem[0+167]*10 + localMem[0+166]];
              ip = 375;
      end

        375 :
      begin                                                                     // jNe
              ip = localMem[0+168] != localMem[0+136] ? 394 : 376;
      end

        376 :
      begin                                                                     // mov
              localMem[0 + 169] = heapMem[localMem[0+136]*10 + 4];
              ip = 377;
      end

        377 :
      begin                                                                     // mov
              localMem[0 + 170] = heapMem[localMem[0+169]*10 + localMem[0+141]];
              ip = 378;
      end

        378 :
      begin                                                                     // mov
              localMem[0 + 171] = heapMem[localMem[0+143]*10 + 4];
              ip = 379;
      end

        379 :
      begin                                                                     // mov
              heapMem[localMem[0+171]*10 + localMem[0+166]] = localMem[0+170];
              ip = 380;
      end

        380 :
      begin                                                                     // mov
              localMem[0 + 172] = heapMem[localMem[0+136]*10 + 5];
              ip = 381;
      end

        381 :
      begin                                                                     // mov
              localMem[0 + 173] = heapMem[localMem[0+172]*10 + localMem[0+141]];
              ip = 382;
      end

        382 :
      begin                                                                     // mov
              localMem[0 + 174] = heapMem[localMem[0+143]*10 + 5];
              ip = 383;
      end

        383 :
      begin                                                                     // mov
              heapMem[localMem[0+174]*10 + localMem[0+166]] = localMem[0+173];
              ip = 384;
      end

        384 :
      begin                                                                     // mov
              localMem[0 + 175] = heapMem[localMem[0+136]*10 + 4];
              ip = 385;
      end

        385 :
      begin                                                                     // resize
              arraySizes[localMem[0+175]] = localMem[0+141];
              ip = 386;
      end

        386 :
      begin                                                                     // mov
              localMem[0 + 176] = heapMem[localMem[0+136]*10 + 5];
              ip = 387;
      end

        387 :
      begin                                                                     // resize
              arraySizes[localMem[0+176]] = localMem[0+141];
              ip = 388;
      end

        388 :
      begin                                                                     // add
              localMem[0 + 177] = localMem[0+166] + 1;
              ip = 389;
      end

        389 :
      begin                                                                     // mov
              heapMem[localMem[0+143]*10 + 0] = localMem[0+177];
              ip = 390;
      end

        390 :
      begin                                                                     // mov
              localMem[0 + 178] = heapMem[localMem[0+143]*10 + 6];
              ip = 391;
      end

        391 :
      begin                                                                     // mov
              heapMem[localMem[0+178]*10 + localMem[0+177]] = localMem[0+144];
              ip = 392;
      end

        392 :
      begin                                                                     // jmp
              ip = 532;
      end

        393 :
      begin                                                                     // jmp
              ip = 416;
      end

        394 :
      begin                                                                     // label
              ip = 395;
      end

        395 :
      begin                                                                     // assertNe
            ip = 396;
      end

        396 :
      begin                                                                     // mov
              localMem[0 + 179] = heapMem[localMem[0+143]*10 + 6];
              ip = 397;
      end

        397 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+179] * NArea + i] == localMem[0+136]) localMem[0 + 180] = i + 1;
              end
              ip = 398;
      end

        398 :
      begin                                                                     // subtract
              localMem[0 + 180] = localMem[0+180] - 1;
              ip = 399;
      end

        399 :
      begin                                                                     // mov
              localMem[0 + 181] = heapMem[localMem[0+136]*10 + 4];
              ip = 400;
      end

        400 :
      begin                                                                     // mov
              localMem[0 + 182] = heapMem[localMem[0+181]*10 + localMem[0+141]];
              ip = 401;
      end

        401 :
      begin                                                                     // mov
              localMem[0 + 183] = heapMem[localMem[0+136]*10 + 5];
              ip = 402;
      end

        402 :
      begin                                                                     // mov
              localMem[0 + 184] = heapMem[localMem[0+183]*10 + localMem[0+141]];
              ip = 403;
      end

        403 :
      begin                                                                     // mov
              localMem[0 + 185] = heapMem[localMem[0+136]*10 + 4];
              ip = 404;
      end

        404 :
      begin                                                                     // resize
              arraySizes[localMem[0+185]] = localMem[0+141];
              ip = 405;
      end

        405 :
      begin                                                                     // mov
              localMem[0 + 186] = heapMem[localMem[0+136]*10 + 5];
              ip = 406;
      end

        406 :
      begin                                                                     // resize
              arraySizes[localMem[0+186]] = localMem[0+141];
              ip = 407;
      end

        407 :
      begin                                                                     // mov
              localMem[0 + 187] = heapMem[localMem[0+143]*10 + 4];
              ip = 408;
      end

        408 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+187] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[180]) begin
                  heapMem[NArea * localMem[0+187] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+187] + localMem[180]] = localMem[0+182];                                    // Insert new value
              arraySizes[localMem[0+187]] = arraySizes[localMem[0+187]] + 1;                              // Increase array size
              ip = 409;
      end

        409 :
      begin                                                                     // mov
              localMem[0 + 188] = heapMem[localMem[0+143]*10 + 5];
              ip = 410;
      end

        410 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+188] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[180]) begin
                  heapMem[NArea * localMem[0+188] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+188] + localMem[180]] = localMem[0+184];                                    // Insert new value
              arraySizes[localMem[0+188]] = arraySizes[localMem[0+188]] + 1;                              // Increase array size
              ip = 411;
      end

        411 :
      begin                                                                     // mov
              localMem[0 + 189] = heapMem[localMem[0+143]*10 + 6];
              ip = 412;
      end

        412 :
      begin                                                                     // add
              localMem[0 + 190] = localMem[0+180] + 1;
              ip = 413;
      end

        413 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+189] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[190]) begin
                  heapMem[NArea * localMem[0+189] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+189] + localMem[190]] = localMem[0+144];                                    // Insert new value
              arraySizes[localMem[0+189]] = arraySizes[localMem[0+189]] + 1;                              // Increase array size
              ip = 414;
      end

        414 :
      begin                                                                     // add
              heapMem[localMem[0+143]*10 + 0] = heapMem[localMem[0+143]*10 + 0] + 1;
              ip = 415;
      end

        415 :
      begin                                                                     // jmp
              ip = 532;
      end

        416 :
      begin                                                                     // label
              ip = 417;
      end

        417 :
      begin                                                                     // label
              ip = 418;
      end

        418 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 191] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 191] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 191]] = 0;
              ip = 419;
      end

        419 :
      begin                                                                     // mov
              heapMem[localMem[0+191]*10 + 0] = localMem[0+141];
              ip = 420;
      end

        420 :
      begin                                                                     // mov
              heapMem[localMem[0+191]*10 + 2] = 0;
              ip = 421;
      end

        421 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 192] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 192] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 192]] = 0;
              ip = 422;
      end

        422 :
      begin                                                                     // mov
              heapMem[localMem[0+191]*10 + 4] = localMem[0+192];
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
              heapMem[localMem[0+191]*10 + 5] = localMem[0+193];
              ip = 425;
      end

        425 :
      begin                                                                     // mov
              heapMem[localMem[0+191]*10 + 6] = 0;
              ip = 426;
      end

        426 :
      begin                                                                     // mov
              heapMem[localMem[0+191]*10 + 3] = localMem[0+139];
              ip = 427;
      end

        427 :
      begin                                                                     // add
              heapMem[localMem[0+139]*10 + 1] = heapMem[localMem[0+139]*10 + 1] + 1;
              ip = 428;
      end

        428 :
      begin                                                                     // mov
              heapMem[localMem[0+191]*10 + 1] = heapMem[localMem[0+139]*10 + 1];
              ip = 429;
      end

        429 :
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
              ip = 430;
      end

        430 :
      begin                                                                     // mov
              heapMem[localMem[0+194]*10 + 0] = localMem[0+141];
              ip = 431;
      end

        431 :
      begin                                                                     // mov
              heapMem[localMem[0+194]*10 + 2] = 0;
              ip = 432;
      end

        432 :
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
              ip = 433;
      end

        433 :
      begin                                                                     // mov
              heapMem[localMem[0+194]*10 + 4] = localMem[0+195];
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
              heapMem[localMem[0+194]*10 + 5] = localMem[0+196];
              ip = 436;
      end

        436 :
      begin                                                                     // mov
              heapMem[localMem[0+194]*10 + 6] = 0;
              ip = 437;
      end

        437 :
      begin                                                                     // mov
              heapMem[localMem[0+194]*10 + 3] = localMem[0+139];
              ip = 438;
      end

        438 :
      begin                                                                     // add
              heapMem[localMem[0+139]*10 + 1] = heapMem[localMem[0+139]*10 + 1] + 1;
              ip = 439;
      end

        439 :
      begin                                                                     // mov
              heapMem[localMem[0+194]*10 + 1] = heapMem[localMem[0+139]*10 + 1];
              ip = 440;
      end

        440 :
      begin                                                                     // not
              localMem[0 + 197] = !heapMem[localMem[0+136]*10 + 6];
              ip = 441;
      end

        441 :
      begin                                                                     // jNe
              ip = localMem[0+197] != 0 ? 493 : 442;
      end

        442 :
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
              ip = 443;
      end

        443 :
      begin                                                                     // mov
              heapMem[localMem[0+191]*10 + 6] = localMem[0+198];
              ip = 444;
      end

        444 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 199] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 199] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 199]] = 0;
              ip = 445;
      end

        445 :
      begin                                                                     // mov
              heapMem[localMem[0+194]*10 + 6] = localMem[0+199];
              ip = 446;
      end

        446 :
      begin                                                                     // mov
              localMem[0 + 200] = heapMem[localMem[0+136]*10 + 4];
              ip = 447;
      end

        447 :
      begin                                                                     // mov
              localMem[0 + 201] = heapMem[localMem[0+191]*10 + 4];
              ip = 448;
      end

        448 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+141]) begin
                  heapMem[NArea * localMem[0+201] + 0 + i] = heapMem[NArea * localMem[0+200] + 0 + i];
                end
              end
              ip = 449;
      end

        449 :
      begin                                                                     // mov
              localMem[0 + 202] = heapMem[localMem[0+136]*10 + 5];
              ip = 450;
      end

        450 :
      begin                                                                     // mov
              localMem[0 + 203] = heapMem[localMem[0+191]*10 + 5];
              ip = 451;
      end

        451 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+141]) begin
                  heapMem[NArea * localMem[0+203] + 0 + i] = heapMem[NArea * localMem[0+202] + 0 + i];
                end
              end
              ip = 452;
      end

        452 :
      begin                                                                     // mov
              localMem[0 + 204] = heapMem[localMem[0+136]*10 + 6];
              ip = 453;
      end

        453 :
      begin                                                                     // mov
              localMem[0 + 205] = heapMem[localMem[0+191]*10 + 6];
              ip = 454;
      end

        454 :
      begin                                                                     // add
              localMem[0 + 206] = localMem[0+141] + 1;
              ip = 455;
      end

        455 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+206]) begin
                  heapMem[NArea * localMem[0+205] + 0 + i] = heapMem[NArea * localMem[0+204] + 0 + i];
                end
              end
              ip = 456;
      end

        456 :
      begin                                                                     // mov
              localMem[0 + 207] = heapMem[localMem[0+136]*10 + 4];
              ip = 457;
      end

        457 :
      begin                                                                     // mov
              localMem[0 + 208] = heapMem[localMem[0+194]*10 + 4];
              ip = 458;
      end

        458 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+141]) begin
                  heapMem[NArea * localMem[0+208] + 0 + i] = heapMem[NArea * localMem[0+207] + localMem[142] + i];
                end
              end
              ip = 459;
      end

        459 :
      begin                                                                     // mov
              localMem[0 + 209] = heapMem[localMem[0+136]*10 + 5];
              ip = 460;
      end

        460 :
      begin                                                                     // mov
              localMem[0 + 210] = heapMem[localMem[0+194]*10 + 5];
              ip = 461;
      end

        461 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+141]) begin
                  heapMem[NArea * localMem[0+210] + 0 + i] = heapMem[NArea * localMem[0+209] + localMem[142] + i];
                end
              end
              ip = 462;
      end

        462 :
      begin                                                                     // mov
              localMem[0 + 211] = heapMem[localMem[0+136]*10 + 6];
              ip = 463;
      end

        463 :
      begin                                                                     // mov
              localMem[0 + 212] = heapMem[localMem[0+194]*10 + 6];
              ip = 464;
      end

        464 :
      begin                                                                     // add
              localMem[0 + 213] = localMem[0+141] + 1;
              ip = 465;
      end

        465 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+213]) begin
                  heapMem[NArea * localMem[0+212] + 0 + i] = heapMem[NArea * localMem[0+211] + localMem[142] + i];
                end
              end
              ip = 466;
      end

        466 :
      begin                                                                     // mov
              localMem[0 + 214] = heapMem[localMem[0+191]*10 + 0];
              ip = 467;
      end

        467 :
      begin                                                                     // add
              localMem[0 + 215] = localMem[0+214] + 1;
              ip = 468;
      end

        468 :
      begin                                                                     // mov
              localMem[0 + 216] = heapMem[localMem[0+191]*10 + 6];
              ip = 469;
      end

        469 :
      begin                                                                     // label
              ip = 470;
      end

        470 :
      begin                                                                     // mov
              localMem[0 + 217] = 0;
              ip = 471;
      end

        471 :
      begin                                                                     // label
              ip = 472;
      end

        472 :
      begin                                                                     // jGe
              ip = localMem[0+217] >= localMem[0+215] ? 478 : 473;
      end

        473 :
      begin                                                                     // mov
              localMem[0 + 218] = heapMem[localMem[0+216]*10 + localMem[0+217]];
              ip = 474;
      end

        474 :
      begin                                                                     // mov
              heapMem[localMem[0+218]*10 + 2] = localMem[0+191];
              ip = 475;
      end

        475 :
      begin                                                                     // label
              ip = 476;
      end

        476 :
      begin                                                                     // add
              localMem[0 + 217] = localMem[0+217] + 1;
              ip = 477;
      end

        477 :
      begin                                                                     // jmp
              ip = 471;
      end

        478 :
      begin                                                                     // label
              ip = 479;
      end

        479 :
      begin                                                                     // mov
              localMem[0 + 219] = heapMem[localMem[0+194]*10 + 0];
              ip = 480;
      end

        480 :
      begin                                                                     // add
              localMem[0 + 220] = localMem[0+219] + 1;
              ip = 481;
      end

        481 :
      begin                                                                     // mov
              localMem[0 + 221] = heapMem[localMem[0+194]*10 + 6];
              ip = 482;
      end

        482 :
      begin                                                                     // label
              ip = 483;
      end

        483 :
      begin                                                                     // mov
              localMem[0 + 222] = 0;
              ip = 484;
      end

        484 :
      begin                                                                     // label
              ip = 485;
      end

        485 :
      begin                                                                     // jGe
              ip = localMem[0+222] >= localMem[0+220] ? 491 : 486;
      end

        486 :
      begin                                                                     // mov
              localMem[0 + 223] = heapMem[localMem[0+221]*10 + localMem[0+222]];
              ip = 487;
      end

        487 :
      begin                                                                     // mov
              heapMem[localMem[0+223]*10 + 2] = localMem[0+194];
              ip = 488;
      end

        488 :
      begin                                                                     // label
              ip = 489;
      end

        489 :
      begin                                                                     // add
              localMem[0 + 222] = localMem[0+222] + 1;
              ip = 490;
      end

        490 :
      begin                                                                     // jmp
              ip = 484;
      end

        491 :
      begin                                                                     // label
              ip = 492;
      end

        492 :
      begin                                                                     // jmp
              ip = 508;
      end

        493 :
      begin                                                                     // label
              ip = 494;
      end

        494 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 224] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 224] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 224]] = 0;
              ip = 495;
      end

        495 :
      begin                                                                     // mov
              heapMem[localMem[0+136]*10 + 6] = localMem[0+224];
              ip = 496;
      end

        496 :
      begin                                                                     // mov
              localMem[0 + 225] = heapMem[localMem[0+136]*10 + 4];
              ip = 497;
      end

        497 :
      begin                                                                     // mov
              localMem[0 + 226] = heapMem[localMem[0+191]*10 + 4];
              ip = 498;
      end

        498 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+141]) begin
                  heapMem[NArea * localMem[0+226] + 0 + i] = heapMem[NArea * localMem[0+225] + 0 + i];
                end
              end
              ip = 499;
      end

        499 :
      begin                                                                     // mov
              localMem[0 + 227] = heapMem[localMem[0+136]*10 + 5];
              ip = 500;
      end

        500 :
      begin                                                                     // mov
              localMem[0 + 228] = heapMem[localMem[0+191]*10 + 5];
              ip = 501;
      end

        501 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+141]) begin
                  heapMem[NArea * localMem[0+228] + 0 + i] = heapMem[NArea * localMem[0+227] + 0 + i];
                end
              end
              ip = 502;
      end

        502 :
      begin                                                                     // mov
              localMem[0 + 229] = heapMem[localMem[0+136]*10 + 4];
              ip = 503;
      end

        503 :
      begin                                                                     // mov
              localMem[0 + 230] = heapMem[localMem[0+194]*10 + 4];
              ip = 504;
      end

        504 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+141]) begin
                  heapMem[NArea * localMem[0+230] + 0 + i] = heapMem[NArea * localMem[0+229] + localMem[142] + i];
                end
              end
              ip = 505;
      end

        505 :
      begin                                                                     // mov
              localMem[0 + 231] = heapMem[localMem[0+136]*10 + 5];
              ip = 506;
      end

        506 :
      begin                                                                     // mov
              localMem[0 + 232] = heapMem[localMem[0+194]*10 + 5];
              ip = 507;
      end

        507 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+141]) begin
                  heapMem[NArea * localMem[0+232] + 0 + i] = heapMem[NArea * localMem[0+231] + localMem[142] + i];
                end
              end
              ip = 508;
      end

        508 :
      begin                                                                     // label
              ip = 509;
      end

        509 :
      begin                                                                     // mov
              heapMem[localMem[0+191]*10 + 2] = localMem[0+136];
              ip = 510;
      end

        510 :
      begin                                                                     // mov
              heapMem[localMem[0+194]*10 + 2] = localMem[0+136];
              ip = 511;
      end

        511 :
      begin                                                                     // mov
              localMem[0 + 233] = heapMem[localMem[0+136]*10 + 4];
              ip = 512;
      end

        512 :
      begin                                                                     // mov
              localMem[0 + 234] = heapMem[localMem[0+233]*10 + localMem[0+141]];
              ip = 513;
      end

        513 :
      begin                                                                     // mov
              localMem[0 + 235] = heapMem[localMem[0+136]*10 + 5];
              ip = 514;
      end

        514 :
      begin                                                                     // mov
              localMem[0 + 236] = heapMem[localMem[0+235]*10 + localMem[0+141]];
              ip = 515;
      end

        515 :
      begin                                                                     // mov
              localMem[0 + 237] = heapMem[localMem[0+136]*10 + 4];
              ip = 516;
      end

        516 :
      begin                                                                     // mov
              heapMem[localMem[0+237]*10 + 0] = localMem[0+234];
              ip = 517;
      end

        517 :
      begin                                                                     // mov
              localMem[0 + 238] = heapMem[localMem[0+136]*10 + 5];
              ip = 518;
      end

        518 :
      begin                                                                     // mov
              heapMem[localMem[0+238]*10 + 0] = localMem[0+236];
              ip = 519;
      end

        519 :
      begin                                                                     // mov
              localMem[0 + 239] = heapMem[localMem[0+136]*10 + 6];
              ip = 520;
      end

        520 :
      begin                                                                     // mov
              heapMem[localMem[0+239]*10 + 0] = localMem[0+191];
              ip = 521;
      end

        521 :
      begin                                                                     // mov
              localMem[0 + 240] = heapMem[localMem[0+136]*10 + 6];
              ip = 522;
      end

        522 :
      begin                                                                     // mov
              heapMem[localMem[0+240]*10 + 1] = localMem[0+194];
              ip = 523;
      end

        523 :
      begin                                                                     // mov
              heapMem[localMem[0+136]*10 + 0] = 1;
              ip = 524;
      end

        524 :
      begin                                                                     // mov
              localMem[0 + 241] = heapMem[localMem[0+136]*10 + 4];
              ip = 525;
      end

        525 :
      begin                                                                     // resize
              arraySizes[localMem[0+241]] = 1;
              ip = 526;
      end

        526 :
      begin                                                                     // mov
              localMem[0 + 242] = heapMem[localMem[0+136]*10 + 5];
              ip = 527;
      end

        527 :
      begin                                                                     // resize
              arraySizes[localMem[0+242]] = 1;
              ip = 528;
      end

        528 :
      begin                                                                     // mov
              localMem[0 + 243] = heapMem[localMem[0+136]*10 + 6];
              ip = 529;
      end

        529 :
      begin                                                                     // resize
              arraySizes[localMem[0+243]] = 2;
              ip = 530;
      end

        530 :
      begin                                                                     // jmp
              ip = 532;
      end

        531 :
      begin                                                                     // jmp
              ip = 537;
      end

        532 :
      begin                                                                     // label
              ip = 533;
      end

        533 :
      begin                                                                     // mov
              localMem[0 + 137] = 1;
              ip = 534;
      end

        534 :
      begin                                                                     // jmp
              ip = 537;
      end

        535 :
      begin                                                                     // label
              ip = 536;
      end

        536 :
      begin                                                                     // mov
              localMem[0 + 137] = 0;
              ip = 537;
      end

        537 :
      begin                                                                     // label
              ip = 538;
      end

        538 :
      begin                                                                     // jNe
              ip = localMem[0+137] != 0 ? 540 : 539;
      end

        539 :
      begin                                                                     // mov
              localMem[0 + 21] = localMem[0+136];
              ip = 540;
      end

        540 :
      begin                                                                     // label
              ip = 541;
      end

        541 :
      begin                                                                     // jmp
              ip = 791;
      end

        542 :
      begin                                                                     // label
              ip = 543;
      end

        543 :
      begin                                                                     // mov
              localMem[0 + 244] = heapMem[localMem[0+21]*10 + 4];
              ip = 544;
      end

        544 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+244] * NArea + i] == 1) localMem[0 + 245] = i + 1;
              end
              ip = 545;
      end

        545 :
      begin                                                                     // jEq
              ip = localMem[0+245] == 0 ? 550 : 546;
      end

        546 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 0] = localMem[0+21];
              ip = 547;
      end

        547 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 1] = 1;
              ip = 548;
      end

        548 :
      begin                                                                     // subtract
              heapMem[localMem[0+1]*10 + 2] = localMem[0+245] - 1;
              ip = 549;
      end

        549 :
      begin                                                                     // jmp
              ip = 798;
      end

        550 :
      begin                                                                     // label
              ip = 551;
      end

        551 :
      begin                                                                     // arrayCountLess
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+244] * NArea + i] < 1) j = j + 1;
              end
              localMem[0 + 246] = j;
              ip = 552;
      end

        552 :
      begin                                                                     // not
              localMem[0 + 247] = !heapMem[localMem[0+21]*10 + 6];
              ip = 553;
      end

        553 :
      begin                                                                     // jEq
              ip = localMem[0+247] == 0 ? 558 : 554;
      end

        554 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 0] = localMem[0+21];
              ip = 555;
      end

        555 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 1] = 0;
              ip = 556;
      end

        556 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 2] = localMem[0+246];
              ip = 557;
      end

        557 :
      begin                                                                     // jmp
              ip = 798;
      end

        558 :
      begin                                                                     // label
              ip = 559;
      end

        559 :
      begin                                                                     // mov
              localMem[0 + 248] = heapMem[localMem[0+21]*10 + 6];
              ip = 560;
      end

        560 :
      begin                                                                     // mov
              localMem[0 + 249] = heapMem[localMem[0+248]*10 + localMem[0+246]];
              ip = 561;
      end

        561 :
      begin                                                                     // label
              ip = 562;
      end

        562 :
      begin                                                                     // mov
              localMem[0 + 251] = heapMem[localMem[0+249]*10 + 0];
              ip = 563;
      end

        563 :
      begin                                                                     // mov
              localMem[0 + 252] = heapMem[localMem[0+249]*10 + 3];
              ip = 564;
      end

        564 :
      begin                                                                     // mov
              localMem[0 + 253] = heapMem[localMem[0+252]*10 + 2];
              ip = 565;
      end

        565 :
      begin                                                                     // jLt
              ip = localMem[0+251] <  localMem[0+253] ? 785 : 566;
      end

        566 :
      begin                                                                     // mov
              localMem[0 + 254] = localMem[0+253];
              ip = 567;
      end

        567 :
      begin                                                                     // shiftRight
              localMem[0 + 254] = localMem[0+254] >> 1;
              ip = 568;
      end

        568 :
      begin                                                                     // add
              localMem[0 + 255] = localMem[0+254] + 1;
              ip = 569;
      end

        569 :
      begin                                                                     // mov
              localMem[0 + 256] = heapMem[localMem[0+249]*10 + 2];
              ip = 570;
      end

        570 :
      begin                                                                     // jEq
              ip = localMem[0+256] == 0 ? 667 : 571;
      end

        571 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 257] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 257] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 257]] = 0;
              ip = 572;
      end

        572 :
      begin                                                                     // mov
              heapMem[localMem[0+257]*10 + 0] = localMem[0+254];
              ip = 573;
      end

        573 :
      begin                                                                     // mov
              heapMem[localMem[0+257]*10 + 2] = 0;
              ip = 574;
      end

        574 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 258] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 258] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 258]] = 0;
              ip = 575;
      end

        575 :
      begin                                                                     // mov
              heapMem[localMem[0+257]*10 + 4] = localMem[0+258];
              ip = 576;
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
              heapMem[localMem[0+257]*10 + 5] = localMem[0+259];
              ip = 578;
      end

        578 :
      begin                                                                     // mov
              heapMem[localMem[0+257]*10 + 6] = 0;
              ip = 579;
      end

        579 :
      begin                                                                     // mov
              heapMem[localMem[0+257]*10 + 3] = localMem[0+252];
              ip = 580;
      end

        580 :
      begin                                                                     // add
              heapMem[localMem[0+252]*10 + 1] = heapMem[localMem[0+252]*10 + 1] + 1;
              ip = 581;
      end

        581 :
      begin                                                                     // mov
              heapMem[localMem[0+257]*10 + 1] = heapMem[localMem[0+252]*10 + 1];
              ip = 582;
      end

        582 :
      begin                                                                     // not
              localMem[0 + 260] = !heapMem[localMem[0+249]*10 + 6];
              ip = 583;
      end

        583 :
      begin                                                                     // jNe
              ip = localMem[0+260] != 0 ? 612 : 584;
      end

        584 :
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
              ip = 585;
      end

        585 :
      begin                                                                     // mov
              heapMem[localMem[0+257]*10 + 6] = localMem[0+261];
              ip = 586;
      end

        586 :
      begin                                                                     // mov
              localMem[0 + 262] = heapMem[localMem[0+249]*10 + 4];
              ip = 587;
      end

        587 :
      begin                                                                     // mov
              localMem[0 + 263] = heapMem[localMem[0+257]*10 + 4];
              ip = 588;
      end

        588 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+254]) begin
                  heapMem[NArea * localMem[0+263] + 0 + i] = heapMem[NArea * localMem[0+262] + localMem[255] + i];
                end
              end
              ip = 589;
      end

        589 :
      begin                                                                     // mov
              localMem[0 + 264] = heapMem[localMem[0+249]*10 + 5];
              ip = 590;
      end

        590 :
      begin                                                                     // mov
              localMem[0 + 265] = heapMem[localMem[0+257]*10 + 5];
              ip = 591;
      end

        591 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+254]) begin
                  heapMem[NArea * localMem[0+265] + 0 + i] = heapMem[NArea * localMem[0+264] + localMem[255] + i];
                end
              end
              ip = 592;
      end

        592 :
      begin                                                                     // mov
              localMem[0 + 266] = heapMem[localMem[0+249]*10 + 6];
              ip = 593;
      end

        593 :
      begin                                                                     // mov
              localMem[0 + 267] = heapMem[localMem[0+257]*10 + 6];
              ip = 594;
      end

        594 :
      begin                                                                     // add
              localMem[0 + 268] = localMem[0+254] + 1;
              ip = 595;
      end

        595 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+268]) begin
                  heapMem[NArea * localMem[0+267] + 0 + i] = heapMem[NArea * localMem[0+266] + localMem[255] + i];
                end
              end
              ip = 596;
      end

        596 :
      begin                                                                     // mov
              localMem[0 + 269] = heapMem[localMem[0+257]*10 + 0];
              ip = 597;
      end

        597 :
      begin                                                                     // add
              localMem[0 + 270] = localMem[0+269] + 1;
              ip = 598;
      end

        598 :
      begin                                                                     // mov
              localMem[0 + 271] = heapMem[localMem[0+257]*10 + 6];
              ip = 599;
      end

        599 :
      begin                                                                     // label
              ip = 600;
      end

        600 :
      begin                                                                     // mov
              localMem[0 + 272] = 0;
              ip = 601;
      end

        601 :
      begin                                                                     // label
              ip = 602;
      end

        602 :
      begin                                                                     // jGe
              ip = localMem[0+272] >= localMem[0+270] ? 608 : 603;
      end

        603 :
      begin                                                                     // mov
              localMem[0 + 273] = heapMem[localMem[0+271]*10 + localMem[0+272]];
              ip = 604;
      end

        604 :
      begin                                                                     // mov
              heapMem[localMem[0+273]*10 + 2] = localMem[0+257];
              ip = 605;
      end

        605 :
      begin                                                                     // label
              ip = 606;
      end

        606 :
      begin                                                                     // add
              localMem[0 + 272] = localMem[0+272] + 1;
              ip = 607;
      end

        607 :
      begin                                                                     // jmp
              ip = 601;
      end

        608 :
      begin                                                                     // label
              ip = 609;
      end

        609 :
      begin                                                                     // mov
              localMem[0 + 274] = heapMem[localMem[0+249]*10 + 6];
              ip = 610;
      end

        610 :
      begin                                                                     // resize
              arraySizes[localMem[0+274]] = localMem[0+255];
              ip = 611;
      end

        611 :
      begin                                                                     // jmp
              ip = 619;
      end

        612 :
      begin                                                                     // label
              ip = 613;
      end

        613 :
      begin                                                                     // mov
              localMem[0 + 275] = heapMem[localMem[0+249]*10 + 4];
              ip = 614;
      end

        614 :
      begin                                                                     // mov
              localMem[0 + 276] = heapMem[localMem[0+257]*10 + 4];
              ip = 615;
      end

        615 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+254]) begin
                  heapMem[NArea * localMem[0+276] + 0 + i] = heapMem[NArea * localMem[0+275] + localMem[255] + i];
                end
              end
              ip = 616;
      end

        616 :
      begin                                                                     // mov
              localMem[0 + 277] = heapMem[localMem[0+249]*10 + 5];
              ip = 617;
      end

        617 :
      begin                                                                     // mov
              localMem[0 + 278] = heapMem[localMem[0+257]*10 + 5];
              ip = 618;
      end

        618 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+254]) begin
                  heapMem[NArea * localMem[0+278] + 0 + i] = heapMem[NArea * localMem[0+277] + localMem[255] + i];
                end
              end
              ip = 619;
      end

        619 :
      begin                                                                     // label
              ip = 620;
      end

        620 :
      begin                                                                     // mov
              heapMem[localMem[0+249]*10 + 0] = localMem[0+254];
              ip = 621;
      end

        621 :
      begin                                                                     // mov
              heapMem[localMem[0+257]*10 + 2] = localMem[0+256];
              ip = 622;
      end

        622 :
      begin                                                                     // mov
              localMem[0 + 279] = heapMem[localMem[0+256]*10 + 0];
              ip = 623;
      end

        623 :
      begin                                                                     // mov
              localMem[0 + 280] = heapMem[localMem[0+256]*10 + 6];
              ip = 624;
      end

        624 :
      begin                                                                     // mov
              localMem[0 + 281] = heapMem[localMem[0+280]*10 + localMem[0+279]];
              ip = 625;
      end

        625 :
      begin                                                                     // jNe
              ip = localMem[0+281] != localMem[0+249] ? 644 : 626;
      end

        626 :
      begin                                                                     // mov
              localMem[0 + 282] = heapMem[localMem[0+249]*10 + 4];
              ip = 627;
      end

        627 :
      begin                                                                     // mov
              localMem[0 + 283] = heapMem[localMem[0+282]*10 + localMem[0+254]];
              ip = 628;
      end

        628 :
      begin                                                                     // mov
              localMem[0 + 284] = heapMem[localMem[0+256]*10 + 4];
              ip = 629;
      end

        629 :
      begin                                                                     // mov
              heapMem[localMem[0+284]*10 + localMem[0+279]] = localMem[0+283];
              ip = 630;
      end

        630 :
      begin                                                                     // mov
              localMem[0 + 285] = heapMem[localMem[0+249]*10 + 5];
              ip = 631;
      end

        631 :
      begin                                                                     // mov
              localMem[0 + 286] = heapMem[localMem[0+285]*10 + localMem[0+254]];
              ip = 632;
      end

        632 :
      begin                                                                     // mov
              localMem[0 + 287] = heapMem[localMem[0+256]*10 + 5];
              ip = 633;
      end

        633 :
      begin                                                                     // mov
              heapMem[localMem[0+287]*10 + localMem[0+279]] = localMem[0+286];
              ip = 634;
      end

        634 :
      begin                                                                     // mov
              localMem[0 + 288] = heapMem[localMem[0+249]*10 + 4];
              ip = 635;
      end

        635 :
      begin                                                                     // resize
              arraySizes[localMem[0+288]] = localMem[0+254];
              ip = 636;
      end

        636 :
      begin                                                                     // mov
              localMem[0 + 289] = heapMem[localMem[0+249]*10 + 5];
              ip = 637;
      end

        637 :
      begin                                                                     // resize
              arraySizes[localMem[0+289]] = localMem[0+254];
              ip = 638;
      end

        638 :
      begin                                                                     // add
              localMem[0 + 290] = localMem[0+279] + 1;
              ip = 639;
      end

        639 :
      begin                                                                     // mov
              heapMem[localMem[0+256]*10 + 0] = localMem[0+290];
              ip = 640;
      end

        640 :
      begin                                                                     // mov
              localMem[0 + 291] = heapMem[localMem[0+256]*10 + 6];
              ip = 641;
      end

        641 :
      begin                                                                     // mov
              heapMem[localMem[0+291]*10 + localMem[0+290]] = localMem[0+257];
              ip = 642;
      end

        642 :
      begin                                                                     // jmp
              ip = 782;
      end

        643 :
      begin                                                                     // jmp
              ip = 666;
      end

        644 :
      begin                                                                     // label
              ip = 645;
      end

        645 :
      begin                                                                     // assertNe
            ip = 646;
      end

        646 :
      begin                                                                     // mov
              localMem[0 + 292] = heapMem[localMem[0+256]*10 + 6];
              ip = 647;
      end

        647 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+292] * NArea + i] == localMem[0+249]) localMem[0 + 293] = i + 1;
              end
              ip = 648;
      end

        648 :
      begin                                                                     // subtract
              localMem[0 + 293] = localMem[0+293] - 1;
              ip = 649;
      end

        649 :
      begin                                                                     // mov
              localMem[0 + 294] = heapMem[localMem[0+249]*10 + 4];
              ip = 650;
      end

        650 :
      begin                                                                     // mov
              localMem[0 + 295] = heapMem[localMem[0+294]*10 + localMem[0+254]];
              ip = 651;
      end

        651 :
      begin                                                                     // mov
              localMem[0 + 296] = heapMem[localMem[0+249]*10 + 5];
              ip = 652;
      end

        652 :
      begin                                                                     // mov
              localMem[0 + 297] = heapMem[localMem[0+296]*10 + localMem[0+254]];
              ip = 653;
      end

        653 :
      begin                                                                     // mov
              localMem[0 + 298] = heapMem[localMem[0+249]*10 + 4];
              ip = 654;
      end

        654 :
      begin                                                                     // resize
              arraySizes[localMem[0+298]] = localMem[0+254];
              ip = 655;
      end

        655 :
      begin                                                                     // mov
              localMem[0 + 299] = heapMem[localMem[0+249]*10 + 5];
              ip = 656;
      end

        656 :
      begin                                                                     // resize
              arraySizes[localMem[0+299]] = localMem[0+254];
              ip = 657;
      end

        657 :
      begin                                                                     // mov
              localMem[0 + 300] = heapMem[localMem[0+256]*10 + 4];
              ip = 658;
      end

        658 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+300] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[293]) begin
                  heapMem[NArea * localMem[0+300] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+300] + localMem[293]] = localMem[0+295];                                    // Insert new value
              arraySizes[localMem[0+300]] = arraySizes[localMem[0+300]] + 1;                              // Increase array size
              ip = 659;
      end

        659 :
      begin                                                                     // mov
              localMem[0 + 301] = heapMem[localMem[0+256]*10 + 5];
              ip = 660;
      end

        660 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+301] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[293]) begin
                  heapMem[NArea * localMem[0+301] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+301] + localMem[293]] = localMem[0+297];                                    // Insert new value
              arraySizes[localMem[0+301]] = arraySizes[localMem[0+301]] + 1;                              // Increase array size
              ip = 661;
      end

        661 :
      begin                                                                     // mov
              localMem[0 + 302] = heapMem[localMem[0+256]*10 + 6];
              ip = 662;
      end

        662 :
      begin                                                                     // add
              localMem[0 + 303] = localMem[0+293] + 1;
              ip = 663;
      end

        663 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+302] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[303]) begin
                  heapMem[NArea * localMem[0+302] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+302] + localMem[303]] = localMem[0+257];                                    // Insert new value
              arraySizes[localMem[0+302]] = arraySizes[localMem[0+302]] + 1;                              // Increase array size
              ip = 664;
      end

        664 :
      begin                                                                     // add
              heapMem[localMem[0+256]*10 + 0] = heapMem[localMem[0+256]*10 + 0] + 1;
              ip = 665;
      end

        665 :
      begin                                                                     // jmp
              ip = 782;
      end

        666 :
      begin                                                                     // label
              ip = 667;
      end

        667 :
      begin                                                                     // label
              ip = 668;
      end

        668 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 304] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 304] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 304]] = 0;
              ip = 669;
      end

        669 :
      begin                                                                     // mov
              heapMem[localMem[0+304]*10 + 0] = localMem[0+254];
              ip = 670;
      end

        670 :
      begin                                                                     // mov
              heapMem[localMem[0+304]*10 + 2] = 0;
              ip = 671;
      end

        671 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 305] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 305] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 305]] = 0;
              ip = 672;
      end

        672 :
      begin                                                                     // mov
              heapMem[localMem[0+304]*10 + 4] = localMem[0+305];
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
              heapMem[localMem[0+304]*10 + 5] = localMem[0+306];
              ip = 675;
      end

        675 :
      begin                                                                     // mov
              heapMem[localMem[0+304]*10 + 6] = 0;
              ip = 676;
      end

        676 :
      begin                                                                     // mov
              heapMem[localMem[0+304]*10 + 3] = localMem[0+252];
              ip = 677;
      end

        677 :
      begin                                                                     // add
              heapMem[localMem[0+252]*10 + 1] = heapMem[localMem[0+252]*10 + 1] + 1;
              ip = 678;
      end

        678 :
      begin                                                                     // mov
              heapMem[localMem[0+304]*10 + 1] = heapMem[localMem[0+252]*10 + 1];
              ip = 679;
      end

        679 :
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
              ip = 680;
      end

        680 :
      begin                                                                     // mov
              heapMem[localMem[0+307]*10 + 0] = localMem[0+254];
              ip = 681;
      end

        681 :
      begin                                                                     // mov
              heapMem[localMem[0+307]*10 + 2] = 0;
              ip = 682;
      end

        682 :
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
              ip = 683;
      end

        683 :
      begin                                                                     // mov
              heapMem[localMem[0+307]*10 + 4] = localMem[0+308];
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
              heapMem[localMem[0+307]*10 + 5] = localMem[0+309];
              ip = 686;
      end

        686 :
      begin                                                                     // mov
              heapMem[localMem[0+307]*10 + 6] = 0;
              ip = 687;
      end

        687 :
      begin                                                                     // mov
              heapMem[localMem[0+307]*10 + 3] = localMem[0+252];
              ip = 688;
      end

        688 :
      begin                                                                     // add
              heapMem[localMem[0+252]*10 + 1] = heapMem[localMem[0+252]*10 + 1] + 1;
              ip = 689;
      end

        689 :
      begin                                                                     // mov
              heapMem[localMem[0+307]*10 + 1] = heapMem[localMem[0+252]*10 + 1];
              ip = 690;
      end

        690 :
      begin                                                                     // not
              localMem[0 + 310] = !heapMem[localMem[0+249]*10 + 6];
              ip = 691;
      end

        691 :
      begin                                                                     // jNe
              ip = localMem[0+310] != 0 ? 743 : 692;
      end

        692 :
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
              ip = 693;
      end

        693 :
      begin                                                                     // mov
              heapMem[localMem[0+304]*10 + 6] = localMem[0+311];
              ip = 694;
      end

        694 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 312] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 312] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 312]] = 0;
              ip = 695;
      end

        695 :
      begin                                                                     // mov
              heapMem[localMem[0+307]*10 + 6] = localMem[0+312];
              ip = 696;
      end

        696 :
      begin                                                                     // mov
              localMem[0 + 313] = heapMem[localMem[0+249]*10 + 4];
              ip = 697;
      end

        697 :
      begin                                                                     // mov
              localMem[0 + 314] = heapMem[localMem[0+304]*10 + 4];
              ip = 698;
      end

        698 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+254]) begin
                  heapMem[NArea * localMem[0+314] + 0 + i] = heapMem[NArea * localMem[0+313] + 0 + i];
                end
              end
              ip = 699;
      end

        699 :
      begin                                                                     // mov
              localMem[0 + 315] = heapMem[localMem[0+249]*10 + 5];
              ip = 700;
      end

        700 :
      begin                                                                     // mov
              localMem[0 + 316] = heapMem[localMem[0+304]*10 + 5];
              ip = 701;
      end

        701 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+254]) begin
                  heapMem[NArea * localMem[0+316] + 0 + i] = heapMem[NArea * localMem[0+315] + 0 + i];
                end
              end
              ip = 702;
      end

        702 :
      begin                                                                     // mov
              localMem[0 + 317] = heapMem[localMem[0+249]*10 + 6];
              ip = 703;
      end

        703 :
      begin                                                                     // mov
              localMem[0 + 318] = heapMem[localMem[0+304]*10 + 6];
              ip = 704;
      end

        704 :
      begin                                                                     // add
              localMem[0 + 319] = localMem[0+254] + 1;
              ip = 705;
      end

        705 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+319]) begin
                  heapMem[NArea * localMem[0+318] + 0 + i] = heapMem[NArea * localMem[0+317] + 0 + i];
                end
              end
              ip = 706;
      end

        706 :
      begin                                                                     // mov
              localMem[0 + 320] = heapMem[localMem[0+249]*10 + 4];
              ip = 707;
      end

        707 :
      begin                                                                     // mov
              localMem[0 + 321] = heapMem[localMem[0+307]*10 + 4];
              ip = 708;
      end

        708 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+254]) begin
                  heapMem[NArea * localMem[0+321] + 0 + i] = heapMem[NArea * localMem[0+320] + localMem[255] + i];
                end
              end
              ip = 709;
      end

        709 :
      begin                                                                     // mov
              localMem[0 + 322] = heapMem[localMem[0+249]*10 + 5];
              ip = 710;
      end

        710 :
      begin                                                                     // mov
              localMem[0 + 323] = heapMem[localMem[0+307]*10 + 5];
              ip = 711;
      end

        711 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+254]) begin
                  heapMem[NArea * localMem[0+323] + 0 + i] = heapMem[NArea * localMem[0+322] + localMem[255] + i];
                end
              end
              ip = 712;
      end

        712 :
      begin                                                                     // mov
              localMem[0 + 324] = heapMem[localMem[0+249]*10 + 6];
              ip = 713;
      end

        713 :
      begin                                                                     // mov
              localMem[0 + 325] = heapMem[localMem[0+307]*10 + 6];
              ip = 714;
      end

        714 :
      begin                                                                     // add
              localMem[0 + 326] = localMem[0+254] + 1;
              ip = 715;
      end

        715 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+326]) begin
                  heapMem[NArea * localMem[0+325] + 0 + i] = heapMem[NArea * localMem[0+324] + localMem[255] + i];
                end
              end
              ip = 716;
      end

        716 :
      begin                                                                     // mov
              localMem[0 + 327] = heapMem[localMem[0+304]*10 + 0];
              ip = 717;
      end

        717 :
      begin                                                                     // add
              localMem[0 + 328] = localMem[0+327] + 1;
              ip = 718;
      end

        718 :
      begin                                                                     // mov
              localMem[0 + 329] = heapMem[localMem[0+304]*10 + 6];
              ip = 719;
      end

        719 :
      begin                                                                     // label
              ip = 720;
      end

        720 :
      begin                                                                     // mov
              localMem[0 + 330] = 0;
              ip = 721;
      end

        721 :
      begin                                                                     // label
              ip = 722;
      end

        722 :
      begin                                                                     // jGe
              ip = localMem[0+330] >= localMem[0+328] ? 728 : 723;
      end

        723 :
      begin                                                                     // mov
              localMem[0 + 331] = heapMem[localMem[0+329]*10 + localMem[0+330]];
              ip = 724;
      end

        724 :
      begin                                                                     // mov
              heapMem[localMem[0+331]*10 + 2] = localMem[0+304];
              ip = 725;
      end

        725 :
      begin                                                                     // label
              ip = 726;
      end

        726 :
      begin                                                                     // add
              localMem[0 + 330] = localMem[0+330] + 1;
              ip = 727;
      end

        727 :
      begin                                                                     // jmp
              ip = 721;
      end

        728 :
      begin                                                                     // label
              ip = 729;
      end

        729 :
      begin                                                                     // mov
              localMem[0 + 332] = heapMem[localMem[0+307]*10 + 0];
              ip = 730;
      end

        730 :
      begin                                                                     // add
              localMem[0 + 333] = localMem[0+332] + 1;
              ip = 731;
      end

        731 :
      begin                                                                     // mov
              localMem[0 + 334] = heapMem[localMem[0+307]*10 + 6];
              ip = 732;
      end

        732 :
      begin                                                                     // label
              ip = 733;
      end

        733 :
      begin                                                                     // mov
              localMem[0 + 335] = 0;
              ip = 734;
      end

        734 :
      begin                                                                     // label
              ip = 735;
      end

        735 :
      begin                                                                     // jGe
              ip = localMem[0+335] >= localMem[0+333] ? 741 : 736;
      end

        736 :
      begin                                                                     // mov
              localMem[0 + 336] = heapMem[localMem[0+334]*10 + localMem[0+335]];
              ip = 737;
      end

        737 :
      begin                                                                     // mov
              heapMem[localMem[0+336]*10 + 2] = localMem[0+307];
              ip = 738;
      end

        738 :
      begin                                                                     // label
              ip = 739;
      end

        739 :
      begin                                                                     // add
              localMem[0 + 335] = localMem[0+335] + 1;
              ip = 740;
      end

        740 :
      begin                                                                     // jmp
              ip = 734;
      end

        741 :
      begin                                                                     // label
              ip = 742;
      end

        742 :
      begin                                                                     // jmp
              ip = 758;
      end

        743 :
      begin                                                                     // label
              ip = 744;
      end

        744 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 337] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 337] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 337]] = 0;
              ip = 745;
      end

        745 :
      begin                                                                     // mov
              heapMem[localMem[0+249]*10 + 6] = localMem[0+337];
              ip = 746;
      end

        746 :
      begin                                                                     // mov
              localMem[0 + 338] = heapMem[localMem[0+249]*10 + 4];
              ip = 747;
      end

        747 :
      begin                                                                     // mov
              localMem[0 + 339] = heapMem[localMem[0+304]*10 + 4];
              ip = 748;
      end

        748 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+254]) begin
                  heapMem[NArea * localMem[0+339] + 0 + i] = heapMem[NArea * localMem[0+338] + 0 + i];
                end
              end
              ip = 749;
      end

        749 :
      begin                                                                     // mov
              localMem[0 + 340] = heapMem[localMem[0+249]*10 + 5];
              ip = 750;
      end

        750 :
      begin                                                                     // mov
              localMem[0 + 341] = heapMem[localMem[0+304]*10 + 5];
              ip = 751;
      end

        751 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+254]) begin
                  heapMem[NArea * localMem[0+341] + 0 + i] = heapMem[NArea * localMem[0+340] + 0 + i];
                end
              end
              ip = 752;
      end

        752 :
      begin                                                                     // mov
              localMem[0 + 342] = heapMem[localMem[0+249]*10 + 4];
              ip = 753;
      end

        753 :
      begin                                                                     // mov
              localMem[0 + 343] = heapMem[localMem[0+307]*10 + 4];
              ip = 754;
      end

        754 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+254]) begin
                  heapMem[NArea * localMem[0+343] + 0 + i] = heapMem[NArea * localMem[0+342] + localMem[255] + i];
                end
              end
              ip = 755;
      end

        755 :
      begin                                                                     // mov
              localMem[0 + 344] = heapMem[localMem[0+249]*10 + 5];
              ip = 756;
      end

        756 :
      begin                                                                     // mov
              localMem[0 + 345] = heapMem[localMem[0+307]*10 + 5];
              ip = 757;
      end

        757 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+254]) begin
                  heapMem[NArea * localMem[0+345] + 0 + i] = heapMem[NArea * localMem[0+344] + localMem[255] + i];
                end
              end
              ip = 758;
      end

        758 :
      begin                                                                     // label
              ip = 759;
      end

        759 :
      begin                                                                     // mov
              heapMem[localMem[0+304]*10 + 2] = localMem[0+249];
              ip = 760;
      end

        760 :
      begin                                                                     // mov
              heapMem[localMem[0+307]*10 + 2] = localMem[0+249];
              ip = 761;
      end

        761 :
      begin                                                                     // mov
              localMem[0 + 346] = heapMem[localMem[0+249]*10 + 4];
              ip = 762;
      end

        762 :
      begin                                                                     // mov
              localMem[0 + 347] = heapMem[localMem[0+346]*10 + localMem[0+254]];
              ip = 763;
      end

        763 :
      begin                                                                     // mov
              localMem[0 + 348] = heapMem[localMem[0+249]*10 + 5];
              ip = 764;
      end

        764 :
      begin                                                                     // mov
              localMem[0 + 349] = heapMem[localMem[0+348]*10 + localMem[0+254]];
              ip = 765;
      end

        765 :
      begin                                                                     // mov
              localMem[0 + 350] = heapMem[localMem[0+249]*10 + 4];
              ip = 766;
      end

        766 :
      begin                                                                     // mov
              heapMem[localMem[0+350]*10 + 0] = localMem[0+347];
              ip = 767;
      end

        767 :
      begin                                                                     // mov
              localMem[0 + 351] = heapMem[localMem[0+249]*10 + 5];
              ip = 768;
      end

        768 :
      begin                                                                     // mov
              heapMem[localMem[0+351]*10 + 0] = localMem[0+349];
              ip = 769;
      end

        769 :
      begin                                                                     // mov
              localMem[0 + 352] = heapMem[localMem[0+249]*10 + 6];
              ip = 770;
      end

        770 :
      begin                                                                     // mov
              heapMem[localMem[0+352]*10 + 0] = localMem[0+304];
              ip = 771;
      end

        771 :
      begin                                                                     // mov
              localMem[0 + 353] = heapMem[localMem[0+249]*10 + 6];
              ip = 772;
      end

        772 :
      begin                                                                     // mov
              heapMem[localMem[0+353]*10 + 1] = localMem[0+307];
              ip = 773;
      end

        773 :
      begin                                                                     // mov
              heapMem[localMem[0+249]*10 + 0] = 1;
              ip = 774;
      end

        774 :
      begin                                                                     // mov
              localMem[0 + 354] = heapMem[localMem[0+249]*10 + 4];
              ip = 775;
      end

        775 :
      begin                                                                     // resize
              arraySizes[localMem[0+354]] = 1;
              ip = 776;
      end

        776 :
      begin                                                                     // mov
              localMem[0 + 355] = heapMem[localMem[0+249]*10 + 5];
              ip = 777;
      end

        777 :
      begin                                                                     // resize
              arraySizes[localMem[0+355]] = 1;
              ip = 778;
      end

        778 :
      begin                                                                     // mov
              localMem[0 + 356] = heapMem[localMem[0+249]*10 + 6];
              ip = 779;
      end

        779 :
      begin                                                                     // resize
              arraySizes[localMem[0+356]] = 2;
              ip = 780;
      end

        780 :
      begin                                                                     // jmp
              ip = 782;
      end

        781 :
      begin                                                                     // jmp
              ip = 787;
      end

        782 :
      begin                                                                     // label
              ip = 783;
      end

        783 :
      begin                                                                     // mov
              localMem[0 + 250] = 1;
              ip = 784;
      end

        784 :
      begin                                                                     // jmp
              ip = 787;
      end

        785 :
      begin                                                                     // label
              ip = 786;
      end

        786 :
      begin                                                                     // mov
              localMem[0 + 250] = 0;
              ip = 787;
      end

        787 :
      begin                                                                     // label
              ip = 788;
      end

        788 :
      begin                                                                     // jNe
              ip = localMem[0+250] != 0 ? 790 : 789;
      end

        789 :
      begin                                                                     // mov
              localMem[0 + 21] = localMem[0+249];
              ip = 790;
      end

        790 :
      begin                                                                     // label
              ip = 791;
      end

        791 :
      begin                                                                     // label
              ip = 792;
      end

        792 :
      begin                                                                     // add
              localMem[0 + 129] = localMem[0+129] + 1;
              ip = 793;
      end

        793 :
      begin                                                                     // jmp
              ip = 295;
      end

        794 :
      begin                                                                     // label
              ip = 795;
      end

        795 :
      begin                                                                     // assert
            ip = 796;
      end

        796 :
      begin                                                                     // label
              ip = 797;
      end

        797 :
      begin                                                                     // label
              ip = 798;
      end

        798 :
      begin                                                                     // label
              ip = 799;
      end

        799 :
      begin                                                                     // mov
              localMem[0 + 357] = heapMem[localMem[0+1]*10 + 0];
              ip = 800;
      end

        800 :
      begin                                                                     // mov
              localMem[0 + 358] = heapMem[localMem[0+1]*10 + 1];
              ip = 801;
      end

        801 :
      begin                                                                     // mov
              localMem[0 + 359] = heapMem[localMem[0+1]*10 + 2];
              ip = 802;
      end

        802 :
      begin                                                                     // jNe
              ip = localMem[0+358] != 1 ? 806 : 803;
      end

        803 :
      begin                                                                     // mov
              localMem[0 + 360] = heapMem[localMem[0+357]*10 + 5];
              ip = 804;
      end

        804 :
      begin                                                                     // mov
              heapMem[localMem[0+360]*10 + localMem[0+359]] = 11;
              ip = 805;
      end

        805 :
      begin                                                                     // jmp
              ip = 1052;
      end

        806 :
      begin                                                                     // label
              ip = 807;
      end

        807 :
      begin                                                                     // jNe
              ip = localMem[0+358] != 2 ? 815 : 808;
      end

        808 :
      begin                                                                     // add
              localMem[0 + 361] = localMem[0+359] + 1;
              ip = 809;
      end

        809 :
      begin                                                                     // mov
              localMem[0 + 362] = heapMem[localMem[0+357]*10 + 4];
              ip = 810;
      end

        810 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+362] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[361]) begin
                  heapMem[NArea * localMem[0+362] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+362] + localMem[361]] = 1;                                    // Insert new value
              arraySizes[localMem[0+362]] = arraySizes[localMem[0+362]] + 1;                              // Increase array size
              ip = 811;
      end

        811 :
      begin                                                                     // mov
              localMem[0 + 363] = heapMem[localMem[0+357]*10 + 5];
              ip = 812;
      end

        812 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+363] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[361]) begin
                  heapMem[NArea * localMem[0+363] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+363] + localMem[361]] = 11;                                    // Insert new value
              arraySizes[localMem[0+363]] = arraySizes[localMem[0+363]] + 1;                              // Increase array size
              ip = 813;
      end

        813 :
      begin                                                                     // add
              heapMem[localMem[0+357]*10 + 0] = heapMem[localMem[0+357]*10 + 0] + 1;
              ip = 814;
      end

        814 :
      begin                                                                     // jmp
              ip = 821;
      end

        815 :
      begin                                                                     // label
              ip = 816;
      end

        816 :
      begin                                                                     // mov
              localMem[0 + 364] = heapMem[localMem[0+357]*10 + 4];
              ip = 817;
      end

        817 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+364] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[359]) begin
                  heapMem[NArea * localMem[0+364] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+364] + localMem[359]] = 1;                                    // Insert new value
              arraySizes[localMem[0+364]] = arraySizes[localMem[0+364]] + 1;                              // Increase array size
              ip = 818;
      end

        818 :
      begin                                                                     // mov
              localMem[0 + 365] = heapMem[localMem[0+357]*10 + 5];
              ip = 819;
      end

        819 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+365] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[359]) begin
                  heapMem[NArea * localMem[0+365] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+365] + localMem[359]] = 11;                                    // Insert new value
              arraySizes[localMem[0+365]] = arraySizes[localMem[0+365]] + 1;                              // Increase array size
              ip = 820;
      end

        820 :
      begin                                                                     // add
              heapMem[localMem[0+357]*10 + 0] = heapMem[localMem[0+357]*10 + 0] + 1;
              ip = 821;
      end

        821 :
      begin                                                                     // label
              ip = 822;
      end

        822 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 823;
      end

        823 :
      begin                                                                     // label
              ip = 824;
      end

        824 :
      begin                                                                     // mov
              localMem[0 + 367] = heapMem[localMem[0+357]*10 + 0];
              ip = 825;
      end

        825 :
      begin                                                                     // mov
              localMem[0 + 368] = heapMem[localMem[0+357]*10 + 3];
              ip = 826;
      end

        826 :
      begin                                                                     // mov
              localMem[0 + 369] = heapMem[localMem[0+368]*10 + 2];
              ip = 827;
      end

        827 :
      begin                                                                     // jLt
              ip = localMem[0+367] <  localMem[0+369] ? 1047 : 828;
      end

        828 :
      begin                                                                     // mov
              localMem[0 + 370] = localMem[0+369];
              ip = 829;
      end

        829 :
      begin                                                                     // shiftRight
              localMem[0 + 370] = localMem[0+370] >> 1;
              ip = 830;
      end

        830 :
      begin                                                                     // add
              localMem[0 + 371] = localMem[0+370] + 1;
              ip = 831;
      end

        831 :
      begin                                                                     // mov
              localMem[0 + 372] = heapMem[localMem[0+357]*10 + 2];
              ip = 832;
      end

        832 :
      begin                                                                     // jEq
              ip = localMem[0+372] == 0 ? 929 : 833;
      end

        833 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 373] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 373] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 373]] = 0;
              ip = 834;
      end

        834 :
      begin                                                                     // mov
              heapMem[localMem[0+373]*10 + 0] = localMem[0+370];
              ip = 835;
      end

        835 :
      begin                                                                     // mov
              heapMem[localMem[0+373]*10 + 2] = 0;
              ip = 836;
      end

        836 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 374] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 374] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 374]] = 0;
              ip = 837;
      end

        837 :
      begin                                                                     // mov
              heapMem[localMem[0+373]*10 + 4] = localMem[0+374];
              ip = 838;
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
              heapMem[localMem[0+373]*10 + 5] = localMem[0+375];
              ip = 840;
      end

        840 :
      begin                                                                     // mov
              heapMem[localMem[0+373]*10 + 6] = 0;
              ip = 841;
      end

        841 :
      begin                                                                     // mov
              heapMem[localMem[0+373]*10 + 3] = localMem[0+368];
              ip = 842;
      end

        842 :
      begin                                                                     // add
              heapMem[localMem[0+368]*10 + 1] = heapMem[localMem[0+368]*10 + 1] + 1;
              ip = 843;
      end

        843 :
      begin                                                                     // mov
              heapMem[localMem[0+373]*10 + 1] = heapMem[localMem[0+368]*10 + 1];
              ip = 844;
      end

        844 :
      begin                                                                     // not
              localMem[0 + 376] = !heapMem[localMem[0+357]*10 + 6];
              ip = 845;
      end

        845 :
      begin                                                                     // jNe
              ip = localMem[0+376] != 0 ? 874 : 846;
      end

        846 :
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
              ip = 847;
      end

        847 :
      begin                                                                     // mov
              heapMem[localMem[0+373]*10 + 6] = localMem[0+377];
              ip = 848;
      end

        848 :
      begin                                                                     // mov
              localMem[0 + 378] = heapMem[localMem[0+357]*10 + 4];
              ip = 849;
      end

        849 :
      begin                                                                     // mov
              localMem[0 + 379] = heapMem[localMem[0+373]*10 + 4];
              ip = 850;
      end

        850 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+370]) begin
                  heapMem[NArea * localMem[0+379] + 0 + i] = heapMem[NArea * localMem[0+378] + localMem[371] + i];
                end
              end
              ip = 851;
      end

        851 :
      begin                                                                     // mov
              localMem[0 + 380] = heapMem[localMem[0+357]*10 + 5];
              ip = 852;
      end

        852 :
      begin                                                                     // mov
              localMem[0 + 381] = heapMem[localMem[0+373]*10 + 5];
              ip = 853;
      end

        853 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+370]) begin
                  heapMem[NArea * localMem[0+381] + 0 + i] = heapMem[NArea * localMem[0+380] + localMem[371] + i];
                end
              end
              ip = 854;
      end

        854 :
      begin                                                                     // mov
              localMem[0 + 382] = heapMem[localMem[0+357]*10 + 6];
              ip = 855;
      end

        855 :
      begin                                                                     // mov
              localMem[0 + 383] = heapMem[localMem[0+373]*10 + 6];
              ip = 856;
      end

        856 :
      begin                                                                     // add
              localMem[0 + 384] = localMem[0+370] + 1;
              ip = 857;
      end

        857 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+384]) begin
                  heapMem[NArea * localMem[0+383] + 0 + i] = heapMem[NArea * localMem[0+382] + localMem[371] + i];
                end
              end
              ip = 858;
      end

        858 :
      begin                                                                     // mov
              localMem[0 + 385] = heapMem[localMem[0+373]*10 + 0];
              ip = 859;
      end

        859 :
      begin                                                                     // add
              localMem[0 + 386] = localMem[0+385] + 1;
              ip = 860;
      end

        860 :
      begin                                                                     // mov
              localMem[0 + 387] = heapMem[localMem[0+373]*10 + 6];
              ip = 861;
      end

        861 :
      begin                                                                     // label
              ip = 862;
      end

        862 :
      begin                                                                     // mov
              localMem[0 + 388] = 0;
              ip = 863;
      end

        863 :
      begin                                                                     // label
              ip = 864;
      end

        864 :
      begin                                                                     // jGe
              ip = localMem[0+388] >= localMem[0+386] ? 870 : 865;
      end

        865 :
      begin                                                                     // mov
              localMem[0 + 389] = heapMem[localMem[0+387]*10 + localMem[0+388]];
              ip = 866;
      end

        866 :
      begin                                                                     // mov
              heapMem[localMem[0+389]*10 + 2] = localMem[0+373];
              ip = 867;
      end

        867 :
      begin                                                                     // label
              ip = 868;
      end

        868 :
      begin                                                                     // add
              localMem[0 + 388] = localMem[0+388] + 1;
              ip = 869;
      end

        869 :
      begin                                                                     // jmp
              ip = 863;
      end

        870 :
      begin                                                                     // label
              ip = 871;
      end

        871 :
      begin                                                                     // mov
              localMem[0 + 390] = heapMem[localMem[0+357]*10 + 6];
              ip = 872;
      end

        872 :
      begin                                                                     // resize
              arraySizes[localMem[0+390]] = localMem[0+371];
              ip = 873;
      end

        873 :
      begin                                                                     // jmp
              ip = 881;
      end

        874 :
      begin                                                                     // label
              ip = 875;
      end

        875 :
      begin                                                                     // mov
              localMem[0 + 391] = heapMem[localMem[0+357]*10 + 4];
              ip = 876;
      end

        876 :
      begin                                                                     // mov
              localMem[0 + 392] = heapMem[localMem[0+373]*10 + 4];
              ip = 877;
      end

        877 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+370]) begin
                  heapMem[NArea * localMem[0+392] + 0 + i] = heapMem[NArea * localMem[0+391] + localMem[371] + i];
                end
              end
              ip = 878;
      end

        878 :
      begin                                                                     // mov
              localMem[0 + 393] = heapMem[localMem[0+357]*10 + 5];
              ip = 879;
      end

        879 :
      begin                                                                     // mov
              localMem[0 + 394] = heapMem[localMem[0+373]*10 + 5];
              ip = 880;
      end

        880 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+370]) begin
                  heapMem[NArea * localMem[0+394] + 0 + i] = heapMem[NArea * localMem[0+393] + localMem[371] + i];
                end
              end
              ip = 881;
      end

        881 :
      begin                                                                     // label
              ip = 882;
      end

        882 :
      begin                                                                     // mov
              heapMem[localMem[0+357]*10 + 0] = localMem[0+370];
              ip = 883;
      end

        883 :
      begin                                                                     // mov
              heapMem[localMem[0+373]*10 + 2] = localMem[0+372];
              ip = 884;
      end

        884 :
      begin                                                                     // mov
              localMem[0 + 395] = heapMem[localMem[0+372]*10 + 0];
              ip = 885;
      end

        885 :
      begin                                                                     // mov
              localMem[0 + 396] = heapMem[localMem[0+372]*10 + 6];
              ip = 886;
      end

        886 :
      begin                                                                     // mov
              localMem[0 + 397] = heapMem[localMem[0+396]*10 + localMem[0+395]];
              ip = 887;
      end

        887 :
      begin                                                                     // jNe
              ip = localMem[0+397] != localMem[0+357] ? 906 : 888;
      end

        888 :
      begin                                                                     // mov
              localMem[0 + 398] = heapMem[localMem[0+357]*10 + 4];
              ip = 889;
      end

        889 :
      begin                                                                     // mov
              localMem[0 + 399] = heapMem[localMem[0+398]*10 + localMem[0+370]];
              ip = 890;
      end

        890 :
      begin                                                                     // mov
              localMem[0 + 400] = heapMem[localMem[0+372]*10 + 4];
              ip = 891;
      end

        891 :
      begin                                                                     // mov
              heapMem[localMem[0+400]*10 + localMem[0+395]] = localMem[0+399];
              ip = 892;
      end

        892 :
      begin                                                                     // mov
              localMem[0 + 401] = heapMem[localMem[0+357]*10 + 5];
              ip = 893;
      end

        893 :
      begin                                                                     // mov
              localMem[0 + 402] = heapMem[localMem[0+401]*10 + localMem[0+370]];
              ip = 894;
      end

        894 :
      begin                                                                     // mov
              localMem[0 + 403] = heapMem[localMem[0+372]*10 + 5];
              ip = 895;
      end

        895 :
      begin                                                                     // mov
              heapMem[localMem[0+403]*10 + localMem[0+395]] = localMem[0+402];
              ip = 896;
      end

        896 :
      begin                                                                     // mov
              localMem[0 + 404] = heapMem[localMem[0+357]*10 + 4];
              ip = 897;
      end

        897 :
      begin                                                                     // resize
              arraySizes[localMem[0+404]] = localMem[0+370];
              ip = 898;
      end

        898 :
      begin                                                                     // mov
              localMem[0 + 405] = heapMem[localMem[0+357]*10 + 5];
              ip = 899;
      end

        899 :
      begin                                                                     // resize
              arraySizes[localMem[0+405]] = localMem[0+370];
              ip = 900;
      end

        900 :
      begin                                                                     // add
              localMem[0 + 406] = localMem[0+395] + 1;
              ip = 901;
      end

        901 :
      begin                                                                     // mov
              heapMem[localMem[0+372]*10 + 0] = localMem[0+406];
              ip = 902;
      end

        902 :
      begin                                                                     // mov
              localMem[0 + 407] = heapMem[localMem[0+372]*10 + 6];
              ip = 903;
      end

        903 :
      begin                                                                     // mov
              heapMem[localMem[0+407]*10 + localMem[0+406]] = localMem[0+373];
              ip = 904;
      end

        904 :
      begin                                                                     // jmp
              ip = 1044;
      end

        905 :
      begin                                                                     // jmp
              ip = 928;
      end

        906 :
      begin                                                                     // label
              ip = 907;
      end

        907 :
      begin                                                                     // assertNe
            ip = 908;
      end

        908 :
      begin                                                                     // mov
              localMem[0 + 408] = heapMem[localMem[0+372]*10 + 6];
              ip = 909;
      end

        909 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+408] * NArea + i] == localMem[0+357]) localMem[0 + 409] = i + 1;
              end
              ip = 910;
      end

        910 :
      begin                                                                     // subtract
              localMem[0 + 409] = localMem[0+409] - 1;
              ip = 911;
      end

        911 :
      begin                                                                     // mov
              localMem[0 + 410] = heapMem[localMem[0+357]*10 + 4];
              ip = 912;
      end

        912 :
      begin                                                                     // mov
              localMem[0 + 411] = heapMem[localMem[0+410]*10 + localMem[0+370]];
              ip = 913;
      end

        913 :
      begin                                                                     // mov
              localMem[0 + 412] = heapMem[localMem[0+357]*10 + 5];
              ip = 914;
      end

        914 :
      begin                                                                     // mov
              localMem[0 + 413] = heapMem[localMem[0+412]*10 + localMem[0+370]];
              ip = 915;
      end

        915 :
      begin                                                                     // mov
              localMem[0 + 414] = heapMem[localMem[0+357]*10 + 4];
              ip = 916;
      end

        916 :
      begin                                                                     // resize
              arraySizes[localMem[0+414]] = localMem[0+370];
              ip = 917;
      end

        917 :
      begin                                                                     // mov
              localMem[0 + 415] = heapMem[localMem[0+357]*10 + 5];
              ip = 918;
      end

        918 :
      begin                                                                     // resize
              arraySizes[localMem[0+415]] = localMem[0+370];
              ip = 919;
      end

        919 :
      begin                                                                     // mov
              localMem[0 + 416] = heapMem[localMem[0+372]*10 + 4];
              ip = 920;
      end

        920 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+416] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[409]) begin
                  heapMem[NArea * localMem[0+416] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+416] + localMem[409]] = localMem[0+411];                                    // Insert new value
              arraySizes[localMem[0+416]] = arraySizes[localMem[0+416]] + 1;                              // Increase array size
              ip = 921;
      end

        921 :
      begin                                                                     // mov
              localMem[0 + 417] = heapMem[localMem[0+372]*10 + 5];
              ip = 922;
      end

        922 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+417] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[409]) begin
                  heapMem[NArea * localMem[0+417] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+417] + localMem[409]] = localMem[0+413];                                    // Insert new value
              arraySizes[localMem[0+417]] = arraySizes[localMem[0+417]] + 1;                              // Increase array size
              ip = 923;
      end

        923 :
      begin                                                                     // mov
              localMem[0 + 418] = heapMem[localMem[0+372]*10 + 6];
              ip = 924;
      end

        924 :
      begin                                                                     // add
              localMem[0 + 419] = localMem[0+409] + 1;
              ip = 925;
      end

        925 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+418] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[419]) begin
                  heapMem[NArea * localMem[0+418] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+418] + localMem[419]] = localMem[0+373];                                    // Insert new value
              arraySizes[localMem[0+418]] = arraySizes[localMem[0+418]] + 1;                              // Increase array size
              ip = 926;
      end

        926 :
      begin                                                                     // add
              heapMem[localMem[0+372]*10 + 0] = heapMem[localMem[0+372]*10 + 0] + 1;
              ip = 927;
      end

        927 :
      begin                                                                     // jmp
              ip = 1044;
      end

        928 :
      begin                                                                     // label
              ip = 929;
      end

        929 :
      begin                                                                     // label
              ip = 930;
      end

        930 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 420] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 420] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 420]] = 0;
              ip = 931;
      end

        931 :
      begin                                                                     // mov
              heapMem[localMem[0+420]*10 + 0] = localMem[0+370];
              ip = 932;
      end

        932 :
      begin                                                                     // mov
              heapMem[localMem[0+420]*10 + 2] = 0;
              ip = 933;
      end

        933 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 421] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 421] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 421]] = 0;
              ip = 934;
      end

        934 :
      begin                                                                     // mov
              heapMem[localMem[0+420]*10 + 4] = localMem[0+421];
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
              heapMem[localMem[0+420]*10 + 5] = localMem[0+422];
              ip = 937;
      end

        937 :
      begin                                                                     // mov
              heapMem[localMem[0+420]*10 + 6] = 0;
              ip = 938;
      end

        938 :
      begin                                                                     // mov
              heapMem[localMem[0+420]*10 + 3] = localMem[0+368];
              ip = 939;
      end

        939 :
      begin                                                                     // add
              heapMem[localMem[0+368]*10 + 1] = heapMem[localMem[0+368]*10 + 1] + 1;
              ip = 940;
      end

        940 :
      begin                                                                     // mov
              heapMem[localMem[0+420]*10 + 1] = heapMem[localMem[0+368]*10 + 1];
              ip = 941;
      end

        941 :
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
              ip = 942;
      end

        942 :
      begin                                                                     // mov
              heapMem[localMem[0+423]*10 + 0] = localMem[0+370];
              ip = 943;
      end

        943 :
      begin                                                                     // mov
              heapMem[localMem[0+423]*10 + 2] = 0;
              ip = 944;
      end

        944 :
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
              ip = 945;
      end

        945 :
      begin                                                                     // mov
              heapMem[localMem[0+423]*10 + 4] = localMem[0+424];
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
              heapMem[localMem[0+423]*10 + 5] = localMem[0+425];
              ip = 948;
      end

        948 :
      begin                                                                     // mov
              heapMem[localMem[0+423]*10 + 6] = 0;
              ip = 949;
      end

        949 :
      begin                                                                     // mov
              heapMem[localMem[0+423]*10 + 3] = localMem[0+368];
              ip = 950;
      end

        950 :
      begin                                                                     // add
              heapMem[localMem[0+368]*10 + 1] = heapMem[localMem[0+368]*10 + 1] + 1;
              ip = 951;
      end

        951 :
      begin                                                                     // mov
              heapMem[localMem[0+423]*10 + 1] = heapMem[localMem[0+368]*10 + 1];
              ip = 952;
      end

        952 :
      begin                                                                     // not
              localMem[0 + 426] = !heapMem[localMem[0+357]*10 + 6];
              ip = 953;
      end

        953 :
      begin                                                                     // jNe
              ip = localMem[0+426] != 0 ? 1005 : 954;
      end

        954 :
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
              ip = 955;
      end

        955 :
      begin                                                                     // mov
              heapMem[localMem[0+420]*10 + 6] = localMem[0+427];
              ip = 956;
      end

        956 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 428] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 428] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 428]] = 0;
              ip = 957;
      end

        957 :
      begin                                                                     // mov
              heapMem[localMem[0+423]*10 + 6] = localMem[0+428];
              ip = 958;
      end

        958 :
      begin                                                                     // mov
              localMem[0 + 429] = heapMem[localMem[0+357]*10 + 4];
              ip = 959;
      end

        959 :
      begin                                                                     // mov
              localMem[0 + 430] = heapMem[localMem[0+420]*10 + 4];
              ip = 960;
      end

        960 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+370]) begin
                  heapMem[NArea * localMem[0+430] + 0 + i] = heapMem[NArea * localMem[0+429] + 0 + i];
                end
              end
              ip = 961;
      end

        961 :
      begin                                                                     // mov
              localMem[0 + 431] = heapMem[localMem[0+357]*10 + 5];
              ip = 962;
      end

        962 :
      begin                                                                     // mov
              localMem[0 + 432] = heapMem[localMem[0+420]*10 + 5];
              ip = 963;
      end

        963 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+370]) begin
                  heapMem[NArea * localMem[0+432] + 0 + i] = heapMem[NArea * localMem[0+431] + 0 + i];
                end
              end
              ip = 964;
      end

        964 :
      begin                                                                     // mov
              localMem[0 + 433] = heapMem[localMem[0+357]*10 + 6];
              ip = 965;
      end

        965 :
      begin                                                                     // mov
              localMem[0 + 434] = heapMem[localMem[0+420]*10 + 6];
              ip = 966;
      end

        966 :
      begin                                                                     // add
              localMem[0 + 435] = localMem[0+370] + 1;
              ip = 967;
      end

        967 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+435]) begin
                  heapMem[NArea * localMem[0+434] + 0 + i] = heapMem[NArea * localMem[0+433] + 0 + i];
                end
              end
              ip = 968;
      end

        968 :
      begin                                                                     // mov
              localMem[0 + 436] = heapMem[localMem[0+357]*10 + 4];
              ip = 969;
      end

        969 :
      begin                                                                     // mov
              localMem[0 + 437] = heapMem[localMem[0+423]*10 + 4];
              ip = 970;
      end

        970 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+370]) begin
                  heapMem[NArea * localMem[0+437] + 0 + i] = heapMem[NArea * localMem[0+436] + localMem[371] + i];
                end
              end
              ip = 971;
      end

        971 :
      begin                                                                     // mov
              localMem[0 + 438] = heapMem[localMem[0+357]*10 + 5];
              ip = 972;
      end

        972 :
      begin                                                                     // mov
              localMem[0 + 439] = heapMem[localMem[0+423]*10 + 5];
              ip = 973;
      end

        973 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+370]) begin
                  heapMem[NArea * localMem[0+439] + 0 + i] = heapMem[NArea * localMem[0+438] + localMem[371] + i];
                end
              end
              ip = 974;
      end

        974 :
      begin                                                                     // mov
              localMem[0 + 440] = heapMem[localMem[0+357]*10 + 6];
              ip = 975;
      end

        975 :
      begin                                                                     // mov
              localMem[0 + 441] = heapMem[localMem[0+423]*10 + 6];
              ip = 976;
      end

        976 :
      begin                                                                     // add
              localMem[0 + 442] = localMem[0+370] + 1;
              ip = 977;
      end

        977 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+442]) begin
                  heapMem[NArea * localMem[0+441] + 0 + i] = heapMem[NArea * localMem[0+440] + localMem[371] + i];
                end
              end
              ip = 978;
      end

        978 :
      begin                                                                     // mov
              localMem[0 + 443] = heapMem[localMem[0+420]*10 + 0];
              ip = 979;
      end

        979 :
      begin                                                                     // add
              localMem[0 + 444] = localMem[0+443] + 1;
              ip = 980;
      end

        980 :
      begin                                                                     // mov
              localMem[0 + 445] = heapMem[localMem[0+420]*10 + 6];
              ip = 981;
      end

        981 :
      begin                                                                     // label
              ip = 982;
      end

        982 :
      begin                                                                     // mov
              localMem[0 + 446] = 0;
              ip = 983;
      end

        983 :
      begin                                                                     // label
              ip = 984;
      end

        984 :
      begin                                                                     // jGe
              ip = localMem[0+446] >= localMem[0+444] ? 990 : 985;
      end

        985 :
      begin                                                                     // mov
              localMem[0 + 447] = heapMem[localMem[0+445]*10 + localMem[0+446]];
              ip = 986;
      end

        986 :
      begin                                                                     // mov
              heapMem[localMem[0+447]*10 + 2] = localMem[0+420];
              ip = 987;
      end

        987 :
      begin                                                                     // label
              ip = 988;
      end

        988 :
      begin                                                                     // add
              localMem[0 + 446] = localMem[0+446] + 1;
              ip = 989;
      end

        989 :
      begin                                                                     // jmp
              ip = 983;
      end

        990 :
      begin                                                                     // label
              ip = 991;
      end

        991 :
      begin                                                                     // mov
              localMem[0 + 448] = heapMem[localMem[0+423]*10 + 0];
              ip = 992;
      end

        992 :
      begin                                                                     // add
              localMem[0 + 449] = localMem[0+448] + 1;
              ip = 993;
      end

        993 :
      begin                                                                     // mov
              localMem[0 + 450] = heapMem[localMem[0+423]*10 + 6];
              ip = 994;
      end

        994 :
      begin                                                                     // label
              ip = 995;
      end

        995 :
      begin                                                                     // mov
              localMem[0 + 451] = 0;
              ip = 996;
      end

        996 :
      begin                                                                     // label
              ip = 997;
      end

        997 :
      begin                                                                     // jGe
              ip = localMem[0+451] >= localMem[0+449] ? 1003 : 998;
      end

        998 :
      begin                                                                     // mov
              localMem[0 + 452] = heapMem[localMem[0+450]*10 + localMem[0+451]];
              ip = 999;
      end

        999 :
      begin                                                                     // mov
              heapMem[localMem[0+452]*10 + 2] = localMem[0+423];
              ip = 1000;
      end

       1000 :
      begin                                                                     // label
              ip = 1001;
      end

       1001 :
      begin                                                                     // add
              localMem[0 + 451] = localMem[0+451] + 1;
              ip = 1002;
      end

       1002 :
      begin                                                                     // jmp
              ip = 996;
      end

       1003 :
      begin                                                                     // label
              ip = 1004;
      end

       1004 :
      begin                                                                     // jmp
              ip = 1020;
      end

       1005 :
      begin                                                                     // label
              ip = 1006;
      end

       1006 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 453] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 453] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 453]] = 0;
              ip = 1007;
      end

       1007 :
      begin                                                                     // mov
              heapMem[localMem[0+357]*10 + 6] = localMem[0+453];
              ip = 1008;
      end

       1008 :
      begin                                                                     // mov
              localMem[0 + 454] = heapMem[localMem[0+357]*10 + 4];
              ip = 1009;
      end

       1009 :
      begin                                                                     // mov
              localMem[0 + 455] = heapMem[localMem[0+420]*10 + 4];
              ip = 1010;
      end

       1010 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+370]) begin
                  heapMem[NArea * localMem[0+455] + 0 + i] = heapMem[NArea * localMem[0+454] + 0 + i];
                end
              end
              ip = 1011;
      end

       1011 :
      begin                                                                     // mov
              localMem[0 + 456] = heapMem[localMem[0+357]*10 + 5];
              ip = 1012;
      end

       1012 :
      begin                                                                     // mov
              localMem[0 + 457] = heapMem[localMem[0+420]*10 + 5];
              ip = 1013;
      end

       1013 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+370]) begin
                  heapMem[NArea * localMem[0+457] + 0 + i] = heapMem[NArea * localMem[0+456] + 0 + i];
                end
              end
              ip = 1014;
      end

       1014 :
      begin                                                                     // mov
              localMem[0 + 458] = heapMem[localMem[0+357]*10 + 4];
              ip = 1015;
      end

       1015 :
      begin                                                                     // mov
              localMem[0 + 459] = heapMem[localMem[0+423]*10 + 4];
              ip = 1016;
      end

       1016 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+370]) begin
                  heapMem[NArea * localMem[0+459] + 0 + i] = heapMem[NArea * localMem[0+458] + localMem[371] + i];
                end
              end
              ip = 1017;
      end

       1017 :
      begin                                                                     // mov
              localMem[0 + 460] = heapMem[localMem[0+357]*10 + 5];
              ip = 1018;
      end

       1018 :
      begin                                                                     // mov
              localMem[0 + 461] = heapMem[localMem[0+423]*10 + 5];
              ip = 1019;
      end

       1019 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+370]) begin
                  heapMem[NArea * localMem[0+461] + 0 + i] = heapMem[NArea * localMem[0+460] + localMem[371] + i];
                end
              end
              ip = 1020;
      end

       1020 :
      begin                                                                     // label
              ip = 1021;
      end

       1021 :
      begin                                                                     // mov
              heapMem[localMem[0+420]*10 + 2] = localMem[0+357];
              ip = 1022;
      end

       1022 :
      begin                                                                     // mov
              heapMem[localMem[0+423]*10 + 2] = localMem[0+357];
              ip = 1023;
      end

       1023 :
      begin                                                                     // mov
              localMem[0 + 462] = heapMem[localMem[0+357]*10 + 4];
              ip = 1024;
      end

       1024 :
      begin                                                                     // mov
              localMem[0 + 463] = heapMem[localMem[0+462]*10 + localMem[0+370]];
              ip = 1025;
      end

       1025 :
      begin                                                                     // mov
              localMem[0 + 464] = heapMem[localMem[0+357]*10 + 5];
              ip = 1026;
      end

       1026 :
      begin                                                                     // mov
              localMem[0 + 465] = heapMem[localMem[0+464]*10 + localMem[0+370]];
              ip = 1027;
      end

       1027 :
      begin                                                                     // mov
              localMem[0 + 466] = heapMem[localMem[0+357]*10 + 4];
              ip = 1028;
      end

       1028 :
      begin                                                                     // mov
              heapMem[localMem[0+466]*10 + 0] = localMem[0+463];
              ip = 1029;
      end

       1029 :
      begin                                                                     // mov
              localMem[0 + 467] = heapMem[localMem[0+357]*10 + 5];
              ip = 1030;
      end

       1030 :
      begin                                                                     // mov
              heapMem[localMem[0+467]*10 + 0] = localMem[0+465];
              ip = 1031;
      end

       1031 :
      begin                                                                     // mov
              localMem[0 + 468] = heapMem[localMem[0+357]*10 + 6];
              ip = 1032;
      end

       1032 :
      begin                                                                     // mov
              heapMem[localMem[0+468]*10 + 0] = localMem[0+420];
              ip = 1033;
      end

       1033 :
      begin                                                                     // mov
              localMem[0 + 469] = heapMem[localMem[0+357]*10 + 6];
              ip = 1034;
      end

       1034 :
      begin                                                                     // mov
              heapMem[localMem[0+469]*10 + 1] = localMem[0+423];
              ip = 1035;
      end

       1035 :
      begin                                                                     // mov
              heapMem[localMem[0+357]*10 + 0] = 1;
              ip = 1036;
      end

       1036 :
      begin                                                                     // mov
              localMem[0 + 470] = heapMem[localMem[0+357]*10 + 4];
              ip = 1037;
      end

       1037 :
      begin                                                                     // resize
              arraySizes[localMem[0+470]] = 1;
              ip = 1038;
      end

       1038 :
      begin                                                                     // mov
              localMem[0 + 471] = heapMem[localMem[0+357]*10 + 5];
              ip = 1039;
      end

       1039 :
      begin                                                                     // resize
              arraySizes[localMem[0+471]] = 1;
              ip = 1040;
      end

       1040 :
      begin                                                                     // mov
              localMem[0 + 472] = heapMem[localMem[0+357]*10 + 6];
              ip = 1041;
      end

       1041 :
      begin                                                                     // resize
              arraySizes[localMem[0+472]] = 2;
              ip = 1042;
      end

       1042 :
      begin                                                                     // jmp
              ip = 1044;
      end

       1043 :
      begin                                                                     // jmp
              ip = 1049;
      end

       1044 :
      begin                                                                     // label
              ip = 1045;
      end

       1045 :
      begin                                                                     // mov
              localMem[0 + 366] = 1;
              ip = 1046;
      end

       1046 :
      begin                                                                     // jmp
              ip = 1049;
      end

       1047 :
      begin                                                                     // label
              ip = 1048;
      end

       1048 :
      begin                                                                     // mov
              localMem[0 + 366] = 0;
              ip = 1049;
      end

       1049 :
      begin                                                                     // label
              ip = 1050;
      end

       1050 :
      begin                                                                     // label
              ip = 1051;
      end

       1051 :
      begin                                                                     // label
              ip = 1052;
      end

       1052 :
      begin                                                                     // label
              ip = 1053;
      end

       1053 :
      begin                                                                     // free
              freedArrays[freedArraysTop] = localMem[0+1];
              freedArraysTop = freedArraysTop + 1;
              ip = 1054;
      end
      default: begin
        success  = 1;
        finished = 1;
      end
    endcase
    if (steps <=     30) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
  end
endmodule
