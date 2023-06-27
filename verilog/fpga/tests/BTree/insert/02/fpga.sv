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

       1054 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 473] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 473] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 473]] = 0;
              ip = 1055;
      end

       1055 :
      begin                                                                     // label
              ip = 1056;
      end

       1056 :
      begin                                                                     // mov
              localMem[0 + 474] = heapMem[localMem[0+0]*10 + 3];
              ip = 1057;
      end

       1057 :
      begin                                                                     // jNe
              ip = localMem[0+474] != 0 ? 1076 : 1058;
      end

       1058 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 475] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 475] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 475]] = 0;
              ip = 1059;
      end

       1059 :
      begin                                                                     // mov
              heapMem[localMem[0+475]*10 + 0] = 1;
              ip = 1060;
      end

       1060 :
      begin                                                                     // mov
              heapMem[localMem[0+475]*10 + 2] = 0;
              ip = 1061;
      end

       1061 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 476] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 476] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 476]] = 0;
              ip = 1062;
      end

       1062 :
      begin                                                                     // mov
              heapMem[localMem[0+475]*10 + 4] = localMem[0+476];
              ip = 1063;
      end

       1063 :
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
              ip = 1064;
      end

       1064 :
      begin                                                                     // mov
              heapMem[localMem[0+475]*10 + 5] = localMem[0+477];
              ip = 1065;
      end

       1065 :
      begin                                                                     // mov
              heapMem[localMem[0+475]*10 + 6] = 0;
              ip = 1066;
      end

       1066 :
      begin                                                                     // mov
              heapMem[localMem[0+475]*10 + 3] = localMem[0+0];
              ip = 1067;
      end

       1067 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 1] = heapMem[localMem[0+0]*10 + 1] + 1;
              ip = 1068;
      end

       1068 :
      begin                                                                     // mov
              heapMem[localMem[0+475]*10 + 1] = heapMem[localMem[0+0]*10 + 1];
              ip = 1069;
      end

       1069 :
      begin                                                                     // mov
              localMem[0 + 478] = heapMem[localMem[0+475]*10 + 4];
              ip = 1070;
      end

       1070 :
      begin                                                                     // mov
              heapMem[localMem[0+478]*10 + 0] = 2;
              ip = 1071;
      end

       1071 :
      begin                                                                     // mov
              localMem[0 + 479] = heapMem[localMem[0+475]*10 + 5];
              ip = 1072;
      end

       1072 :
      begin                                                                     // mov
              heapMem[localMem[0+479]*10 + 0] = 22;
              ip = 1073;
      end

       1073 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 1074;
      end

       1074 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 3] = localMem[0+475];
              ip = 1075;
      end

       1075 :
      begin                                                                     // jmp
              ip = 2101;
      end

       1076 :
      begin                                                                     // label
              ip = 1077;
      end

       1077 :
      begin                                                                     // mov
              localMem[0 + 480] = heapMem[localMem[0+474]*10 + 0];
              ip = 1078;
      end

       1078 :
      begin                                                                     // mov
              localMem[0 + 481] = heapMem[localMem[0+0]*10 + 2];
              ip = 1079;
      end

       1079 :
      begin                                                                     // jGe
              ip = localMem[0+480] >= localMem[0+481] ? 1112 : 1080;
      end

       1080 :
      begin                                                                     // mov
              localMem[0 + 482] = heapMem[localMem[0+474]*10 + 2];
              ip = 1081;
      end

       1081 :
      begin                                                                     // jNe
              ip = localMem[0+482] != 0 ? 1111 : 1082;
      end

       1082 :
      begin                                                                     // not
              localMem[0 + 483] = !heapMem[localMem[0+474]*10 + 6];
              ip = 1083;
      end

       1083 :
      begin                                                                     // jEq
              ip = localMem[0+483] == 0 ? 1110 : 1084;
      end

       1084 :
      begin                                                                     // mov
              localMem[0 + 484] = heapMem[localMem[0+474]*10 + 4];
              ip = 1085;
      end

       1085 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+484] * NArea + i] == 2) localMem[0 + 485] = i + 1;
              end
              ip = 1086;
      end

       1086 :
      begin                                                                     // jEq
              ip = localMem[0+485] == 0 ? 1091 : 1087;
      end

       1087 :
      begin                                                                     // subtract
              localMem[0 + 485] = localMem[0+485] - 1;
              ip = 1088;
      end

       1088 :
      begin                                                                     // mov
              localMem[0 + 486] = heapMem[localMem[0+474]*10 + 5];
              ip = 1089;
      end

       1089 :
      begin                                                                     // mov
              heapMem[localMem[0+486]*10 + localMem[0+485]] = 22;
              ip = 1090;
      end

       1090 :
      begin                                                                     // jmp
              ip = 2101;
      end

       1091 :
      begin                                                                     // label
              ip = 1092;
      end

       1092 :
      begin                                                                     // arrayCountGreater
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+484] * NArea + i] > 2) j = j + 1;
              end
              localMem[0 + 487] = j;
              ip = 1093;
      end

       1093 :
      begin                                                                     // jNe
              ip = localMem[0+487] != 0 ? 1101 : 1094;
      end

       1094 :
      begin                                                                     // mov
              localMem[0 + 488] = heapMem[localMem[0+474]*10 + 4];
              ip = 1095;
      end

       1095 :
      begin                                                                     // mov
              heapMem[localMem[0+488]*10 + localMem[0+480]] = 2;
              ip = 1096;
      end

       1096 :
      begin                                                                     // mov
              localMem[0 + 489] = heapMem[localMem[0+474]*10 + 5];
              ip = 1097;
      end

       1097 :
      begin                                                                     // mov
              heapMem[localMem[0+489]*10 + localMem[0+480]] = 22;
              ip = 1098;
      end

       1098 :
      begin                                                                     // add
              heapMem[localMem[0+474]*10 + 0] = localMem[0+480] + 1;
              ip = 1099;
      end

       1099 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 1100;
      end

       1100 :
      begin                                                                     // jmp
              ip = 2101;
      end

       1101 :
      begin                                                                     // label
              ip = 1102;
      end

       1102 :
      begin                                                                     // arrayCountLess
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+484] * NArea + i] < 2) j = j + 1;
              end
              localMem[0 + 490] = j;
              ip = 1103;
      end

       1103 :
      begin                                                                     // mov
              localMem[0 + 491] = heapMem[localMem[0+474]*10 + 4];
              ip = 1104;
      end

       1104 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+491] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[490]) begin
                  heapMem[NArea * localMem[0+491] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+491] + localMem[490]] = 2;                                    // Insert new value
              arraySizes[localMem[0+491]] = arraySizes[localMem[0+491]] + 1;                              // Increase array size
              ip = 1105;
      end

       1105 :
      begin                                                                     // mov
              localMem[0 + 492] = heapMem[localMem[0+474]*10 + 5];
              ip = 1106;
      end

       1106 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+492] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[490]) begin
                  heapMem[NArea * localMem[0+492] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+492] + localMem[490]] = 22;                                    // Insert new value
              arraySizes[localMem[0+492]] = arraySizes[localMem[0+492]] + 1;                              // Increase array size
              ip = 1107;
      end

       1107 :
      begin                                                                     // add
              heapMem[localMem[0+474]*10 + 0] = heapMem[localMem[0+474]*10 + 0] + 1;
              ip = 1108;
      end

       1108 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 1109;
      end

       1109 :
      begin                                                                     // jmp
              ip = 2101;
      end

       1110 :
      begin                                                                     // label
              ip = 1111;
      end

       1111 :
      begin                                                                     // label
              ip = 1112;
      end

       1112 :
      begin                                                                     // label
              ip = 1113;
      end

       1113 :
      begin                                                                     // mov
              localMem[0 + 493] = heapMem[localMem[0+0]*10 + 3];
              ip = 1114;
      end

       1114 :
      begin                                                                     // label
              ip = 1115;
      end

       1115 :
      begin                                                                     // mov
              localMem[0 + 495] = heapMem[localMem[0+493]*10 + 0];
              ip = 1116;
      end

       1116 :
      begin                                                                     // mov
              localMem[0 + 496] = heapMem[localMem[0+493]*10 + 3];
              ip = 1117;
      end

       1117 :
      begin                                                                     // mov
              localMem[0 + 497] = heapMem[localMem[0+496]*10 + 2];
              ip = 1118;
      end

       1118 :
      begin                                                                     // jLt
              ip = localMem[0+495] <  localMem[0+497] ? 1338 : 1119;
      end

       1119 :
      begin                                                                     // mov
              localMem[0 + 498] = localMem[0+497];
              ip = 1120;
      end

       1120 :
      begin                                                                     // shiftRight
              localMem[0 + 498] = localMem[0+498] >> 1;
              ip = 1121;
      end

       1121 :
      begin                                                                     // add
              localMem[0 + 499] = localMem[0+498] + 1;
              ip = 1122;
      end

       1122 :
      begin                                                                     // mov
              localMem[0 + 500] = heapMem[localMem[0+493]*10 + 2];
              ip = 1123;
      end

       1123 :
      begin                                                                     // jEq
              ip = localMem[0+500] == 0 ? 1220 : 1124;
      end

       1124 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 501] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 501] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 501]] = 0;
              ip = 1125;
      end

       1125 :
      begin                                                                     // mov
              heapMem[localMem[0+501]*10 + 0] = localMem[0+498];
              ip = 1126;
      end

       1126 :
      begin                                                                     // mov
              heapMem[localMem[0+501]*10 + 2] = 0;
              ip = 1127;
      end

       1127 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 502] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 502] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 502]] = 0;
              ip = 1128;
      end

       1128 :
      begin                                                                     // mov
              heapMem[localMem[0+501]*10 + 4] = localMem[0+502];
              ip = 1129;
      end

       1129 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 503] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 503] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 503]] = 0;
              ip = 1130;
      end

       1130 :
      begin                                                                     // mov
              heapMem[localMem[0+501]*10 + 5] = localMem[0+503];
              ip = 1131;
      end

       1131 :
      begin                                                                     // mov
              heapMem[localMem[0+501]*10 + 6] = 0;
              ip = 1132;
      end

       1132 :
      begin                                                                     // mov
              heapMem[localMem[0+501]*10 + 3] = localMem[0+496];
              ip = 1133;
      end

       1133 :
      begin                                                                     // add
              heapMem[localMem[0+496]*10 + 1] = heapMem[localMem[0+496]*10 + 1] + 1;
              ip = 1134;
      end

       1134 :
      begin                                                                     // mov
              heapMem[localMem[0+501]*10 + 1] = heapMem[localMem[0+496]*10 + 1];
              ip = 1135;
      end

       1135 :
      begin                                                                     // not
              localMem[0 + 504] = !heapMem[localMem[0+493]*10 + 6];
              ip = 1136;
      end

       1136 :
      begin                                                                     // jNe
              ip = localMem[0+504] != 0 ? 1165 : 1137;
      end

       1137 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 505] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 505] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 505]] = 0;
              ip = 1138;
      end

       1138 :
      begin                                                                     // mov
              heapMem[localMem[0+501]*10 + 6] = localMem[0+505];
              ip = 1139;
      end

       1139 :
      begin                                                                     // mov
              localMem[0 + 506] = heapMem[localMem[0+493]*10 + 4];
              ip = 1140;
      end

       1140 :
      begin                                                                     // mov
              localMem[0 + 507] = heapMem[localMem[0+501]*10 + 4];
              ip = 1141;
      end

       1141 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+498]) begin
                  heapMem[NArea * localMem[0+507] + 0 + i] = heapMem[NArea * localMem[0+506] + localMem[499] + i];
                end
              end
              ip = 1142;
      end

       1142 :
      begin                                                                     // mov
              localMem[0 + 508] = heapMem[localMem[0+493]*10 + 5];
              ip = 1143;
      end

       1143 :
      begin                                                                     // mov
              localMem[0 + 509] = heapMem[localMem[0+501]*10 + 5];
              ip = 1144;
      end

       1144 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+498]) begin
                  heapMem[NArea * localMem[0+509] + 0 + i] = heapMem[NArea * localMem[0+508] + localMem[499] + i];
                end
              end
              ip = 1145;
      end

       1145 :
      begin                                                                     // mov
              localMem[0 + 510] = heapMem[localMem[0+493]*10 + 6];
              ip = 1146;
      end

       1146 :
      begin                                                                     // mov
              localMem[0 + 511] = heapMem[localMem[0+501]*10 + 6];
              ip = 1147;
      end

       1147 :
      begin                                                                     // add
              localMem[0 + 512] = localMem[0+498] + 1;
              ip = 1148;
      end

       1148 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+512]) begin
                  heapMem[NArea * localMem[0+511] + 0 + i] = heapMem[NArea * localMem[0+510] + localMem[499] + i];
                end
              end
              ip = 1149;
      end

       1149 :
      begin                                                                     // mov
              localMem[0 + 513] = heapMem[localMem[0+501]*10 + 0];
              ip = 1150;
      end

       1150 :
      begin                                                                     // add
              localMem[0 + 514] = localMem[0+513] + 1;
              ip = 1151;
      end

       1151 :
      begin                                                                     // mov
              localMem[0 + 515] = heapMem[localMem[0+501]*10 + 6];
              ip = 1152;
      end

       1152 :
      begin                                                                     // label
              ip = 1153;
      end

       1153 :
      begin                                                                     // mov
              localMem[0 + 516] = 0;
              ip = 1154;
      end

       1154 :
      begin                                                                     // label
              ip = 1155;
      end

       1155 :
      begin                                                                     // jGe
              ip = localMem[0+516] >= localMem[0+514] ? 1161 : 1156;
      end

       1156 :
      begin                                                                     // mov
              localMem[0 + 517] = heapMem[localMem[0+515]*10 + localMem[0+516]];
              ip = 1157;
      end

       1157 :
      begin                                                                     // mov
              heapMem[localMem[0+517]*10 + 2] = localMem[0+501];
              ip = 1158;
      end

       1158 :
      begin                                                                     // label
              ip = 1159;
      end

       1159 :
      begin                                                                     // add
              localMem[0 + 516] = localMem[0+516] + 1;
              ip = 1160;
      end

       1160 :
      begin                                                                     // jmp
              ip = 1154;
      end

       1161 :
      begin                                                                     // label
              ip = 1162;
      end

       1162 :
      begin                                                                     // mov
              localMem[0 + 518] = heapMem[localMem[0+493]*10 + 6];
              ip = 1163;
      end

       1163 :
      begin                                                                     // resize
              arraySizes[localMem[0+518]] = localMem[0+499];
              ip = 1164;
      end

       1164 :
      begin                                                                     // jmp
              ip = 1172;
      end

       1165 :
      begin                                                                     // label
              ip = 1166;
      end

       1166 :
      begin                                                                     // mov
              localMem[0 + 519] = heapMem[localMem[0+493]*10 + 4];
              ip = 1167;
      end

       1167 :
      begin                                                                     // mov
              localMem[0 + 520] = heapMem[localMem[0+501]*10 + 4];
              ip = 1168;
      end

       1168 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+498]) begin
                  heapMem[NArea * localMem[0+520] + 0 + i] = heapMem[NArea * localMem[0+519] + localMem[499] + i];
                end
              end
              ip = 1169;
      end

       1169 :
      begin                                                                     // mov
              localMem[0 + 521] = heapMem[localMem[0+493]*10 + 5];
              ip = 1170;
      end

       1170 :
      begin                                                                     // mov
              localMem[0 + 522] = heapMem[localMem[0+501]*10 + 5];
              ip = 1171;
      end

       1171 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+498]) begin
                  heapMem[NArea * localMem[0+522] + 0 + i] = heapMem[NArea * localMem[0+521] + localMem[499] + i];
                end
              end
              ip = 1172;
      end

       1172 :
      begin                                                                     // label
              ip = 1173;
      end

       1173 :
      begin                                                                     // mov
              heapMem[localMem[0+493]*10 + 0] = localMem[0+498];
              ip = 1174;
      end

       1174 :
      begin                                                                     // mov
              heapMem[localMem[0+501]*10 + 2] = localMem[0+500];
              ip = 1175;
      end

       1175 :
      begin                                                                     // mov
              localMem[0 + 523] = heapMem[localMem[0+500]*10 + 0];
              ip = 1176;
      end

       1176 :
      begin                                                                     // mov
              localMem[0 + 524] = heapMem[localMem[0+500]*10 + 6];
              ip = 1177;
      end

       1177 :
      begin                                                                     // mov
              localMem[0 + 525] = heapMem[localMem[0+524]*10 + localMem[0+523]];
              ip = 1178;
      end

       1178 :
      begin                                                                     // jNe
              ip = localMem[0+525] != localMem[0+493] ? 1197 : 1179;
      end

       1179 :
      begin                                                                     // mov
              localMem[0 + 526] = heapMem[localMem[0+493]*10 + 4];
              ip = 1180;
      end

       1180 :
      begin                                                                     // mov
              localMem[0 + 527] = heapMem[localMem[0+526]*10 + localMem[0+498]];
              ip = 1181;
      end

       1181 :
      begin                                                                     // mov
              localMem[0 + 528] = heapMem[localMem[0+500]*10 + 4];
              ip = 1182;
      end

       1182 :
      begin                                                                     // mov
              heapMem[localMem[0+528]*10 + localMem[0+523]] = localMem[0+527];
              ip = 1183;
      end

       1183 :
      begin                                                                     // mov
              localMem[0 + 529] = heapMem[localMem[0+493]*10 + 5];
              ip = 1184;
      end

       1184 :
      begin                                                                     // mov
              localMem[0 + 530] = heapMem[localMem[0+529]*10 + localMem[0+498]];
              ip = 1185;
      end

       1185 :
      begin                                                                     // mov
              localMem[0 + 531] = heapMem[localMem[0+500]*10 + 5];
              ip = 1186;
      end

       1186 :
      begin                                                                     // mov
              heapMem[localMem[0+531]*10 + localMem[0+523]] = localMem[0+530];
              ip = 1187;
      end

       1187 :
      begin                                                                     // mov
              localMem[0 + 532] = heapMem[localMem[0+493]*10 + 4];
              ip = 1188;
      end

       1188 :
      begin                                                                     // resize
              arraySizes[localMem[0+532]] = localMem[0+498];
              ip = 1189;
      end

       1189 :
      begin                                                                     // mov
              localMem[0 + 533] = heapMem[localMem[0+493]*10 + 5];
              ip = 1190;
      end

       1190 :
      begin                                                                     // resize
              arraySizes[localMem[0+533]] = localMem[0+498];
              ip = 1191;
      end

       1191 :
      begin                                                                     // add
              localMem[0 + 534] = localMem[0+523] + 1;
              ip = 1192;
      end

       1192 :
      begin                                                                     // mov
              heapMem[localMem[0+500]*10 + 0] = localMem[0+534];
              ip = 1193;
      end

       1193 :
      begin                                                                     // mov
              localMem[0 + 535] = heapMem[localMem[0+500]*10 + 6];
              ip = 1194;
      end

       1194 :
      begin                                                                     // mov
              heapMem[localMem[0+535]*10 + localMem[0+534]] = localMem[0+501];
              ip = 1195;
      end

       1195 :
      begin                                                                     // jmp
              ip = 1335;
      end

       1196 :
      begin                                                                     // jmp
              ip = 1219;
      end

       1197 :
      begin                                                                     // label
              ip = 1198;
      end

       1198 :
      begin                                                                     // assertNe
            ip = 1199;
      end

       1199 :
      begin                                                                     // mov
              localMem[0 + 536] = heapMem[localMem[0+500]*10 + 6];
              ip = 1200;
      end

       1200 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+536] * NArea + i] == localMem[0+493]) localMem[0 + 537] = i + 1;
              end
              ip = 1201;
      end

       1201 :
      begin                                                                     // subtract
              localMem[0 + 537] = localMem[0+537] - 1;
              ip = 1202;
      end

       1202 :
      begin                                                                     // mov
              localMem[0 + 538] = heapMem[localMem[0+493]*10 + 4];
              ip = 1203;
      end

       1203 :
      begin                                                                     // mov
              localMem[0 + 539] = heapMem[localMem[0+538]*10 + localMem[0+498]];
              ip = 1204;
      end

       1204 :
      begin                                                                     // mov
              localMem[0 + 540] = heapMem[localMem[0+493]*10 + 5];
              ip = 1205;
      end

       1205 :
      begin                                                                     // mov
              localMem[0 + 541] = heapMem[localMem[0+540]*10 + localMem[0+498]];
              ip = 1206;
      end

       1206 :
      begin                                                                     // mov
              localMem[0 + 542] = heapMem[localMem[0+493]*10 + 4];
              ip = 1207;
      end

       1207 :
      begin                                                                     // resize
              arraySizes[localMem[0+542]] = localMem[0+498];
              ip = 1208;
      end

       1208 :
      begin                                                                     // mov
              localMem[0 + 543] = heapMem[localMem[0+493]*10 + 5];
              ip = 1209;
      end

       1209 :
      begin                                                                     // resize
              arraySizes[localMem[0+543]] = localMem[0+498];
              ip = 1210;
      end

       1210 :
      begin                                                                     // mov
              localMem[0 + 544] = heapMem[localMem[0+500]*10 + 4];
              ip = 1211;
      end

       1211 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+544] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[537]) begin
                  heapMem[NArea * localMem[0+544] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+544] + localMem[537]] = localMem[0+539];                                    // Insert new value
              arraySizes[localMem[0+544]] = arraySizes[localMem[0+544]] + 1;                              // Increase array size
              ip = 1212;
      end

       1212 :
      begin                                                                     // mov
              localMem[0 + 545] = heapMem[localMem[0+500]*10 + 5];
              ip = 1213;
      end

       1213 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+545] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[537]) begin
                  heapMem[NArea * localMem[0+545] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+545] + localMem[537]] = localMem[0+541];                                    // Insert new value
              arraySizes[localMem[0+545]] = arraySizes[localMem[0+545]] + 1;                              // Increase array size
              ip = 1214;
      end

       1214 :
      begin                                                                     // mov
              localMem[0 + 546] = heapMem[localMem[0+500]*10 + 6];
              ip = 1215;
      end

       1215 :
      begin                                                                     // add
              localMem[0 + 547] = localMem[0+537] + 1;
              ip = 1216;
      end

       1216 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+546] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[547]) begin
                  heapMem[NArea * localMem[0+546] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+546] + localMem[547]] = localMem[0+501];                                    // Insert new value
              arraySizes[localMem[0+546]] = arraySizes[localMem[0+546]] + 1;                              // Increase array size
              ip = 1217;
      end

       1217 :
      begin                                                                     // add
              heapMem[localMem[0+500]*10 + 0] = heapMem[localMem[0+500]*10 + 0] + 1;
              ip = 1218;
      end

       1218 :
      begin                                                                     // jmp
              ip = 1335;
      end

       1219 :
      begin                                                                     // label
              ip = 1220;
      end

       1220 :
      begin                                                                     // label
              ip = 1221;
      end

       1221 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 548] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 548] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 548]] = 0;
              ip = 1222;
      end

       1222 :
      begin                                                                     // mov
              heapMem[localMem[0+548]*10 + 0] = localMem[0+498];
              ip = 1223;
      end

       1223 :
      begin                                                                     // mov
              heapMem[localMem[0+548]*10 + 2] = 0;
              ip = 1224;
      end

       1224 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 549] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 549] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 549]] = 0;
              ip = 1225;
      end

       1225 :
      begin                                                                     // mov
              heapMem[localMem[0+548]*10 + 4] = localMem[0+549];
              ip = 1226;
      end

       1226 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 550] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 550] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 550]] = 0;
              ip = 1227;
      end

       1227 :
      begin                                                                     // mov
              heapMem[localMem[0+548]*10 + 5] = localMem[0+550];
              ip = 1228;
      end

       1228 :
      begin                                                                     // mov
              heapMem[localMem[0+548]*10 + 6] = 0;
              ip = 1229;
      end

       1229 :
      begin                                                                     // mov
              heapMem[localMem[0+548]*10 + 3] = localMem[0+496];
              ip = 1230;
      end

       1230 :
      begin                                                                     // add
              heapMem[localMem[0+496]*10 + 1] = heapMem[localMem[0+496]*10 + 1] + 1;
              ip = 1231;
      end

       1231 :
      begin                                                                     // mov
              heapMem[localMem[0+548]*10 + 1] = heapMem[localMem[0+496]*10 + 1];
              ip = 1232;
      end

       1232 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 551] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 551] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 551]] = 0;
              ip = 1233;
      end

       1233 :
      begin                                                                     // mov
              heapMem[localMem[0+551]*10 + 0] = localMem[0+498];
              ip = 1234;
      end

       1234 :
      begin                                                                     // mov
              heapMem[localMem[0+551]*10 + 2] = 0;
              ip = 1235;
      end

       1235 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 552] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 552] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 552]] = 0;
              ip = 1236;
      end

       1236 :
      begin                                                                     // mov
              heapMem[localMem[0+551]*10 + 4] = localMem[0+552];
              ip = 1237;
      end

       1237 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 553] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 553] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 553]] = 0;
              ip = 1238;
      end

       1238 :
      begin                                                                     // mov
              heapMem[localMem[0+551]*10 + 5] = localMem[0+553];
              ip = 1239;
      end

       1239 :
      begin                                                                     // mov
              heapMem[localMem[0+551]*10 + 6] = 0;
              ip = 1240;
      end

       1240 :
      begin                                                                     // mov
              heapMem[localMem[0+551]*10 + 3] = localMem[0+496];
              ip = 1241;
      end

       1241 :
      begin                                                                     // add
              heapMem[localMem[0+496]*10 + 1] = heapMem[localMem[0+496]*10 + 1] + 1;
              ip = 1242;
      end

       1242 :
      begin                                                                     // mov
              heapMem[localMem[0+551]*10 + 1] = heapMem[localMem[0+496]*10 + 1];
              ip = 1243;
      end

       1243 :
      begin                                                                     // not
              localMem[0 + 554] = !heapMem[localMem[0+493]*10 + 6];
              ip = 1244;
      end

       1244 :
      begin                                                                     // jNe
              ip = localMem[0+554] != 0 ? 1296 : 1245;
      end

       1245 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 555] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 555] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 555]] = 0;
              ip = 1246;
      end

       1246 :
      begin                                                                     // mov
              heapMem[localMem[0+548]*10 + 6] = localMem[0+555];
              ip = 1247;
      end

       1247 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 556] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 556] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 556]] = 0;
              ip = 1248;
      end

       1248 :
      begin                                                                     // mov
              heapMem[localMem[0+551]*10 + 6] = localMem[0+556];
              ip = 1249;
      end

       1249 :
      begin                                                                     // mov
              localMem[0 + 557] = heapMem[localMem[0+493]*10 + 4];
              ip = 1250;
      end

       1250 :
      begin                                                                     // mov
              localMem[0 + 558] = heapMem[localMem[0+548]*10 + 4];
              ip = 1251;
      end

       1251 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+498]) begin
                  heapMem[NArea * localMem[0+558] + 0 + i] = heapMem[NArea * localMem[0+557] + 0 + i];
                end
              end
              ip = 1252;
      end

       1252 :
      begin                                                                     // mov
              localMem[0 + 559] = heapMem[localMem[0+493]*10 + 5];
              ip = 1253;
      end

       1253 :
      begin                                                                     // mov
              localMem[0 + 560] = heapMem[localMem[0+548]*10 + 5];
              ip = 1254;
      end

       1254 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+498]) begin
                  heapMem[NArea * localMem[0+560] + 0 + i] = heapMem[NArea * localMem[0+559] + 0 + i];
                end
              end
              ip = 1255;
      end

       1255 :
      begin                                                                     // mov
              localMem[0 + 561] = heapMem[localMem[0+493]*10 + 6];
              ip = 1256;
      end

       1256 :
      begin                                                                     // mov
              localMem[0 + 562] = heapMem[localMem[0+548]*10 + 6];
              ip = 1257;
      end

       1257 :
      begin                                                                     // add
              localMem[0 + 563] = localMem[0+498] + 1;
              ip = 1258;
      end

       1258 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+563]) begin
                  heapMem[NArea * localMem[0+562] + 0 + i] = heapMem[NArea * localMem[0+561] + 0 + i];
                end
              end
              ip = 1259;
      end

       1259 :
      begin                                                                     // mov
              localMem[0 + 564] = heapMem[localMem[0+493]*10 + 4];
              ip = 1260;
      end

       1260 :
      begin                                                                     // mov
              localMem[0 + 565] = heapMem[localMem[0+551]*10 + 4];
              ip = 1261;
      end

       1261 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+498]) begin
                  heapMem[NArea * localMem[0+565] + 0 + i] = heapMem[NArea * localMem[0+564] + localMem[499] + i];
                end
              end
              ip = 1262;
      end

       1262 :
      begin                                                                     // mov
              localMem[0 + 566] = heapMem[localMem[0+493]*10 + 5];
              ip = 1263;
      end

       1263 :
      begin                                                                     // mov
              localMem[0 + 567] = heapMem[localMem[0+551]*10 + 5];
              ip = 1264;
      end

       1264 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+498]) begin
                  heapMem[NArea * localMem[0+567] + 0 + i] = heapMem[NArea * localMem[0+566] + localMem[499] + i];
                end
              end
              ip = 1265;
      end

       1265 :
      begin                                                                     // mov
              localMem[0 + 568] = heapMem[localMem[0+493]*10 + 6];
              ip = 1266;
      end

       1266 :
      begin                                                                     // mov
              localMem[0 + 569] = heapMem[localMem[0+551]*10 + 6];
              ip = 1267;
      end

       1267 :
      begin                                                                     // add
              localMem[0 + 570] = localMem[0+498] + 1;
              ip = 1268;
      end

       1268 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+570]) begin
                  heapMem[NArea * localMem[0+569] + 0 + i] = heapMem[NArea * localMem[0+568] + localMem[499] + i];
                end
              end
              ip = 1269;
      end

       1269 :
      begin                                                                     // mov
              localMem[0 + 571] = heapMem[localMem[0+548]*10 + 0];
              ip = 1270;
      end

       1270 :
      begin                                                                     // add
              localMem[0 + 572] = localMem[0+571] + 1;
              ip = 1271;
      end

       1271 :
      begin                                                                     // mov
              localMem[0 + 573] = heapMem[localMem[0+548]*10 + 6];
              ip = 1272;
      end

       1272 :
      begin                                                                     // label
              ip = 1273;
      end

       1273 :
      begin                                                                     // mov
              localMem[0 + 574] = 0;
              ip = 1274;
      end

       1274 :
      begin                                                                     // label
              ip = 1275;
      end

       1275 :
      begin                                                                     // jGe
              ip = localMem[0+574] >= localMem[0+572] ? 1281 : 1276;
      end

       1276 :
      begin                                                                     // mov
              localMem[0 + 575] = heapMem[localMem[0+573]*10 + localMem[0+574]];
              ip = 1277;
      end

       1277 :
      begin                                                                     // mov
              heapMem[localMem[0+575]*10 + 2] = localMem[0+548];
              ip = 1278;
      end

       1278 :
      begin                                                                     // label
              ip = 1279;
      end

       1279 :
      begin                                                                     // add
              localMem[0 + 574] = localMem[0+574] + 1;
              ip = 1280;
      end

       1280 :
      begin                                                                     // jmp
              ip = 1274;
      end

       1281 :
      begin                                                                     // label
              ip = 1282;
      end

       1282 :
      begin                                                                     // mov
              localMem[0 + 576] = heapMem[localMem[0+551]*10 + 0];
              ip = 1283;
      end

       1283 :
      begin                                                                     // add
              localMem[0 + 577] = localMem[0+576] + 1;
              ip = 1284;
      end

       1284 :
      begin                                                                     // mov
              localMem[0 + 578] = heapMem[localMem[0+551]*10 + 6];
              ip = 1285;
      end

       1285 :
      begin                                                                     // label
              ip = 1286;
      end

       1286 :
      begin                                                                     // mov
              localMem[0 + 579] = 0;
              ip = 1287;
      end

       1287 :
      begin                                                                     // label
              ip = 1288;
      end

       1288 :
      begin                                                                     // jGe
              ip = localMem[0+579] >= localMem[0+577] ? 1294 : 1289;
      end

       1289 :
      begin                                                                     // mov
              localMem[0 + 580] = heapMem[localMem[0+578]*10 + localMem[0+579]];
              ip = 1290;
      end

       1290 :
      begin                                                                     // mov
              heapMem[localMem[0+580]*10 + 2] = localMem[0+551];
              ip = 1291;
      end

       1291 :
      begin                                                                     // label
              ip = 1292;
      end

       1292 :
      begin                                                                     // add
              localMem[0 + 579] = localMem[0+579] + 1;
              ip = 1293;
      end

       1293 :
      begin                                                                     // jmp
              ip = 1287;
      end

       1294 :
      begin                                                                     // label
              ip = 1295;
      end

       1295 :
      begin                                                                     // jmp
              ip = 1311;
      end

       1296 :
      begin                                                                     // label
              ip = 1297;
      end

       1297 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 581] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 581] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 581]] = 0;
              ip = 1298;
      end

       1298 :
      begin                                                                     // mov
              heapMem[localMem[0+493]*10 + 6] = localMem[0+581];
              ip = 1299;
      end

       1299 :
      begin                                                                     // mov
              localMem[0 + 582] = heapMem[localMem[0+493]*10 + 4];
              ip = 1300;
      end

       1300 :
      begin                                                                     // mov
              localMem[0 + 583] = heapMem[localMem[0+548]*10 + 4];
              ip = 1301;
      end

       1301 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+498]) begin
                  heapMem[NArea * localMem[0+583] + 0 + i] = heapMem[NArea * localMem[0+582] + 0 + i];
                end
              end
              ip = 1302;
      end

       1302 :
      begin                                                                     // mov
              localMem[0 + 584] = heapMem[localMem[0+493]*10 + 5];
              ip = 1303;
      end

       1303 :
      begin                                                                     // mov
              localMem[0 + 585] = heapMem[localMem[0+548]*10 + 5];
              ip = 1304;
      end

       1304 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+498]) begin
                  heapMem[NArea * localMem[0+585] + 0 + i] = heapMem[NArea * localMem[0+584] + 0 + i];
                end
              end
              ip = 1305;
      end

       1305 :
      begin                                                                     // mov
              localMem[0 + 586] = heapMem[localMem[0+493]*10 + 4];
              ip = 1306;
      end

       1306 :
      begin                                                                     // mov
              localMem[0 + 587] = heapMem[localMem[0+551]*10 + 4];
              ip = 1307;
      end

       1307 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+498]) begin
                  heapMem[NArea * localMem[0+587] + 0 + i] = heapMem[NArea * localMem[0+586] + localMem[499] + i];
                end
              end
              ip = 1308;
      end

       1308 :
      begin                                                                     // mov
              localMem[0 + 588] = heapMem[localMem[0+493]*10 + 5];
              ip = 1309;
      end

       1309 :
      begin                                                                     // mov
              localMem[0 + 589] = heapMem[localMem[0+551]*10 + 5];
              ip = 1310;
      end

       1310 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+498]) begin
                  heapMem[NArea * localMem[0+589] + 0 + i] = heapMem[NArea * localMem[0+588] + localMem[499] + i];
                end
              end
              ip = 1311;
      end

       1311 :
      begin                                                                     // label
              ip = 1312;
      end

       1312 :
      begin                                                                     // mov
              heapMem[localMem[0+548]*10 + 2] = localMem[0+493];
              ip = 1313;
      end

       1313 :
      begin                                                                     // mov
              heapMem[localMem[0+551]*10 + 2] = localMem[0+493];
              ip = 1314;
      end

       1314 :
      begin                                                                     // mov
              localMem[0 + 590] = heapMem[localMem[0+493]*10 + 4];
              ip = 1315;
      end

       1315 :
      begin                                                                     // mov
              localMem[0 + 591] = heapMem[localMem[0+590]*10 + localMem[0+498]];
              ip = 1316;
      end

       1316 :
      begin                                                                     // mov
              localMem[0 + 592] = heapMem[localMem[0+493]*10 + 5];
              ip = 1317;
      end

       1317 :
      begin                                                                     // mov
              localMem[0 + 593] = heapMem[localMem[0+592]*10 + localMem[0+498]];
              ip = 1318;
      end

       1318 :
      begin                                                                     // mov
              localMem[0 + 594] = heapMem[localMem[0+493]*10 + 4];
              ip = 1319;
      end

       1319 :
      begin                                                                     // mov
              heapMem[localMem[0+594]*10 + 0] = localMem[0+591];
              ip = 1320;
      end

       1320 :
      begin                                                                     // mov
              localMem[0 + 595] = heapMem[localMem[0+493]*10 + 5];
              ip = 1321;
      end

       1321 :
      begin                                                                     // mov
              heapMem[localMem[0+595]*10 + 0] = localMem[0+593];
              ip = 1322;
      end

       1322 :
      begin                                                                     // mov
              localMem[0 + 596] = heapMem[localMem[0+493]*10 + 6];
              ip = 1323;
      end

       1323 :
      begin                                                                     // mov
              heapMem[localMem[0+596]*10 + 0] = localMem[0+548];
              ip = 1324;
      end

       1324 :
      begin                                                                     // mov
              localMem[0 + 597] = heapMem[localMem[0+493]*10 + 6];
              ip = 1325;
      end

       1325 :
      begin                                                                     // mov
              heapMem[localMem[0+597]*10 + 1] = localMem[0+551];
              ip = 1326;
      end

       1326 :
      begin                                                                     // mov
              heapMem[localMem[0+493]*10 + 0] = 1;
              ip = 1327;
      end

       1327 :
      begin                                                                     // mov
              localMem[0 + 598] = heapMem[localMem[0+493]*10 + 4];
              ip = 1328;
      end

       1328 :
      begin                                                                     // resize
              arraySizes[localMem[0+598]] = 1;
              ip = 1329;
      end

       1329 :
      begin                                                                     // mov
              localMem[0 + 599] = heapMem[localMem[0+493]*10 + 5];
              ip = 1330;
      end

       1330 :
      begin                                                                     // resize
              arraySizes[localMem[0+599]] = 1;
              ip = 1331;
      end

       1331 :
      begin                                                                     // mov
              localMem[0 + 600] = heapMem[localMem[0+493]*10 + 6];
              ip = 1332;
      end

       1332 :
      begin                                                                     // resize
              arraySizes[localMem[0+600]] = 2;
              ip = 1333;
      end

       1333 :
      begin                                                                     // jmp
              ip = 1335;
      end

       1334 :
      begin                                                                     // jmp
              ip = 1340;
      end

       1335 :
      begin                                                                     // label
              ip = 1336;
      end

       1336 :
      begin                                                                     // mov
              localMem[0 + 494] = 1;
              ip = 1337;
      end

       1337 :
      begin                                                                     // jmp
              ip = 1340;
      end

       1338 :
      begin                                                                     // label
              ip = 1339;
      end

       1339 :
      begin                                                                     // mov
              localMem[0 + 494] = 0;
              ip = 1340;
      end

       1340 :
      begin                                                                     // label
              ip = 1341;
      end

       1341 :
      begin                                                                     // label
              ip = 1342;
      end

       1342 :
      begin                                                                     // label
              ip = 1343;
      end

       1343 :
      begin                                                                     // mov
              localMem[0 + 601] = 0;
              ip = 1344;
      end

       1344 :
      begin                                                                     // label
              ip = 1345;
      end

       1345 :
      begin                                                                     // jGe
              ip = localMem[0+601] >= 99 ? 1843 : 1346;
      end

       1346 :
      begin                                                                     // mov
              localMem[0 + 602] = heapMem[localMem[0+493]*10 + 0];
              ip = 1347;
      end

       1347 :
      begin                                                                     // subtract
              localMem[0 + 603] = localMem[0+602] - 1;
              ip = 1348;
      end

       1348 :
      begin                                                                     // mov
              localMem[0 + 604] = heapMem[localMem[0+493]*10 + 4];
              ip = 1349;
      end

       1349 :
      begin                                                                     // mov
              localMem[0 + 605] = heapMem[localMem[0+604]*10 + localMem[0+603]];
              ip = 1350;
      end

       1350 :
      begin                                                                     // jLe
              ip = 2 <= localMem[0+605] ? 1591 : 1351;
      end

       1351 :
      begin                                                                     // not
              localMem[0 + 606] = !heapMem[localMem[0+493]*10 + 6];
              ip = 1352;
      end

       1352 :
      begin                                                                     // jEq
              ip = localMem[0+606] == 0 ? 1357 : 1353;
      end

       1353 :
      begin                                                                     // mov
              heapMem[localMem[0+473]*10 + 0] = localMem[0+493];
              ip = 1354;
      end

       1354 :
      begin                                                                     // mov
              heapMem[localMem[0+473]*10 + 1] = 2;
              ip = 1355;
      end

       1355 :
      begin                                                                     // subtract
              heapMem[localMem[0+473]*10 + 2] = localMem[0+602] - 1;
              ip = 1356;
      end

       1356 :
      begin                                                                     // jmp
              ip = 1847;
      end

       1357 :
      begin                                                                     // label
              ip = 1358;
      end

       1358 :
      begin                                                                     // mov
              localMem[0 + 607] = heapMem[localMem[0+493]*10 + 6];
              ip = 1359;
      end

       1359 :
      begin                                                                     // mov
              localMem[0 + 608] = heapMem[localMem[0+607]*10 + localMem[0+602]];
              ip = 1360;
      end

       1360 :
      begin                                                                     // label
              ip = 1361;
      end

       1361 :
      begin                                                                     // mov
              localMem[0 + 610] = heapMem[localMem[0+608]*10 + 0];
              ip = 1362;
      end

       1362 :
      begin                                                                     // mov
              localMem[0 + 611] = heapMem[localMem[0+608]*10 + 3];
              ip = 1363;
      end

       1363 :
      begin                                                                     // mov
              localMem[0 + 612] = heapMem[localMem[0+611]*10 + 2];
              ip = 1364;
      end

       1364 :
      begin                                                                     // jLt
              ip = localMem[0+610] <  localMem[0+612] ? 1584 : 1365;
      end

       1365 :
      begin                                                                     // mov
              localMem[0 + 613] = localMem[0+612];
              ip = 1366;
      end

       1366 :
      begin                                                                     // shiftRight
              localMem[0 + 613] = localMem[0+613] >> 1;
              ip = 1367;
      end

       1367 :
      begin                                                                     // add
              localMem[0 + 614] = localMem[0+613] + 1;
              ip = 1368;
      end

       1368 :
      begin                                                                     // mov
              localMem[0 + 615] = heapMem[localMem[0+608]*10 + 2];
              ip = 1369;
      end

       1369 :
      begin                                                                     // jEq
              ip = localMem[0+615] == 0 ? 1466 : 1370;
      end

       1370 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 616] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 616] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 616]] = 0;
              ip = 1371;
      end

       1371 :
      begin                                                                     // mov
              heapMem[localMem[0+616]*10 + 0] = localMem[0+613];
              ip = 1372;
      end

       1372 :
      begin                                                                     // mov
              heapMem[localMem[0+616]*10 + 2] = 0;
              ip = 1373;
      end

       1373 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 617] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 617] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 617]] = 0;
              ip = 1374;
      end

       1374 :
      begin                                                                     // mov
              heapMem[localMem[0+616]*10 + 4] = localMem[0+617];
              ip = 1375;
      end

       1375 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 618] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 618] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 618]] = 0;
              ip = 1376;
      end

       1376 :
      begin                                                                     // mov
              heapMem[localMem[0+616]*10 + 5] = localMem[0+618];
              ip = 1377;
      end

       1377 :
      begin                                                                     // mov
              heapMem[localMem[0+616]*10 + 6] = 0;
              ip = 1378;
      end

       1378 :
      begin                                                                     // mov
              heapMem[localMem[0+616]*10 + 3] = localMem[0+611];
              ip = 1379;
      end

       1379 :
      begin                                                                     // add
              heapMem[localMem[0+611]*10 + 1] = heapMem[localMem[0+611]*10 + 1] + 1;
              ip = 1380;
      end

       1380 :
      begin                                                                     // mov
              heapMem[localMem[0+616]*10 + 1] = heapMem[localMem[0+611]*10 + 1];
              ip = 1381;
      end

       1381 :
      begin                                                                     // not
              localMem[0 + 619] = !heapMem[localMem[0+608]*10 + 6];
              ip = 1382;
      end

       1382 :
      begin                                                                     // jNe
              ip = localMem[0+619] != 0 ? 1411 : 1383;
      end

       1383 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 620] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 620] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 620]] = 0;
              ip = 1384;
      end

       1384 :
      begin                                                                     // mov
              heapMem[localMem[0+616]*10 + 6] = localMem[0+620];
              ip = 1385;
      end

       1385 :
      begin                                                                     // mov
              localMem[0 + 621] = heapMem[localMem[0+608]*10 + 4];
              ip = 1386;
      end

       1386 :
      begin                                                                     // mov
              localMem[0 + 622] = heapMem[localMem[0+616]*10 + 4];
              ip = 1387;
      end

       1387 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+613]) begin
                  heapMem[NArea * localMem[0+622] + 0 + i] = heapMem[NArea * localMem[0+621] + localMem[614] + i];
                end
              end
              ip = 1388;
      end

       1388 :
      begin                                                                     // mov
              localMem[0 + 623] = heapMem[localMem[0+608]*10 + 5];
              ip = 1389;
      end

       1389 :
      begin                                                                     // mov
              localMem[0 + 624] = heapMem[localMem[0+616]*10 + 5];
              ip = 1390;
      end

       1390 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+613]) begin
                  heapMem[NArea * localMem[0+624] + 0 + i] = heapMem[NArea * localMem[0+623] + localMem[614] + i];
                end
              end
              ip = 1391;
      end

       1391 :
      begin                                                                     // mov
              localMem[0 + 625] = heapMem[localMem[0+608]*10 + 6];
              ip = 1392;
      end

       1392 :
      begin                                                                     // mov
              localMem[0 + 626] = heapMem[localMem[0+616]*10 + 6];
              ip = 1393;
      end

       1393 :
      begin                                                                     // add
              localMem[0 + 627] = localMem[0+613] + 1;
              ip = 1394;
      end

       1394 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+627]) begin
                  heapMem[NArea * localMem[0+626] + 0 + i] = heapMem[NArea * localMem[0+625] + localMem[614] + i];
                end
              end
              ip = 1395;
      end

       1395 :
      begin                                                                     // mov
              localMem[0 + 628] = heapMem[localMem[0+616]*10 + 0];
              ip = 1396;
      end

       1396 :
      begin                                                                     // add
              localMem[0 + 629] = localMem[0+628] + 1;
              ip = 1397;
      end

       1397 :
      begin                                                                     // mov
              localMem[0 + 630] = heapMem[localMem[0+616]*10 + 6];
              ip = 1398;
      end

       1398 :
      begin                                                                     // label
              ip = 1399;
      end

       1399 :
      begin                                                                     // mov
              localMem[0 + 631] = 0;
              ip = 1400;
      end

       1400 :
      begin                                                                     // label
              ip = 1401;
      end

       1401 :
      begin                                                                     // jGe
              ip = localMem[0+631] >= localMem[0+629] ? 1407 : 1402;
      end

       1402 :
      begin                                                                     // mov
              localMem[0 + 632] = heapMem[localMem[0+630]*10 + localMem[0+631]];
              ip = 1403;
      end

       1403 :
      begin                                                                     // mov
              heapMem[localMem[0+632]*10 + 2] = localMem[0+616];
              ip = 1404;
      end

       1404 :
      begin                                                                     // label
              ip = 1405;
      end

       1405 :
      begin                                                                     // add
              localMem[0 + 631] = localMem[0+631] + 1;
              ip = 1406;
      end

       1406 :
      begin                                                                     // jmp
              ip = 1400;
      end

       1407 :
      begin                                                                     // label
              ip = 1408;
      end

       1408 :
      begin                                                                     // mov
              localMem[0 + 633] = heapMem[localMem[0+608]*10 + 6];
              ip = 1409;
      end

       1409 :
      begin                                                                     // resize
              arraySizes[localMem[0+633]] = localMem[0+614];
              ip = 1410;
      end

       1410 :
      begin                                                                     // jmp
              ip = 1418;
      end

       1411 :
      begin                                                                     // label
              ip = 1412;
      end

       1412 :
      begin                                                                     // mov
              localMem[0 + 634] = heapMem[localMem[0+608]*10 + 4];
              ip = 1413;
      end

       1413 :
      begin                                                                     // mov
              localMem[0 + 635] = heapMem[localMem[0+616]*10 + 4];
              ip = 1414;
      end

       1414 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+613]) begin
                  heapMem[NArea * localMem[0+635] + 0 + i] = heapMem[NArea * localMem[0+634] + localMem[614] + i];
                end
              end
              ip = 1415;
      end

       1415 :
      begin                                                                     // mov
              localMem[0 + 636] = heapMem[localMem[0+608]*10 + 5];
              ip = 1416;
      end

       1416 :
      begin                                                                     // mov
              localMem[0 + 637] = heapMem[localMem[0+616]*10 + 5];
              ip = 1417;
      end

       1417 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+613]) begin
                  heapMem[NArea * localMem[0+637] + 0 + i] = heapMem[NArea * localMem[0+636] + localMem[614] + i];
                end
              end
              ip = 1418;
      end

       1418 :
      begin                                                                     // label
              ip = 1419;
      end

       1419 :
      begin                                                                     // mov
              heapMem[localMem[0+608]*10 + 0] = localMem[0+613];
              ip = 1420;
      end

       1420 :
      begin                                                                     // mov
              heapMem[localMem[0+616]*10 + 2] = localMem[0+615];
              ip = 1421;
      end

       1421 :
      begin                                                                     // mov
              localMem[0 + 638] = heapMem[localMem[0+615]*10 + 0];
              ip = 1422;
      end

       1422 :
      begin                                                                     // mov
              localMem[0 + 639] = heapMem[localMem[0+615]*10 + 6];
              ip = 1423;
      end

       1423 :
      begin                                                                     // mov
              localMem[0 + 640] = heapMem[localMem[0+639]*10 + localMem[0+638]];
              ip = 1424;
      end

       1424 :
      begin                                                                     // jNe
              ip = localMem[0+640] != localMem[0+608] ? 1443 : 1425;
      end

       1425 :
      begin                                                                     // mov
              localMem[0 + 641] = heapMem[localMem[0+608]*10 + 4];
              ip = 1426;
      end

       1426 :
      begin                                                                     // mov
              localMem[0 + 642] = heapMem[localMem[0+641]*10 + localMem[0+613]];
              ip = 1427;
      end

       1427 :
      begin                                                                     // mov
              localMem[0 + 643] = heapMem[localMem[0+615]*10 + 4];
              ip = 1428;
      end

       1428 :
      begin                                                                     // mov
              heapMem[localMem[0+643]*10 + localMem[0+638]] = localMem[0+642];
              ip = 1429;
      end

       1429 :
      begin                                                                     // mov
              localMem[0 + 644] = heapMem[localMem[0+608]*10 + 5];
              ip = 1430;
      end

       1430 :
      begin                                                                     // mov
              localMem[0 + 645] = heapMem[localMem[0+644]*10 + localMem[0+613]];
              ip = 1431;
      end

       1431 :
      begin                                                                     // mov
              localMem[0 + 646] = heapMem[localMem[0+615]*10 + 5];
              ip = 1432;
      end

       1432 :
      begin                                                                     // mov
              heapMem[localMem[0+646]*10 + localMem[0+638]] = localMem[0+645];
              ip = 1433;
      end

       1433 :
      begin                                                                     // mov
              localMem[0 + 647] = heapMem[localMem[0+608]*10 + 4];
              ip = 1434;
      end

       1434 :
      begin                                                                     // resize
              arraySizes[localMem[0+647]] = localMem[0+613];
              ip = 1435;
      end

       1435 :
      begin                                                                     // mov
              localMem[0 + 648] = heapMem[localMem[0+608]*10 + 5];
              ip = 1436;
      end

       1436 :
      begin                                                                     // resize
              arraySizes[localMem[0+648]] = localMem[0+613];
              ip = 1437;
      end

       1437 :
      begin                                                                     // add
              localMem[0 + 649] = localMem[0+638] + 1;
              ip = 1438;
      end

       1438 :
      begin                                                                     // mov
              heapMem[localMem[0+615]*10 + 0] = localMem[0+649];
              ip = 1439;
      end

       1439 :
      begin                                                                     // mov
              localMem[0 + 650] = heapMem[localMem[0+615]*10 + 6];
              ip = 1440;
      end

       1440 :
      begin                                                                     // mov
              heapMem[localMem[0+650]*10 + localMem[0+649]] = localMem[0+616];
              ip = 1441;
      end

       1441 :
      begin                                                                     // jmp
              ip = 1581;
      end

       1442 :
      begin                                                                     // jmp
              ip = 1465;
      end

       1443 :
      begin                                                                     // label
              ip = 1444;
      end

       1444 :
      begin                                                                     // assertNe
            ip = 1445;
      end

       1445 :
      begin                                                                     // mov
              localMem[0 + 651] = heapMem[localMem[0+615]*10 + 6];
              ip = 1446;
      end

       1446 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+651] * NArea + i] == localMem[0+608]) localMem[0 + 652] = i + 1;
              end
              ip = 1447;
      end

       1447 :
      begin                                                                     // subtract
              localMem[0 + 652] = localMem[0+652] - 1;
              ip = 1448;
      end

       1448 :
      begin                                                                     // mov
              localMem[0 + 653] = heapMem[localMem[0+608]*10 + 4];
              ip = 1449;
      end

       1449 :
      begin                                                                     // mov
              localMem[0 + 654] = heapMem[localMem[0+653]*10 + localMem[0+613]];
              ip = 1450;
      end

       1450 :
      begin                                                                     // mov
              localMem[0 + 655] = heapMem[localMem[0+608]*10 + 5];
              ip = 1451;
      end

       1451 :
      begin                                                                     // mov
              localMem[0 + 656] = heapMem[localMem[0+655]*10 + localMem[0+613]];
              ip = 1452;
      end

       1452 :
      begin                                                                     // mov
              localMem[0 + 657] = heapMem[localMem[0+608]*10 + 4];
              ip = 1453;
      end

       1453 :
      begin                                                                     // resize
              arraySizes[localMem[0+657]] = localMem[0+613];
              ip = 1454;
      end

       1454 :
      begin                                                                     // mov
              localMem[0 + 658] = heapMem[localMem[0+608]*10 + 5];
              ip = 1455;
      end

       1455 :
      begin                                                                     // resize
              arraySizes[localMem[0+658]] = localMem[0+613];
              ip = 1456;
      end

       1456 :
      begin                                                                     // mov
              localMem[0 + 659] = heapMem[localMem[0+615]*10 + 4];
              ip = 1457;
      end

       1457 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+659] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[652]) begin
                  heapMem[NArea * localMem[0+659] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+659] + localMem[652]] = localMem[0+654];                                    // Insert new value
              arraySizes[localMem[0+659]] = arraySizes[localMem[0+659]] + 1;                              // Increase array size
              ip = 1458;
      end

       1458 :
      begin                                                                     // mov
              localMem[0 + 660] = heapMem[localMem[0+615]*10 + 5];
              ip = 1459;
      end

       1459 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+660] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[652]) begin
                  heapMem[NArea * localMem[0+660] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+660] + localMem[652]] = localMem[0+656];                                    // Insert new value
              arraySizes[localMem[0+660]] = arraySizes[localMem[0+660]] + 1;                              // Increase array size
              ip = 1460;
      end

       1460 :
      begin                                                                     // mov
              localMem[0 + 661] = heapMem[localMem[0+615]*10 + 6];
              ip = 1461;
      end

       1461 :
      begin                                                                     // add
              localMem[0 + 662] = localMem[0+652] + 1;
              ip = 1462;
      end

       1462 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+661] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[662]) begin
                  heapMem[NArea * localMem[0+661] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+661] + localMem[662]] = localMem[0+616];                                    // Insert new value
              arraySizes[localMem[0+661]] = arraySizes[localMem[0+661]] + 1;                              // Increase array size
              ip = 1463;
      end

       1463 :
      begin                                                                     // add
              heapMem[localMem[0+615]*10 + 0] = heapMem[localMem[0+615]*10 + 0] + 1;
              ip = 1464;
      end

       1464 :
      begin                                                                     // jmp
              ip = 1581;
      end

       1465 :
      begin                                                                     // label
              ip = 1466;
      end

       1466 :
      begin                                                                     // label
              ip = 1467;
      end

       1467 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 663] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 663] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 663]] = 0;
              ip = 1468;
      end

       1468 :
      begin                                                                     // mov
              heapMem[localMem[0+663]*10 + 0] = localMem[0+613];
              ip = 1469;
      end

       1469 :
      begin                                                                     // mov
              heapMem[localMem[0+663]*10 + 2] = 0;
              ip = 1470;
      end

       1470 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 664] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 664] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 664]] = 0;
              ip = 1471;
      end

       1471 :
      begin                                                                     // mov
              heapMem[localMem[0+663]*10 + 4] = localMem[0+664];
              ip = 1472;
      end

       1472 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 665] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 665] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 665]] = 0;
              ip = 1473;
      end

       1473 :
      begin                                                                     // mov
              heapMem[localMem[0+663]*10 + 5] = localMem[0+665];
              ip = 1474;
      end

       1474 :
      begin                                                                     // mov
              heapMem[localMem[0+663]*10 + 6] = 0;
              ip = 1475;
      end

       1475 :
      begin                                                                     // mov
              heapMem[localMem[0+663]*10 + 3] = localMem[0+611];
              ip = 1476;
      end

       1476 :
      begin                                                                     // add
              heapMem[localMem[0+611]*10 + 1] = heapMem[localMem[0+611]*10 + 1] + 1;
              ip = 1477;
      end

       1477 :
      begin                                                                     // mov
              heapMem[localMem[0+663]*10 + 1] = heapMem[localMem[0+611]*10 + 1];
              ip = 1478;
      end

       1478 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 666] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 666] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 666]] = 0;
              ip = 1479;
      end

       1479 :
      begin                                                                     // mov
              heapMem[localMem[0+666]*10 + 0] = localMem[0+613];
              ip = 1480;
      end

       1480 :
      begin                                                                     // mov
              heapMem[localMem[0+666]*10 + 2] = 0;
              ip = 1481;
      end

       1481 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 667] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 667] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 667]] = 0;
              ip = 1482;
      end

       1482 :
      begin                                                                     // mov
              heapMem[localMem[0+666]*10 + 4] = localMem[0+667];
              ip = 1483;
      end

       1483 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 668] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 668] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 668]] = 0;
              ip = 1484;
      end

       1484 :
      begin                                                                     // mov
              heapMem[localMem[0+666]*10 + 5] = localMem[0+668];
              ip = 1485;
      end

       1485 :
      begin                                                                     // mov
              heapMem[localMem[0+666]*10 + 6] = 0;
              ip = 1486;
      end

       1486 :
      begin                                                                     // mov
              heapMem[localMem[0+666]*10 + 3] = localMem[0+611];
              ip = 1487;
      end

       1487 :
      begin                                                                     // add
              heapMem[localMem[0+611]*10 + 1] = heapMem[localMem[0+611]*10 + 1] + 1;
              ip = 1488;
      end

       1488 :
      begin                                                                     // mov
              heapMem[localMem[0+666]*10 + 1] = heapMem[localMem[0+611]*10 + 1];
              ip = 1489;
      end

       1489 :
      begin                                                                     // not
              localMem[0 + 669] = !heapMem[localMem[0+608]*10 + 6];
              ip = 1490;
      end

       1490 :
      begin                                                                     // jNe
              ip = localMem[0+669] != 0 ? 1542 : 1491;
      end

       1491 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 670] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 670] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 670]] = 0;
              ip = 1492;
      end

       1492 :
      begin                                                                     // mov
              heapMem[localMem[0+663]*10 + 6] = localMem[0+670];
              ip = 1493;
      end

       1493 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 671] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 671] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 671]] = 0;
              ip = 1494;
      end

       1494 :
      begin                                                                     // mov
              heapMem[localMem[0+666]*10 + 6] = localMem[0+671];
              ip = 1495;
      end

       1495 :
      begin                                                                     // mov
              localMem[0 + 672] = heapMem[localMem[0+608]*10 + 4];
              ip = 1496;
      end

       1496 :
      begin                                                                     // mov
              localMem[0 + 673] = heapMem[localMem[0+663]*10 + 4];
              ip = 1497;
      end

       1497 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+613]) begin
                  heapMem[NArea * localMem[0+673] + 0 + i] = heapMem[NArea * localMem[0+672] + 0 + i];
                end
              end
              ip = 1498;
      end

       1498 :
      begin                                                                     // mov
              localMem[0 + 674] = heapMem[localMem[0+608]*10 + 5];
              ip = 1499;
      end

       1499 :
      begin                                                                     // mov
              localMem[0 + 675] = heapMem[localMem[0+663]*10 + 5];
              ip = 1500;
      end

       1500 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+613]) begin
                  heapMem[NArea * localMem[0+675] + 0 + i] = heapMem[NArea * localMem[0+674] + 0 + i];
                end
              end
              ip = 1501;
      end

       1501 :
      begin                                                                     // mov
              localMem[0 + 676] = heapMem[localMem[0+608]*10 + 6];
              ip = 1502;
      end

       1502 :
      begin                                                                     // mov
              localMem[0 + 677] = heapMem[localMem[0+663]*10 + 6];
              ip = 1503;
      end

       1503 :
      begin                                                                     // add
              localMem[0 + 678] = localMem[0+613] + 1;
              ip = 1504;
      end

       1504 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+678]) begin
                  heapMem[NArea * localMem[0+677] + 0 + i] = heapMem[NArea * localMem[0+676] + 0 + i];
                end
              end
              ip = 1505;
      end

       1505 :
      begin                                                                     // mov
              localMem[0 + 679] = heapMem[localMem[0+608]*10 + 4];
              ip = 1506;
      end

       1506 :
      begin                                                                     // mov
              localMem[0 + 680] = heapMem[localMem[0+666]*10 + 4];
              ip = 1507;
      end

       1507 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+613]) begin
                  heapMem[NArea * localMem[0+680] + 0 + i] = heapMem[NArea * localMem[0+679] + localMem[614] + i];
                end
              end
              ip = 1508;
      end

       1508 :
      begin                                                                     // mov
              localMem[0 + 681] = heapMem[localMem[0+608]*10 + 5];
              ip = 1509;
      end

       1509 :
      begin                                                                     // mov
              localMem[0 + 682] = heapMem[localMem[0+666]*10 + 5];
              ip = 1510;
      end

       1510 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+613]) begin
                  heapMem[NArea * localMem[0+682] + 0 + i] = heapMem[NArea * localMem[0+681] + localMem[614] + i];
                end
              end
              ip = 1511;
      end

       1511 :
      begin                                                                     // mov
              localMem[0 + 683] = heapMem[localMem[0+608]*10 + 6];
              ip = 1512;
      end

       1512 :
      begin                                                                     // mov
              localMem[0 + 684] = heapMem[localMem[0+666]*10 + 6];
              ip = 1513;
      end

       1513 :
      begin                                                                     // add
              localMem[0 + 685] = localMem[0+613] + 1;
              ip = 1514;
      end

       1514 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+685]) begin
                  heapMem[NArea * localMem[0+684] + 0 + i] = heapMem[NArea * localMem[0+683] + localMem[614] + i];
                end
              end
              ip = 1515;
      end

       1515 :
      begin                                                                     // mov
              localMem[0 + 686] = heapMem[localMem[0+663]*10 + 0];
              ip = 1516;
      end

       1516 :
      begin                                                                     // add
              localMem[0 + 687] = localMem[0+686] + 1;
              ip = 1517;
      end

       1517 :
      begin                                                                     // mov
              localMem[0 + 688] = heapMem[localMem[0+663]*10 + 6];
              ip = 1518;
      end

       1518 :
      begin                                                                     // label
              ip = 1519;
      end

       1519 :
      begin                                                                     // mov
              localMem[0 + 689] = 0;
              ip = 1520;
      end

       1520 :
      begin                                                                     // label
              ip = 1521;
      end

       1521 :
      begin                                                                     // jGe
              ip = localMem[0+689] >= localMem[0+687] ? 1527 : 1522;
      end

       1522 :
      begin                                                                     // mov
              localMem[0 + 690] = heapMem[localMem[0+688]*10 + localMem[0+689]];
              ip = 1523;
      end

       1523 :
      begin                                                                     // mov
              heapMem[localMem[0+690]*10 + 2] = localMem[0+663];
              ip = 1524;
      end

       1524 :
      begin                                                                     // label
              ip = 1525;
      end

       1525 :
      begin                                                                     // add
              localMem[0 + 689] = localMem[0+689] + 1;
              ip = 1526;
      end

       1526 :
      begin                                                                     // jmp
              ip = 1520;
      end

       1527 :
      begin                                                                     // label
              ip = 1528;
      end

       1528 :
      begin                                                                     // mov
              localMem[0 + 691] = heapMem[localMem[0+666]*10 + 0];
              ip = 1529;
      end

       1529 :
      begin                                                                     // add
              localMem[0 + 692] = localMem[0+691] + 1;
              ip = 1530;
      end

       1530 :
      begin                                                                     // mov
              localMem[0 + 693] = heapMem[localMem[0+666]*10 + 6];
              ip = 1531;
      end

       1531 :
      begin                                                                     // label
              ip = 1532;
      end

       1532 :
      begin                                                                     // mov
              localMem[0 + 694] = 0;
              ip = 1533;
      end

       1533 :
      begin                                                                     // label
              ip = 1534;
      end

       1534 :
      begin                                                                     // jGe
              ip = localMem[0+694] >= localMem[0+692] ? 1540 : 1535;
      end

       1535 :
      begin                                                                     // mov
              localMem[0 + 695] = heapMem[localMem[0+693]*10 + localMem[0+694]];
              ip = 1536;
      end

       1536 :
      begin                                                                     // mov
              heapMem[localMem[0+695]*10 + 2] = localMem[0+666];
              ip = 1537;
      end

       1537 :
      begin                                                                     // label
              ip = 1538;
      end

       1538 :
      begin                                                                     // add
              localMem[0 + 694] = localMem[0+694] + 1;
              ip = 1539;
      end

       1539 :
      begin                                                                     // jmp
              ip = 1533;
      end

       1540 :
      begin                                                                     // label
              ip = 1541;
      end

       1541 :
      begin                                                                     // jmp
              ip = 1557;
      end

       1542 :
      begin                                                                     // label
              ip = 1543;
      end

       1543 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 696] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 696] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 696]] = 0;
              ip = 1544;
      end

       1544 :
      begin                                                                     // mov
              heapMem[localMem[0+608]*10 + 6] = localMem[0+696];
              ip = 1545;
      end

       1545 :
      begin                                                                     // mov
              localMem[0 + 697] = heapMem[localMem[0+608]*10 + 4];
              ip = 1546;
      end

       1546 :
      begin                                                                     // mov
              localMem[0 + 698] = heapMem[localMem[0+663]*10 + 4];
              ip = 1547;
      end

       1547 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+613]) begin
                  heapMem[NArea * localMem[0+698] + 0 + i] = heapMem[NArea * localMem[0+697] + 0 + i];
                end
              end
              ip = 1548;
      end

       1548 :
      begin                                                                     // mov
              localMem[0 + 699] = heapMem[localMem[0+608]*10 + 5];
              ip = 1549;
      end

       1549 :
      begin                                                                     // mov
              localMem[0 + 700] = heapMem[localMem[0+663]*10 + 5];
              ip = 1550;
      end

       1550 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+613]) begin
                  heapMem[NArea * localMem[0+700] + 0 + i] = heapMem[NArea * localMem[0+699] + 0 + i];
                end
              end
              ip = 1551;
      end

       1551 :
      begin                                                                     // mov
              localMem[0 + 701] = heapMem[localMem[0+608]*10 + 4];
              ip = 1552;
      end

       1552 :
      begin                                                                     // mov
              localMem[0 + 702] = heapMem[localMem[0+666]*10 + 4];
              ip = 1553;
      end

       1553 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+613]) begin
                  heapMem[NArea * localMem[0+702] + 0 + i] = heapMem[NArea * localMem[0+701] + localMem[614] + i];
                end
              end
              ip = 1554;
      end

       1554 :
      begin                                                                     // mov
              localMem[0 + 703] = heapMem[localMem[0+608]*10 + 5];
              ip = 1555;
      end

       1555 :
      begin                                                                     // mov
              localMem[0 + 704] = heapMem[localMem[0+666]*10 + 5];
              ip = 1556;
      end

       1556 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+613]) begin
                  heapMem[NArea * localMem[0+704] + 0 + i] = heapMem[NArea * localMem[0+703] + localMem[614] + i];
                end
              end
              ip = 1557;
      end

       1557 :
      begin                                                                     // label
              ip = 1558;
      end

       1558 :
      begin                                                                     // mov
              heapMem[localMem[0+663]*10 + 2] = localMem[0+608];
              ip = 1559;
      end

       1559 :
      begin                                                                     // mov
              heapMem[localMem[0+666]*10 + 2] = localMem[0+608];
              ip = 1560;
      end

       1560 :
      begin                                                                     // mov
              localMem[0 + 705] = heapMem[localMem[0+608]*10 + 4];
              ip = 1561;
      end

       1561 :
      begin                                                                     // mov
              localMem[0 + 706] = heapMem[localMem[0+705]*10 + localMem[0+613]];
              ip = 1562;
      end

       1562 :
      begin                                                                     // mov
              localMem[0 + 707] = heapMem[localMem[0+608]*10 + 5];
              ip = 1563;
      end

       1563 :
      begin                                                                     // mov
              localMem[0 + 708] = heapMem[localMem[0+707]*10 + localMem[0+613]];
              ip = 1564;
      end

       1564 :
      begin                                                                     // mov
              localMem[0 + 709] = heapMem[localMem[0+608]*10 + 4];
              ip = 1565;
      end

       1565 :
      begin                                                                     // mov
              heapMem[localMem[0+709]*10 + 0] = localMem[0+706];
              ip = 1566;
      end

       1566 :
      begin                                                                     // mov
              localMem[0 + 710] = heapMem[localMem[0+608]*10 + 5];
              ip = 1567;
      end

       1567 :
      begin                                                                     // mov
              heapMem[localMem[0+710]*10 + 0] = localMem[0+708];
              ip = 1568;
      end

       1568 :
      begin                                                                     // mov
              localMem[0 + 711] = heapMem[localMem[0+608]*10 + 6];
              ip = 1569;
      end

       1569 :
      begin                                                                     // mov
              heapMem[localMem[0+711]*10 + 0] = localMem[0+663];
              ip = 1570;
      end

       1570 :
      begin                                                                     // mov
              localMem[0 + 712] = heapMem[localMem[0+608]*10 + 6];
              ip = 1571;
      end

       1571 :
      begin                                                                     // mov
              heapMem[localMem[0+712]*10 + 1] = localMem[0+666];
              ip = 1572;
      end

       1572 :
      begin                                                                     // mov
              heapMem[localMem[0+608]*10 + 0] = 1;
              ip = 1573;
      end

       1573 :
      begin                                                                     // mov
              localMem[0 + 713] = heapMem[localMem[0+608]*10 + 4];
              ip = 1574;
      end

       1574 :
      begin                                                                     // resize
              arraySizes[localMem[0+713]] = 1;
              ip = 1575;
      end

       1575 :
      begin                                                                     // mov
              localMem[0 + 714] = heapMem[localMem[0+608]*10 + 5];
              ip = 1576;
      end

       1576 :
      begin                                                                     // resize
              arraySizes[localMem[0+714]] = 1;
              ip = 1577;
      end

       1577 :
      begin                                                                     // mov
              localMem[0 + 715] = heapMem[localMem[0+608]*10 + 6];
              ip = 1578;
      end

       1578 :
      begin                                                                     // resize
              arraySizes[localMem[0+715]] = 2;
              ip = 1579;
      end

       1579 :
      begin                                                                     // jmp
              ip = 1581;
      end

       1580 :
      begin                                                                     // jmp
              ip = 1586;
      end

       1581 :
      begin                                                                     // label
              ip = 1582;
      end

       1582 :
      begin                                                                     // mov
              localMem[0 + 609] = 1;
              ip = 1583;
      end

       1583 :
      begin                                                                     // jmp
              ip = 1586;
      end

       1584 :
      begin                                                                     // label
              ip = 1585;
      end

       1585 :
      begin                                                                     // mov
              localMem[0 + 609] = 0;
              ip = 1586;
      end

       1586 :
      begin                                                                     // label
              ip = 1587;
      end

       1587 :
      begin                                                                     // jNe
              ip = localMem[0+609] != 0 ? 1589 : 1588;
      end

       1588 :
      begin                                                                     // mov
              localMem[0 + 493] = localMem[0+608];
              ip = 1589;
      end

       1589 :
      begin                                                                     // label
              ip = 1590;
      end

       1590 :
      begin                                                                     // jmp
              ip = 1840;
      end

       1591 :
      begin                                                                     // label
              ip = 1592;
      end

       1592 :
      begin                                                                     // mov
              localMem[0 + 716] = heapMem[localMem[0+493]*10 + 4];
              ip = 1593;
      end

       1593 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+716] * NArea + i] == 2) localMem[0 + 717] = i + 1;
              end
              ip = 1594;
      end

       1594 :
      begin                                                                     // jEq
              ip = localMem[0+717] == 0 ? 1599 : 1595;
      end

       1595 :
      begin                                                                     // mov
              heapMem[localMem[0+473]*10 + 0] = localMem[0+493];
              ip = 1596;
      end

       1596 :
      begin                                                                     // mov
              heapMem[localMem[0+473]*10 + 1] = 1;
              ip = 1597;
      end

       1597 :
      begin                                                                     // subtract
              heapMem[localMem[0+473]*10 + 2] = localMem[0+717] - 1;
              ip = 1598;
      end

       1598 :
      begin                                                                     // jmp
              ip = 1847;
      end

       1599 :
      begin                                                                     // label
              ip = 1600;
      end

       1600 :
      begin                                                                     // arrayCountLess
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+716] * NArea + i] < 2) j = j + 1;
              end
              localMem[0 + 718] = j;
              ip = 1601;
      end

       1601 :
      begin                                                                     // not
              localMem[0 + 719] = !heapMem[localMem[0+493]*10 + 6];
              ip = 1602;
      end

       1602 :
      begin                                                                     // jEq
              ip = localMem[0+719] == 0 ? 1607 : 1603;
      end

       1603 :
      begin                                                                     // mov
              heapMem[localMem[0+473]*10 + 0] = localMem[0+493];
              ip = 1604;
      end

       1604 :
      begin                                                                     // mov
              heapMem[localMem[0+473]*10 + 1] = 0;
              ip = 1605;
      end

       1605 :
      begin                                                                     // mov
              heapMem[localMem[0+473]*10 + 2] = localMem[0+718];
              ip = 1606;
      end

       1606 :
      begin                                                                     // jmp
              ip = 1847;
      end

       1607 :
      begin                                                                     // label
              ip = 1608;
      end

       1608 :
      begin                                                                     // mov
              localMem[0 + 720] = heapMem[localMem[0+493]*10 + 6];
              ip = 1609;
      end

       1609 :
      begin                                                                     // mov
              localMem[0 + 721] = heapMem[localMem[0+720]*10 + localMem[0+718]];
              ip = 1610;
      end

       1610 :
      begin                                                                     // label
              ip = 1611;
      end

       1611 :
      begin                                                                     // mov
              localMem[0 + 723] = heapMem[localMem[0+721]*10 + 0];
              ip = 1612;
      end

       1612 :
      begin                                                                     // mov
              localMem[0 + 724] = heapMem[localMem[0+721]*10 + 3];
              ip = 1613;
      end

       1613 :
      begin                                                                     // mov
              localMem[0 + 725] = heapMem[localMem[0+724]*10 + 2];
              ip = 1614;
      end

       1614 :
      begin                                                                     // jLt
              ip = localMem[0+723] <  localMem[0+725] ? 1834 : 1615;
      end

       1615 :
      begin                                                                     // mov
              localMem[0 + 726] = localMem[0+725];
              ip = 1616;
      end

       1616 :
      begin                                                                     // shiftRight
              localMem[0 + 726] = localMem[0+726] >> 1;
              ip = 1617;
      end

       1617 :
      begin                                                                     // add
              localMem[0 + 727] = localMem[0+726] + 1;
              ip = 1618;
      end

       1618 :
      begin                                                                     // mov
              localMem[0 + 728] = heapMem[localMem[0+721]*10 + 2];
              ip = 1619;
      end

       1619 :
      begin                                                                     // jEq
              ip = localMem[0+728] == 0 ? 1716 : 1620;
      end

       1620 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 729] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 729] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 729]] = 0;
              ip = 1621;
      end

       1621 :
      begin                                                                     // mov
              heapMem[localMem[0+729]*10 + 0] = localMem[0+726];
              ip = 1622;
      end

       1622 :
      begin                                                                     // mov
              heapMem[localMem[0+729]*10 + 2] = 0;
              ip = 1623;
      end

       1623 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 730] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 730] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 730]] = 0;
              ip = 1624;
      end

       1624 :
      begin                                                                     // mov
              heapMem[localMem[0+729]*10 + 4] = localMem[0+730];
              ip = 1625;
      end

       1625 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 731] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 731] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 731]] = 0;
              ip = 1626;
      end

       1626 :
      begin                                                                     // mov
              heapMem[localMem[0+729]*10 + 5] = localMem[0+731];
              ip = 1627;
      end

       1627 :
      begin                                                                     // mov
              heapMem[localMem[0+729]*10 + 6] = 0;
              ip = 1628;
      end

       1628 :
      begin                                                                     // mov
              heapMem[localMem[0+729]*10 + 3] = localMem[0+724];
              ip = 1629;
      end

       1629 :
      begin                                                                     // add
              heapMem[localMem[0+724]*10 + 1] = heapMem[localMem[0+724]*10 + 1] + 1;
              ip = 1630;
      end

       1630 :
      begin                                                                     // mov
              heapMem[localMem[0+729]*10 + 1] = heapMem[localMem[0+724]*10 + 1];
              ip = 1631;
      end

       1631 :
      begin                                                                     // not
              localMem[0 + 732] = !heapMem[localMem[0+721]*10 + 6];
              ip = 1632;
      end

       1632 :
      begin                                                                     // jNe
              ip = localMem[0+732] != 0 ? 1661 : 1633;
      end

       1633 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 733] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 733] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 733]] = 0;
              ip = 1634;
      end

       1634 :
      begin                                                                     // mov
              heapMem[localMem[0+729]*10 + 6] = localMem[0+733];
              ip = 1635;
      end

       1635 :
      begin                                                                     // mov
              localMem[0 + 734] = heapMem[localMem[0+721]*10 + 4];
              ip = 1636;
      end

       1636 :
      begin                                                                     // mov
              localMem[0 + 735] = heapMem[localMem[0+729]*10 + 4];
              ip = 1637;
      end

       1637 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+726]) begin
                  heapMem[NArea * localMem[0+735] + 0 + i] = heapMem[NArea * localMem[0+734] + localMem[727] + i];
                end
              end
              ip = 1638;
      end

       1638 :
      begin                                                                     // mov
              localMem[0 + 736] = heapMem[localMem[0+721]*10 + 5];
              ip = 1639;
      end

       1639 :
      begin                                                                     // mov
              localMem[0 + 737] = heapMem[localMem[0+729]*10 + 5];
              ip = 1640;
      end

       1640 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+726]) begin
                  heapMem[NArea * localMem[0+737] + 0 + i] = heapMem[NArea * localMem[0+736] + localMem[727] + i];
                end
              end
              ip = 1641;
      end

       1641 :
      begin                                                                     // mov
              localMem[0 + 738] = heapMem[localMem[0+721]*10 + 6];
              ip = 1642;
      end

       1642 :
      begin                                                                     // mov
              localMem[0 + 739] = heapMem[localMem[0+729]*10 + 6];
              ip = 1643;
      end

       1643 :
      begin                                                                     // add
              localMem[0 + 740] = localMem[0+726] + 1;
              ip = 1644;
      end

       1644 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+740]) begin
                  heapMem[NArea * localMem[0+739] + 0 + i] = heapMem[NArea * localMem[0+738] + localMem[727] + i];
                end
              end
              ip = 1645;
      end

       1645 :
      begin                                                                     // mov
              localMem[0 + 741] = heapMem[localMem[0+729]*10 + 0];
              ip = 1646;
      end

       1646 :
      begin                                                                     // add
              localMem[0 + 742] = localMem[0+741] + 1;
              ip = 1647;
      end

       1647 :
      begin                                                                     // mov
              localMem[0 + 743] = heapMem[localMem[0+729]*10 + 6];
              ip = 1648;
      end

       1648 :
      begin                                                                     // label
              ip = 1649;
      end

       1649 :
      begin                                                                     // mov
              localMem[0 + 744] = 0;
              ip = 1650;
      end

       1650 :
      begin                                                                     // label
              ip = 1651;
      end

       1651 :
      begin                                                                     // jGe
              ip = localMem[0+744] >= localMem[0+742] ? 1657 : 1652;
      end

       1652 :
      begin                                                                     // mov
              localMem[0 + 745] = heapMem[localMem[0+743]*10 + localMem[0+744]];
              ip = 1653;
      end

       1653 :
      begin                                                                     // mov
              heapMem[localMem[0+745]*10 + 2] = localMem[0+729];
              ip = 1654;
      end

       1654 :
      begin                                                                     // label
              ip = 1655;
      end

       1655 :
      begin                                                                     // add
              localMem[0 + 744] = localMem[0+744] + 1;
              ip = 1656;
      end

       1656 :
      begin                                                                     // jmp
              ip = 1650;
      end

       1657 :
      begin                                                                     // label
              ip = 1658;
      end

       1658 :
      begin                                                                     // mov
              localMem[0 + 746] = heapMem[localMem[0+721]*10 + 6];
              ip = 1659;
      end

       1659 :
      begin                                                                     // resize
              arraySizes[localMem[0+746]] = localMem[0+727];
              ip = 1660;
      end

       1660 :
      begin                                                                     // jmp
              ip = 1668;
      end

       1661 :
      begin                                                                     // label
              ip = 1662;
      end

       1662 :
      begin                                                                     // mov
              localMem[0 + 747] = heapMem[localMem[0+721]*10 + 4];
              ip = 1663;
      end

       1663 :
      begin                                                                     // mov
              localMem[0 + 748] = heapMem[localMem[0+729]*10 + 4];
              ip = 1664;
      end

       1664 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+726]) begin
                  heapMem[NArea * localMem[0+748] + 0 + i] = heapMem[NArea * localMem[0+747] + localMem[727] + i];
                end
              end
              ip = 1665;
      end

       1665 :
      begin                                                                     // mov
              localMem[0 + 749] = heapMem[localMem[0+721]*10 + 5];
              ip = 1666;
      end

       1666 :
      begin                                                                     // mov
              localMem[0 + 750] = heapMem[localMem[0+729]*10 + 5];
              ip = 1667;
      end

       1667 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+726]) begin
                  heapMem[NArea * localMem[0+750] + 0 + i] = heapMem[NArea * localMem[0+749] + localMem[727] + i];
                end
              end
              ip = 1668;
      end

       1668 :
      begin                                                                     // label
              ip = 1669;
      end

       1669 :
      begin                                                                     // mov
              heapMem[localMem[0+721]*10 + 0] = localMem[0+726];
              ip = 1670;
      end

       1670 :
      begin                                                                     // mov
              heapMem[localMem[0+729]*10 + 2] = localMem[0+728];
              ip = 1671;
      end

       1671 :
      begin                                                                     // mov
              localMem[0 + 751] = heapMem[localMem[0+728]*10 + 0];
              ip = 1672;
      end

       1672 :
      begin                                                                     // mov
              localMem[0 + 752] = heapMem[localMem[0+728]*10 + 6];
              ip = 1673;
      end

       1673 :
      begin                                                                     // mov
              localMem[0 + 753] = heapMem[localMem[0+752]*10 + localMem[0+751]];
              ip = 1674;
      end

       1674 :
      begin                                                                     // jNe
              ip = localMem[0+753] != localMem[0+721] ? 1693 : 1675;
      end

       1675 :
      begin                                                                     // mov
              localMem[0 + 754] = heapMem[localMem[0+721]*10 + 4];
              ip = 1676;
      end

       1676 :
      begin                                                                     // mov
              localMem[0 + 755] = heapMem[localMem[0+754]*10 + localMem[0+726]];
              ip = 1677;
      end

       1677 :
      begin                                                                     // mov
              localMem[0 + 756] = heapMem[localMem[0+728]*10 + 4];
              ip = 1678;
      end

       1678 :
      begin                                                                     // mov
              heapMem[localMem[0+756]*10 + localMem[0+751]] = localMem[0+755];
              ip = 1679;
      end

       1679 :
      begin                                                                     // mov
              localMem[0 + 757] = heapMem[localMem[0+721]*10 + 5];
              ip = 1680;
      end

       1680 :
      begin                                                                     // mov
              localMem[0 + 758] = heapMem[localMem[0+757]*10 + localMem[0+726]];
              ip = 1681;
      end

       1681 :
      begin                                                                     // mov
              localMem[0 + 759] = heapMem[localMem[0+728]*10 + 5];
              ip = 1682;
      end

       1682 :
      begin                                                                     // mov
              heapMem[localMem[0+759]*10 + localMem[0+751]] = localMem[0+758];
              ip = 1683;
      end

       1683 :
      begin                                                                     // mov
              localMem[0 + 760] = heapMem[localMem[0+721]*10 + 4];
              ip = 1684;
      end

       1684 :
      begin                                                                     // resize
              arraySizes[localMem[0+760]] = localMem[0+726];
              ip = 1685;
      end

       1685 :
      begin                                                                     // mov
              localMem[0 + 761] = heapMem[localMem[0+721]*10 + 5];
              ip = 1686;
      end

       1686 :
      begin                                                                     // resize
              arraySizes[localMem[0+761]] = localMem[0+726];
              ip = 1687;
      end

       1687 :
      begin                                                                     // add
              localMem[0 + 762] = localMem[0+751] + 1;
              ip = 1688;
      end

       1688 :
      begin                                                                     // mov
              heapMem[localMem[0+728]*10 + 0] = localMem[0+762];
              ip = 1689;
      end

       1689 :
      begin                                                                     // mov
              localMem[0 + 763] = heapMem[localMem[0+728]*10 + 6];
              ip = 1690;
      end

       1690 :
      begin                                                                     // mov
              heapMem[localMem[0+763]*10 + localMem[0+762]] = localMem[0+729];
              ip = 1691;
      end

       1691 :
      begin                                                                     // jmp
              ip = 1831;
      end

       1692 :
      begin                                                                     // jmp
              ip = 1715;
      end

       1693 :
      begin                                                                     // label
              ip = 1694;
      end

       1694 :
      begin                                                                     // assertNe
            ip = 1695;
      end

       1695 :
      begin                                                                     // mov
              localMem[0 + 764] = heapMem[localMem[0+728]*10 + 6];
              ip = 1696;
      end

       1696 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+764] * NArea + i] == localMem[0+721]) localMem[0 + 765] = i + 1;
              end
              ip = 1697;
      end

       1697 :
      begin                                                                     // subtract
              localMem[0 + 765] = localMem[0+765] - 1;
              ip = 1698;
      end

       1698 :
      begin                                                                     // mov
              localMem[0 + 766] = heapMem[localMem[0+721]*10 + 4];
              ip = 1699;
      end

       1699 :
      begin                                                                     // mov
              localMem[0 + 767] = heapMem[localMem[0+766]*10 + localMem[0+726]];
              ip = 1700;
      end

       1700 :
      begin                                                                     // mov
              localMem[0 + 768] = heapMem[localMem[0+721]*10 + 5];
              ip = 1701;
      end

       1701 :
      begin                                                                     // mov
              localMem[0 + 769] = heapMem[localMem[0+768]*10 + localMem[0+726]];
              ip = 1702;
      end

       1702 :
      begin                                                                     // mov
              localMem[0 + 770] = heapMem[localMem[0+721]*10 + 4];
              ip = 1703;
      end

       1703 :
      begin                                                                     // resize
              arraySizes[localMem[0+770]] = localMem[0+726];
              ip = 1704;
      end

       1704 :
      begin                                                                     // mov
              localMem[0 + 771] = heapMem[localMem[0+721]*10 + 5];
              ip = 1705;
      end

       1705 :
      begin                                                                     // resize
              arraySizes[localMem[0+771]] = localMem[0+726];
              ip = 1706;
      end

       1706 :
      begin                                                                     // mov
              localMem[0 + 772] = heapMem[localMem[0+728]*10 + 4];
              ip = 1707;
      end

       1707 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+772] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[765]) begin
                  heapMem[NArea * localMem[0+772] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+772] + localMem[765]] = localMem[0+767];                                    // Insert new value
              arraySizes[localMem[0+772]] = arraySizes[localMem[0+772]] + 1;                              // Increase array size
              ip = 1708;
      end

       1708 :
      begin                                                                     // mov
              localMem[0 + 773] = heapMem[localMem[0+728]*10 + 5];
              ip = 1709;
      end

       1709 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+773] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[765]) begin
                  heapMem[NArea * localMem[0+773] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+773] + localMem[765]] = localMem[0+769];                                    // Insert new value
              arraySizes[localMem[0+773]] = arraySizes[localMem[0+773]] + 1;                              // Increase array size
              ip = 1710;
      end

       1710 :
      begin                                                                     // mov
              localMem[0 + 774] = heapMem[localMem[0+728]*10 + 6];
              ip = 1711;
      end

       1711 :
      begin                                                                     // add
              localMem[0 + 775] = localMem[0+765] + 1;
              ip = 1712;
      end

       1712 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+774] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[775]) begin
                  heapMem[NArea * localMem[0+774] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+774] + localMem[775]] = localMem[0+729];                                    // Insert new value
              arraySizes[localMem[0+774]] = arraySizes[localMem[0+774]] + 1;                              // Increase array size
              ip = 1713;
      end

       1713 :
      begin                                                                     // add
              heapMem[localMem[0+728]*10 + 0] = heapMem[localMem[0+728]*10 + 0] + 1;
              ip = 1714;
      end

       1714 :
      begin                                                                     // jmp
              ip = 1831;
      end

       1715 :
      begin                                                                     // label
              ip = 1716;
      end

       1716 :
      begin                                                                     // label
              ip = 1717;
      end

       1717 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 776] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 776] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 776]] = 0;
              ip = 1718;
      end

       1718 :
      begin                                                                     // mov
              heapMem[localMem[0+776]*10 + 0] = localMem[0+726];
              ip = 1719;
      end

       1719 :
      begin                                                                     // mov
              heapMem[localMem[0+776]*10 + 2] = 0;
              ip = 1720;
      end

       1720 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 777] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 777] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 777]] = 0;
              ip = 1721;
      end

       1721 :
      begin                                                                     // mov
              heapMem[localMem[0+776]*10 + 4] = localMem[0+777];
              ip = 1722;
      end

       1722 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 778] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 778] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 778]] = 0;
              ip = 1723;
      end

       1723 :
      begin                                                                     // mov
              heapMem[localMem[0+776]*10 + 5] = localMem[0+778];
              ip = 1724;
      end

       1724 :
      begin                                                                     // mov
              heapMem[localMem[0+776]*10 + 6] = 0;
              ip = 1725;
      end

       1725 :
      begin                                                                     // mov
              heapMem[localMem[0+776]*10 + 3] = localMem[0+724];
              ip = 1726;
      end

       1726 :
      begin                                                                     // add
              heapMem[localMem[0+724]*10 + 1] = heapMem[localMem[0+724]*10 + 1] + 1;
              ip = 1727;
      end

       1727 :
      begin                                                                     // mov
              heapMem[localMem[0+776]*10 + 1] = heapMem[localMem[0+724]*10 + 1];
              ip = 1728;
      end

       1728 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 779] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 779] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 779]] = 0;
              ip = 1729;
      end

       1729 :
      begin                                                                     // mov
              heapMem[localMem[0+779]*10 + 0] = localMem[0+726];
              ip = 1730;
      end

       1730 :
      begin                                                                     // mov
              heapMem[localMem[0+779]*10 + 2] = 0;
              ip = 1731;
      end

       1731 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 780] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 780] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 780]] = 0;
              ip = 1732;
      end

       1732 :
      begin                                                                     // mov
              heapMem[localMem[0+779]*10 + 4] = localMem[0+780];
              ip = 1733;
      end

       1733 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 781] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 781] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 781]] = 0;
              ip = 1734;
      end

       1734 :
      begin                                                                     // mov
              heapMem[localMem[0+779]*10 + 5] = localMem[0+781];
              ip = 1735;
      end

       1735 :
      begin                                                                     // mov
              heapMem[localMem[0+779]*10 + 6] = 0;
              ip = 1736;
      end

       1736 :
      begin                                                                     // mov
              heapMem[localMem[0+779]*10 + 3] = localMem[0+724];
              ip = 1737;
      end

       1737 :
      begin                                                                     // add
              heapMem[localMem[0+724]*10 + 1] = heapMem[localMem[0+724]*10 + 1] + 1;
              ip = 1738;
      end

       1738 :
      begin                                                                     // mov
              heapMem[localMem[0+779]*10 + 1] = heapMem[localMem[0+724]*10 + 1];
              ip = 1739;
      end

       1739 :
      begin                                                                     // not
              localMem[0 + 782] = !heapMem[localMem[0+721]*10 + 6];
              ip = 1740;
      end

       1740 :
      begin                                                                     // jNe
              ip = localMem[0+782] != 0 ? 1792 : 1741;
      end

       1741 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 783] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 783] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 783]] = 0;
              ip = 1742;
      end

       1742 :
      begin                                                                     // mov
              heapMem[localMem[0+776]*10 + 6] = localMem[0+783];
              ip = 1743;
      end

       1743 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 784] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 784] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 784]] = 0;
              ip = 1744;
      end

       1744 :
      begin                                                                     // mov
              heapMem[localMem[0+779]*10 + 6] = localMem[0+784];
              ip = 1745;
      end

       1745 :
      begin                                                                     // mov
              localMem[0 + 785] = heapMem[localMem[0+721]*10 + 4];
              ip = 1746;
      end

       1746 :
      begin                                                                     // mov
              localMem[0 + 786] = heapMem[localMem[0+776]*10 + 4];
              ip = 1747;
      end

       1747 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+726]) begin
                  heapMem[NArea * localMem[0+786] + 0 + i] = heapMem[NArea * localMem[0+785] + 0 + i];
                end
              end
              ip = 1748;
      end

       1748 :
      begin                                                                     // mov
              localMem[0 + 787] = heapMem[localMem[0+721]*10 + 5];
              ip = 1749;
      end

       1749 :
      begin                                                                     // mov
              localMem[0 + 788] = heapMem[localMem[0+776]*10 + 5];
              ip = 1750;
      end

       1750 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+726]) begin
                  heapMem[NArea * localMem[0+788] + 0 + i] = heapMem[NArea * localMem[0+787] + 0 + i];
                end
              end
              ip = 1751;
      end

       1751 :
      begin                                                                     // mov
              localMem[0 + 789] = heapMem[localMem[0+721]*10 + 6];
              ip = 1752;
      end

       1752 :
      begin                                                                     // mov
              localMem[0 + 790] = heapMem[localMem[0+776]*10 + 6];
              ip = 1753;
      end

       1753 :
      begin                                                                     // add
              localMem[0 + 791] = localMem[0+726] + 1;
              ip = 1754;
      end

       1754 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+791]) begin
                  heapMem[NArea * localMem[0+790] + 0 + i] = heapMem[NArea * localMem[0+789] + 0 + i];
                end
              end
              ip = 1755;
      end

       1755 :
      begin                                                                     // mov
              localMem[0 + 792] = heapMem[localMem[0+721]*10 + 4];
              ip = 1756;
      end

       1756 :
      begin                                                                     // mov
              localMem[0 + 793] = heapMem[localMem[0+779]*10 + 4];
              ip = 1757;
      end

       1757 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+726]) begin
                  heapMem[NArea * localMem[0+793] + 0 + i] = heapMem[NArea * localMem[0+792] + localMem[727] + i];
                end
              end
              ip = 1758;
      end

       1758 :
      begin                                                                     // mov
              localMem[0 + 794] = heapMem[localMem[0+721]*10 + 5];
              ip = 1759;
      end

       1759 :
      begin                                                                     // mov
              localMem[0 + 795] = heapMem[localMem[0+779]*10 + 5];
              ip = 1760;
      end

       1760 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+726]) begin
                  heapMem[NArea * localMem[0+795] + 0 + i] = heapMem[NArea * localMem[0+794] + localMem[727] + i];
                end
              end
              ip = 1761;
      end

       1761 :
      begin                                                                     // mov
              localMem[0 + 796] = heapMem[localMem[0+721]*10 + 6];
              ip = 1762;
      end

       1762 :
      begin                                                                     // mov
              localMem[0 + 797] = heapMem[localMem[0+779]*10 + 6];
              ip = 1763;
      end

       1763 :
      begin                                                                     // add
              localMem[0 + 798] = localMem[0+726] + 1;
              ip = 1764;
      end

       1764 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+798]) begin
                  heapMem[NArea * localMem[0+797] + 0 + i] = heapMem[NArea * localMem[0+796] + localMem[727] + i];
                end
              end
              ip = 1765;
      end

       1765 :
      begin                                                                     // mov
              localMem[0 + 799] = heapMem[localMem[0+776]*10 + 0];
              ip = 1766;
      end

       1766 :
      begin                                                                     // add
              localMem[0 + 800] = localMem[0+799] + 1;
              ip = 1767;
      end

       1767 :
      begin                                                                     // mov
              localMem[0 + 801] = heapMem[localMem[0+776]*10 + 6];
              ip = 1768;
      end

       1768 :
      begin                                                                     // label
              ip = 1769;
      end

       1769 :
      begin                                                                     // mov
              localMem[0 + 802] = 0;
              ip = 1770;
      end

       1770 :
      begin                                                                     // label
              ip = 1771;
      end

       1771 :
      begin                                                                     // jGe
              ip = localMem[0+802] >= localMem[0+800] ? 1777 : 1772;
      end

       1772 :
      begin                                                                     // mov
              localMem[0 + 803] = heapMem[localMem[0+801]*10 + localMem[0+802]];
              ip = 1773;
      end

       1773 :
      begin                                                                     // mov
              heapMem[localMem[0+803]*10 + 2] = localMem[0+776];
              ip = 1774;
      end

       1774 :
      begin                                                                     // label
              ip = 1775;
      end

       1775 :
      begin                                                                     // add
              localMem[0 + 802] = localMem[0+802] + 1;
              ip = 1776;
      end

       1776 :
      begin                                                                     // jmp
              ip = 1770;
      end

       1777 :
      begin                                                                     // label
              ip = 1778;
      end

       1778 :
      begin                                                                     // mov
              localMem[0 + 804] = heapMem[localMem[0+779]*10 + 0];
              ip = 1779;
      end

       1779 :
      begin                                                                     // add
              localMem[0 + 805] = localMem[0+804] + 1;
              ip = 1780;
      end

       1780 :
      begin                                                                     // mov
              localMem[0 + 806] = heapMem[localMem[0+779]*10 + 6];
              ip = 1781;
      end

       1781 :
      begin                                                                     // label
              ip = 1782;
      end

       1782 :
      begin                                                                     // mov
              localMem[0 + 807] = 0;
              ip = 1783;
      end

       1783 :
      begin                                                                     // label
              ip = 1784;
      end

       1784 :
      begin                                                                     // jGe
              ip = localMem[0+807] >= localMem[0+805] ? 1790 : 1785;
      end

       1785 :
      begin                                                                     // mov
              localMem[0 + 808] = heapMem[localMem[0+806]*10 + localMem[0+807]];
              ip = 1786;
      end

       1786 :
      begin                                                                     // mov
              heapMem[localMem[0+808]*10 + 2] = localMem[0+779];
              ip = 1787;
      end

       1787 :
      begin                                                                     // label
              ip = 1788;
      end

       1788 :
      begin                                                                     // add
              localMem[0 + 807] = localMem[0+807] + 1;
              ip = 1789;
      end

       1789 :
      begin                                                                     // jmp
              ip = 1783;
      end

       1790 :
      begin                                                                     // label
              ip = 1791;
      end

       1791 :
      begin                                                                     // jmp
              ip = 1807;
      end

       1792 :
      begin                                                                     // label
              ip = 1793;
      end

       1793 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 809] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 809] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 809]] = 0;
              ip = 1794;
      end

       1794 :
      begin                                                                     // mov
              heapMem[localMem[0+721]*10 + 6] = localMem[0+809];
              ip = 1795;
      end

       1795 :
      begin                                                                     // mov
              localMem[0 + 810] = heapMem[localMem[0+721]*10 + 4];
              ip = 1796;
      end

       1796 :
      begin                                                                     // mov
              localMem[0 + 811] = heapMem[localMem[0+776]*10 + 4];
              ip = 1797;
      end

       1797 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+726]) begin
                  heapMem[NArea * localMem[0+811] + 0 + i] = heapMem[NArea * localMem[0+810] + 0 + i];
                end
              end
              ip = 1798;
      end

       1798 :
      begin                                                                     // mov
              localMem[0 + 812] = heapMem[localMem[0+721]*10 + 5];
              ip = 1799;
      end

       1799 :
      begin                                                                     // mov
              localMem[0 + 813] = heapMem[localMem[0+776]*10 + 5];
              ip = 1800;
      end

       1800 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+726]) begin
                  heapMem[NArea * localMem[0+813] + 0 + i] = heapMem[NArea * localMem[0+812] + 0 + i];
                end
              end
              ip = 1801;
      end

       1801 :
      begin                                                                     // mov
              localMem[0 + 814] = heapMem[localMem[0+721]*10 + 4];
              ip = 1802;
      end

       1802 :
      begin                                                                     // mov
              localMem[0 + 815] = heapMem[localMem[0+779]*10 + 4];
              ip = 1803;
      end

       1803 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+726]) begin
                  heapMem[NArea * localMem[0+815] + 0 + i] = heapMem[NArea * localMem[0+814] + localMem[727] + i];
                end
              end
              ip = 1804;
      end

       1804 :
      begin                                                                     // mov
              localMem[0 + 816] = heapMem[localMem[0+721]*10 + 5];
              ip = 1805;
      end

       1805 :
      begin                                                                     // mov
              localMem[0 + 817] = heapMem[localMem[0+779]*10 + 5];
              ip = 1806;
      end

       1806 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+726]) begin
                  heapMem[NArea * localMem[0+817] + 0 + i] = heapMem[NArea * localMem[0+816] + localMem[727] + i];
                end
              end
              ip = 1807;
      end

       1807 :
      begin                                                                     // label
              ip = 1808;
      end

       1808 :
      begin                                                                     // mov
              heapMem[localMem[0+776]*10 + 2] = localMem[0+721];
              ip = 1809;
      end

       1809 :
      begin                                                                     // mov
              heapMem[localMem[0+779]*10 + 2] = localMem[0+721];
              ip = 1810;
      end

       1810 :
      begin                                                                     // mov
              localMem[0 + 818] = heapMem[localMem[0+721]*10 + 4];
              ip = 1811;
      end

       1811 :
      begin                                                                     // mov
              localMem[0 + 819] = heapMem[localMem[0+818]*10 + localMem[0+726]];
              ip = 1812;
      end

       1812 :
      begin                                                                     // mov
              localMem[0 + 820] = heapMem[localMem[0+721]*10 + 5];
              ip = 1813;
      end

       1813 :
      begin                                                                     // mov
              localMem[0 + 821] = heapMem[localMem[0+820]*10 + localMem[0+726]];
              ip = 1814;
      end

       1814 :
      begin                                                                     // mov
              localMem[0 + 822] = heapMem[localMem[0+721]*10 + 4];
              ip = 1815;
      end

       1815 :
      begin                                                                     // mov
              heapMem[localMem[0+822]*10 + 0] = localMem[0+819];
              ip = 1816;
      end

       1816 :
      begin                                                                     // mov
              localMem[0 + 823] = heapMem[localMem[0+721]*10 + 5];
              ip = 1817;
      end

       1817 :
      begin                                                                     // mov
              heapMem[localMem[0+823]*10 + 0] = localMem[0+821];
              ip = 1818;
      end

       1818 :
      begin                                                                     // mov
              localMem[0 + 824] = heapMem[localMem[0+721]*10 + 6];
              ip = 1819;
      end

       1819 :
      begin                                                                     // mov
              heapMem[localMem[0+824]*10 + 0] = localMem[0+776];
              ip = 1820;
      end

       1820 :
      begin                                                                     // mov
              localMem[0 + 825] = heapMem[localMem[0+721]*10 + 6];
              ip = 1821;
      end

       1821 :
      begin                                                                     // mov
              heapMem[localMem[0+825]*10 + 1] = localMem[0+779];
              ip = 1822;
      end

       1822 :
      begin                                                                     // mov
              heapMem[localMem[0+721]*10 + 0] = 1;
              ip = 1823;
      end

       1823 :
      begin                                                                     // mov
              localMem[0 + 826] = heapMem[localMem[0+721]*10 + 4];
              ip = 1824;
      end

       1824 :
      begin                                                                     // resize
              arraySizes[localMem[0+826]] = 1;
              ip = 1825;
      end

       1825 :
      begin                                                                     // mov
              localMem[0 + 827] = heapMem[localMem[0+721]*10 + 5];
              ip = 1826;
      end

       1826 :
      begin                                                                     // resize
              arraySizes[localMem[0+827]] = 1;
              ip = 1827;
      end

       1827 :
      begin                                                                     // mov
              localMem[0 + 828] = heapMem[localMem[0+721]*10 + 6];
              ip = 1828;
      end

       1828 :
      begin                                                                     // resize
              arraySizes[localMem[0+828]] = 2;
              ip = 1829;
      end

       1829 :
      begin                                                                     // jmp
              ip = 1831;
      end

       1830 :
      begin                                                                     // jmp
              ip = 1836;
      end

       1831 :
      begin                                                                     // label
              ip = 1832;
      end

       1832 :
      begin                                                                     // mov
              localMem[0 + 722] = 1;
              ip = 1833;
      end

       1833 :
      begin                                                                     // jmp
              ip = 1836;
      end

       1834 :
      begin                                                                     // label
              ip = 1835;
      end

       1835 :
      begin                                                                     // mov
              localMem[0 + 722] = 0;
              ip = 1836;
      end

       1836 :
      begin                                                                     // label
              ip = 1837;
      end

       1837 :
      begin                                                                     // jNe
              ip = localMem[0+722] != 0 ? 1839 : 1838;
      end

       1838 :
      begin                                                                     // mov
              localMem[0 + 493] = localMem[0+721];
              ip = 1839;
      end

       1839 :
      begin                                                                     // label
              ip = 1840;
      end

       1840 :
      begin                                                                     // label
              ip = 1841;
      end

       1841 :
      begin                                                                     // add
              localMem[0 + 601] = localMem[0+601] + 1;
              ip = 1842;
      end

       1842 :
      begin                                                                     // jmp
              ip = 1344;
      end

       1843 :
      begin                                                                     // label
              ip = 1844;
      end

       1844 :
      begin                                                                     // assert
            ip = 1845;
      end

       1845 :
      begin                                                                     // label
              ip = 1846;
      end

       1846 :
      begin                                                                     // label
              ip = 1847;
      end

       1847 :
      begin                                                                     // label
              ip = 1848;
      end

       1848 :
      begin                                                                     // mov
              localMem[0 + 829] = heapMem[localMem[0+473]*10 + 0];
              ip = 1849;
      end

       1849 :
      begin                                                                     // mov
              localMem[0 + 830] = heapMem[localMem[0+473]*10 + 1];
              ip = 1850;
      end

       1850 :
      begin                                                                     // mov
              localMem[0 + 831] = heapMem[localMem[0+473]*10 + 2];
              ip = 1851;
      end

       1851 :
      begin                                                                     // jNe
              ip = localMem[0+830] != 1 ? 1855 : 1852;
      end

       1852 :
      begin                                                                     // mov
              localMem[0 + 832] = heapMem[localMem[0+829]*10 + 5];
              ip = 1853;
      end

       1853 :
      begin                                                                     // mov
              heapMem[localMem[0+832]*10 + localMem[0+831]] = 22;
              ip = 1854;
      end

       1854 :
      begin                                                                     // jmp
              ip = 2101;
      end

       1855 :
      begin                                                                     // label
              ip = 1856;
      end

       1856 :
      begin                                                                     // jNe
              ip = localMem[0+830] != 2 ? 1864 : 1857;
      end

       1857 :
      begin                                                                     // add
              localMem[0 + 833] = localMem[0+831] + 1;
              ip = 1858;
      end

       1858 :
      begin                                                                     // mov
              localMem[0 + 834] = heapMem[localMem[0+829]*10 + 4];
              ip = 1859;
      end

       1859 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+834] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[833]) begin
                  heapMem[NArea * localMem[0+834] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+834] + localMem[833]] = 2;                                    // Insert new value
              arraySizes[localMem[0+834]] = arraySizes[localMem[0+834]] + 1;                              // Increase array size
              ip = 1860;
      end

       1860 :
      begin                                                                     // mov
              localMem[0 + 835] = heapMem[localMem[0+829]*10 + 5];
              ip = 1861;
      end

       1861 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+835] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[833]) begin
                  heapMem[NArea * localMem[0+835] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+835] + localMem[833]] = 22;                                    // Insert new value
              arraySizes[localMem[0+835]] = arraySizes[localMem[0+835]] + 1;                              // Increase array size
              ip = 1862;
      end

       1862 :
      begin                                                                     // add
              heapMem[localMem[0+829]*10 + 0] = heapMem[localMem[0+829]*10 + 0] + 1;
              ip = 1863;
      end

       1863 :
      begin                                                                     // jmp
              ip = 1870;
      end

       1864 :
      begin                                                                     // label
              ip = 1865;
      end

       1865 :
      begin                                                                     // mov
              localMem[0 + 836] = heapMem[localMem[0+829]*10 + 4];
              ip = 1866;
      end

       1866 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+836] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[831]) begin
                  heapMem[NArea * localMem[0+836] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+836] + localMem[831]] = 2;                                    // Insert new value
              arraySizes[localMem[0+836]] = arraySizes[localMem[0+836]] + 1;                              // Increase array size
              ip = 1867;
      end

       1867 :
      begin                                                                     // mov
              localMem[0 + 837] = heapMem[localMem[0+829]*10 + 5];
              ip = 1868;
      end

       1868 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+837] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[831]) begin
                  heapMem[NArea * localMem[0+837] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+837] + localMem[831]] = 22;                                    // Insert new value
              arraySizes[localMem[0+837]] = arraySizes[localMem[0+837]] + 1;                              // Increase array size
              ip = 1869;
      end

       1869 :
      begin                                                                     // add
              heapMem[localMem[0+829]*10 + 0] = heapMem[localMem[0+829]*10 + 0] + 1;
              ip = 1870;
      end

       1870 :
      begin                                                                     // label
              ip = 1871;
      end

       1871 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 1872;
      end

       1872 :
      begin                                                                     // label
              ip = 1873;
      end

       1873 :
      begin                                                                     // mov
              localMem[0 + 839] = heapMem[localMem[0+829]*10 + 0];
              ip = 1874;
      end

       1874 :
      begin                                                                     // mov
              localMem[0 + 840] = heapMem[localMem[0+829]*10 + 3];
              ip = 1875;
      end

       1875 :
      begin                                                                     // mov
              localMem[0 + 841] = heapMem[localMem[0+840]*10 + 2];
              ip = 1876;
      end

       1876 :
      begin                                                                     // jLt
              ip = localMem[0+839] <  localMem[0+841] ? 2096 : 1877;
      end

       1877 :
      begin                                                                     // mov
              localMem[0 + 842] = localMem[0+841];
              ip = 1878;
      end

       1878 :
      begin                                                                     // shiftRight
              localMem[0 + 842] = localMem[0+842] >> 1;
              ip = 1879;
      end

       1879 :
      begin                                                                     // add
              localMem[0 + 843] = localMem[0+842] + 1;
              ip = 1880;
      end

       1880 :
      begin                                                                     // mov
              localMem[0 + 844] = heapMem[localMem[0+829]*10 + 2];
              ip = 1881;
      end

       1881 :
      begin                                                                     // jEq
              ip = localMem[0+844] == 0 ? 1978 : 1882;
      end

       1882 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 845] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 845] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 845]] = 0;
              ip = 1883;
      end

       1883 :
      begin                                                                     // mov
              heapMem[localMem[0+845]*10 + 0] = localMem[0+842];
              ip = 1884;
      end

       1884 :
      begin                                                                     // mov
              heapMem[localMem[0+845]*10 + 2] = 0;
              ip = 1885;
      end

       1885 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 846] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 846] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 846]] = 0;
              ip = 1886;
      end

       1886 :
      begin                                                                     // mov
              heapMem[localMem[0+845]*10 + 4] = localMem[0+846];
              ip = 1887;
      end

       1887 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 847] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 847] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 847]] = 0;
              ip = 1888;
      end

       1888 :
      begin                                                                     // mov
              heapMem[localMem[0+845]*10 + 5] = localMem[0+847];
              ip = 1889;
      end

       1889 :
      begin                                                                     // mov
              heapMem[localMem[0+845]*10 + 6] = 0;
              ip = 1890;
      end

       1890 :
      begin                                                                     // mov
              heapMem[localMem[0+845]*10 + 3] = localMem[0+840];
              ip = 1891;
      end

       1891 :
      begin                                                                     // add
              heapMem[localMem[0+840]*10 + 1] = heapMem[localMem[0+840]*10 + 1] + 1;
              ip = 1892;
      end

       1892 :
      begin                                                                     // mov
              heapMem[localMem[0+845]*10 + 1] = heapMem[localMem[0+840]*10 + 1];
              ip = 1893;
      end

       1893 :
      begin                                                                     // not
              localMem[0 + 848] = !heapMem[localMem[0+829]*10 + 6];
              ip = 1894;
      end

       1894 :
      begin                                                                     // jNe
              ip = localMem[0+848] != 0 ? 1923 : 1895;
      end

       1895 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 849] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 849] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 849]] = 0;
              ip = 1896;
      end

       1896 :
      begin                                                                     // mov
              heapMem[localMem[0+845]*10 + 6] = localMem[0+849];
              ip = 1897;
      end

       1897 :
      begin                                                                     // mov
              localMem[0 + 850] = heapMem[localMem[0+829]*10 + 4];
              ip = 1898;
      end

       1898 :
      begin                                                                     // mov
              localMem[0 + 851] = heapMem[localMem[0+845]*10 + 4];
              ip = 1899;
      end

       1899 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+842]) begin
                  heapMem[NArea * localMem[0+851] + 0 + i] = heapMem[NArea * localMem[0+850] + localMem[843] + i];
                end
              end
              ip = 1900;
      end

       1900 :
      begin                                                                     // mov
              localMem[0 + 852] = heapMem[localMem[0+829]*10 + 5];
              ip = 1901;
      end

       1901 :
      begin                                                                     // mov
              localMem[0 + 853] = heapMem[localMem[0+845]*10 + 5];
              ip = 1902;
      end

       1902 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+842]) begin
                  heapMem[NArea * localMem[0+853] + 0 + i] = heapMem[NArea * localMem[0+852] + localMem[843] + i];
                end
              end
              ip = 1903;
      end

       1903 :
      begin                                                                     // mov
              localMem[0 + 854] = heapMem[localMem[0+829]*10 + 6];
              ip = 1904;
      end

       1904 :
      begin                                                                     // mov
              localMem[0 + 855] = heapMem[localMem[0+845]*10 + 6];
              ip = 1905;
      end

       1905 :
      begin                                                                     // add
              localMem[0 + 856] = localMem[0+842] + 1;
              ip = 1906;
      end

       1906 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+856]) begin
                  heapMem[NArea * localMem[0+855] + 0 + i] = heapMem[NArea * localMem[0+854] + localMem[843] + i];
                end
              end
              ip = 1907;
      end

       1907 :
      begin                                                                     // mov
              localMem[0 + 857] = heapMem[localMem[0+845]*10 + 0];
              ip = 1908;
      end

       1908 :
      begin                                                                     // add
              localMem[0 + 858] = localMem[0+857] + 1;
              ip = 1909;
      end

       1909 :
      begin                                                                     // mov
              localMem[0 + 859] = heapMem[localMem[0+845]*10 + 6];
              ip = 1910;
      end

       1910 :
      begin                                                                     // label
              ip = 1911;
      end

       1911 :
      begin                                                                     // mov
              localMem[0 + 860] = 0;
              ip = 1912;
      end

       1912 :
      begin                                                                     // label
              ip = 1913;
      end

       1913 :
      begin                                                                     // jGe
              ip = localMem[0+860] >= localMem[0+858] ? 1919 : 1914;
      end

       1914 :
      begin                                                                     // mov
              localMem[0 + 861] = heapMem[localMem[0+859]*10 + localMem[0+860]];
              ip = 1915;
      end

       1915 :
      begin                                                                     // mov
              heapMem[localMem[0+861]*10 + 2] = localMem[0+845];
              ip = 1916;
      end

       1916 :
      begin                                                                     // label
              ip = 1917;
      end

       1917 :
      begin                                                                     // add
              localMem[0 + 860] = localMem[0+860] + 1;
              ip = 1918;
      end

       1918 :
      begin                                                                     // jmp
              ip = 1912;
      end

       1919 :
      begin                                                                     // label
              ip = 1920;
      end

       1920 :
      begin                                                                     // mov
              localMem[0 + 862] = heapMem[localMem[0+829]*10 + 6];
              ip = 1921;
      end

       1921 :
      begin                                                                     // resize
              arraySizes[localMem[0+862]] = localMem[0+843];
              ip = 1922;
      end

       1922 :
      begin                                                                     // jmp
              ip = 1930;
      end

       1923 :
      begin                                                                     // label
              ip = 1924;
      end

       1924 :
      begin                                                                     // mov
              localMem[0 + 863] = heapMem[localMem[0+829]*10 + 4];
              ip = 1925;
      end

       1925 :
      begin                                                                     // mov
              localMem[0 + 864] = heapMem[localMem[0+845]*10 + 4];
              ip = 1926;
      end

       1926 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+842]) begin
                  heapMem[NArea * localMem[0+864] + 0 + i] = heapMem[NArea * localMem[0+863] + localMem[843] + i];
                end
              end
              ip = 1927;
      end

       1927 :
      begin                                                                     // mov
              localMem[0 + 865] = heapMem[localMem[0+829]*10 + 5];
              ip = 1928;
      end

       1928 :
      begin                                                                     // mov
              localMem[0 + 866] = heapMem[localMem[0+845]*10 + 5];
              ip = 1929;
      end

       1929 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+842]) begin
                  heapMem[NArea * localMem[0+866] + 0 + i] = heapMem[NArea * localMem[0+865] + localMem[843] + i];
                end
              end
              ip = 1930;
      end

       1930 :
      begin                                                                     // label
              ip = 1931;
      end

       1931 :
      begin                                                                     // mov
              heapMem[localMem[0+829]*10 + 0] = localMem[0+842];
              ip = 1932;
      end

       1932 :
      begin                                                                     // mov
              heapMem[localMem[0+845]*10 + 2] = localMem[0+844];
              ip = 1933;
      end

       1933 :
      begin                                                                     // mov
              localMem[0 + 867] = heapMem[localMem[0+844]*10 + 0];
              ip = 1934;
      end

       1934 :
      begin                                                                     // mov
              localMem[0 + 868] = heapMem[localMem[0+844]*10 + 6];
              ip = 1935;
      end

       1935 :
      begin                                                                     // mov
              localMem[0 + 869] = heapMem[localMem[0+868]*10 + localMem[0+867]];
              ip = 1936;
      end

       1936 :
      begin                                                                     // jNe
              ip = localMem[0+869] != localMem[0+829] ? 1955 : 1937;
      end

       1937 :
      begin                                                                     // mov
              localMem[0 + 870] = heapMem[localMem[0+829]*10 + 4];
              ip = 1938;
      end

       1938 :
      begin                                                                     // mov
              localMem[0 + 871] = heapMem[localMem[0+870]*10 + localMem[0+842]];
              ip = 1939;
      end

       1939 :
      begin                                                                     // mov
              localMem[0 + 872] = heapMem[localMem[0+844]*10 + 4];
              ip = 1940;
      end

       1940 :
      begin                                                                     // mov
              heapMem[localMem[0+872]*10 + localMem[0+867]] = localMem[0+871];
              ip = 1941;
      end

       1941 :
      begin                                                                     // mov
              localMem[0 + 873] = heapMem[localMem[0+829]*10 + 5];
              ip = 1942;
      end

       1942 :
      begin                                                                     // mov
              localMem[0 + 874] = heapMem[localMem[0+873]*10 + localMem[0+842]];
              ip = 1943;
      end

       1943 :
      begin                                                                     // mov
              localMem[0 + 875] = heapMem[localMem[0+844]*10 + 5];
              ip = 1944;
      end

       1944 :
      begin                                                                     // mov
              heapMem[localMem[0+875]*10 + localMem[0+867]] = localMem[0+874];
              ip = 1945;
      end

       1945 :
      begin                                                                     // mov
              localMem[0 + 876] = heapMem[localMem[0+829]*10 + 4];
              ip = 1946;
      end

       1946 :
      begin                                                                     // resize
              arraySizes[localMem[0+876]] = localMem[0+842];
              ip = 1947;
      end

       1947 :
      begin                                                                     // mov
              localMem[0 + 877] = heapMem[localMem[0+829]*10 + 5];
              ip = 1948;
      end

       1948 :
      begin                                                                     // resize
              arraySizes[localMem[0+877]] = localMem[0+842];
              ip = 1949;
      end

       1949 :
      begin                                                                     // add
              localMem[0 + 878] = localMem[0+867] + 1;
              ip = 1950;
      end

       1950 :
      begin                                                                     // mov
              heapMem[localMem[0+844]*10 + 0] = localMem[0+878];
              ip = 1951;
      end

       1951 :
      begin                                                                     // mov
              localMem[0 + 879] = heapMem[localMem[0+844]*10 + 6];
              ip = 1952;
      end

       1952 :
      begin                                                                     // mov
              heapMem[localMem[0+879]*10 + localMem[0+878]] = localMem[0+845];
              ip = 1953;
      end

       1953 :
      begin                                                                     // jmp
              ip = 2093;
      end

       1954 :
      begin                                                                     // jmp
              ip = 1977;
      end

       1955 :
      begin                                                                     // label
              ip = 1956;
      end

       1956 :
      begin                                                                     // assertNe
            ip = 1957;
      end

       1957 :
      begin                                                                     // mov
              localMem[0 + 880] = heapMem[localMem[0+844]*10 + 6];
              ip = 1958;
      end

       1958 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+880] * NArea + i] == localMem[0+829]) localMem[0 + 881] = i + 1;
              end
              ip = 1959;
      end

       1959 :
      begin                                                                     // subtract
              localMem[0 + 881] = localMem[0+881] - 1;
              ip = 1960;
      end

       1960 :
      begin                                                                     // mov
              localMem[0 + 882] = heapMem[localMem[0+829]*10 + 4];
              ip = 1961;
      end

       1961 :
      begin                                                                     // mov
              localMem[0 + 883] = heapMem[localMem[0+882]*10 + localMem[0+842]];
              ip = 1962;
      end

       1962 :
      begin                                                                     // mov
              localMem[0 + 884] = heapMem[localMem[0+829]*10 + 5];
              ip = 1963;
      end

       1963 :
      begin                                                                     // mov
              localMem[0 + 885] = heapMem[localMem[0+884]*10 + localMem[0+842]];
              ip = 1964;
      end

       1964 :
      begin                                                                     // mov
              localMem[0 + 886] = heapMem[localMem[0+829]*10 + 4];
              ip = 1965;
      end

       1965 :
      begin                                                                     // resize
              arraySizes[localMem[0+886]] = localMem[0+842];
              ip = 1966;
      end

       1966 :
      begin                                                                     // mov
              localMem[0 + 887] = heapMem[localMem[0+829]*10 + 5];
              ip = 1967;
      end

       1967 :
      begin                                                                     // resize
              arraySizes[localMem[0+887]] = localMem[0+842];
              ip = 1968;
      end

       1968 :
      begin                                                                     // mov
              localMem[0 + 888] = heapMem[localMem[0+844]*10 + 4];
              ip = 1969;
      end

       1969 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+888] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[881]) begin
                  heapMem[NArea * localMem[0+888] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+888] + localMem[881]] = localMem[0+883];                                    // Insert new value
              arraySizes[localMem[0+888]] = arraySizes[localMem[0+888]] + 1;                              // Increase array size
              ip = 1970;
      end

       1970 :
      begin                                                                     // mov
              localMem[0 + 889] = heapMem[localMem[0+844]*10 + 5];
              ip = 1971;
      end

       1971 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+889] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[881]) begin
                  heapMem[NArea * localMem[0+889] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+889] + localMem[881]] = localMem[0+885];                                    // Insert new value
              arraySizes[localMem[0+889]] = arraySizes[localMem[0+889]] + 1;                              // Increase array size
              ip = 1972;
      end

       1972 :
      begin                                                                     // mov
              localMem[0 + 890] = heapMem[localMem[0+844]*10 + 6];
              ip = 1973;
      end

       1973 :
      begin                                                                     // add
              localMem[0 + 891] = localMem[0+881] + 1;
              ip = 1974;
      end

       1974 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+890] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[891]) begin
                  heapMem[NArea * localMem[0+890] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+890] + localMem[891]] = localMem[0+845];                                    // Insert new value
              arraySizes[localMem[0+890]] = arraySizes[localMem[0+890]] + 1;                              // Increase array size
              ip = 1975;
      end

       1975 :
      begin                                                                     // add
              heapMem[localMem[0+844]*10 + 0] = heapMem[localMem[0+844]*10 + 0] + 1;
              ip = 1976;
      end

       1976 :
      begin                                                                     // jmp
              ip = 2093;
      end

       1977 :
      begin                                                                     // label
              ip = 1978;
      end

       1978 :
      begin                                                                     // label
              ip = 1979;
      end

       1979 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 892] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 892] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 892]] = 0;
              ip = 1980;
      end

       1980 :
      begin                                                                     // mov
              heapMem[localMem[0+892]*10 + 0] = localMem[0+842];
              ip = 1981;
      end

       1981 :
      begin                                                                     // mov
              heapMem[localMem[0+892]*10 + 2] = 0;
              ip = 1982;
      end

       1982 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 893] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 893] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 893]] = 0;
              ip = 1983;
      end

       1983 :
      begin                                                                     // mov
              heapMem[localMem[0+892]*10 + 4] = localMem[0+893];
              ip = 1984;
      end

       1984 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 894] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 894] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 894]] = 0;
              ip = 1985;
      end

       1985 :
      begin                                                                     // mov
              heapMem[localMem[0+892]*10 + 5] = localMem[0+894];
              ip = 1986;
      end

       1986 :
      begin                                                                     // mov
              heapMem[localMem[0+892]*10 + 6] = 0;
              ip = 1987;
      end

       1987 :
      begin                                                                     // mov
              heapMem[localMem[0+892]*10 + 3] = localMem[0+840];
              ip = 1988;
      end

       1988 :
      begin                                                                     // add
              heapMem[localMem[0+840]*10 + 1] = heapMem[localMem[0+840]*10 + 1] + 1;
              ip = 1989;
      end

       1989 :
      begin                                                                     // mov
              heapMem[localMem[0+892]*10 + 1] = heapMem[localMem[0+840]*10 + 1];
              ip = 1990;
      end

       1990 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 895] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 895] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 895]] = 0;
              ip = 1991;
      end

       1991 :
      begin                                                                     // mov
              heapMem[localMem[0+895]*10 + 0] = localMem[0+842];
              ip = 1992;
      end

       1992 :
      begin                                                                     // mov
              heapMem[localMem[0+895]*10 + 2] = 0;
              ip = 1993;
      end

       1993 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 896] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 896] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 896]] = 0;
              ip = 1994;
      end

       1994 :
      begin                                                                     // mov
              heapMem[localMem[0+895]*10 + 4] = localMem[0+896];
              ip = 1995;
      end

       1995 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 897] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 897] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 897]] = 0;
              ip = 1996;
      end

       1996 :
      begin                                                                     // mov
              heapMem[localMem[0+895]*10 + 5] = localMem[0+897];
              ip = 1997;
      end

       1997 :
      begin                                                                     // mov
              heapMem[localMem[0+895]*10 + 6] = 0;
              ip = 1998;
      end

       1998 :
      begin                                                                     // mov
              heapMem[localMem[0+895]*10 + 3] = localMem[0+840];
              ip = 1999;
      end

       1999 :
      begin                                                                     // add
              heapMem[localMem[0+840]*10 + 1] = heapMem[localMem[0+840]*10 + 1] + 1;
              ip = 2000;
      end

       2000 :
      begin                                                                     // mov
              heapMem[localMem[0+895]*10 + 1] = heapMem[localMem[0+840]*10 + 1];
              ip = 2001;
      end

       2001 :
      begin                                                                     // not
              localMem[0 + 898] = !heapMem[localMem[0+829]*10 + 6];
              ip = 2002;
      end

       2002 :
      begin                                                                     // jNe
              ip = localMem[0+898] != 0 ? 2054 : 2003;
      end

       2003 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 899] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 899] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 899]] = 0;
              ip = 2004;
      end

       2004 :
      begin                                                                     // mov
              heapMem[localMem[0+892]*10 + 6] = localMem[0+899];
              ip = 2005;
      end

       2005 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 900] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 900] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 900]] = 0;
              ip = 2006;
      end

       2006 :
      begin                                                                     // mov
              heapMem[localMem[0+895]*10 + 6] = localMem[0+900];
              ip = 2007;
      end

       2007 :
      begin                                                                     // mov
              localMem[0 + 901] = heapMem[localMem[0+829]*10 + 4];
              ip = 2008;
      end

       2008 :
      begin                                                                     // mov
              localMem[0 + 902] = heapMem[localMem[0+892]*10 + 4];
              ip = 2009;
      end

       2009 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+842]) begin
                  heapMem[NArea * localMem[0+902] + 0 + i] = heapMem[NArea * localMem[0+901] + 0 + i];
                end
              end
              ip = 2010;
      end

       2010 :
      begin                                                                     // mov
              localMem[0 + 903] = heapMem[localMem[0+829]*10 + 5];
              ip = 2011;
      end

       2011 :
      begin                                                                     // mov
              localMem[0 + 904] = heapMem[localMem[0+892]*10 + 5];
              ip = 2012;
      end

       2012 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+842]) begin
                  heapMem[NArea * localMem[0+904] + 0 + i] = heapMem[NArea * localMem[0+903] + 0 + i];
                end
              end
              ip = 2013;
      end

       2013 :
      begin                                                                     // mov
              localMem[0 + 905] = heapMem[localMem[0+829]*10 + 6];
              ip = 2014;
      end

       2014 :
      begin                                                                     // mov
              localMem[0 + 906] = heapMem[localMem[0+892]*10 + 6];
              ip = 2015;
      end

       2015 :
      begin                                                                     // add
              localMem[0 + 907] = localMem[0+842] + 1;
              ip = 2016;
      end

       2016 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+907]) begin
                  heapMem[NArea * localMem[0+906] + 0 + i] = heapMem[NArea * localMem[0+905] + 0 + i];
                end
              end
              ip = 2017;
      end

       2017 :
      begin                                                                     // mov
              localMem[0 + 908] = heapMem[localMem[0+829]*10 + 4];
              ip = 2018;
      end

       2018 :
      begin                                                                     // mov
              localMem[0 + 909] = heapMem[localMem[0+895]*10 + 4];
              ip = 2019;
      end

       2019 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+842]) begin
                  heapMem[NArea * localMem[0+909] + 0 + i] = heapMem[NArea * localMem[0+908] + localMem[843] + i];
                end
              end
              ip = 2020;
      end

       2020 :
      begin                                                                     // mov
              localMem[0 + 910] = heapMem[localMem[0+829]*10 + 5];
              ip = 2021;
      end

       2021 :
      begin                                                                     // mov
              localMem[0 + 911] = heapMem[localMem[0+895]*10 + 5];
              ip = 2022;
      end

       2022 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+842]) begin
                  heapMem[NArea * localMem[0+911] + 0 + i] = heapMem[NArea * localMem[0+910] + localMem[843] + i];
                end
              end
              ip = 2023;
      end

       2023 :
      begin                                                                     // mov
              localMem[0 + 912] = heapMem[localMem[0+829]*10 + 6];
              ip = 2024;
      end

       2024 :
      begin                                                                     // mov
              localMem[0 + 913] = heapMem[localMem[0+895]*10 + 6];
              ip = 2025;
      end

       2025 :
      begin                                                                     // add
              localMem[0 + 914] = localMem[0+842] + 1;
              ip = 2026;
      end

       2026 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+914]) begin
                  heapMem[NArea * localMem[0+913] + 0 + i] = heapMem[NArea * localMem[0+912] + localMem[843] + i];
                end
              end
              ip = 2027;
      end

       2027 :
      begin                                                                     // mov
              localMem[0 + 915] = heapMem[localMem[0+892]*10 + 0];
              ip = 2028;
      end

       2028 :
      begin                                                                     // add
              localMem[0 + 916] = localMem[0+915] + 1;
              ip = 2029;
      end

       2029 :
      begin                                                                     // mov
              localMem[0 + 917] = heapMem[localMem[0+892]*10 + 6];
              ip = 2030;
      end

       2030 :
      begin                                                                     // label
              ip = 2031;
      end

       2031 :
      begin                                                                     // mov
              localMem[0 + 918] = 0;
              ip = 2032;
      end

       2032 :
      begin                                                                     // label
              ip = 2033;
      end

       2033 :
      begin                                                                     // jGe
              ip = localMem[0+918] >= localMem[0+916] ? 2039 : 2034;
      end

       2034 :
      begin                                                                     // mov
              localMem[0 + 919] = heapMem[localMem[0+917]*10 + localMem[0+918]];
              ip = 2035;
      end

       2035 :
      begin                                                                     // mov
              heapMem[localMem[0+919]*10 + 2] = localMem[0+892];
              ip = 2036;
      end

       2036 :
      begin                                                                     // label
              ip = 2037;
      end

       2037 :
      begin                                                                     // add
              localMem[0 + 918] = localMem[0+918] + 1;
              ip = 2038;
      end

       2038 :
      begin                                                                     // jmp
              ip = 2032;
      end

       2039 :
      begin                                                                     // label
              ip = 2040;
      end

       2040 :
      begin                                                                     // mov
              localMem[0 + 920] = heapMem[localMem[0+895]*10 + 0];
              ip = 2041;
      end

       2041 :
      begin                                                                     // add
              localMem[0 + 921] = localMem[0+920] + 1;
              ip = 2042;
      end

       2042 :
      begin                                                                     // mov
              localMem[0 + 922] = heapMem[localMem[0+895]*10 + 6];
              ip = 2043;
      end

       2043 :
      begin                                                                     // label
              ip = 2044;
      end

       2044 :
      begin                                                                     // mov
              localMem[0 + 923] = 0;
              ip = 2045;
      end

       2045 :
      begin                                                                     // label
              ip = 2046;
      end

       2046 :
      begin                                                                     // jGe
              ip = localMem[0+923] >= localMem[0+921] ? 2052 : 2047;
      end

       2047 :
      begin                                                                     // mov
              localMem[0 + 924] = heapMem[localMem[0+922]*10 + localMem[0+923]];
              ip = 2048;
      end

       2048 :
      begin                                                                     // mov
              heapMem[localMem[0+924]*10 + 2] = localMem[0+895];
              ip = 2049;
      end

       2049 :
      begin                                                                     // label
              ip = 2050;
      end

       2050 :
      begin                                                                     // add
              localMem[0 + 923] = localMem[0+923] + 1;
              ip = 2051;
      end

       2051 :
      begin                                                                     // jmp
              ip = 2045;
      end

       2052 :
      begin                                                                     // label
              ip = 2053;
      end

       2053 :
      begin                                                                     // jmp
              ip = 2069;
      end

       2054 :
      begin                                                                     // label
              ip = 2055;
      end

       2055 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 925] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 925] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 925]] = 0;
              ip = 2056;
      end

       2056 :
      begin                                                                     // mov
              heapMem[localMem[0+829]*10 + 6] = localMem[0+925];
              ip = 2057;
      end

       2057 :
      begin                                                                     // mov
              localMem[0 + 926] = heapMem[localMem[0+829]*10 + 4];
              ip = 2058;
      end

       2058 :
      begin                                                                     // mov
              localMem[0 + 927] = heapMem[localMem[0+892]*10 + 4];
              ip = 2059;
      end

       2059 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+842]) begin
                  heapMem[NArea * localMem[0+927] + 0 + i] = heapMem[NArea * localMem[0+926] + 0 + i];
                end
              end
              ip = 2060;
      end

       2060 :
      begin                                                                     // mov
              localMem[0 + 928] = heapMem[localMem[0+829]*10 + 5];
              ip = 2061;
      end

       2061 :
      begin                                                                     // mov
              localMem[0 + 929] = heapMem[localMem[0+892]*10 + 5];
              ip = 2062;
      end

       2062 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+842]) begin
                  heapMem[NArea * localMem[0+929] + 0 + i] = heapMem[NArea * localMem[0+928] + 0 + i];
                end
              end
              ip = 2063;
      end

       2063 :
      begin                                                                     // mov
              localMem[0 + 930] = heapMem[localMem[0+829]*10 + 4];
              ip = 2064;
      end

       2064 :
      begin                                                                     // mov
              localMem[0 + 931] = heapMem[localMem[0+895]*10 + 4];
              ip = 2065;
      end

       2065 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+842]) begin
                  heapMem[NArea * localMem[0+931] + 0 + i] = heapMem[NArea * localMem[0+930] + localMem[843] + i];
                end
              end
              ip = 2066;
      end

       2066 :
      begin                                                                     // mov
              localMem[0 + 932] = heapMem[localMem[0+829]*10 + 5];
              ip = 2067;
      end

       2067 :
      begin                                                                     // mov
              localMem[0 + 933] = heapMem[localMem[0+895]*10 + 5];
              ip = 2068;
      end

       2068 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+842]) begin
                  heapMem[NArea * localMem[0+933] + 0 + i] = heapMem[NArea * localMem[0+932] + localMem[843] + i];
                end
              end
              ip = 2069;
      end

       2069 :
      begin                                                                     // label
              ip = 2070;
      end

       2070 :
      begin                                                                     // mov
              heapMem[localMem[0+892]*10 + 2] = localMem[0+829];
              ip = 2071;
      end

       2071 :
      begin                                                                     // mov
              heapMem[localMem[0+895]*10 + 2] = localMem[0+829];
              ip = 2072;
      end

       2072 :
      begin                                                                     // mov
              localMem[0 + 934] = heapMem[localMem[0+829]*10 + 4];
              ip = 2073;
      end

       2073 :
      begin                                                                     // mov
              localMem[0 + 935] = heapMem[localMem[0+934]*10 + localMem[0+842]];
              ip = 2074;
      end

       2074 :
      begin                                                                     // mov
              localMem[0 + 936] = heapMem[localMem[0+829]*10 + 5];
              ip = 2075;
      end

       2075 :
      begin                                                                     // mov
              localMem[0 + 937] = heapMem[localMem[0+936]*10 + localMem[0+842]];
              ip = 2076;
      end

       2076 :
      begin                                                                     // mov
              localMem[0 + 938] = heapMem[localMem[0+829]*10 + 4];
              ip = 2077;
      end

       2077 :
      begin                                                                     // mov
              heapMem[localMem[0+938]*10 + 0] = localMem[0+935];
              ip = 2078;
      end

       2078 :
      begin                                                                     // mov
              localMem[0 + 939] = heapMem[localMem[0+829]*10 + 5];
              ip = 2079;
      end

       2079 :
      begin                                                                     // mov
              heapMem[localMem[0+939]*10 + 0] = localMem[0+937];
              ip = 2080;
      end

       2080 :
      begin                                                                     // mov
              localMem[0 + 940] = heapMem[localMem[0+829]*10 + 6];
              ip = 2081;
      end

       2081 :
      begin                                                                     // mov
              heapMem[localMem[0+940]*10 + 0] = localMem[0+892];
              ip = 2082;
      end

       2082 :
      begin                                                                     // mov
              localMem[0 + 941] = heapMem[localMem[0+829]*10 + 6];
              ip = 2083;
      end

       2083 :
      begin                                                                     // mov
              heapMem[localMem[0+941]*10 + 1] = localMem[0+895];
              ip = 2084;
      end

       2084 :
      begin                                                                     // mov
              heapMem[localMem[0+829]*10 + 0] = 1;
              ip = 2085;
      end

       2085 :
      begin                                                                     // mov
              localMem[0 + 942] = heapMem[localMem[0+829]*10 + 4];
              ip = 2086;
      end

       2086 :
      begin                                                                     // resize
              arraySizes[localMem[0+942]] = 1;
              ip = 2087;
      end

       2087 :
      begin                                                                     // mov
              localMem[0 + 943] = heapMem[localMem[0+829]*10 + 5];
              ip = 2088;
      end

       2088 :
      begin                                                                     // resize
              arraySizes[localMem[0+943]] = 1;
              ip = 2089;
      end

       2089 :
      begin                                                                     // mov
              localMem[0 + 944] = heapMem[localMem[0+829]*10 + 6];
              ip = 2090;
      end

       2090 :
      begin                                                                     // resize
              arraySizes[localMem[0+944]] = 2;
              ip = 2091;
      end

       2091 :
      begin                                                                     // jmp
              ip = 2093;
      end

       2092 :
      begin                                                                     // jmp
              ip = 2098;
      end

       2093 :
      begin                                                                     // label
              ip = 2094;
      end

       2094 :
      begin                                                                     // mov
              localMem[0 + 838] = 1;
              ip = 2095;
      end

       2095 :
      begin                                                                     // jmp
              ip = 2098;
      end

       2096 :
      begin                                                                     // label
              ip = 2097;
      end

       2097 :
      begin                                                                     // mov
              localMem[0 + 838] = 0;
              ip = 2098;
      end

       2098 :
      begin                                                                     // label
              ip = 2099;
      end

       2099 :
      begin                                                                     // label
              ip = 2100;
      end

       2100 :
      begin                                                                     // label
              ip = 2101;
      end

       2101 :
      begin                                                                     // label
              ip = 2102;
      end

       2102 :
      begin                                                                     // free
              freedArrays[freedArraysTop] = localMem[0+473];
              freedArraysTop = freedArraysTop + 1;
              ip = 2103;
      end
      default: begin
        success  = 1;
        finished = 1;
      end
    endcase
    if (steps <=     57) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
  end
endmodule
