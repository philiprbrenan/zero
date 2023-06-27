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

       2103 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 945] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 945] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 945]] = 0;
              ip = 2104;
      end

       2104 :
      begin                                                                     // label
              ip = 2105;
      end

       2105 :
      begin                                                                     // mov
              localMem[0 + 946] = heapMem[localMem[0+0]*10 + 3];
              ip = 2106;
      end

       2106 :
      begin                                                                     // jNe
              ip = localMem[0+946] != 0 ? 2125 : 2107;
      end

       2107 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 947] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 947] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 947]] = 0;
              ip = 2108;
      end

       2108 :
      begin                                                                     // mov
              heapMem[localMem[0+947]*10 + 0] = 1;
              ip = 2109;
      end

       2109 :
      begin                                                                     // mov
              heapMem[localMem[0+947]*10 + 2] = 0;
              ip = 2110;
      end

       2110 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 948] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 948] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 948]] = 0;
              ip = 2111;
      end

       2111 :
      begin                                                                     // mov
              heapMem[localMem[0+947]*10 + 4] = localMem[0+948];
              ip = 2112;
      end

       2112 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 949] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 949] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 949]] = 0;
              ip = 2113;
      end

       2113 :
      begin                                                                     // mov
              heapMem[localMem[0+947]*10 + 5] = localMem[0+949];
              ip = 2114;
      end

       2114 :
      begin                                                                     // mov
              heapMem[localMem[0+947]*10 + 6] = 0;
              ip = 2115;
      end

       2115 :
      begin                                                                     // mov
              heapMem[localMem[0+947]*10 + 3] = localMem[0+0];
              ip = 2116;
      end

       2116 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 1] = heapMem[localMem[0+0]*10 + 1] + 1;
              ip = 2117;
      end

       2117 :
      begin                                                                     // mov
              heapMem[localMem[0+947]*10 + 1] = heapMem[localMem[0+0]*10 + 1];
              ip = 2118;
      end

       2118 :
      begin                                                                     // mov
              localMem[0 + 950] = heapMem[localMem[0+947]*10 + 4];
              ip = 2119;
      end

       2119 :
      begin                                                                     // mov
              heapMem[localMem[0+950]*10 + 0] = 3;
              ip = 2120;
      end

       2120 :
      begin                                                                     // mov
              localMem[0 + 951] = heapMem[localMem[0+947]*10 + 5];
              ip = 2121;
      end

       2121 :
      begin                                                                     // mov
              heapMem[localMem[0+951]*10 + 0] = 33;
              ip = 2122;
      end

       2122 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 2123;
      end

       2123 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 3] = localMem[0+947];
              ip = 2124;
      end

       2124 :
      begin                                                                     // jmp
              ip = 3150;
      end

       2125 :
      begin                                                                     // label
              ip = 2126;
      end

       2126 :
      begin                                                                     // mov
              localMem[0 + 952] = heapMem[localMem[0+946]*10 + 0];
              ip = 2127;
      end

       2127 :
      begin                                                                     // mov
              localMem[0 + 953] = heapMem[localMem[0+0]*10 + 2];
              ip = 2128;
      end

       2128 :
      begin                                                                     // jGe
              ip = localMem[0+952] >= localMem[0+953] ? 2161 : 2129;
      end

       2129 :
      begin                                                                     // mov
              localMem[0 + 954] = heapMem[localMem[0+946]*10 + 2];
              ip = 2130;
      end

       2130 :
      begin                                                                     // jNe
              ip = localMem[0+954] != 0 ? 2160 : 2131;
      end

       2131 :
      begin                                                                     // not
              localMem[0 + 955] = !heapMem[localMem[0+946]*10 + 6];
              ip = 2132;
      end

       2132 :
      begin                                                                     // jEq
              ip = localMem[0+955] == 0 ? 2159 : 2133;
      end

       2133 :
      begin                                                                     // mov
              localMem[0 + 956] = heapMem[localMem[0+946]*10 + 4];
              ip = 2134;
      end

       2134 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+956] * NArea + i] == 3) localMem[0 + 957] = i + 1;
              end
              ip = 2135;
      end

       2135 :
      begin                                                                     // jEq
              ip = localMem[0+957] == 0 ? 2140 : 2136;
      end

       2136 :
      begin                                                                     // subtract
              localMem[0 + 957] = localMem[0+957] - 1;
              ip = 2137;
      end

       2137 :
      begin                                                                     // mov
              localMem[0 + 958] = heapMem[localMem[0+946]*10 + 5];
              ip = 2138;
      end

       2138 :
      begin                                                                     // mov
              heapMem[localMem[0+958]*10 + localMem[0+957]] = 33;
              ip = 2139;
      end

       2139 :
      begin                                                                     // jmp
              ip = 3150;
      end

       2140 :
      begin                                                                     // label
              ip = 2141;
      end

       2141 :
      begin                                                                     // arrayCountGreater
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+956] * NArea + i] > 3) j = j + 1;
              end
              localMem[0 + 959] = j;
              ip = 2142;
      end

       2142 :
      begin                                                                     // jNe
              ip = localMem[0+959] != 0 ? 2150 : 2143;
      end

       2143 :
      begin                                                                     // mov
              localMem[0 + 960] = heapMem[localMem[0+946]*10 + 4];
              ip = 2144;
      end

       2144 :
      begin                                                                     // mov
              heapMem[localMem[0+960]*10 + localMem[0+952]] = 3;
              ip = 2145;
      end

       2145 :
      begin                                                                     // mov
              localMem[0 + 961] = heapMem[localMem[0+946]*10 + 5];
              ip = 2146;
      end

       2146 :
      begin                                                                     // mov
              heapMem[localMem[0+961]*10 + localMem[0+952]] = 33;
              ip = 2147;
      end

       2147 :
      begin                                                                     // add
              heapMem[localMem[0+946]*10 + 0] = localMem[0+952] + 1;
              ip = 2148;
      end

       2148 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 2149;
      end

       2149 :
      begin                                                                     // jmp
              ip = 3150;
      end

       2150 :
      begin                                                                     // label
              ip = 2151;
      end

       2151 :
      begin                                                                     // arrayCountLess
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+956] * NArea + i] < 3) j = j + 1;
              end
              localMem[0 + 962] = j;
              ip = 2152;
      end

       2152 :
      begin                                                                     // mov
              localMem[0 + 963] = heapMem[localMem[0+946]*10 + 4];
              ip = 2153;
      end

       2153 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+963] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[962]) begin
                  heapMem[NArea * localMem[0+963] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+963] + localMem[962]] = 3;                                    // Insert new value
              arraySizes[localMem[0+963]] = arraySizes[localMem[0+963]] + 1;                              // Increase array size
              ip = 2154;
      end

       2154 :
      begin                                                                     // mov
              localMem[0 + 964] = heapMem[localMem[0+946]*10 + 5];
              ip = 2155;
      end

       2155 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+964] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[962]) begin
                  heapMem[NArea * localMem[0+964] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+964] + localMem[962]] = 33;                                    // Insert new value
              arraySizes[localMem[0+964]] = arraySizes[localMem[0+964]] + 1;                              // Increase array size
              ip = 2156;
      end

       2156 :
      begin                                                                     // add
              heapMem[localMem[0+946]*10 + 0] = heapMem[localMem[0+946]*10 + 0] + 1;
              ip = 2157;
      end

       2157 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 2158;
      end

       2158 :
      begin                                                                     // jmp
              ip = 3150;
      end

       2159 :
      begin                                                                     // label
              ip = 2160;
      end

       2160 :
      begin                                                                     // label
              ip = 2161;
      end

       2161 :
      begin                                                                     // label
              ip = 2162;
      end

       2162 :
      begin                                                                     // mov
              localMem[0 + 965] = heapMem[localMem[0+0]*10 + 3];
              ip = 2163;
      end

       2163 :
      begin                                                                     // label
              ip = 2164;
      end

       2164 :
      begin                                                                     // mov
              localMem[0 + 967] = heapMem[localMem[0+965]*10 + 0];
              ip = 2165;
      end

       2165 :
      begin                                                                     // mov
              localMem[0 + 968] = heapMem[localMem[0+965]*10 + 3];
              ip = 2166;
      end

       2166 :
      begin                                                                     // mov
              localMem[0 + 969] = heapMem[localMem[0+968]*10 + 2];
              ip = 2167;
      end

       2167 :
      begin                                                                     // jLt
              ip = localMem[0+967] <  localMem[0+969] ? 2387 : 2168;
      end

       2168 :
      begin                                                                     // mov
              localMem[0 + 970] = localMem[0+969];
              ip = 2169;
      end

       2169 :
      begin                                                                     // shiftRight
              localMem[0 + 970] = localMem[0+970] >> 1;
              ip = 2170;
      end

       2170 :
      begin                                                                     // add
              localMem[0 + 971] = localMem[0+970] + 1;
              ip = 2171;
      end

       2171 :
      begin                                                                     // mov
              localMem[0 + 972] = heapMem[localMem[0+965]*10 + 2];
              ip = 2172;
      end

       2172 :
      begin                                                                     // jEq
              ip = localMem[0+972] == 0 ? 2269 : 2173;
      end

       2173 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 973] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 973] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 973]] = 0;
              ip = 2174;
      end

       2174 :
      begin                                                                     // mov
              heapMem[localMem[0+973]*10 + 0] = localMem[0+970];
              ip = 2175;
      end

       2175 :
      begin                                                                     // mov
              heapMem[localMem[0+973]*10 + 2] = 0;
              ip = 2176;
      end

       2176 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 974] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 974] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 974]] = 0;
              ip = 2177;
      end

       2177 :
      begin                                                                     // mov
              heapMem[localMem[0+973]*10 + 4] = localMem[0+974];
              ip = 2178;
      end

       2178 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 975] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 975] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 975]] = 0;
              ip = 2179;
      end

       2179 :
      begin                                                                     // mov
              heapMem[localMem[0+973]*10 + 5] = localMem[0+975];
              ip = 2180;
      end

       2180 :
      begin                                                                     // mov
              heapMem[localMem[0+973]*10 + 6] = 0;
              ip = 2181;
      end

       2181 :
      begin                                                                     // mov
              heapMem[localMem[0+973]*10 + 3] = localMem[0+968];
              ip = 2182;
      end

       2182 :
      begin                                                                     // add
              heapMem[localMem[0+968]*10 + 1] = heapMem[localMem[0+968]*10 + 1] + 1;
              ip = 2183;
      end

       2183 :
      begin                                                                     // mov
              heapMem[localMem[0+973]*10 + 1] = heapMem[localMem[0+968]*10 + 1];
              ip = 2184;
      end

       2184 :
      begin                                                                     // not
              localMem[0 + 976] = !heapMem[localMem[0+965]*10 + 6];
              ip = 2185;
      end

       2185 :
      begin                                                                     // jNe
              ip = localMem[0+976] != 0 ? 2214 : 2186;
      end

       2186 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 977] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 977] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 977]] = 0;
              ip = 2187;
      end

       2187 :
      begin                                                                     // mov
              heapMem[localMem[0+973]*10 + 6] = localMem[0+977];
              ip = 2188;
      end

       2188 :
      begin                                                                     // mov
              localMem[0 + 978] = heapMem[localMem[0+965]*10 + 4];
              ip = 2189;
      end

       2189 :
      begin                                                                     // mov
              localMem[0 + 979] = heapMem[localMem[0+973]*10 + 4];
              ip = 2190;
      end

       2190 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+970]) begin
                  heapMem[NArea * localMem[0+979] + 0 + i] = heapMem[NArea * localMem[0+978] + localMem[971] + i];
                end
              end
              ip = 2191;
      end

       2191 :
      begin                                                                     // mov
              localMem[0 + 980] = heapMem[localMem[0+965]*10 + 5];
              ip = 2192;
      end

       2192 :
      begin                                                                     // mov
              localMem[0 + 981] = heapMem[localMem[0+973]*10 + 5];
              ip = 2193;
      end

       2193 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+970]) begin
                  heapMem[NArea * localMem[0+981] + 0 + i] = heapMem[NArea * localMem[0+980] + localMem[971] + i];
                end
              end
              ip = 2194;
      end

       2194 :
      begin                                                                     // mov
              localMem[0 + 982] = heapMem[localMem[0+965]*10 + 6];
              ip = 2195;
      end

       2195 :
      begin                                                                     // mov
              localMem[0 + 983] = heapMem[localMem[0+973]*10 + 6];
              ip = 2196;
      end

       2196 :
      begin                                                                     // add
              localMem[0 + 984] = localMem[0+970] + 1;
              ip = 2197;
      end

       2197 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+984]) begin
                  heapMem[NArea * localMem[0+983] + 0 + i] = heapMem[NArea * localMem[0+982] + localMem[971] + i];
                end
              end
              ip = 2198;
      end

       2198 :
      begin                                                                     // mov
              localMem[0 + 985] = heapMem[localMem[0+973]*10 + 0];
              ip = 2199;
      end

       2199 :
      begin                                                                     // add
              localMem[0 + 986] = localMem[0+985] + 1;
              ip = 2200;
      end

       2200 :
      begin                                                                     // mov
              localMem[0 + 987] = heapMem[localMem[0+973]*10 + 6];
              ip = 2201;
      end

       2201 :
      begin                                                                     // label
              ip = 2202;
      end

       2202 :
      begin                                                                     // mov
              localMem[0 + 988] = 0;
              ip = 2203;
      end

       2203 :
      begin                                                                     // label
              ip = 2204;
      end

       2204 :
      begin                                                                     // jGe
              ip = localMem[0+988] >= localMem[0+986] ? 2210 : 2205;
      end

       2205 :
      begin                                                                     // mov
              localMem[0 + 989] = heapMem[localMem[0+987]*10 + localMem[0+988]];
              ip = 2206;
      end

       2206 :
      begin                                                                     // mov
              heapMem[localMem[0+989]*10 + 2] = localMem[0+973];
              ip = 2207;
      end

       2207 :
      begin                                                                     // label
              ip = 2208;
      end

       2208 :
      begin                                                                     // add
              localMem[0 + 988] = localMem[0+988] + 1;
              ip = 2209;
      end

       2209 :
      begin                                                                     // jmp
              ip = 2203;
      end

       2210 :
      begin                                                                     // label
              ip = 2211;
      end

       2211 :
      begin                                                                     // mov
              localMem[0 + 990] = heapMem[localMem[0+965]*10 + 6];
              ip = 2212;
      end

       2212 :
      begin                                                                     // resize
              arraySizes[localMem[0+990]] = localMem[0+971];
              ip = 2213;
      end

       2213 :
      begin                                                                     // jmp
              ip = 2221;
      end

       2214 :
      begin                                                                     // label
              ip = 2215;
      end

       2215 :
      begin                                                                     // mov
              localMem[0 + 991] = heapMem[localMem[0+965]*10 + 4];
              ip = 2216;
      end

       2216 :
      begin                                                                     // mov
              localMem[0 + 992] = heapMem[localMem[0+973]*10 + 4];
              ip = 2217;
      end

       2217 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+970]) begin
                  heapMem[NArea * localMem[0+992] + 0 + i] = heapMem[NArea * localMem[0+991] + localMem[971] + i];
                end
              end
              ip = 2218;
      end

       2218 :
      begin                                                                     // mov
              localMem[0 + 993] = heapMem[localMem[0+965]*10 + 5];
              ip = 2219;
      end

       2219 :
      begin                                                                     // mov
              localMem[0 + 994] = heapMem[localMem[0+973]*10 + 5];
              ip = 2220;
      end

       2220 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+970]) begin
                  heapMem[NArea * localMem[0+994] + 0 + i] = heapMem[NArea * localMem[0+993] + localMem[971] + i];
                end
              end
              ip = 2221;
      end

       2221 :
      begin                                                                     // label
              ip = 2222;
      end

       2222 :
      begin                                                                     // mov
              heapMem[localMem[0+965]*10 + 0] = localMem[0+970];
              ip = 2223;
      end

       2223 :
      begin                                                                     // mov
              heapMem[localMem[0+973]*10 + 2] = localMem[0+972];
              ip = 2224;
      end

       2224 :
      begin                                                                     // mov
              localMem[0 + 995] = heapMem[localMem[0+972]*10 + 0];
              ip = 2225;
      end

       2225 :
      begin                                                                     // mov
              localMem[0 + 996] = heapMem[localMem[0+972]*10 + 6];
              ip = 2226;
      end

       2226 :
      begin                                                                     // mov
              localMem[0 + 997] = heapMem[localMem[0+996]*10 + localMem[0+995]];
              ip = 2227;
      end

       2227 :
      begin                                                                     // jNe
              ip = localMem[0+997] != localMem[0+965] ? 2246 : 2228;
      end

       2228 :
      begin                                                                     // mov
              localMem[0 + 998] = heapMem[localMem[0+965]*10 + 4];
              ip = 2229;
      end

       2229 :
      begin                                                                     // mov
              localMem[0 + 999] = heapMem[localMem[0+998]*10 + localMem[0+970]];
              ip = 2230;
      end

       2230 :
      begin                                                                     // mov
              localMem[0 + 1000] = heapMem[localMem[0+972]*10 + 4];
              ip = 2231;
      end

       2231 :
      begin                                                                     // mov
              heapMem[localMem[0+1000]*10 + localMem[0+995]] = localMem[0+999];
              ip = 2232;
      end

       2232 :
      begin                                                                     // mov
              localMem[0 + 1001] = heapMem[localMem[0+965]*10 + 5];
              ip = 2233;
      end

       2233 :
      begin                                                                     // mov
              localMem[0 + 1002] = heapMem[localMem[0+1001]*10 + localMem[0+970]];
              ip = 2234;
      end

       2234 :
      begin                                                                     // mov
              localMem[0 + 1003] = heapMem[localMem[0+972]*10 + 5];
              ip = 2235;
      end

       2235 :
      begin                                                                     // mov
              heapMem[localMem[0+1003]*10 + localMem[0+995]] = localMem[0+1002];
              ip = 2236;
      end

       2236 :
      begin                                                                     // mov
              localMem[0 + 1004] = heapMem[localMem[0+965]*10 + 4];
              ip = 2237;
      end

       2237 :
      begin                                                                     // resize
              arraySizes[localMem[0+1004]] = localMem[0+970];
              ip = 2238;
      end

       2238 :
      begin                                                                     // mov
              localMem[0 + 1005] = heapMem[localMem[0+965]*10 + 5];
              ip = 2239;
      end

       2239 :
      begin                                                                     // resize
              arraySizes[localMem[0+1005]] = localMem[0+970];
              ip = 2240;
      end

       2240 :
      begin                                                                     // add
              localMem[0 + 1006] = localMem[0+995] + 1;
              ip = 2241;
      end

       2241 :
      begin                                                                     // mov
              heapMem[localMem[0+972]*10 + 0] = localMem[0+1006];
              ip = 2242;
      end

       2242 :
      begin                                                                     // mov
              localMem[0 + 1007] = heapMem[localMem[0+972]*10 + 6];
              ip = 2243;
      end

       2243 :
      begin                                                                     // mov
              heapMem[localMem[0+1007]*10 + localMem[0+1006]] = localMem[0+973];
              ip = 2244;
      end

       2244 :
      begin                                                                     // jmp
              ip = 2384;
      end

       2245 :
      begin                                                                     // jmp
              ip = 2268;
      end

       2246 :
      begin                                                                     // label
              ip = 2247;
      end

       2247 :
      begin                                                                     // assertNe
            ip = 2248;
      end

       2248 :
      begin                                                                     // mov
              localMem[0 + 1008] = heapMem[localMem[0+972]*10 + 6];
              ip = 2249;
      end

       2249 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+1008] * NArea + i] == localMem[0+965]) localMem[0 + 1009] = i + 1;
              end
              ip = 2250;
      end

       2250 :
      begin                                                                     // subtract
              localMem[0 + 1009] = localMem[0+1009] - 1;
              ip = 2251;
      end

       2251 :
      begin                                                                     // mov
              localMem[0 + 1010] = heapMem[localMem[0+965]*10 + 4];
              ip = 2252;
      end

       2252 :
      begin                                                                     // mov
              localMem[0 + 1011] = heapMem[localMem[0+1010]*10 + localMem[0+970]];
              ip = 2253;
      end

       2253 :
      begin                                                                     // mov
              localMem[0 + 1012] = heapMem[localMem[0+965]*10 + 5];
              ip = 2254;
      end

       2254 :
      begin                                                                     // mov
              localMem[0 + 1013] = heapMem[localMem[0+1012]*10 + localMem[0+970]];
              ip = 2255;
      end

       2255 :
      begin                                                                     // mov
              localMem[0 + 1014] = heapMem[localMem[0+965]*10 + 4];
              ip = 2256;
      end

       2256 :
      begin                                                                     // resize
              arraySizes[localMem[0+1014]] = localMem[0+970];
              ip = 2257;
      end

       2257 :
      begin                                                                     // mov
              localMem[0 + 1015] = heapMem[localMem[0+965]*10 + 5];
              ip = 2258;
      end

       2258 :
      begin                                                                     // resize
              arraySizes[localMem[0+1015]] = localMem[0+970];
              ip = 2259;
      end

       2259 :
      begin                                                                     // mov
              localMem[0 + 1016] = heapMem[localMem[0+972]*10 + 4];
              ip = 2260;
      end

       2260 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1016] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1009]) begin
                  heapMem[NArea * localMem[0+1016] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1016] + localMem[1009]] = localMem[0+1011];                                    // Insert new value
              arraySizes[localMem[0+1016]] = arraySizes[localMem[0+1016]] + 1;                              // Increase array size
              ip = 2261;
      end

       2261 :
      begin                                                                     // mov
              localMem[0 + 1017] = heapMem[localMem[0+972]*10 + 5];
              ip = 2262;
      end

       2262 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1017] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1009]) begin
                  heapMem[NArea * localMem[0+1017] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1017] + localMem[1009]] = localMem[0+1013];                                    // Insert new value
              arraySizes[localMem[0+1017]] = arraySizes[localMem[0+1017]] + 1;                              // Increase array size
              ip = 2263;
      end

       2263 :
      begin                                                                     // mov
              localMem[0 + 1018] = heapMem[localMem[0+972]*10 + 6];
              ip = 2264;
      end

       2264 :
      begin                                                                     // add
              localMem[0 + 1019] = localMem[0+1009] + 1;
              ip = 2265;
      end

       2265 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1018] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1019]) begin
                  heapMem[NArea * localMem[0+1018] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1018] + localMem[1019]] = localMem[0+973];                                    // Insert new value
              arraySizes[localMem[0+1018]] = arraySizes[localMem[0+1018]] + 1;                              // Increase array size
              ip = 2266;
      end

       2266 :
      begin                                                                     // add
              heapMem[localMem[0+972]*10 + 0] = heapMem[localMem[0+972]*10 + 0] + 1;
              ip = 2267;
      end

       2267 :
      begin                                                                     // jmp
              ip = 2384;
      end

       2268 :
      begin                                                                     // label
              ip = 2269;
      end

       2269 :
      begin                                                                     // label
              ip = 2270;
      end

       2270 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1020] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1020] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1020]] = 0;
              ip = 2271;
      end

       2271 :
      begin                                                                     // mov
              heapMem[localMem[0+1020]*10 + 0] = localMem[0+970];
              ip = 2272;
      end

       2272 :
      begin                                                                     // mov
              heapMem[localMem[0+1020]*10 + 2] = 0;
              ip = 2273;
      end

       2273 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1021] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1021] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1021]] = 0;
              ip = 2274;
      end

       2274 :
      begin                                                                     // mov
              heapMem[localMem[0+1020]*10 + 4] = localMem[0+1021];
              ip = 2275;
      end

       2275 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1022] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1022] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1022]] = 0;
              ip = 2276;
      end

       2276 :
      begin                                                                     // mov
              heapMem[localMem[0+1020]*10 + 5] = localMem[0+1022];
              ip = 2277;
      end

       2277 :
      begin                                                                     // mov
              heapMem[localMem[0+1020]*10 + 6] = 0;
              ip = 2278;
      end

       2278 :
      begin                                                                     // mov
              heapMem[localMem[0+1020]*10 + 3] = localMem[0+968];
              ip = 2279;
      end

       2279 :
      begin                                                                     // add
              heapMem[localMem[0+968]*10 + 1] = heapMem[localMem[0+968]*10 + 1] + 1;
              ip = 2280;
      end

       2280 :
      begin                                                                     // mov
              heapMem[localMem[0+1020]*10 + 1] = heapMem[localMem[0+968]*10 + 1];
              ip = 2281;
      end

       2281 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1023] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1023] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1023]] = 0;
              ip = 2282;
      end

       2282 :
      begin                                                                     // mov
              heapMem[localMem[0+1023]*10 + 0] = localMem[0+970];
              ip = 2283;
      end

       2283 :
      begin                                                                     // mov
              heapMem[localMem[0+1023]*10 + 2] = 0;
              ip = 2284;
      end

       2284 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1024] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1024] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1024]] = 0;
              ip = 2285;
      end

       2285 :
      begin                                                                     // mov
              heapMem[localMem[0+1023]*10 + 4] = localMem[0+1024];
              ip = 2286;
      end

       2286 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1025] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1025] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1025]] = 0;
              ip = 2287;
      end

       2287 :
      begin                                                                     // mov
              heapMem[localMem[0+1023]*10 + 5] = localMem[0+1025];
              ip = 2288;
      end

       2288 :
      begin                                                                     // mov
              heapMem[localMem[0+1023]*10 + 6] = 0;
              ip = 2289;
      end

       2289 :
      begin                                                                     // mov
              heapMem[localMem[0+1023]*10 + 3] = localMem[0+968];
              ip = 2290;
      end

       2290 :
      begin                                                                     // add
              heapMem[localMem[0+968]*10 + 1] = heapMem[localMem[0+968]*10 + 1] + 1;
              ip = 2291;
      end

       2291 :
      begin                                                                     // mov
              heapMem[localMem[0+1023]*10 + 1] = heapMem[localMem[0+968]*10 + 1];
              ip = 2292;
      end

       2292 :
      begin                                                                     // not
              localMem[0 + 1026] = !heapMem[localMem[0+965]*10 + 6];
              ip = 2293;
      end

       2293 :
      begin                                                                     // jNe
              ip = localMem[0+1026] != 0 ? 2345 : 2294;
      end

       2294 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1027] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1027] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1027]] = 0;
              ip = 2295;
      end

       2295 :
      begin                                                                     // mov
              heapMem[localMem[0+1020]*10 + 6] = localMem[0+1027];
              ip = 2296;
      end

       2296 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1028] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1028] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1028]] = 0;
              ip = 2297;
      end

       2297 :
      begin                                                                     // mov
              heapMem[localMem[0+1023]*10 + 6] = localMem[0+1028];
              ip = 2298;
      end

       2298 :
      begin                                                                     // mov
              localMem[0 + 1029] = heapMem[localMem[0+965]*10 + 4];
              ip = 2299;
      end

       2299 :
      begin                                                                     // mov
              localMem[0 + 1030] = heapMem[localMem[0+1020]*10 + 4];
              ip = 2300;
      end

       2300 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+970]) begin
                  heapMem[NArea * localMem[0+1030] + 0 + i] = heapMem[NArea * localMem[0+1029] + 0 + i];
                end
              end
              ip = 2301;
      end

       2301 :
      begin                                                                     // mov
              localMem[0 + 1031] = heapMem[localMem[0+965]*10 + 5];
              ip = 2302;
      end

       2302 :
      begin                                                                     // mov
              localMem[0 + 1032] = heapMem[localMem[0+1020]*10 + 5];
              ip = 2303;
      end

       2303 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+970]) begin
                  heapMem[NArea * localMem[0+1032] + 0 + i] = heapMem[NArea * localMem[0+1031] + 0 + i];
                end
              end
              ip = 2304;
      end

       2304 :
      begin                                                                     // mov
              localMem[0 + 1033] = heapMem[localMem[0+965]*10 + 6];
              ip = 2305;
      end

       2305 :
      begin                                                                     // mov
              localMem[0 + 1034] = heapMem[localMem[0+1020]*10 + 6];
              ip = 2306;
      end

       2306 :
      begin                                                                     // add
              localMem[0 + 1035] = localMem[0+970] + 1;
              ip = 2307;
      end

       2307 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1035]) begin
                  heapMem[NArea * localMem[0+1034] + 0 + i] = heapMem[NArea * localMem[0+1033] + 0 + i];
                end
              end
              ip = 2308;
      end

       2308 :
      begin                                                                     // mov
              localMem[0 + 1036] = heapMem[localMem[0+965]*10 + 4];
              ip = 2309;
      end

       2309 :
      begin                                                                     // mov
              localMem[0 + 1037] = heapMem[localMem[0+1023]*10 + 4];
              ip = 2310;
      end

       2310 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+970]) begin
                  heapMem[NArea * localMem[0+1037] + 0 + i] = heapMem[NArea * localMem[0+1036] + localMem[971] + i];
                end
              end
              ip = 2311;
      end

       2311 :
      begin                                                                     // mov
              localMem[0 + 1038] = heapMem[localMem[0+965]*10 + 5];
              ip = 2312;
      end

       2312 :
      begin                                                                     // mov
              localMem[0 + 1039] = heapMem[localMem[0+1023]*10 + 5];
              ip = 2313;
      end

       2313 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+970]) begin
                  heapMem[NArea * localMem[0+1039] + 0 + i] = heapMem[NArea * localMem[0+1038] + localMem[971] + i];
                end
              end
              ip = 2314;
      end

       2314 :
      begin                                                                     // mov
              localMem[0 + 1040] = heapMem[localMem[0+965]*10 + 6];
              ip = 2315;
      end

       2315 :
      begin                                                                     // mov
              localMem[0 + 1041] = heapMem[localMem[0+1023]*10 + 6];
              ip = 2316;
      end

       2316 :
      begin                                                                     // add
              localMem[0 + 1042] = localMem[0+970] + 1;
              ip = 2317;
      end

       2317 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1042]) begin
                  heapMem[NArea * localMem[0+1041] + 0 + i] = heapMem[NArea * localMem[0+1040] + localMem[971] + i];
                end
              end
              ip = 2318;
      end

       2318 :
      begin                                                                     // mov
              localMem[0 + 1043] = heapMem[localMem[0+1020]*10 + 0];
              ip = 2319;
      end

       2319 :
      begin                                                                     // add
              localMem[0 + 1044] = localMem[0+1043] + 1;
              ip = 2320;
      end

       2320 :
      begin                                                                     // mov
              localMem[0 + 1045] = heapMem[localMem[0+1020]*10 + 6];
              ip = 2321;
      end

       2321 :
      begin                                                                     // label
              ip = 2322;
      end

       2322 :
      begin                                                                     // mov
              localMem[0 + 1046] = 0;
              ip = 2323;
      end

       2323 :
      begin                                                                     // label
              ip = 2324;
      end

       2324 :
      begin                                                                     // jGe
              ip = localMem[0+1046] >= localMem[0+1044] ? 2330 : 2325;
      end

       2325 :
      begin                                                                     // mov
              localMem[0 + 1047] = heapMem[localMem[0+1045]*10 + localMem[0+1046]];
              ip = 2326;
      end

       2326 :
      begin                                                                     // mov
              heapMem[localMem[0+1047]*10 + 2] = localMem[0+1020];
              ip = 2327;
      end

       2327 :
      begin                                                                     // label
              ip = 2328;
      end

       2328 :
      begin                                                                     // add
              localMem[0 + 1046] = localMem[0+1046] + 1;
              ip = 2329;
      end

       2329 :
      begin                                                                     // jmp
              ip = 2323;
      end

       2330 :
      begin                                                                     // label
              ip = 2331;
      end

       2331 :
      begin                                                                     // mov
              localMem[0 + 1048] = heapMem[localMem[0+1023]*10 + 0];
              ip = 2332;
      end

       2332 :
      begin                                                                     // add
              localMem[0 + 1049] = localMem[0+1048] + 1;
              ip = 2333;
      end

       2333 :
      begin                                                                     // mov
              localMem[0 + 1050] = heapMem[localMem[0+1023]*10 + 6];
              ip = 2334;
      end

       2334 :
      begin                                                                     // label
              ip = 2335;
      end

       2335 :
      begin                                                                     // mov
              localMem[0 + 1051] = 0;
              ip = 2336;
      end

       2336 :
      begin                                                                     // label
              ip = 2337;
      end

       2337 :
      begin                                                                     // jGe
              ip = localMem[0+1051] >= localMem[0+1049] ? 2343 : 2338;
      end

       2338 :
      begin                                                                     // mov
              localMem[0 + 1052] = heapMem[localMem[0+1050]*10 + localMem[0+1051]];
              ip = 2339;
      end

       2339 :
      begin                                                                     // mov
              heapMem[localMem[0+1052]*10 + 2] = localMem[0+1023];
              ip = 2340;
      end

       2340 :
      begin                                                                     // label
              ip = 2341;
      end

       2341 :
      begin                                                                     // add
              localMem[0 + 1051] = localMem[0+1051] + 1;
              ip = 2342;
      end

       2342 :
      begin                                                                     // jmp
              ip = 2336;
      end

       2343 :
      begin                                                                     // label
              ip = 2344;
      end

       2344 :
      begin                                                                     // jmp
              ip = 2360;
      end

       2345 :
      begin                                                                     // label
              ip = 2346;
      end

       2346 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1053] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1053] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1053]] = 0;
              ip = 2347;
      end

       2347 :
      begin                                                                     // mov
              heapMem[localMem[0+965]*10 + 6] = localMem[0+1053];
              ip = 2348;
      end

       2348 :
      begin                                                                     // mov
              localMem[0 + 1054] = heapMem[localMem[0+965]*10 + 4];
              ip = 2349;
      end

       2349 :
      begin                                                                     // mov
              localMem[0 + 1055] = heapMem[localMem[0+1020]*10 + 4];
              ip = 2350;
      end

       2350 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+970]) begin
                  heapMem[NArea * localMem[0+1055] + 0 + i] = heapMem[NArea * localMem[0+1054] + 0 + i];
                end
              end
              ip = 2351;
      end

       2351 :
      begin                                                                     // mov
              localMem[0 + 1056] = heapMem[localMem[0+965]*10 + 5];
              ip = 2352;
      end

       2352 :
      begin                                                                     // mov
              localMem[0 + 1057] = heapMem[localMem[0+1020]*10 + 5];
              ip = 2353;
      end

       2353 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+970]) begin
                  heapMem[NArea * localMem[0+1057] + 0 + i] = heapMem[NArea * localMem[0+1056] + 0 + i];
                end
              end
              ip = 2354;
      end

       2354 :
      begin                                                                     // mov
              localMem[0 + 1058] = heapMem[localMem[0+965]*10 + 4];
              ip = 2355;
      end

       2355 :
      begin                                                                     // mov
              localMem[0 + 1059] = heapMem[localMem[0+1023]*10 + 4];
              ip = 2356;
      end

       2356 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+970]) begin
                  heapMem[NArea * localMem[0+1059] + 0 + i] = heapMem[NArea * localMem[0+1058] + localMem[971] + i];
                end
              end
              ip = 2357;
      end

       2357 :
      begin                                                                     // mov
              localMem[0 + 1060] = heapMem[localMem[0+965]*10 + 5];
              ip = 2358;
      end

       2358 :
      begin                                                                     // mov
              localMem[0 + 1061] = heapMem[localMem[0+1023]*10 + 5];
              ip = 2359;
      end

       2359 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+970]) begin
                  heapMem[NArea * localMem[0+1061] + 0 + i] = heapMem[NArea * localMem[0+1060] + localMem[971] + i];
                end
              end
              ip = 2360;
      end

       2360 :
      begin                                                                     // label
              ip = 2361;
      end

       2361 :
      begin                                                                     // mov
              heapMem[localMem[0+1020]*10 + 2] = localMem[0+965];
              ip = 2362;
      end

       2362 :
      begin                                                                     // mov
              heapMem[localMem[0+1023]*10 + 2] = localMem[0+965];
              ip = 2363;
      end

       2363 :
      begin                                                                     // mov
              localMem[0 + 1062] = heapMem[localMem[0+965]*10 + 4];
              ip = 2364;
      end

       2364 :
      begin                                                                     // mov
              localMem[0 + 1063] = heapMem[localMem[0+1062]*10 + localMem[0+970]];
              ip = 2365;
      end

       2365 :
      begin                                                                     // mov
              localMem[0 + 1064] = heapMem[localMem[0+965]*10 + 5];
              ip = 2366;
      end

       2366 :
      begin                                                                     // mov
              localMem[0 + 1065] = heapMem[localMem[0+1064]*10 + localMem[0+970]];
              ip = 2367;
      end

       2367 :
      begin                                                                     // mov
              localMem[0 + 1066] = heapMem[localMem[0+965]*10 + 4];
              ip = 2368;
      end

       2368 :
      begin                                                                     // mov
              heapMem[localMem[0+1066]*10 + 0] = localMem[0+1063];
              ip = 2369;
      end

       2369 :
      begin                                                                     // mov
              localMem[0 + 1067] = heapMem[localMem[0+965]*10 + 5];
              ip = 2370;
      end

       2370 :
      begin                                                                     // mov
              heapMem[localMem[0+1067]*10 + 0] = localMem[0+1065];
              ip = 2371;
      end

       2371 :
      begin                                                                     // mov
              localMem[0 + 1068] = heapMem[localMem[0+965]*10 + 6];
              ip = 2372;
      end

       2372 :
      begin                                                                     // mov
              heapMem[localMem[0+1068]*10 + 0] = localMem[0+1020];
              ip = 2373;
      end

       2373 :
      begin                                                                     // mov
              localMem[0 + 1069] = heapMem[localMem[0+965]*10 + 6];
              ip = 2374;
      end

       2374 :
      begin                                                                     // mov
              heapMem[localMem[0+1069]*10 + 1] = localMem[0+1023];
              ip = 2375;
      end

       2375 :
      begin                                                                     // mov
              heapMem[localMem[0+965]*10 + 0] = 1;
              ip = 2376;
      end

       2376 :
      begin                                                                     // mov
              localMem[0 + 1070] = heapMem[localMem[0+965]*10 + 4];
              ip = 2377;
      end

       2377 :
      begin                                                                     // resize
              arraySizes[localMem[0+1070]] = 1;
              ip = 2378;
      end

       2378 :
      begin                                                                     // mov
              localMem[0 + 1071] = heapMem[localMem[0+965]*10 + 5];
              ip = 2379;
      end

       2379 :
      begin                                                                     // resize
              arraySizes[localMem[0+1071]] = 1;
              ip = 2380;
      end

       2380 :
      begin                                                                     // mov
              localMem[0 + 1072] = heapMem[localMem[0+965]*10 + 6];
              ip = 2381;
      end

       2381 :
      begin                                                                     // resize
              arraySizes[localMem[0+1072]] = 2;
              ip = 2382;
      end

       2382 :
      begin                                                                     // jmp
              ip = 2384;
      end

       2383 :
      begin                                                                     // jmp
              ip = 2389;
      end

       2384 :
      begin                                                                     // label
              ip = 2385;
      end

       2385 :
      begin                                                                     // mov
              localMem[0 + 966] = 1;
              ip = 2386;
      end

       2386 :
      begin                                                                     // jmp
              ip = 2389;
      end

       2387 :
      begin                                                                     // label
              ip = 2388;
      end

       2388 :
      begin                                                                     // mov
              localMem[0 + 966] = 0;
              ip = 2389;
      end

       2389 :
      begin                                                                     // label
              ip = 2390;
      end

       2390 :
      begin                                                                     // label
              ip = 2391;
      end

       2391 :
      begin                                                                     // label
              ip = 2392;
      end

       2392 :
      begin                                                                     // mov
              localMem[0 + 1073] = 0;
              ip = 2393;
      end

       2393 :
      begin                                                                     // label
              ip = 2394;
      end

       2394 :
      begin                                                                     // jGe
              ip = localMem[0+1073] >= 99 ? 2892 : 2395;
      end

       2395 :
      begin                                                                     // mov
              localMem[0 + 1074] = heapMem[localMem[0+965]*10 + 0];
              ip = 2396;
      end

       2396 :
      begin                                                                     // subtract
              localMem[0 + 1075] = localMem[0+1074] - 1;
              ip = 2397;
      end

       2397 :
      begin                                                                     // mov
              localMem[0 + 1076] = heapMem[localMem[0+965]*10 + 4];
              ip = 2398;
      end

       2398 :
      begin                                                                     // mov
              localMem[0 + 1077] = heapMem[localMem[0+1076]*10 + localMem[0+1075]];
              ip = 2399;
      end

       2399 :
      begin                                                                     // jLe
              ip = 3 <= localMem[0+1077] ? 2640 : 2400;
      end

       2400 :
      begin                                                                     // not
              localMem[0 + 1078] = !heapMem[localMem[0+965]*10 + 6];
              ip = 2401;
      end

       2401 :
      begin                                                                     // jEq
              ip = localMem[0+1078] == 0 ? 2406 : 2402;
      end

       2402 :
      begin                                                                     // mov
              heapMem[localMem[0+945]*10 + 0] = localMem[0+965];
              ip = 2403;
      end

       2403 :
      begin                                                                     // mov
              heapMem[localMem[0+945]*10 + 1] = 2;
              ip = 2404;
      end

       2404 :
      begin                                                                     // subtract
              heapMem[localMem[0+945]*10 + 2] = localMem[0+1074] - 1;
              ip = 2405;
      end

       2405 :
      begin                                                                     // jmp
              ip = 2896;
      end

       2406 :
      begin                                                                     // label
              ip = 2407;
      end

       2407 :
      begin                                                                     // mov
              localMem[0 + 1079] = heapMem[localMem[0+965]*10 + 6];
              ip = 2408;
      end

       2408 :
      begin                                                                     // mov
              localMem[0 + 1080] = heapMem[localMem[0+1079]*10 + localMem[0+1074]];
              ip = 2409;
      end

       2409 :
      begin                                                                     // label
              ip = 2410;
      end

       2410 :
      begin                                                                     // mov
              localMem[0 + 1082] = heapMem[localMem[0+1080]*10 + 0];
              ip = 2411;
      end

       2411 :
      begin                                                                     // mov
              localMem[0 + 1083] = heapMem[localMem[0+1080]*10 + 3];
              ip = 2412;
      end

       2412 :
      begin                                                                     // mov
              localMem[0 + 1084] = heapMem[localMem[0+1083]*10 + 2];
              ip = 2413;
      end

       2413 :
      begin                                                                     // jLt
              ip = localMem[0+1082] <  localMem[0+1084] ? 2633 : 2414;
      end

       2414 :
      begin                                                                     // mov
              localMem[0 + 1085] = localMem[0+1084];
              ip = 2415;
      end

       2415 :
      begin                                                                     // shiftRight
              localMem[0 + 1085] = localMem[0+1085] >> 1;
              ip = 2416;
      end

       2416 :
      begin                                                                     // add
              localMem[0 + 1086] = localMem[0+1085] + 1;
              ip = 2417;
      end

       2417 :
      begin                                                                     // mov
              localMem[0 + 1087] = heapMem[localMem[0+1080]*10 + 2];
              ip = 2418;
      end

       2418 :
      begin                                                                     // jEq
              ip = localMem[0+1087] == 0 ? 2515 : 2419;
      end

       2419 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1088] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1088] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1088]] = 0;
              ip = 2420;
      end

       2420 :
      begin                                                                     // mov
              heapMem[localMem[0+1088]*10 + 0] = localMem[0+1085];
              ip = 2421;
      end

       2421 :
      begin                                                                     // mov
              heapMem[localMem[0+1088]*10 + 2] = 0;
              ip = 2422;
      end

       2422 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1089] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1089] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1089]] = 0;
              ip = 2423;
      end

       2423 :
      begin                                                                     // mov
              heapMem[localMem[0+1088]*10 + 4] = localMem[0+1089];
              ip = 2424;
      end

       2424 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1090] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1090] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1090]] = 0;
              ip = 2425;
      end

       2425 :
      begin                                                                     // mov
              heapMem[localMem[0+1088]*10 + 5] = localMem[0+1090];
              ip = 2426;
      end

       2426 :
      begin                                                                     // mov
              heapMem[localMem[0+1088]*10 + 6] = 0;
              ip = 2427;
      end

       2427 :
      begin                                                                     // mov
              heapMem[localMem[0+1088]*10 + 3] = localMem[0+1083];
              ip = 2428;
      end

       2428 :
      begin                                                                     // add
              heapMem[localMem[0+1083]*10 + 1] = heapMem[localMem[0+1083]*10 + 1] + 1;
              ip = 2429;
      end

       2429 :
      begin                                                                     // mov
              heapMem[localMem[0+1088]*10 + 1] = heapMem[localMem[0+1083]*10 + 1];
              ip = 2430;
      end

       2430 :
      begin                                                                     // not
              localMem[0 + 1091] = !heapMem[localMem[0+1080]*10 + 6];
              ip = 2431;
      end

       2431 :
      begin                                                                     // jNe
              ip = localMem[0+1091] != 0 ? 2460 : 2432;
      end

       2432 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1092] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1092] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1092]] = 0;
              ip = 2433;
      end

       2433 :
      begin                                                                     // mov
              heapMem[localMem[0+1088]*10 + 6] = localMem[0+1092];
              ip = 2434;
      end

       2434 :
      begin                                                                     // mov
              localMem[0 + 1093] = heapMem[localMem[0+1080]*10 + 4];
              ip = 2435;
      end

       2435 :
      begin                                                                     // mov
              localMem[0 + 1094] = heapMem[localMem[0+1088]*10 + 4];
              ip = 2436;
      end

       2436 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1085]) begin
                  heapMem[NArea * localMem[0+1094] + 0 + i] = heapMem[NArea * localMem[0+1093] + localMem[1086] + i];
                end
              end
              ip = 2437;
      end

       2437 :
      begin                                                                     // mov
              localMem[0 + 1095] = heapMem[localMem[0+1080]*10 + 5];
              ip = 2438;
      end

       2438 :
      begin                                                                     // mov
              localMem[0 + 1096] = heapMem[localMem[0+1088]*10 + 5];
              ip = 2439;
      end

       2439 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1085]) begin
                  heapMem[NArea * localMem[0+1096] + 0 + i] = heapMem[NArea * localMem[0+1095] + localMem[1086] + i];
                end
              end
              ip = 2440;
      end

       2440 :
      begin                                                                     // mov
              localMem[0 + 1097] = heapMem[localMem[0+1080]*10 + 6];
              ip = 2441;
      end

       2441 :
      begin                                                                     // mov
              localMem[0 + 1098] = heapMem[localMem[0+1088]*10 + 6];
              ip = 2442;
      end

       2442 :
      begin                                                                     // add
              localMem[0 + 1099] = localMem[0+1085] + 1;
              ip = 2443;
      end

       2443 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1099]) begin
                  heapMem[NArea * localMem[0+1098] + 0 + i] = heapMem[NArea * localMem[0+1097] + localMem[1086] + i];
                end
              end
              ip = 2444;
      end

       2444 :
      begin                                                                     // mov
              localMem[0 + 1100] = heapMem[localMem[0+1088]*10 + 0];
              ip = 2445;
      end

       2445 :
      begin                                                                     // add
              localMem[0 + 1101] = localMem[0+1100] + 1;
              ip = 2446;
      end

       2446 :
      begin                                                                     // mov
              localMem[0 + 1102] = heapMem[localMem[0+1088]*10 + 6];
              ip = 2447;
      end

       2447 :
      begin                                                                     // label
              ip = 2448;
      end

       2448 :
      begin                                                                     // mov
              localMem[0 + 1103] = 0;
              ip = 2449;
      end

       2449 :
      begin                                                                     // label
              ip = 2450;
      end

       2450 :
      begin                                                                     // jGe
              ip = localMem[0+1103] >= localMem[0+1101] ? 2456 : 2451;
      end

       2451 :
      begin                                                                     // mov
              localMem[0 + 1104] = heapMem[localMem[0+1102]*10 + localMem[0+1103]];
              ip = 2452;
      end

       2452 :
      begin                                                                     // mov
              heapMem[localMem[0+1104]*10 + 2] = localMem[0+1088];
              ip = 2453;
      end

       2453 :
      begin                                                                     // label
              ip = 2454;
      end

       2454 :
      begin                                                                     // add
              localMem[0 + 1103] = localMem[0+1103] + 1;
              ip = 2455;
      end

       2455 :
      begin                                                                     // jmp
              ip = 2449;
      end

       2456 :
      begin                                                                     // label
              ip = 2457;
      end

       2457 :
      begin                                                                     // mov
              localMem[0 + 1105] = heapMem[localMem[0+1080]*10 + 6];
              ip = 2458;
      end

       2458 :
      begin                                                                     // resize
              arraySizes[localMem[0+1105]] = localMem[0+1086];
              ip = 2459;
      end

       2459 :
      begin                                                                     // jmp
              ip = 2467;
      end

       2460 :
      begin                                                                     // label
              ip = 2461;
      end

       2461 :
      begin                                                                     // mov
              localMem[0 + 1106] = heapMem[localMem[0+1080]*10 + 4];
              ip = 2462;
      end

       2462 :
      begin                                                                     // mov
              localMem[0 + 1107] = heapMem[localMem[0+1088]*10 + 4];
              ip = 2463;
      end

       2463 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1085]) begin
                  heapMem[NArea * localMem[0+1107] + 0 + i] = heapMem[NArea * localMem[0+1106] + localMem[1086] + i];
                end
              end
              ip = 2464;
      end

       2464 :
      begin                                                                     // mov
              localMem[0 + 1108] = heapMem[localMem[0+1080]*10 + 5];
              ip = 2465;
      end

       2465 :
      begin                                                                     // mov
              localMem[0 + 1109] = heapMem[localMem[0+1088]*10 + 5];
              ip = 2466;
      end

       2466 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1085]) begin
                  heapMem[NArea * localMem[0+1109] + 0 + i] = heapMem[NArea * localMem[0+1108] + localMem[1086] + i];
                end
              end
              ip = 2467;
      end

       2467 :
      begin                                                                     // label
              ip = 2468;
      end

       2468 :
      begin                                                                     // mov
              heapMem[localMem[0+1080]*10 + 0] = localMem[0+1085];
              ip = 2469;
      end

       2469 :
      begin                                                                     // mov
              heapMem[localMem[0+1088]*10 + 2] = localMem[0+1087];
              ip = 2470;
      end

       2470 :
      begin                                                                     // mov
              localMem[0 + 1110] = heapMem[localMem[0+1087]*10 + 0];
              ip = 2471;
      end

       2471 :
      begin                                                                     // mov
              localMem[0 + 1111] = heapMem[localMem[0+1087]*10 + 6];
              ip = 2472;
      end

       2472 :
      begin                                                                     // mov
              localMem[0 + 1112] = heapMem[localMem[0+1111]*10 + localMem[0+1110]];
              ip = 2473;
      end

       2473 :
      begin                                                                     // jNe
              ip = localMem[0+1112] != localMem[0+1080] ? 2492 : 2474;
      end

       2474 :
      begin                                                                     // mov
              localMem[0 + 1113] = heapMem[localMem[0+1080]*10 + 4];
              ip = 2475;
      end

       2475 :
      begin                                                                     // mov
              localMem[0 + 1114] = heapMem[localMem[0+1113]*10 + localMem[0+1085]];
              ip = 2476;
      end

       2476 :
      begin                                                                     // mov
              localMem[0 + 1115] = heapMem[localMem[0+1087]*10 + 4];
              ip = 2477;
      end

       2477 :
      begin                                                                     // mov
              heapMem[localMem[0+1115]*10 + localMem[0+1110]] = localMem[0+1114];
              ip = 2478;
      end

       2478 :
      begin                                                                     // mov
              localMem[0 + 1116] = heapMem[localMem[0+1080]*10 + 5];
              ip = 2479;
      end

       2479 :
      begin                                                                     // mov
              localMem[0 + 1117] = heapMem[localMem[0+1116]*10 + localMem[0+1085]];
              ip = 2480;
      end

       2480 :
      begin                                                                     // mov
              localMem[0 + 1118] = heapMem[localMem[0+1087]*10 + 5];
              ip = 2481;
      end

       2481 :
      begin                                                                     // mov
              heapMem[localMem[0+1118]*10 + localMem[0+1110]] = localMem[0+1117];
              ip = 2482;
      end

       2482 :
      begin                                                                     // mov
              localMem[0 + 1119] = heapMem[localMem[0+1080]*10 + 4];
              ip = 2483;
      end

       2483 :
      begin                                                                     // resize
              arraySizes[localMem[0+1119]] = localMem[0+1085];
              ip = 2484;
      end

       2484 :
      begin                                                                     // mov
              localMem[0 + 1120] = heapMem[localMem[0+1080]*10 + 5];
              ip = 2485;
      end

       2485 :
      begin                                                                     // resize
              arraySizes[localMem[0+1120]] = localMem[0+1085];
              ip = 2486;
      end

       2486 :
      begin                                                                     // add
              localMem[0 + 1121] = localMem[0+1110] + 1;
              ip = 2487;
      end

       2487 :
      begin                                                                     // mov
              heapMem[localMem[0+1087]*10 + 0] = localMem[0+1121];
              ip = 2488;
      end

       2488 :
      begin                                                                     // mov
              localMem[0 + 1122] = heapMem[localMem[0+1087]*10 + 6];
              ip = 2489;
      end

       2489 :
      begin                                                                     // mov
              heapMem[localMem[0+1122]*10 + localMem[0+1121]] = localMem[0+1088];
              ip = 2490;
      end

       2490 :
      begin                                                                     // jmp
              ip = 2630;
      end

       2491 :
      begin                                                                     // jmp
              ip = 2514;
      end

       2492 :
      begin                                                                     // label
              ip = 2493;
      end

       2493 :
      begin                                                                     // assertNe
            ip = 2494;
      end

       2494 :
      begin                                                                     // mov
              localMem[0 + 1123] = heapMem[localMem[0+1087]*10 + 6];
              ip = 2495;
      end

       2495 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+1123] * NArea + i] == localMem[0+1080]) localMem[0 + 1124] = i + 1;
              end
              ip = 2496;
      end

       2496 :
      begin                                                                     // subtract
              localMem[0 + 1124] = localMem[0+1124] - 1;
              ip = 2497;
      end

       2497 :
      begin                                                                     // mov
              localMem[0 + 1125] = heapMem[localMem[0+1080]*10 + 4];
              ip = 2498;
      end

       2498 :
      begin                                                                     // mov
              localMem[0 + 1126] = heapMem[localMem[0+1125]*10 + localMem[0+1085]];
              ip = 2499;
      end

       2499 :
      begin                                                                     // mov
              localMem[0 + 1127] = heapMem[localMem[0+1080]*10 + 5];
              ip = 2500;
      end

       2500 :
      begin                                                                     // mov
              localMem[0 + 1128] = heapMem[localMem[0+1127]*10 + localMem[0+1085]];
              ip = 2501;
      end

       2501 :
      begin                                                                     // mov
              localMem[0 + 1129] = heapMem[localMem[0+1080]*10 + 4];
              ip = 2502;
      end

       2502 :
      begin                                                                     // resize
              arraySizes[localMem[0+1129]] = localMem[0+1085];
              ip = 2503;
      end

       2503 :
      begin                                                                     // mov
              localMem[0 + 1130] = heapMem[localMem[0+1080]*10 + 5];
              ip = 2504;
      end

       2504 :
      begin                                                                     // resize
              arraySizes[localMem[0+1130]] = localMem[0+1085];
              ip = 2505;
      end

       2505 :
      begin                                                                     // mov
              localMem[0 + 1131] = heapMem[localMem[0+1087]*10 + 4];
              ip = 2506;
      end

       2506 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1131] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1124]) begin
                  heapMem[NArea * localMem[0+1131] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1131] + localMem[1124]] = localMem[0+1126];                                    // Insert new value
              arraySizes[localMem[0+1131]] = arraySizes[localMem[0+1131]] + 1;                              // Increase array size
              ip = 2507;
      end

       2507 :
      begin                                                                     // mov
              localMem[0 + 1132] = heapMem[localMem[0+1087]*10 + 5];
              ip = 2508;
      end

       2508 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1132] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1124]) begin
                  heapMem[NArea * localMem[0+1132] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1132] + localMem[1124]] = localMem[0+1128];                                    // Insert new value
              arraySizes[localMem[0+1132]] = arraySizes[localMem[0+1132]] + 1;                              // Increase array size
              ip = 2509;
      end

       2509 :
      begin                                                                     // mov
              localMem[0 + 1133] = heapMem[localMem[0+1087]*10 + 6];
              ip = 2510;
      end

       2510 :
      begin                                                                     // add
              localMem[0 + 1134] = localMem[0+1124] + 1;
              ip = 2511;
      end

       2511 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1133] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1134]) begin
                  heapMem[NArea * localMem[0+1133] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1133] + localMem[1134]] = localMem[0+1088];                                    // Insert new value
              arraySizes[localMem[0+1133]] = arraySizes[localMem[0+1133]] + 1;                              // Increase array size
              ip = 2512;
      end

       2512 :
      begin                                                                     // add
              heapMem[localMem[0+1087]*10 + 0] = heapMem[localMem[0+1087]*10 + 0] + 1;
              ip = 2513;
      end

       2513 :
      begin                                                                     // jmp
              ip = 2630;
      end

       2514 :
      begin                                                                     // label
              ip = 2515;
      end

       2515 :
      begin                                                                     // label
              ip = 2516;
      end

       2516 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1135] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1135] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1135]] = 0;
              ip = 2517;
      end

       2517 :
      begin                                                                     // mov
              heapMem[localMem[0+1135]*10 + 0] = localMem[0+1085];
              ip = 2518;
      end

       2518 :
      begin                                                                     // mov
              heapMem[localMem[0+1135]*10 + 2] = 0;
              ip = 2519;
      end

       2519 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1136] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1136] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1136]] = 0;
              ip = 2520;
      end

       2520 :
      begin                                                                     // mov
              heapMem[localMem[0+1135]*10 + 4] = localMem[0+1136];
              ip = 2521;
      end

       2521 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1137] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1137] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1137]] = 0;
              ip = 2522;
      end

       2522 :
      begin                                                                     // mov
              heapMem[localMem[0+1135]*10 + 5] = localMem[0+1137];
              ip = 2523;
      end

       2523 :
      begin                                                                     // mov
              heapMem[localMem[0+1135]*10 + 6] = 0;
              ip = 2524;
      end

       2524 :
      begin                                                                     // mov
              heapMem[localMem[0+1135]*10 + 3] = localMem[0+1083];
              ip = 2525;
      end

       2525 :
      begin                                                                     // add
              heapMem[localMem[0+1083]*10 + 1] = heapMem[localMem[0+1083]*10 + 1] + 1;
              ip = 2526;
      end

       2526 :
      begin                                                                     // mov
              heapMem[localMem[0+1135]*10 + 1] = heapMem[localMem[0+1083]*10 + 1];
              ip = 2527;
      end

       2527 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1138] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1138] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1138]] = 0;
              ip = 2528;
      end

       2528 :
      begin                                                                     // mov
              heapMem[localMem[0+1138]*10 + 0] = localMem[0+1085];
              ip = 2529;
      end

       2529 :
      begin                                                                     // mov
              heapMem[localMem[0+1138]*10 + 2] = 0;
              ip = 2530;
      end

       2530 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1139] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1139] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1139]] = 0;
              ip = 2531;
      end

       2531 :
      begin                                                                     // mov
              heapMem[localMem[0+1138]*10 + 4] = localMem[0+1139];
              ip = 2532;
      end

       2532 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1140] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1140] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1140]] = 0;
              ip = 2533;
      end

       2533 :
      begin                                                                     // mov
              heapMem[localMem[0+1138]*10 + 5] = localMem[0+1140];
              ip = 2534;
      end

       2534 :
      begin                                                                     // mov
              heapMem[localMem[0+1138]*10 + 6] = 0;
              ip = 2535;
      end

       2535 :
      begin                                                                     // mov
              heapMem[localMem[0+1138]*10 + 3] = localMem[0+1083];
              ip = 2536;
      end

       2536 :
      begin                                                                     // add
              heapMem[localMem[0+1083]*10 + 1] = heapMem[localMem[0+1083]*10 + 1] + 1;
              ip = 2537;
      end

       2537 :
      begin                                                                     // mov
              heapMem[localMem[0+1138]*10 + 1] = heapMem[localMem[0+1083]*10 + 1];
              ip = 2538;
      end

       2538 :
      begin                                                                     // not
              localMem[0 + 1141] = !heapMem[localMem[0+1080]*10 + 6];
              ip = 2539;
      end

       2539 :
      begin                                                                     // jNe
              ip = localMem[0+1141] != 0 ? 2591 : 2540;
      end

       2540 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1142] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1142] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1142]] = 0;
              ip = 2541;
      end

       2541 :
      begin                                                                     // mov
              heapMem[localMem[0+1135]*10 + 6] = localMem[0+1142];
              ip = 2542;
      end

       2542 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1143] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1143] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1143]] = 0;
              ip = 2543;
      end

       2543 :
      begin                                                                     // mov
              heapMem[localMem[0+1138]*10 + 6] = localMem[0+1143];
              ip = 2544;
      end

       2544 :
      begin                                                                     // mov
              localMem[0 + 1144] = heapMem[localMem[0+1080]*10 + 4];
              ip = 2545;
      end

       2545 :
      begin                                                                     // mov
              localMem[0 + 1145] = heapMem[localMem[0+1135]*10 + 4];
              ip = 2546;
      end

       2546 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1085]) begin
                  heapMem[NArea * localMem[0+1145] + 0 + i] = heapMem[NArea * localMem[0+1144] + 0 + i];
                end
              end
              ip = 2547;
      end

       2547 :
      begin                                                                     // mov
              localMem[0 + 1146] = heapMem[localMem[0+1080]*10 + 5];
              ip = 2548;
      end

       2548 :
      begin                                                                     // mov
              localMem[0 + 1147] = heapMem[localMem[0+1135]*10 + 5];
              ip = 2549;
      end

       2549 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1085]) begin
                  heapMem[NArea * localMem[0+1147] + 0 + i] = heapMem[NArea * localMem[0+1146] + 0 + i];
                end
              end
              ip = 2550;
      end

       2550 :
      begin                                                                     // mov
              localMem[0 + 1148] = heapMem[localMem[0+1080]*10 + 6];
              ip = 2551;
      end

       2551 :
      begin                                                                     // mov
              localMem[0 + 1149] = heapMem[localMem[0+1135]*10 + 6];
              ip = 2552;
      end

       2552 :
      begin                                                                     // add
              localMem[0 + 1150] = localMem[0+1085] + 1;
              ip = 2553;
      end

       2553 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1150]) begin
                  heapMem[NArea * localMem[0+1149] + 0 + i] = heapMem[NArea * localMem[0+1148] + 0 + i];
                end
              end
              ip = 2554;
      end

       2554 :
      begin                                                                     // mov
              localMem[0 + 1151] = heapMem[localMem[0+1080]*10 + 4];
              ip = 2555;
      end

       2555 :
      begin                                                                     // mov
              localMem[0 + 1152] = heapMem[localMem[0+1138]*10 + 4];
              ip = 2556;
      end

       2556 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1085]) begin
                  heapMem[NArea * localMem[0+1152] + 0 + i] = heapMem[NArea * localMem[0+1151] + localMem[1086] + i];
                end
              end
              ip = 2557;
      end

       2557 :
      begin                                                                     // mov
              localMem[0 + 1153] = heapMem[localMem[0+1080]*10 + 5];
              ip = 2558;
      end

       2558 :
      begin                                                                     // mov
              localMem[0 + 1154] = heapMem[localMem[0+1138]*10 + 5];
              ip = 2559;
      end

       2559 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1085]) begin
                  heapMem[NArea * localMem[0+1154] + 0 + i] = heapMem[NArea * localMem[0+1153] + localMem[1086] + i];
                end
              end
              ip = 2560;
      end

       2560 :
      begin                                                                     // mov
              localMem[0 + 1155] = heapMem[localMem[0+1080]*10 + 6];
              ip = 2561;
      end

       2561 :
      begin                                                                     // mov
              localMem[0 + 1156] = heapMem[localMem[0+1138]*10 + 6];
              ip = 2562;
      end

       2562 :
      begin                                                                     // add
              localMem[0 + 1157] = localMem[0+1085] + 1;
              ip = 2563;
      end

       2563 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1157]) begin
                  heapMem[NArea * localMem[0+1156] + 0 + i] = heapMem[NArea * localMem[0+1155] + localMem[1086] + i];
                end
              end
              ip = 2564;
      end

       2564 :
      begin                                                                     // mov
              localMem[0 + 1158] = heapMem[localMem[0+1135]*10 + 0];
              ip = 2565;
      end

       2565 :
      begin                                                                     // add
              localMem[0 + 1159] = localMem[0+1158] + 1;
              ip = 2566;
      end

       2566 :
      begin                                                                     // mov
              localMem[0 + 1160] = heapMem[localMem[0+1135]*10 + 6];
              ip = 2567;
      end

       2567 :
      begin                                                                     // label
              ip = 2568;
      end

       2568 :
      begin                                                                     // mov
              localMem[0 + 1161] = 0;
              ip = 2569;
      end

       2569 :
      begin                                                                     // label
              ip = 2570;
      end

       2570 :
      begin                                                                     // jGe
              ip = localMem[0+1161] >= localMem[0+1159] ? 2576 : 2571;
      end

       2571 :
      begin                                                                     // mov
              localMem[0 + 1162] = heapMem[localMem[0+1160]*10 + localMem[0+1161]];
              ip = 2572;
      end

       2572 :
      begin                                                                     // mov
              heapMem[localMem[0+1162]*10 + 2] = localMem[0+1135];
              ip = 2573;
      end

       2573 :
      begin                                                                     // label
              ip = 2574;
      end

       2574 :
      begin                                                                     // add
              localMem[0 + 1161] = localMem[0+1161] + 1;
              ip = 2575;
      end

       2575 :
      begin                                                                     // jmp
              ip = 2569;
      end

       2576 :
      begin                                                                     // label
              ip = 2577;
      end

       2577 :
      begin                                                                     // mov
              localMem[0 + 1163] = heapMem[localMem[0+1138]*10 + 0];
              ip = 2578;
      end

       2578 :
      begin                                                                     // add
              localMem[0 + 1164] = localMem[0+1163] + 1;
              ip = 2579;
      end

       2579 :
      begin                                                                     // mov
              localMem[0 + 1165] = heapMem[localMem[0+1138]*10 + 6];
              ip = 2580;
      end

       2580 :
      begin                                                                     // label
              ip = 2581;
      end

       2581 :
      begin                                                                     // mov
              localMem[0 + 1166] = 0;
              ip = 2582;
      end

       2582 :
      begin                                                                     // label
              ip = 2583;
      end

       2583 :
      begin                                                                     // jGe
              ip = localMem[0+1166] >= localMem[0+1164] ? 2589 : 2584;
      end

       2584 :
      begin                                                                     // mov
              localMem[0 + 1167] = heapMem[localMem[0+1165]*10 + localMem[0+1166]];
              ip = 2585;
      end

       2585 :
      begin                                                                     // mov
              heapMem[localMem[0+1167]*10 + 2] = localMem[0+1138];
              ip = 2586;
      end

       2586 :
      begin                                                                     // label
              ip = 2587;
      end

       2587 :
      begin                                                                     // add
              localMem[0 + 1166] = localMem[0+1166] + 1;
              ip = 2588;
      end

       2588 :
      begin                                                                     // jmp
              ip = 2582;
      end

       2589 :
      begin                                                                     // label
              ip = 2590;
      end

       2590 :
      begin                                                                     // jmp
              ip = 2606;
      end

       2591 :
      begin                                                                     // label
              ip = 2592;
      end

       2592 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1168] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1168] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1168]] = 0;
              ip = 2593;
      end

       2593 :
      begin                                                                     // mov
              heapMem[localMem[0+1080]*10 + 6] = localMem[0+1168];
              ip = 2594;
      end

       2594 :
      begin                                                                     // mov
              localMem[0 + 1169] = heapMem[localMem[0+1080]*10 + 4];
              ip = 2595;
      end

       2595 :
      begin                                                                     // mov
              localMem[0 + 1170] = heapMem[localMem[0+1135]*10 + 4];
              ip = 2596;
      end

       2596 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1085]) begin
                  heapMem[NArea * localMem[0+1170] + 0 + i] = heapMem[NArea * localMem[0+1169] + 0 + i];
                end
              end
              ip = 2597;
      end

       2597 :
      begin                                                                     // mov
              localMem[0 + 1171] = heapMem[localMem[0+1080]*10 + 5];
              ip = 2598;
      end

       2598 :
      begin                                                                     // mov
              localMem[0 + 1172] = heapMem[localMem[0+1135]*10 + 5];
              ip = 2599;
      end

       2599 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1085]) begin
                  heapMem[NArea * localMem[0+1172] + 0 + i] = heapMem[NArea * localMem[0+1171] + 0 + i];
                end
              end
              ip = 2600;
      end

       2600 :
      begin                                                                     // mov
              localMem[0 + 1173] = heapMem[localMem[0+1080]*10 + 4];
              ip = 2601;
      end

       2601 :
      begin                                                                     // mov
              localMem[0 + 1174] = heapMem[localMem[0+1138]*10 + 4];
              ip = 2602;
      end

       2602 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1085]) begin
                  heapMem[NArea * localMem[0+1174] + 0 + i] = heapMem[NArea * localMem[0+1173] + localMem[1086] + i];
                end
              end
              ip = 2603;
      end

       2603 :
      begin                                                                     // mov
              localMem[0 + 1175] = heapMem[localMem[0+1080]*10 + 5];
              ip = 2604;
      end

       2604 :
      begin                                                                     // mov
              localMem[0 + 1176] = heapMem[localMem[0+1138]*10 + 5];
              ip = 2605;
      end

       2605 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1085]) begin
                  heapMem[NArea * localMem[0+1176] + 0 + i] = heapMem[NArea * localMem[0+1175] + localMem[1086] + i];
                end
              end
              ip = 2606;
      end

       2606 :
      begin                                                                     // label
              ip = 2607;
      end

       2607 :
      begin                                                                     // mov
              heapMem[localMem[0+1135]*10 + 2] = localMem[0+1080];
              ip = 2608;
      end

       2608 :
      begin                                                                     // mov
              heapMem[localMem[0+1138]*10 + 2] = localMem[0+1080];
              ip = 2609;
      end

       2609 :
      begin                                                                     // mov
              localMem[0 + 1177] = heapMem[localMem[0+1080]*10 + 4];
              ip = 2610;
      end

       2610 :
      begin                                                                     // mov
              localMem[0 + 1178] = heapMem[localMem[0+1177]*10 + localMem[0+1085]];
              ip = 2611;
      end

       2611 :
      begin                                                                     // mov
              localMem[0 + 1179] = heapMem[localMem[0+1080]*10 + 5];
              ip = 2612;
      end

       2612 :
      begin                                                                     // mov
              localMem[0 + 1180] = heapMem[localMem[0+1179]*10 + localMem[0+1085]];
              ip = 2613;
      end

       2613 :
      begin                                                                     // mov
              localMem[0 + 1181] = heapMem[localMem[0+1080]*10 + 4];
              ip = 2614;
      end

       2614 :
      begin                                                                     // mov
              heapMem[localMem[0+1181]*10 + 0] = localMem[0+1178];
              ip = 2615;
      end

       2615 :
      begin                                                                     // mov
              localMem[0 + 1182] = heapMem[localMem[0+1080]*10 + 5];
              ip = 2616;
      end

       2616 :
      begin                                                                     // mov
              heapMem[localMem[0+1182]*10 + 0] = localMem[0+1180];
              ip = 2617;
      end

       2617 :
      begin                                                                     // mov
              localMem[0 + 1183] = heapMem[localMem[0+1080]*10 + 6];
              ip = 2618;
      end

       2618 :
      begin                                                                     // mov
              heapMem[localMem[0+1183]*10 + 0] = localMem[0+1135];
              ip = 2619;
      end

       2619 :
      begin                                                                     // mov
              localMem[0 + 1184] = heapMem[localMem[0+1080]*10 + 6];
              ip = 2620;
      end

       2620 :
      begin                                                                     // mov
              heapMem[localMem[0+1184]*10 + 1] = localMem[0+1138];
              ip = 2621;
      end

       2621 :
      begin                                                                     // mov
              heapMem[localMem[0+1080]*10 + 0] = 1;
              ip = 2622;
      end

       2622 :
      begin                                                                     // mov
              localMem[0 + 1185] = heapMem[localMem[0+1080]*10 + 4];
              ip = 2623;
      end

       2623 :
      begin                                                                     // resize
              arraySizes[localMem[0+1185]] = 1;
              ip = 2624;
      end

       2624 :
      begin                                                                     // mov
              localMem[0 + 1186] = heapMem[localMem[0+1080]*10 + 5];
              ip = 2625;
      end

       2625 :
      begin                                                                     // resize
              arraySizes[localMem[0+1186]] = 1;
              ip = 2626;
      end

       2626 :
      begin                                                                     // mov
              localMem[0 + 1187] = heapMem[localMem[0+1080]*10 + 6];
              ip = 2627;
      end

       2627 :
      begin                                                                     // resize
              arraySizes[localMem[0+1187]] = 2;
              ip = 2628;
      end

       2628 :
      begin                                                                     // jmp
              ip = 2630;
      end

       2629 :
      begin                                                                     // jmp
              ip = 2635;
      end

       2630 :
      begin                                                                     // label
              ip = 2631;
      end

       2631 :
      begin                                                                     // mov
              localMem[0 + 1081] = 1;
              ip = 2632;
      end

       2632 :
      begin                                                                     // jmp
              ip = 2635;
      end

       2633 :
      begin                                                                     // label
              ip = 2634;
      end

       2634 :
      begin                                                                     // mov
              localMem[0 + 1081] = 0;
              ip = 2635;
      end

       2635 :
      begin                                                                     // label
              ip = 2636;
      end

       2636 :
      begin                                                                     // jNe
              ip = localMem[0+1081] != 0 ? 2638 : 2637;
      end

       2637 :
      begin                                                                     // mov
              localMem[0 + 965] = localMem[0+1080];
              ip = 2638;
      end

       2638 :
      begin                                                                     // label
              ip = 2639;
      end

       2639 :
      begin                                                                     // jmp
              ip = 2889;
      end

       2640 :
      begin                                                                     // label
              ip = 2641;
      end

       2641 :
      begin                                                                     // mov
              localMem[0 + 1188] = heapMem[localMem[0+965]*10 + 4];
              ip = 2642;
      end

       2642 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+1188] * NArea + i] == 3) localMem[0 + 1189] = i + 1;
              end
              ip = 2643;
      end

       2643 :
      begin                                                                     // jEq
              ip = localMem[0+1189] == 0 ? 2648 : 2644;
      end

       2644 :
      begin                                                                     // mov
              heapMem[localMem[0+945]*10 + 0] = localMem[0+965];
              ip = 2645;
      end

       2645 :
      begin                                                                     // mov
              heapMem[localMem[0+945]*10 + 1] = 1;
              ip = 2646;
      end

       2646 :
      begin                                                                     // subtract
              heapMem[localMem[0+945]*10 + 2] = localMem[0+1189] - 1;
              ip = 2647;
      end

       2647 :
      begin                                                                     // jmp
              ip = 2896;
      end

       2648 :
      begin                                                                     // label
              ip = 2649;
      end

       2649 :
      begin                                                                     // arrayCountLess
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+1188] * NArea + i] < 3) j = j + 1;
              end
              localMem[0 + 1190] = j;
              ip = 2650;
      end

       2650 :
      begin                                                                     // not
              localMem[0 + 1191] = !heapMem[localMem[0+965]*10 + 6];
              ip = 2651;
      end

       2651 :
      begin                                                                     // jEq
              ip = localMem[0+1191] == 0 ? 2656 : 2652;
      end

       2652 :
      begin                                                                     // mov
              heapMem[localMem[0+945]*10 + 0] = localMem[0+965];
              ip = 2653;
      end

       2653 :
      begin                                                                     // mov
              heapMem[localMem[0+945]*10 + 1] = 0;
              ip = 2654;
      end

       2654 :
      begin                                                                     // mov
              heapMem[localMem[0+945]*10 + 2] = localMem[0+1190];
              ip = 2655;
      end

       2655 :
      begin                                                                     // jmp
              ip = 2896;
      end

       2656 :
      begin                                                                     // label
              ip = 2657;
      end

       2657 :
      begin                                                                     // mov
              localMem[0 + 1192] = heapMem[localMem[0+965]*10 + 6];
              ip = 2658;
      end

       2658 :
      begin                                                                     // mov
              localMem[0 + 1193] = heapMem[localMem[0+1192]*10 + localMem[0+1190]];
              ip = 2659;
      end

       2659 :
      begin                                                                     // label
              ip = 2660;
      end

       2660 :
      begin                                                                     // mov
              localMem[0 + 1195] = heapMem[localMem[0+1193]*10 + 0];
              ip = 2661;
      end

       2661 :
      begin                                                                     // mov
              localMem[0 + 1196] = heapMem[localMem[0+1193]*10 + 3];
              ip = 2662;
      end

       2662 :
      begin                                                                     // mov
              localMem[0 + 1197] = heapMem[localMem[0+1196]*10 + 2];
              ip = 2663;
      end

       2663 :
      begin                                                                     // jLt
              ip = localMem[0+1195] <  localMem[0+1197] ? 2883 : 2664;
      end

       2664 :
      begin                                                                     // mov
              localMem[0 + 1198] = localMem[0+1197];
              ip = 2665;
      end

       2665 :
      begin                                                                     // shiftRight
              localMem[0 + 1198] = localMem[0+1198] >> 1;
              ip = 2666;
      end

       2666 :
      begin                                                                     // add
              localMem[0 + 1199] = localMem[0+1198] + 1;
              ip = 2667;
      end

       2667 :
      begin                                                                     // mov
              localMem[0 + 1200] = heapMem[localMem[0+1193]*10 + 2];
              ip = 2668;
      end

       2668 :
      begin                                                                     // jEq
              ip = localMem[0+1200] == 0 ? 2765 : 2669;
      end

       2669 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1201] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1201] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1201]] = 0;
              ip = 2670;
      end

       2670 :
      begin                                                                     // mov
              heapMem[localMem[0+1201]*10 + 0] = localMem[0+1198];
              ip = 2671;
      end

       2671 :
      begin                                                                     // mov
              heapMem[localMem[0+1201]*10 + 2] = 0;
              ip = 2672;
      end

       2672 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1202] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1202] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1202]] = 0;
              ip = 2673;
      end

       2673 :
      begin                                                                     // mov
              heapMem[localMem[0+1201]*10 + 4] = localMem[0+1202];
              ip = 2674;
      end

       2674 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1203] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1203] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1203]] = 0;
              ip = 2675;
      end

       2675 :
      begin                                                                     // mov
              heapMem[localMem[0+1201]*10 + 5] = localMem[0+1203];
              ip = 2676;
      end

       2676 :
      begin                                                                     // mov
              heapMem[localMem[0+1201]*10 + 6] = 0;
              ip = 2677;
      end

       2677 :
      begin                                                                     // mov
              heapMem[localMem[0+1201]*10 + 3] = localMem[0+1196];
              ip = 2678;
      end

       2678 :
      begin                                                                     // add
              heapMem[localMem[0+1196]*10 + 1] = heapMem[localMem[0+1196]*10 + 1] + 1;
              ip = 2679;
      end

       2679 :
      begin                                                                     // mov
              heapMem[localMem[0+1201]*10 + 1] = heapMem[localMem[0+1196]*10 + 1];
              ip = 2680;
      end

       2680 :
      begin                                                                     // not
              localMem[0 + 1204] = !heapMem[localMem[0+1193]*10 + 6];
              ip = 2681;
      end

       2681 :
      begin                                                                     // jNe
              ip = localMem[0+1204] != 0 ? 2710 : 2682;
      end

       2682 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1205] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1205] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1205]] = 0;
              ip = 2683;
      end

       2683 :
      begin                                                                     // mov
              heapMem[localMem[0+1201]*10 + 6] = localMem[0+1205];
              ip = 2684;
      end

       2684 :
      begin                                                                     // mov
              localMem[0 + 1206] = heapMem[localMem[0+1193]*10 + 4];
              ip = 2685;
      end

       2685 :
      begin                                                                     // mov
              localMem[0 + 1207] = heapMem[localMem[0+1201]*10 + 4];
              ip = 2686;
      end

       2686 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1198]) begin
                  heapMem[NArea * localMem[0+1207] + 0 + i] = heapMem[NArea * localMem[0+1206] + localMem[1199] + i];
                end
              end
              ip = 2687;
      end

       2687 :
      begin                                                                     // mov
              localMem[0 + 1208] = heapMem[localMem[0+1193]*10 + 5];
              ip = 2688;
      end

       2688 :
      begin                                                                     // mov
              localMem[0 + 1209] = heapMem[localMem[0+1201]*10 + 5];
              ip = 2689;
      end

       2689 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1198]) begin
                  heapMem[NArea * localMem[0+1209] + 0 + i] = heapMem[NArea * localMem[0+1208] + localMem[1199] + i];
                end
              end
              ip = 2690;
      end

       2690 :
      begin                                                                     // mov
              localMem[0 + 1210] = heapMem[localMem[0+1193]*10 + 6];
              ip = 2691;
      end

       2691 :
      begin                                                                     // mov
              localMem[0 + 1211] = heapMem[localMem[0+1201]*10 + 6];
              ip = 2692;
      end

       2692 :
      begin                                                                     // add
              localMem[0 + 1212] = localMem[0+1198] + 1;
              ip = 2693;
      end

       2693 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1212]) begin
                  heapMem[NArea * localMem[0+1211] + 0 + i] = heapMem[NArea * localMem[0+1210] + localMem[1199] + i];
                end
              end
              ip = 2694;
      end

       2694 :
      begin                                                                     // mov
              localMem[0 + 1213] = heapMem[localMem[0+1201]*10 + 0];
              ip = 2695;
      end

       2695 :
      begin                                                                     // add
              localMem[0 + 1214] = localMem[0+1213] + 1;
              ip = 2696;
      end

       2696 :
      begin                                                                     // mov
              localMem[0 + 1215] = heapMem[localMem[0+1201]*10 + 6];
              ip = 2697;
      end

       2697 :
      begin                                                                     // label
              ip = 2698;
      end

       2698 :
      begin                                                                     // mov
              localMem[0 + 1216] = 0;
              ip = 2699;
      end

       2699 :
      begin                                                                     // label
              ip = 2700;
      end

       2700 :
      begin                                                                     // jGe
              ip = localMem[0+1216] >= localMem[0+1214] ? 2706 : 2701;
      end

       2701 :
      begin                                                                     // mov
              localMem[0 + 1217] = heapMem[localMem[0+1215]*10 + localMem[0+1216]];
              ip = 2702;
      end

       2702 :
      begin                                                                     // mov
              heapMem[localMem[0+1217]*10 + 2] = localMem[0+1201];
              ip = 2703;
      end

       2703 :
      begin                                                                     // label
              ip = 2704;
      end

       2704 :
      begin                                                                     // add
              localMem[0 + 1216] = localMem[0+1216] + 1;
              ip = 2705;
      end

       2705 :
      begin                                                                     // jmp
              ip = 2699;
      end

       2706 :
      begin                                                                     // label
              ip = 2707;
      end

       2707 :
      begin                                                                     // mov
              localMem[0 + 1218] = heapMem[localMem[0+1193]*10 + 6];
              ip = 2708;
      end

       2708 :
      begin                                                                     // resize
              arraySizes[localMem[0+1218]] = localMem[0+1199];
              ip = 2709;
      end

       2709 :
      begin                                                                     // jmp
              ip = 2717;
      end

       2710 :
      begin                                                                     // label
              ip = 2711;
      end

       2711 :
      begin                                                                     // mov
              localMem[0 + 1219] = heapMem[localMem[0+1193]*10 + 4];
              ip = 2712;
      end

       2712 :
      begin                                                                     // mov
              localMem[0 + 1220] = heapMem[localMem[0+1201]*10 + 4];
              ip = 2713;
      end

       2713 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1198]) begin
                  heapMem[NArea * localMem[0+1220] + 0 + i] = heapMem[NArea * localMem[0+1219] + localMem[1199] + i];
                end
              end
              ip = 2714;
      end

       2714 :
      begin                                                                     // mov
              localMem[0 + 1221] = heapMem[localMem[0+1193]*10 + 5];
              ip = 2715;
      end

       2715 :
      begin                                                                     // mov
              localMem[0 + 1222] = heapMem[localMem[0+1201]*10 + 5];
              ip = 2716;
      end

       2716 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1198]) begin
                  heapMem[NArea * localMem[0+1222] + 0 + i] = heapMem[NArea * localMem[0+1221] + localMem[1199] + i];
                end
              end
              ip = 2717;
      end

       2717 :
      begin                                                                     // label
              ip = 2718;
      end

       2718 :
      begin                                                                     // mov
              heapMem[localMem[0+1193]*10 + 0] = localMem[0+1198];
              ip = 2719;
      end

       2719 :
      begin                                                                     // mov
              heapMem[localMem[0+1201]*10 + 2] = localMem[0+1200];
              ip = 2720;
      end

       2720 :
      begin                                                                     // mov
              localMem[0 + 1223] = heapMem[localMem[0+1200]*10 + 0];
              ip = 2721;
      end

       2721 :
      begin                                                                     // mov
              localMem[0 + 1224] = heapMem[localMem[0+1200]*10 + 6];
              ip = 2722;
      end

       2722 :
      begin                                                                     // mov
              localMem[0 + 1225] = heapMem[localMem[0+1224]*10 + localMem[0+1223]];
              ip = 2723;
      end

       2723 :
      begin                                                                     // jNe
              ip = localMem[0+1225] != localMem[0+1193] ? 2742 : 2724;
      end

       2724 :
      begin                                                                     // mov
              localMem[0 + 1226] = heapMem[localMem[0+1193]*10 + 4];
              ip = 2725;
      end

       2725 :
      begin                                                                     // mov
              localMem[0 + 1227] = heapMem[localMem[0+1226]*10 + localMem[0+1198]];
              ip = 2726;
      end

       2726 :
      begin                                                                     // mov
              localMem[0 + 1228] = heapMem[localMem[0+1200]*10 + 4];
              ip = 2727;
      end

       2727 :
      begin                                                                     // mov
              heapMem[localMem[0+1228]*10 + localMem[0+1223]] = localMem[0+1227];
              ip = 2728;
      end

       2728 :
      begin                                                                     // mov
              localMem[0 + 1229] = heapMem[localMem[0+1193]*10 + 5];
              ip = 2729;
      end

       2729 :
      begin                                                                     // mov
              localMem[0 + 1230] = heapMem[localMem[0+1229]*10 + localMem[0+1198]];
              ip = 2730;
      end

       2730 :
      begin                                                                     // mov
              localMem[0 + 1231] = heapMem[localMem[0+1200]*10 + 5];
              ip = 2731;
      end

       2731 :
      begin                                                                     // mov
              heapMem[localMem[0+1231]*10 + localMem[0+1223]] = localMem[0+1230];
              ip = 2732;
      end

       2732 :
      begin                                                                     // mov
              localMem[0 + 1232] = heapMem[localMem[0+1193]*10 + 4];
              ip = 2733;
      end

       2733 :
      begin                                                                     // resize
              arraySizes[localMem[0+1232]] = localMem[0+1198];
              ip = 2734;
      end

       2734 :
      begin                                                                     // mov
              localMem[0 + 1233] = heapMem[localMem[0+1193]*10 + 5];
              ip = 2735;
      end

       2735 :
      begin                                                                     // resize
              arraySizes[localMem[0+1233]] = localMem[0+1198];
              ip = 2736;
      end

       2736 :
      begin                                                                     // add
              localMem[0 + 1234] = localMem[0+1223] + 1;
              ip = 2737;
      end

       2737 :
      begin                                                                     // mov
              heapMem[localMem[0+1200]*10 + 0] = localMem[0+1234];
              ip = 2738;
      end

       2738 :
      begin                                                                     // mov
              localMem[0 + 1235] = heapMem[localMem[0+1200]*10 + 6];
              ip = 2739;
      end

       2739 :
      begin                                                                     // mov
              heapMem[localMem[0+1235]*10 + localMem[0+1234]] = localMem[0+1201];
              ip = 2740;
      end

       2740 :
      begin                                                                     // jmp
              ip = 2880;
      end

       2741 :
      begin                                                                     // jmp
              ip = 2764;
      end

       2742 :
      begin                                                                     // label
              ip = 2743;
      end

       2743 :
      begin                                                                     // assertNe
            ip = 2744;
      end

       2744 :
      begin                                                                     // mov
              localMem[0 + 1236] = heapMem[localMem[0+1200]*10 + 6];
              ip = 2745;
      end

       2745 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+1236] * NArea + i] == localMem[0+1193]) localMem[0 + 1237] = i + 1;
              end
              ip = 2746;
      end

       2746 :
      begin                                                                     // subtract
              localMem[0 + 1237] = localMem[0+1237] - 1;
              ip = 2747;
      end

       2747 :
      begin                                                                     // mov
              localMem[0 + 1238] = heapMem[localMem[0+1193]*10 + 4];
              ip = 2748;
      end

       2748 :
      begin                                                                     // mov
              localMem[0 + 1239] = heapMem[localMem[0+1238]*10 + localMem[0+1198]];
              ip = 2749;
      end

       2749 :
      begin                                                                     // mov
              localMem[0 + 1240] = heapMem[localMem[0+1193]*10 + 5];
              ip = 2750;
      end

       2750 :
      begin                                                                     // mov
              localMem[0 + 1241] = heapMem[localMem[0+1240]*10 + localMem[0+1198]];
              ip = 2751;
      end

       2751 :
      begin                                                                     // mov
              localMem[0 + 1242] = heapMem[localMem[0+1193]*10 + 4];
              ip = 2752;
      end

       2752 :
      begin                                                                     // resize
              arraySizes[localMem[0+1242]] = localMem[0+1198];
              ip = 2753;
      end

       2753 :
      begin                                                                     // mov
              localMem[0 + 1243] = heapMem[localMem[0+1193]*10 + 5];
              ip = 2754;
      end

       2754 :
      begin                                                                     // resize
              arraySizes[localMem[0+1243]] = localMem[0+1198];
              ip = 2755;
      end

       2755 :
      begin                                                                     // mov
              localMem[0 + 1244] = heapMem[localMem[0+1200]*10 + 4];
              ip = 2756;
      end

       2756 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1244] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1237]) begin
                  heapMem[NArea * localMem[0+1244] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1244] + localMem[1237]] = localMem[0+1239];                                    // Insert new value
              arraySizes[localMem[0+1244]] = arraySizes[localMem[0+1244]] + 1;                              // Increase array size
              ip = 2757;
      end

       2757 :
      begin                                                                     // mov
              localMem[0 + 1245] = heapMem[localMem[0+1200]*10 + 5];
              ip = 2758;
      end

       2758 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1245] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1237]) begin
                  heapMem[NArea * localMem[0+1245] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1245] + localMem[1237]] = localMem[0+1241];                                    // Insert new value
              arraySizes[localMem[0+1245]] = arraySizes[localMem[0+1245]] + 1;                              // Increase array size
              ip = 2759;
      end

       2759 :
      begin                                                                     // mov
              localMem[0 + 1246] = heapMem[localMem[0+1200]*10 + 6];
              ip = 2760;
      end

       2760 :
      begin                                                                     // add
              localMem[0 + 1247] = localMem[0+1237] + 1;
              ip = 2761;
      end

       2761 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1246] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1247]) begin
                  heapMem[NArea * localMem[0+1246] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1246] + localMem[1247]] = localMem[0+1201];                                    // Insert new value
              arraySizes[localMem[0+1246]] = arraySizes[localMem[0+1246]] + 1;                              // Increase array size
              ip = 2762;
      end

       2762 :
      begin                                                                     // add
              heapMem[localMem[0+1200]*10 + 0] = heapMem[localMem[0+1200]*10 + 0] + 1;
              ip = 2763;
      end

       2763 :
      begin                                                                     // jmp
              ip = 2880;
      end

       2764 :
      begin                                                                     // label
              ip = 2765;
      end

       2765 :
      begin                                                                     // label
              ip = 2766;
      end

       2766 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1248] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1248] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1248]] = 0;
              ip = 2767;
      end

       2767 :
      begin                                                                     // mov
              heapMem[localMem[0+1248]*10 + 0] = localMem[0+1198];
              ip = 2768;
      end

       2768 :
      begin                                                                     // mov
              heapMem[localMem[0+1248]*10 + 2] = 0;
              ip = 2769;
      end

       2769 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1249] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1249] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1249]] = 0;
              ip = 2770;
      end

       2770 :
      begin                                                                     // mov
              heapMem[localMem[0+1248]*10 + 4] = localMem[0+1249];
              ip = 2771;
      end

       2771 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1250] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1250] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1250]] = 0;
              ip = 2772;
      end

       2772 :
      begin                                                                     // mov
              heapMem[localMem[0+1248]*10 + 5] = localMem[0+1250];
              ip = 2773;
      end

       2773 :
      begin                                                                     // mov
              heapMem[localMem[0+1248]*10 + 6] = 0;
              ip = 2774;
      end

       2774 :
      begin                                                                     // mov
              heapMem[localMem[0+1248]*10 + 3] = localMem[0+1196];
              ip = 2775;
      end

       2775 :
      begin                                                                     // add
              heapMem[localMem[0+1196]*10 + 1] = heapMem[localMem[0+1196]*10 + 1] + 1;
              ip = 2776;
      end

       2776 :
      begin                                                                     // mov
              heapMem[localMem[0+1248]*10 + 1] = heapMem[localMem[0+1196]*10 + 1];
              ip = 2777;
      end

       2777 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1251] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1251] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1251]] = 0;
              ip = 2778;
      end

       2778 :
      begin                                                                     // mov
              heapMem[localMem[0+1251]*10 + 0] = localMem[0+1198];
              ip = 2779;
      end

       2779 :
      begin                                                                     // mov
              heapMem[localMem[0+1251]*10 + 2] = 0;
              ip = 2780;
      end

       2780 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1252] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1252] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1252]] = 0;
              ip = 2781;
      end

       2781 :
      begin                                                                     // mov
              heapMem[localMem[0+1251]*10 + 4] = localMem[0+1252];
              ip = 2782;
      end

       2782 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1253] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1253] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1253]] = 0;
              ip = 2783;
      end

       2783 :
      begin                                                                     // mov
              heapMem[localMem[0+1251]*10 + 5] = localMem[0+1253];
              ip = 2784;
      end

       2784 :
      begin                                                                     // mov
              heapMem[localMem[0+1251]*10 + 6] = 0;
              ip = 2785;
      end

       2785 :
      begin                                                                     // mov
              heapMem[localMem[0+1251]*10 + 3] = localMem[0+1196];
              ip = 2786;
      end

       2786 :
      begin                                                                     // add
              heapMem[localMem[0+1196]*10 + 1] = heapMem[localMem[0+1196]*10 + 1] + 1;
              ip = 2787;
      end

       2787 :
      begin                                                                     // mov
              heapMem[localMem[0+1251]*10 + 1] = heapMem[localMem[0+1196]*10 + 1];
              ip = 2788;
      end

       2788 :
      begin                                                                     // not
              localMem[0 + 1254] = !heapMem[localMem[0+1193]*10 + 6];
              ip = 2789;
      end

       2789 :
      begin                                                                     // jNe
              ip = localMem[0+1254] != 0 ? 2841 : 2790;
      end

       2790 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1255] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1255] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1255]] = 0;
              ip = 2791;
      end

       2791 :
      begin                                                                     // mov
              heapMem[localMem[0+1248]*10 + 6] = localMem[0+1255];
              ip = 2792;
      end

       2792 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1256] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1256] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1256]] = 0;
              ip = 2793;
      end

       2793 :
      begin                                                                     // mov
              heapMem[localMem[0+1251]*10 + 6] = localMem[0+1256];
              ip = 2794;
      end

       2794 :
      begin                                                                     // mov
              localMem[0 + 1257] = heapMem[localMem[0+1193]*10 + 4];
              ip = 2795;
      end

       2795 :
      begin                                                                     // mov
              localMem[0 + 1258] = heapMem[localMem[0+1248]*10 + 4];
              ip = 2796;
      end

       2796 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1198]) begin
                  heapMem[NArea * localMem[0+1258] + 0 + i] = heapMem[NArea * localMem[0+1257] + 0 + i];
                end
              end
              ip = 2797;
      end

       2797 :
      begin                                                                     // mov
              localMem[0 + 1259] = heapMem[localMem[0+1193]*10 + 5];
              ip = 2798;
      end

       2798 :
      begin                                                                     // mov
              localMem[0 + 1260] = heapMem[localMem[0+1248]*10 + 5];
              ip = 2799;
      end

       2799 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1198]) begin
                  heapMem[NArea * localMem[0+1260] + 0 + i] = heapMem[NArea * localMem[0+1259] + 0 + i];
                end
              end
              ip = 2800;
      end

       2800 :
      begin                                                                     // mov
              localMem[0 + 1261] = heapMem[localMem[0+1193]*10 + 6];
              ip = 2801;
      end

       2801 :
      begin                                                                     // mov
              localMem[0 + 1262] = heapMem[localMem[0+1248]*10 + 6];
              ip = 2802;
      end

       2802 :
      begin                                                                     // add
              localMem[0 + 1263] = localMem[0+1198] + 1;
              ip = 2803;
      end

       2803 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1263]) begin
                  heapMem[NArea * localMem[0+1262] + 0 + i] = heapMem[NArea * localMem[0+1261] + 0 + i];
                end
              end
              ip = 2804;
      end

       2804 :
      begin                                                                     // mov
              localMem[0 + 1264] = heapMem[localMem[0+1193]*10 + 4];
              ip = 2805;
      end

       2805 :
      begin                                                                     // mov
              localMem[0 + 1265] = heapMem[localMem[0+1251]*10 + 4];
              ip = 2806;
      end

       2806 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1198]) begin
                  heapMem[NArea * localMem[0+1265] + 0 + i] = heapMem[NArea * localMem[0+1264] + localMem[1199] + i];
                end
              end
              ip = 2807;
      end

       2807 :
      begin                                                                     // mov
              localMem[0 + 1266] = heapMem[localMem[0+1193]*10 + 5];
              ip = 2808;
      end

       2808 :
      begin                                                                     // mov
              localMem[0 + 1267] = heapMem[localMem[0+1251]*10 + 5];
              ip = 2809;
      end

       2809 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1198]) begin
                  heapMem[NArea * localMem[0+1267] + 0 + i] = heapMem[NArea * localMem[0+1266] + localMem[1199] + i];
                end
              end
              ip = 2810;
      end

       2810 :
      begin                                                                     // mov
              localMem[0 + 1268] = heapMem[localMem[0+1193]*10 + 6];
              ip = 2811;
      end

       2811 :
      begin                                                                     // mov
              localMem[0 + 1269] = heapMem[localMem[0+1251]*10 + 6];
              ip = 2812;
      end

       2812 :
      begin                                                                     // add
              localMem[0 + 1270] = localMem[0+1198] + 1;
              ip = 2813;
      end

       2813 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1270]) begin
                  heapMem[NArea * localMem[0+1269] + 0 + i] = heapMem[NArea * localMem[0+1268] + localMem[1199] + i];
                end
              end
              ip = 2814;
      end

       2814 :
      begin                                                                     // mov
              localMem[0 + 1271] = heapMem[localMem[0+1248]*10 + 0];
              ip = 2815;
      end

       2815 :
      begin                                                                     // add
              localMem[0 + 1272] = localMem[0+1271] + 1;
              ip = 2816;
      end

       2816 :
      begin                                                                     // mov
              localMem[0 + 1273] = heapMem[localMem[0+1248]*10 + 6];
              ip = 2817;
      end

       2817 :
      begin                                                                     // label
              ip = 2818;
      end

       2818 :
      begin                                                                     // mov
              localMem[0 + 1274] = 0;
              ip = 2819;
      end

       2819 :
      begin                                                                     // label
              ip = 2820;
      end

       2820 :
      begin                                                                     // jGe
              ip = localMem[0+1274] >= localMem[0+1272] ? 2826 : 2821;
      end

       2821 :
      begin                                                                     // mov
              localMem[0 + 1275] = heapMem[localMem[0+1273]*10 + localMem[0+1274]];
              ip = 2822;
      end

       2822 :
      begin                                                                     // mov
              heapMem[localMem[0+1275]*10 + 2] = localMem[0+1248];
              ip = 2823;
      end

       2823 :
      begin                                                                     // label
              ip = 2824;
      end

       2824 :
      begin                                                                     // add
              localMem[0 + 1274] = localMem[0+1274] + 1;
              ip = 2825;
      end

       2825 :
      begin                                                                     // jmp
              ip = 2819;
      end

       2826 :
      begin                                                                     // label
              ip = 2827;
      end

       2827 :
      begin                                                                     // mov
              localMem[0 + 1276] = heapMem[localMem[0+1251]*10 + 0];
              ip = 2828;
      end

       2828 :
      begin                                                                     // add
              localMem[0 + 1277] = localMem[0+1276] + 1;
              ip = 2829;
      end

       2829 :
      begin                                                                     // mov
              localMem[0 + 1278] = heapMem[localMem[0+1251]*10 + 6];
              ip = 2830;
      end

       2830 :
      begin                                                                     // label
              ip = 2831;
      end

       2831 :
      begin                                                                     // mov
              localMem[0 + 1279] = 0;
              ip = 2832;
      end

       2832 :
      begin                                                                     // label
              ip = 2833;
      end

       2833 :
      begin                                                                     // jGe
              ip = localMem[0+1279] >= localMem[0+1277] ? 2839 : 2834;
      end

       2834 :
      begin                                                                     // mov
              localMem[0 + 1280] = heapMem[localMem[0+1278]*10 + localMem[0+1279]];
              ip = 2835;
      end

       2835 :
      begin                                                                     // mov
              heapMem[localMem[0+1280]*10 + 2] = localMem[0+1251];
              ip = 2836;
      end

       2836 :
      begin                                                                     // label
              ip = 2837;
      end

       2837 :
      begin                                                                     // add
              localMem[0 + 1279] = localMem[0+1279] + 1;
              ip = 2838;
      end

       2838 :
      begin                                                                     // jmp
              ip = 2832;
      end

       2839 :
      begin                                                                     // label
              ip = 2840;
      end

       2840 :
      begin                                                                     // jmp
              ip = 2856;
      end

       2841 :
      begin                                                                     // label
              ip = 2842;
      end

       2842 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1281] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1281] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1281]] = 0;
              ip = 2843;
      end

       2843 :
      begin                                                                     // mov
              heapMem[localMem[0+1193]*10 + 6] = localMem[0+1281];
              ip = 2844;
      end

       2844 :
      begin                                                                     // mov
              localMem[0 + 1282] = heapMem[localMem[0+1193]*10 + 4];
              ip = 2845;
      end

       2845 :
      begin                                                                     // mov
              localMem[0 + 1283] = heapMem[localMem[0+1248]*10 + 4];
              ip = 2846;
      end

       2846 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1198]) begin
                  heapMem[NArea * localMem[0+1283] + 0 + i] = heapMem[NArea * localMem[0+1282] + 0 + i];
                end
              end
              ip = 2847;
      end

       2847 :
      begin                                                                     // mov
              localMem[0 + 1284] = heapMem[localMem[0+1193]*10 + 5];
              ip = 2848;
      end

       2848 :
      begin                                                                     // mov
              localMem[0 + 1285] = heapMem[localMem[0+1248]*10 + 5];
              ip = 2849;
      end

       2849 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1198]) begin
                  heapMem[NArea * localMem[0+1285] + 0 + i] = heapMem[NArea * localMem[0+1284] + 0 + i];
                end
              end
              ip = 2850;
      end

       2850 :
      begin                                                                     // mov
              localMem[0 + 1286] = heapMem[localMem[0+1193]*10 + 4];
              ip = 2851;
      end

       2851 :
      begin                                                                     // mov
              localMem[0 + 1287] = heapMem[localMem[0+1251]*10 + 4];
              ip = 2852;
      end

       2852 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1198]) begin
                  heapMem[NArea * localMem[0+1287] + 0 + i] = heapMem[NArea * localMem[0+1286] + localMem[1199] + i];
                end
              end
              ip = 2853;
      end

       2853 :
      begin                                                                     // mov
              localMem[0 + 1288] = heapMem[localMem[0+1193]*10 + 5];
              ip = 2854;
      end

       2854 :
      begin                                                                     // mov
              localMem[0 + 1289] = heapMem[localMem[0+1251]*10 + 5];
              ip = 2855;
      end

       2855 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1198]) begin
                  heapMem[NArea * localMem[0+1289] + 0 + i] = heapMem[NArea * localMem[0+1288] + localMem[1199] + i];
                end
              end
              ip = 2856;
      end

       2856 :
      begin                                                                     // label
              ip = 2857;
      end

       2857 :
      begin                                                                     // mov
              heapMem[localMem[0+1248]*10 + 2] = localMem[0+1193];
              ip = 2858;
      end

       2858 :
      begin                                                                     // mov
              heapMem[localMem[0+1251]*10 + 2] = localMem[0+1193];
              ip = 2859;
      end

       2859 :
      begin                                                                     // mov
              localMem[0 + 1290] = heapMem[localMem[0+1193]*10 + 4];
              ip = 2860;
      end

       2860 :
      begin                                                                     // mov
              localMem[0 + 1291] = heapMem[localMem[0+1290]*10 + localMem[0+1198]];
              ip = 2861;
      end

       2861 :
      begin                                                                     // mov
              localMem[0 + 1292] = heapMem[localMem[0+1193]*10 + 5];
              ip = 2862;
      end

       2862 :
      begin                                                                     // mov
              localMem[0 + 1293] = heapMem[localMem[0+1292]*10 + localMem[0+1198]];
              ip = 2863;
      end

       2863 :
      begin                                                                     // mov
              localMem[0 + 1294] = heapMem[localMem[0+1193]*10 + 4];
              ip = 2864;
      end

       2864 :
      begin                                                                     // mov
              heapMem[localMem[0+1294]*10 + 0] = localMem[0+1291];
              ip = 2865;
      end

       2865 :
      begin                                                                     // mov
              localMem[0 + 1295] = heapMem[localMem[0+1193]*10 + 5];
              ip = 2866;
      end

       2866 :
      begin                                                                     // mov
              heapMem[localMem[0+1295]*10 + 0] = localMem[0+1293];
              ip = 2867;
      end

       2867 :
      begin                                                                     // mov
              localMem[0 + 1296] = heapMem[localMem[0+1193]*10 + 6];
              ip = 2868;
      end

       2868 :
      begin                                                                     // mov
              heapMem[localMem[0+1296]*10 + 0] = localMem[0+1248];
              ip = 2869;
      end

       2869 :
      begin                                                                     // mov
              localMem[0 + 1297] = heapMem[localMem[0+1193]*10 + 6];
              ip = 2870;
      end

       2870 :
      begin                                                                     // mov
              heapMem[localMem[0+1297]*10 + 1] = localMem[0+1251];
              ip = 2871;
      end

       2871 :
      begin                                                                     // mov
              heapMem[localMem[0+1193]*10 + 0] = 1;
              ip = 2872;
      end

       2872 :
      begin                                                                     // mov
              localMem[0 + 1298] = heapMem[localMem[0+1193]*10 + 4];
              ip = 2873;
      end

       2873 :
      begin                                                                     // resize
              arraySizes[localMem[0+1298]] = 1;
              ip = 2874;
      end

       2874 :
      begin                                                                     // mov
              localMem[0 + 1299] = heapMem[localMem[0+1193]*10 + 5];
              ip = 2875;
      end

       2875 :
      begin                                                                     // resize
              arraySizes[localMem[0+1299]] = 1;
              ip = 2876;
      end

       2876 :
      begin                                                                     // mov
              localMem[0 + 1300] = heapMem[localMem[0+1193]*10 + 6];
              ip = 2877;
      end

       2877 :
      begin                                                                     // resize
              arraySizes[localMem[0+1300]] = 2;
              ip = 2878;
      end

       2878 :
      begin                                                                     // jmp
              ip = 2880;
      end

       2879 :
      begin                                                                     // jmp
              ip = 2885;
      end

       2880 :
      begin                                                                     // label
              ip = 2881;
      end

       2881 :
      begin                                                                     // mov
              localMem[0 + 1194] = 1;
              ip = 2882;
      end

       2882 :
      begin                                                                     // jmp
              ip = 2885;
      end

       2883 :
      begin                                                                     // label
              ip = 2884;
      end

       2884 :
      begin                                                                     // mov
              localMem[0 + 1194] = 0;
              ip = 2885;
      end

       2885 :
      begin                                                                     // label
              ip = 2886;
      end

       2886 :
      begin                                                                     // jNe
              ip = localMem[0+1194] != 0 ? 2888 : 2887;
      end

       2887 :
      begin                                                                     // mov
              localMem[0 + 965] = localMem[0+1193];
              ip = 2888;
      end

       2888 :
      begin                                                                     // label
              ip = 2889;
      end

       2889 :
      begin                                                                     // label
              ip = 2890;
      end

       2890 :
      begin                                                                     // add
              localMem[0 + 1073] = localMem[0+1073] + 1;
              ip = 2891;
      end

       2891 :
      begin                                                                     // jmp
              ip = 2393;
      end

       2892 :
      begin                                                                     // label
              ip = 2893;
      end

       2893 :
      begin                                                                     // assert
            ip = 2894;
      end

       2894 :
      begin                                                                     // label
              ip = 2895;
      end

       2895 :
      begin                                                                     // label
              ip = 2896;
      end

       2896 :
      begin                                                                     // label
              ip = 2897;
      end

       2897 :
      begin                                                                     // mov
              localMem[0 + 1301] = heapMem[localMem[0+945]*10 + 0];
              ip = 2898;
      end

       2898 :
      begin                                                                     // mov
              localMem[0 + 1302] = heapMem[localMem[0+945]*10 + 1];
              ip = 2899;
      end

       2899 :
      begin                                                                     // mov
              localMem[0 + 1303] = heapMem[localMem[0+945]*10 + 2];
              ip = 2900;
      end

       2900 :
      begin                                                                     // jNe
              ip = localMem[0+1302] != 1 ? 2904 : 2901;
      end

       2901 :
      begin                                                                     // mov
              localMem[0 + 1304] = heapMem[localMem[0+1301]*10 + 5];
              ip = 2902;
      end

       2902 :
      begin                                                                     // mov
              heapMem[localMem[0+1304]*10 + localMem[0+1303]] = 33;
              ip = 2903;
      end

       2903 :
      begin                                                                     // jmp
              ip = 3150;
      end

       2904 :
      begin                                                                     // label
              ip = 2905;
      end

       2905 :
      begin                                                                     // jNe
              ip = localMem[0+1302] != 2 ? 2913 : 2906;
      end

       2906 :
      begin                                                                     // add
              localMem[0 + 1305] = localMem[0+1303] + 1;
              ip = 2907;
      end

       2907 :
      begin                                                                     // mov
              localMem[0 + 1306] = heapMem[localMem[0+1301]*10 + 4];
              ip = 2908;
      end

       2908 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1306] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1305]) begin
                  heapMem[NArea * localMem[0+1306] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1306] + localMem[1305]] = 3;                                    // Insert new value
              arraySizes[localMem[0+1306]] = arraySizes[localMem[0+1306]] + 1;                              // Increase array size
              ip = 2909;
      end

       2909 :
      begin                                                                     // mov
              localMem[0 + 1307] = heapMem[localMem[0+1301]*10 + 5];
              ip = 2910;
      end

       2910 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1307] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1305]) begin
                  heapMem[NArea * localMem[0+1307] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1307] + localMem[1305]] = 33;                                    // Insert new value
              arraySizes[localMem[0+1307]] = arraySizes[localMem[0+1307]] + 1;                              // Increase array size
              ip = 2911;
      end

       2911 :
      begin                                                                     // add
              heapMem[localMem[0+1301]*10 + 0] = heapMem[localMem[0+1301]*10 + 0] + 1;
              ip = 2912;
      end

       2912 :
      begin                                                                     // jmp
              ip = 2919;
      end

       2913 :
      begin                                                                     // label
              ip = 2914;
      end

       2914 :
      begin                                                                     // mov
              localMem[0 + 1308] = heapMem[localMem[0+1301]*10 + 4];
              ip = 2915;
      end

       2915 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1308] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1303]) begin
                  heapMem[NArea * localMem[0+1308] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1308] + localMem[1303]] = 3;                                    // Insert new value
              arraySizes[localMem[0+1308]] = arraySizes[localMem[0+1308]] + 1;                              // Increase array size
              ip = 2916;
      end

       2916 :
      begin                                                                     // mov
              localMem[0 + 1309] = heapMem[localMem[0+1301]*10 + 5];
              ip = 2917;
      end

       2917 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1309] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1303]) begin
                  heapMem[NArea * localMem[0+1309] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1309] + localMem[1303]] = 33;                                    // Insert new value
              arraySizes[localMem[0+1309]] = arraySizes[localMem[0+1309]] + 1;                              // Increase array size
              ip = 2918;
      end

       2918 :
      begin                                                                     // add
              heapMem[localMem[0+1301]*10 + 0] = heapMem[localMem[0+1301]*10 + 0] + 1;
              ip = 2919;
      end

       2919 :
      begin                                                                     // label
              ip = 2920;
      end

       2920 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 2921;
      end

       2921 :
      begin                                                                     // label
              ip = 2922;
      end

       2922 :
      begin                                                                     // mov
              localMem[0 + 1311] = heapMem[localMem[0+1301]*10 + 0];
              ip = 2923;
      end

       2923 :
      begin                                                                     // mov
              localMem[0 + 1312] = heapMem[localMem[0+1301]*10 + 3];
              ip = 2924;
      end

       2924 :
      begin                                                                     // mov
              localMem[0 + 1313] = heapMem[localMem[0+1312]*10 + 2];
              ip = 2925;
      end

       2925 :
      begin                                                                     // jLt
              ip = localMem[0+1311] <  localMem[0+1313] ? 3145 : 2926;
      end

       2926 :
      begin                                                                     // mov
              localMem[0 + 1314] = localMem[0+1313];
              ip = 2927;
      end

       2927 :
      begin                                                                     // shiftRight
              localMem[0 + 1314] = localMem[0+1314] >> 1;
              ip = 2928;
      end

       2928 :
      begin                                                                     // add
              localMem[0 + 1315] = localMem[0+1314] + 1;
              ip = 2929;
      end

       2929 :
      begin                                                                     // mov
              localMem[0 + 1316] = heapMem[localMem[0+1301]*10 + 2];
              ip = 2930;
      end

       2930 :
      begin                                                                     // jEq
              ip = localMem[0+1316] == 0 ? 3027 : 2931;
      end

       2931 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1317] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1317] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1317]] = 0;
              ip = 2932;
      end

       2932 :
      begin                                                                     // mov
              heapMem[localMem[0+1317]*10 + 0] = localMem[0+1314];
              ip = 2933;
      end

       2933 :
      begin                                                                     // mov
              heapMem[localMem[0+1317]*10 + 2] = 0;
              ip = 2934;
      end

       2934 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1318] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1318] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1318]] = 0;
              ip = 2935;
      end

       2935 :
      begin                                                                     // mov
              heapMem[localMem[0+1317]*10 + 4] = localMem[0+1318];
              ip = 2936;
      end

       2936 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1319] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1319] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1319]] = 0;
              ip = 2937;
      end

       2937 :
      begin                                                                     // mov
              heapMem[localMem[0+1317]*10 + 5] = localMem[0+1319];
              ip = 2938;
      end

       2938 :
      begin                                                                     // mov
              heapMem[localMem[0+1317]*10 + 6] = 0;
              ip = 2939;
      end

       2939 :
      begin                                                                     // mov
              heapMem[localMem[0+1317]*10 + 3] = localMem[0+1312];
              ip = 2940;
      end

       2940 :
      begin                                                                     // add
              heapMem[localMem[0+1312]*10 + 1] = heapMem[localMem[0+1312]*10 + 1] + 1;
              ip = 2941;
      end

       2941 :
      begin                                                                     // mov
              heapMem[localMem[0+1317]*10 + 1] = heapMem[localMem[0+1312]*10 + 1];
              ip = 2942;
      end

       2942 :
      begin                                                                     // not
              localMem[0 + 1320] = !heapMem[localMem[0+1301]*10 + 6];
              ip = 2943;
      end

       2943 :
      begin                                                                     // jNe
              ip = localMem[0+1320] != 0 ? 2972 : 2944;
      end

       2944 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1321] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1321] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1321]] = 0;
              ip = 2945;
      end

       2945 :
      begin                                                                     // mov
              heapMem[localMem[0+1317]*10 + 6] = localMem[0+1321];
              ip = 2946;
      end

       2946 :
      begin                                                                     // mov
              localMem[0 + 1322] = heapMem[localMem[0+1301]*10 + 4];
              ip = 2947;
      end

       2947 :
      begin                                                                     // mov
              localMem[0 + 1323] = heapMem[localMem[0+1317]*10 + 4];
              ip = 2948;
      end

       2948 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1314]) begin
                  heapMem[NArea * localMem[0+1323] + 0 + i] = heapMem[NArea * localMem[0+1322] + localMem[1315] + i];
                end
              end
              ip = 2949;
      end

       2949 :
      begin                                                                     // mov
              localMem[0 + 1324] = heapMem[localMem[0+1301]*10 + 5];
              ip = 2950;
      end

       2950 :
      begin                                                                     // mov
              localMem[0 + 1325] = heapMem[localMem[0+1317]*10 + 5];
              ip = 2951;
      end

       2951 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1314]) begin
                  heapMem[NArea * localMem[0+1325] + 0 + i] = heapMem[NArea * localMem[0+1324] + localMem[1315] + i];
                end
              end
              ip = 2952;
      end

       2952 :
      begin                                                                     // mov
              localMem[0 + 1326] = heapMem[localMem[0+1301]*10 + 6];
              ip = 2953;
      end

       2953 :
      begin                                                                     // mov
              localMem[0 + 1327] = heapMem[localMem[0+1317]*10 + 6];
              ip = 2954;
      end

       2954 :
      begin                                                                     // add
              localMem[0 + 1328] = localMem[0+1314] + 1;
              ip = 2955;
      end

       2955 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1328]) begin
                  heapMem[NArea * localMem[0+1327] + 0 + i] = heapMem[NArea * localMem[0+1326] + localMem[1315] + i];
                end
              end
              ip = 2956;
      end

       2956 :
      begin                                                                     // mov
              localMem[0 + 1329] = heapMem[localMem[0+1317]*10 + 0];
              ip = 2957;
      end

       2957 :
      begin                                                                     // add
              localMem[0 + 1330] = localMem[0+1329] + 1;
              ip = 2958;
      end

       2958 :
      begin                                                                     // mov
              localMem[0 + 1331] = heapMem[localMem[0+1317]*10 + 6];
              ip = 2959;
      end

       2959 :
      begin                                                                     // label
              ip = 2960;
      end

       2960 :
      begin                                                                     // mov
              localMem[0 + 1332] = 0;
              ip = 2961;
      end

       2961 :
      begin                                                                     // label
              ip = 2962;
      end

       2962 :
      begin                                                                     // jGe
              ip = localMem[0+1332] >= localMem[0+1330] ? 2968 : 2963;
      end

       2963 :
      begin                                                                     // mov
              localMem[0 + 1333] = heapMem[localMem[0+1331]*10 + localMem[0+1332]];
              ip = 2964;
      end

       2964 :
      begin                                                                     // mov
              heapMem[localMem[0+1333]*10 + 2] = localMem[0+1317];
              ip = 2965;
      end

       2965 :
      begin                                                                     // label
              ip = 2966;
      end

       2966 :
      begin                                                                     // add
              localMem[0 + 1332] = localMem[0+1332] + 1;
              ip = 2967;
      end

       2967 :
      begin                                                                     // jmp
              ip = 2961;
      end

       2968 :
      begin                                                                     // label
              ip = 2969;
      end

       2969 :
      begin                                                                     // mov
              localMem[0 + 1334] = heapMem[localMem[0+1301]*10 + 6];
              ip = 2970;
      end

       2970 :
      begin                                                                     // resize
              arraySizes[localMem[0+1334]] = localMem[0+1315];
              ip = 2971;
      end

       2971 :
      begin                                                                     // jmp
              ip = 2979;
      end

       2972 :
      begin                                                                     // label
              ip = 2973;
      end

       2973 :
      begin                                                                     // mov
              localMem[0 + 1335] = heapMem[localMem[0+1301]*10 + 4];
              ip = 2974;
      end

       2974 :
      begin                                                                     // mov
              localMem[0 + 1336] = heapMem[localMem[0+1317]*10 + 4];
              ip = 2975;
      end

       2975 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1314]) begin
                  heapMem[NArea * localMem[0+1336] + 0 + i] = heapMem[NArea * localMem[0+1335] + localMem[1315] + i];
                end
              end
              ip = 2976;
      end

       2976 :
      begin                                                                     // mov
              localMem[0 + 1337] = heapMem[localMem[0+1301]*10 + 5];
              ip = 2977;
      end

       2977 :
      begin                                                                     // mov
              localMem[0 + 1338] = heapMem[localMem[0+1317]*10 + 5];
              ip = 2978;
      end

       2978 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1314]) begin
                  heapMem[NArea * localMem[0+1338] + 0 + i] = heapMem[NArea * localMem[0+1337] + localMem[1315] + i];
                end
              end
              ip = 2979;
      end

       2979 :
      begin                                                                     // label
              ip = 2980;
      end

       2980 :
      begin                                                                     // mov
              heapMem[localMem[0+1301]*10 + 0] = localMem[0+1314];
              ip = 2981;
      end

       2981 :
      begin                                                                     // mov
              heapMem[localMem[0+1317]*10 + 2] = localMem[0+1316];
              ip = 2982;
      end

       2982 :
      begin                                                                     // mov
              localMem[0 + 1339] = heapMem[localMem[0+1316]*10 + 0];
              ip = 2983;
      end

       2983 :
      begin                                                                     // mov
              localMem[0 + 1340] = heapMem[localMem[0+1316]*10 + 6];
              ip = 2984;
      end

       2984 :
      begin                                                                     // mov
              localMem[0 + 1341] = heapMem[localMem[0+1340]*10 + localMem[0+1339]];
              ip = 2985;
      end

       2985 :
      begin                                                                     // jNe
              ip = localMem[0+1341] != localMem[0+1301] ? 3004 : 2986;
      end

       2986 :
      begin                                                                     // mov
              localMem[0 + 1342] = heapMem[localMem[0+1301]*10 + 4];
              ip = 2987;
      end

       2987 :
      begin                                                                     // mov
              localMem[0 + 1343] = heapMem[localMem[0+1342]*10 + localMem[0+1314]];
              ip = 2988;
      end

       2988 :
      begin                                                                     // mov
              localMem[0 + 1344] = heapMem[localMem[0+1316]*10 + 4];
              ip = 2989;
      end

       2989 :
      begin                                                                     // mov
              heapMem[localMem[0+1344]*10 + localMem[0+1339]] = localMem[0+1343];
              ip = 2990;
      end

       2990 :
      begin                                                                     // mov
              localMem[0 + 1345] = heapMem[localMem[0+1301]*10 + 5];
              ip = 2991;
      end

       2991 :
      begin                                                                     // mov
              localMem[0 + 1346] = heapMem[localMem[0+1345]*10 + localMem[0+1314]];
              ip = 2992;
      end

       2992 :
      begin                                                                     // mov
              localMem[0 + 1347] = heapMem[localMem[0+1316]*10 + 5];
              ip = 2993;
      end

       2993 :
      begin                                                                     // mov
              heapMem[localMem[0+1347]*10 + localMem[0+1339]] = localMem[0+1346];
              ip = 2994;
      end

       2994 :
      begin                                                                     // mov
              localMem[0 + 1348] = heapMem[localMem[0+1301]*10 + 4];
              ip = 2995;
      end

       2995 :
      begin                                                                     // resize
              arraySizes[localMem[0+1348]] = localMem[0+1314];
              ip = 2996;
      end

       2996 :
      begin                                                                     // mov
              localMem[0 + 1349] = heapMem[localMem[0+1301]*10 + 5];
              ip = 2997;
      end

       2997 :
      begin                                                                     // resize
              arraySizes[localMem[0+1349]] = localMem[0+1314];
              ip = 2998;
      end

       2998 :
      begin                                                                     // add
              localMem[0 + 1350] = localMem[0+1339] + 1;
              ip = 2999;
      end

       2999 :
      begin                                                                     // mov
              heapMem[localMem[0+1316]*10 + 0] = localMem[0+1350];
              ip = 3000;
      end

       3000 :
      begin                                                                     // mov
              localMem[0 + 1351] = heapMem[localMem[0+1316]*10 + 6];
              ip = 3001;
      end

       3001 :
      begin                                                                     // mov
              heapMem[localMem[0+1351]*10 + localMem[0+1350]] = localMem[0+1317];
              ip = 3002;
      end

       3002 :
      begin                                                                     // jmp
              ip = 3142;
      end

       3003 :
      begin                                                                     // jmp
              ip = 3026;
      end

       3004 :
      begin                                                                     // label
              ip = 3005;
      end

       3005 :
      begin                                                                     // assertNe
            ip = 3006;
      end

       3006 :
      begin                                                                     // mov
              localMem[0 + 1352] = heapMem[localMem[0+1316]*10 + 6];
              ip = 3007;
      end

       3007 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+1352] * NArea + i] == localMem[0+1301]) localMem[0 + 1353] = i + 1;
              end
              ip = 3008;
      end

       3008 :
      begin                                                                     // subtract
              localMem[0 + 1353] = localMem[0+1353] - 1;
              ip = 3009;
      end

       3009 :
      begin                                                                     // mov
              localMem[0 + 1354] = heapMem[localMem[0+1301]*10 + 4];
              ip = 3010;
      end

       3010 :
      begin                                                                     // mov
              localMem[0 + 1355] = heapMem[localMem[0+1354]*10 + localMem[0+1314]];
              ip = 3011;
      end

       3011 :
      begin                                                                     // mov
              localMem[0 + 1356] = heapMem[localMem[0+1301]*10 + 5];
              ip = 3012;
      end

       3012 :
      begin                                                                     // mov
              localMem[0 + 1357] = heapMem[localMem[0+1356]*10 + localMem[0+1314]];
              ip = 3013;
      end

       3013 :
      begin                                                                     // mov
              localMem[0 + 1358] = heapMem[localMem[0+1301]*10 + 4];
              ip = 3014;
      end

       3014 :
      begin                                                                     // resize
              arraySizes[localMem[0+1358]] = localMem[0+1314];
              ip = 3015;
      end

       3015 :
      begin                                                                     // mov
              localMem[0 + 1359] = heapMem[localMem[0+1301]*10 + 5];
              ip = 3016;
      end

       3016 :
      begin                                                                     // resize
              arraySizes[localMem[0+1359]] = localMem[0+1314];
              ip = 3017;
      end

       3017 :
      begin                                                                     // mov
              localMem[0 + 1360] = heapMem[localMem[0+1316]*10 + 4];
              ip = 3018;
      end

       3018 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1360] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1353]) begin
                  heapMem[NArea * localMem[0+1360] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1360] + localMem[1353]] = localMem[0+1355];                                    // Insert new value
              arraySizes[localMem[0+1360]] = arraySizes[localMem[0+1360]] + 1;                              // Increase array size
              ip = 3019;
      end

       3019 :
      begin                                                                     // mov
              localMem[0 + 1361] = heapMem[localMem[0+1316]*10 + 5];
              ip = 3020;
      end

       3020 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1361] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1353]) begin
                  heapMem[NArea * localMem[0+1361] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1361] + localMem[1353]] = localMem[0+1357];                                    // Insert new value
              arraySizes[localMem[0+1361]] = arraySizes[localMem[0+1361]] + 1;                              // Increase array size
              ip = 3021;
      end

       3021 :
      begin                                                                     // mov
              localMem[0 + 1362] = heapMem[localMem[0+1316]*10 + 6];
              ip = 3022;
      end

       3022 :
      begin                                                                     // add
              localMem[0 + 1363] = localMem[0+1353] + 1;
              ip = 3023;
      end

       3023 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1362] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1363]) begin
                  heapMem[NArea * localMem[0+1362] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1362] + localMem[1363]] = localMem[0+1317];                                    // Insert new value
              arraySizes[localMem[0+1362]] = arraySizes[localMem[0+1362]] + 1;                              // Increase array size
              ip = 3024;
      end

       3024 :
      begin                                                                     // add
              heapMem[localMem[0+1316]*10 + 0] = heapMem[localMem[0+1316]*10 + 0] + 1;
              ip = 3025;
      end

       3025 :
      begin                                                                     // jmp
              ip = 3142;
      end

       3026 :
      begin                                                                     // label
              ip = 3027;
      end

       3027 :
      begin                                                                     // label
              ip = 3028;
      end

       3028 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1364] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1364] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1364]] = 0;
              ip = 3029;
      end

       3029 :
      begin                                                                     // mov
              heapMem[localMem[0+1364]*10 + 0] = localMem[0+1314];
              ip = 3030;
      end

       3030 :
      begin                                                                     // mov
              heapMem[localMem[0+1364]*10 + 2] = 0;
              ip = 3031;
      end

       3031 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1365] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1365] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1365]] = 0;
              ip = 3032;
      end

       3032 :
      begin                                                                     // mov
              heapMem[localMem[0+1364]*10 + 4] = localMem[0+1365];
              ip = 3033;
      end

       3033 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1366] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1366] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1366]] = 0;
              ip = 3034;
      end

       3034 :
      begin                                                                     // mov
              heapMem[localMem[0+1364]*10 + 5] = localMem[0+1366];
              ip = 3035;
      end

       3035 :
      begin                                                                     // mov
              heapMem[localMem[0+1364]*10 + 6] = 0;
              ip = 3036;
      end

       3036 :
      begin                                                                     // mov
              heapMem[localMem[0+1364]*10 + 3] = localMem[0+1312];
              ip = 3037;
      end

       3037 :
      begin                                                                     // add
              heapMem[localMem[0+1312]*10 + 1] = heapMem[localMem[0+1312]*10 + 1] + 1;
              ip = 3038;
      end

       3038 :
      begin                                                                     // mov
              heapMem[localMem[0+1364]*10 + 1] = heapMem[localMem[0+1312]*10 + 1];
              ip = 3039;
      end

       3039 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1367] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1367] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1367]] = 0;
              ip = 3040;
      end

       3040 :
      begin                                                                     // mov
              heapMem[localMem[0+1367]*10 + 0] = localMem[0+1314];
              ip = 3041;
      end

       3041 :
      begin                                                                     // mov
              heapMem[localMem[0+1367]*10 + 2] = 0;
              ip = 3042;
      end

       3042 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1368] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1368] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1368]] = 0;
              ip = 3043;
      end

       3043 :
      begin                                                                     // mov
              heapMem[localMem[0+1367]*10 + 4] = localMem[0+1368];
              ip = 3044;
      end

       3044 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1369] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1369] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1369]] = 0;
              ip = 3045;
      end

       3045 :
      begin                                                                     // mov
              heapMem[localMem[0+1367]*10 + 5] = localMem[0+1369];
              ip = 3046;
      end

       3046 :
      begin                                                                     // mov
              heapMem[localMem[0+1367]*10 + 6] = 0;
              ip = 3047;
      end

       3047 :
      begin                                                                     // mov
              heapMem[localMem[0+1367]*10 + 3] = localMem[0+1312];
              ip = 3048;
      end

       3048 :
      begin                                                                     // add
              heapMem[localMem[0+1312]*10 + 1] = heapMem[localMem[0+1312]*10 + 1] + 1;
              ip = 3049;
      end

       3049 :
      begin                                                                     // mov
              heapMem[localMem[0+1367]*10 + 1] = heapMem[localMem[0+1312]*10 + 1];
              ip = 3050;
      end

       3050 :
      begin                                                                     // not
              localMem[0 + 1370] = !heapMem[localMem[0+1301]*10 + 6];
              ip = 3051;
      end

       3051 :
      begin                                                                     // jNe
              ip = localMem[0+1370] != 0 ? 3103 : 3052;
      end

       3052 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1371] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1371] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1371]] = 0;
              ip = 3053;
      end

       3053 :
      begin                                                                     // mov
              heapMem[localMem[0+1364]*10 + 6] = localMem[0+1371];
              ip = 3054;
      end

       3054 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1372] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1372] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1372]] = 0;
              ip = 3055;
      end

       3055 :
      begin                                                                     // mov
              heapMem[localMem[0+1367]*10 + 6] = localMem[0+1372];
              ip = 3056;
      end

       3056 :
      begin                                                                     // mov
              localMem[0 + 1373] = heapMem[localMem[0+1301]*10 + 4];
              ip = 3057;
      end

       3057 :
      begin                                                                     // mov
              localMem[0 + 1374] = heapMem[localMem[0+1364]*10 + 4];
              ip = 3058;
      end

       3058 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1314]) begin
                  heapMem[NArea * localMem[0+1374] + 0 + i] = heapMem[NArea * localMem[0+1373] + 0 + i];
                end
              end
              ip = 3059;
      end

       3059 :
      begin                                                                     // mov
              localMem[0 + 1375] = heapMem[localMem[0+1301]*10 + 5];
              ip = 3060;
      end

       3060 :
      begin                                                                     // mov
              localMem[0 + 1376] = heapMem[localMem[0+1364]*10 + 5];
              ip = 3061;
      end

       3061 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1314]) begin
                  heapMem[NArea * localMem[0+1376] + 0 + i] = heapMem[NArea * localMem[0+1375] + 0 + i];
                end
              end
              ip = 3062;
      end

       3062 :
      begin                                                                     // mov
              localMem[0 + 1377] = heapMem[localMem[0+1301]*10 + 6];
              ip = 3063;
      end

       3063 :
      begin                                                                     // mov
              localMem[0 + 1378] = heapMem[localMem[0+1364]*10 + 6];
              ip = 3064;
      end

       3064 :
      begin                                                                     // add
              localMem[0 + 1379] = localMem[0+1314] + 1;
              ip = 3065;
      end

       3065 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1379]) begin
                  heapMem[NArea * localMem[0+1378] + 0 + i] = heapMem[NArea * localMem[0+1377] + 0 + i];
                end
              end
              ip = 3066;
      end

       3066 :
      begin                                                                     // mov
              localMem[0 + 1380] = heapMem[localMem[0+1301]*10 + 4];
              ip = 3067;
      end

       3067 :
      begin                                                                     // mov
              localMem[0 + 1381] = heapMem[localMem[0+1367]*10 + 4];
              ip = 3068;
      end

       3068 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1314]) begin
                  heapMem[NArea * localMem[0+1381] + 0 + i] = heapMem[NArea * localMem[0+1380] + localMem[1315] + i];
                end
              end
              ip = 3069;
      end

       3069 :
      begin                                                                     // mov
              localMem[0 + 1382] = heapMem[localMem[0+1301]*10 + 5];
              ip = 3070;
      end

       3070 :
      begin                                                                     // mov
              localMem[0 + 1383] = heapMem[localMem[0+1367]*10 + 5];
              ip = 3071;
      end

       3071 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1314]) begin
                  heapMem[NArea * localMem[0+1383] + 0 + i] = heapMem[NArea * localMem[0+1382] + localMem[1315] + i];
                end
              end
              ip = 3072;
      end

       3072 :
      begin                                                                     // mov
              localMem[0 + 1384] = heapMem[localMem[0+1301]*10 + 6];
              ip = 3073;
      end

       3073 :
      begin                                                                     // mov
              localMem[0 + 1385] = heapMem[localMem[0+1367]*10 + 6];
              ip = 3074;
      end

       3074 :
      begin                                                                     // add
              localMem[0 + 1386] = localMem[0+1314] + 1;
              ip = 3075;
      end

       3075 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1386]) begin
                  heapMem[NArea * localMem[0+1385] + 0 + i] = heapMem[NArea * localMem[0+1384] + localMem[1315] + i];
                end
              end
              ip = 3076;
      end

       3076 :
      begin                                                                     // mov
              localMem[0 + 1387] = heapMem[localMem[0+1364]*10 + 0];
              ip = 3077;
      end

       3077 :
      begin                                                                     // add
              localMem[0 + 1388] = localMem[0+1387] + 1;
              ip = 3078;
      end

       3078 :
      begin                                                                     // mov
              localMem[0 + 1389] = heapMem[localMem[0+1364]*10 + 6];
              ip = 3079;
      end

       3079 :
      begin                                                                     // label
              ip = 3080;
      end

       3080 :
      begin                                                                     // mov
              localMem[0 + 1390] = 0;
              ip = 3081;
      end

       3081 :
      begin                                                                     // label
              ip = 3082;
      end

       3082 :
      begin                                                                     // jGe
              ip = localMem[0+1390] >= localMem[0+1388] ? 3088 : 3083;
      end

       3083 :
      begin                                                                     // mov
              localMem[0 + 1391] = heapMem[localMem[0+1389]*10 + localMem[0+1390]];
              ip = 3084;
      end

       3084 :
      begin                                                                     // mov
              heapMem[localMem[0+1391]*10 + 2] = localMem[0+1364];
              ip = 3085;
      end

       3085 :
      begin                                                                     // label
              ip = 3086;
      end

       3086 :
      begin                                                                     // add
              localMem[0 + 1390] = localMem[0+1390] + 1;
              ip = 3087;
      end

       3087 :
      begin                                                                     // jmp
              ip = 3081;
      end

       3088 :
      begin                                                                     // label
              ip = 3089;
      end

       3089 :
      begin                                                                     // mov
              localMem[0 + 1392] = heapMem[localMem[0+1367]*10 + 0];
              ip = 3090;
      end

       3090 :
      begin                                                                     // add
              localMem[0 + 1393] = localMem[0+1392] + 1;
              ip = 3091;
      end

       3091 :
      begin                                                                     // mov
              localMem[0 + 1394] = heapMem[localMem[0+1367]*10 + 6];
              ip = 3092;
      end

       3092 :
      begin                                                                     // label
              ip = 3093;
      end

       3093 :
      begin                                                                     // mov
              localMem[0 + 1395] = 0;
              ip = 3094;
      end

       3094 :
      begin                                                                     // label
              ip = 3095;
      end

       3095 :
      begin                                                                     // jGe
              ip = localMem[0+1395] >= localMem[0+1393] ? 3101 : 3096;
      end

       3096 :
      begin                                                                     // mov
              localMem[0 + 1396] = heapMem[localMem[0+1394]*10 + localMem[0+1395]];
              ip = 3097;
      end

       3097 :
      begin                                                                     // mov
              heapMem[localMem[0+1396]*10 + 2] = localMem[0+1367];
              ip = 3098;
      end

       3098 :
      begin                                                                     // label
              ip = 3099;
      end

       3099 :
      begin                                                                     // add
              localMem[0 + 1395] = localMem[0+1395] + 1;
              ip = 3100;
      end

       3100 :
      begin                                                                     // jmp
              ip = 3094;
      end

       3101 :
      begin                                                                     // label
              ip = 3102;
      end

       3102 :
      begin                                                                     // jmp
              ip = 3118;
      end

       3103 :
      begin                                                                     // label
              ip = 3104;
      end

       3104 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1397] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1397] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1397]] = 0;
              ip = 3105;
      end

       3105 :
      begin                                                                     // mov
              heapMem[localMem[0+1301]*10 + 6] = localMem[0+1397];
              ip = 3106;
      end

       3106 :
      begin                                                                     // mov
              localMem[0 + 1398] = heapMem[localMem[0+1301]*10 + 4];
              ip = 3107;
      end

       3107 :
      begin                                                                     // mov
              localMem[0 + 1399] = heapMem[localMem[0+1364]*10 + 4];
              ip = 3108;
      end

       3108 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1314]) begin
                  heapMem[NArea * localMem[0+1399] + 0 + i] = heapMem[NArea * localMem[0+1398] + 0 + i];
                end
              end
              ip = 3109;
      end

       3109 :
      begin                                                                     // mov
              localMem[0 + 1400] = heapMem[localMem[0+1301]*10 + 5];
              ip = 3110;
      end

       3110 :
      begin                                                                     // mov
              localMem[0 + 1401] = heapMem[localMem[0+1364]*10 + 5];
              ip = 3111;
      end

       3111 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1314]) begin
                  heapMem[NArea * localMem[0+1401] + 0 + i] = heapMem[NArea * localMem[0+1400] + 0 + i];
                end
              end
              ip = 3112;
      end

       3112 :
      begin                                                                     // mov
              localMem[0 + 1402] = heapMem[localMem[0+1301]*10 + 4];
              ip = 3113;
      end

       3113 :
      begin                                                                     // mov
              localMem[0 + 1403] = heapMem[localMem[0+1367]*10 + 4];
              ip = 3114;
      end

       3114 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1314]) begin
                  heapMem[NArea * localMem[0+1403] + 0 + i] = heapMem[NArea * localMem[0+1402] + localMem[1315] + i];
                end
              end
              ip = 3115;
      end

       3115 :
      begin                                                                     // mov
              localMem[0 + 1404] = heapMem[localMem[0+1301]*10 + 5];
              ip = 3116;
      end

       3116 :
      begin                                                                     // mov
              localMem[0 + 1405] = heapMem[localMem[0+1367]*10 + 5];
              ip = 3117;
      end

       3117 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1314]) begin
                  heapMem[NArea * localMem[0+1405] + 0 + i] = heapMem[NArea * localMem[0+1404] + localMem[1315] + i];
                end
              end
              ip = 3118;
      end

       3118 :
      begin                                                                     // label
              ip = 3119;
      end

       3119 :
      begin                                                                     // mov
              heapMem[localMem[0+1364]*10 + 2] = localMem[0+1301];
              ip = 3120;
      end

       3120 :
      begin                                                                     // mov
              heapMem[localMem[0+1367]*10 + 2] = localMem[0+1301];
              ip = 3121;
      end

       3121 :
      begin                                                                     // mov
              localMem[0 + 1406] = heapMem[localMem[0+1301]*10 + 4];
              ip = 3122;
      end

       3122 :
      begin                                                                     // mov
              localMem[0 + 1407] = heapMem[localMem[0+1406]*10 + localMem[0+1314]];
              ip = 3123;
      end

       3123 :
      begin                                                                     // mov
              localMem[0 + 1408] = heapMem[localMem[0+1301]*10 + 5];
              ip = 3124;
      end

       3124 :
      begin                                                                     // mov
              localMem[0 + 1409] = heapMem[localMem[0+1408]*10 + localMem[0+1314]];
              ip = 3125;
      end

       3125 :
      begin                                                                     // mov
              localMem[0 + 1410] = heapMem[localMem[0+1301]*10 + 4];
              ip = 3126;
      end

       3126 :
      begin                                                                     // mov
              heapMem[localMem[0+1410]*10 + 0] = localMem[0+1407];
              ip = 3127;
      end

       3127 :
      begin                                                                     // mov
              localMem[0 + 1411] = heapMem[localMem[0+1301]*10 + 5];
              ip = 3128;
      end

       3128 :
      begin                                                                     // mov
              heapMem[localMem[0+1411]*10 + 0] = localMem[0+1409];
              ip = 3129;
      end

       3129 :
      begin                                                                     // mov
              localMem[0 + 1412] = heapMem[localMem[0+1301]*10 + 6];
              ip = 3130;
      end

       3130 :
      begin                                                                     // mov
              heapMem[localMem[0+1412]*10 + 0] = localMem[0+1364];
              ip = 3131;
      end

       3131 :
      begin                                                                     // mov
              localMem[0 + 1413] = heapMem[localMem[0+1301]*10 + 6];
              ip = 3132;
      end

       3132 :
      begin                                                                     // mov
              heapMem[localMem[0+1413]*10 + 1] = localMem[0+1367];
              ip = 3133;
      end

       3133 :
      begin                                                                     // mov
              heapMem[localMem[0+1301]*10 + 0] = 1;
              ip = 3134;
      end

       3134 :
      begin                                                                     // mov
              localMem[0 + 1414] = heapMem[localMem[0+1301]*10 + 4];
              ip = 3135;
      end

       3135 :
      begin                                                                     // resize
              arraySizes[localMem[0+1414]] = 1;
              ip = 3136;
      end

       3136 :
      begin                                                                     // mov
              localMem[0 + 1415] = heapMem[localMem[0+1301]*10 + 5];
              ip = 3137;
      end

       3137 :
      begin                                                                     // resize
              arraySizes[localMem[0+1415]] = 1;
              ip = 3138;
      end

       3138 :
      begin                                                                     // mov
              localMem[0 + 1416] = heapMem[localMem[0+1301]*10 + 6];
              ip = 3139;
      end

       3139 :
      begin                                                                     // resize
              arraySizes[localMem[0+1416]] = 2;
              ip = 3140;
      end

       3140 :
      begin                                                                     // jmp
              ip = 3142;
      end

       3141 :
      begin                                                                     // jmp
              ip = 3147;
      end

       3142 :
      begin                                                                     // label
              ip = 3143;
      end

       3143 :
      begin                                                                     // mov
              localMem[0 + 1310] = 1;
              ip = 3144;
      end

       3144 :
      begin                                                                     // jmp
              ip = 3147;
      end

       3145 :
      begin                                                                     // label
              ip = 3146;
      end

       3146 :
      begin                                                                     // mov
              localMem[0 + 1310] = 0;
              ip = 3147;
      end

       3147 :
      begin                                                                     // label
              ip = 3148;
      end

       3148 :
      begin                                                                     // label
              ip = 3149;
      end

       3149 :
      begin                                                                     // label
              ip = 3150;
      end

       3150 :
      begin                                                                     // label
              ip = 3151;
      end

       3151 :
      begin                                                                     // free
              freedArrays[freedArraysTop] = localMem[0+945];
              freedArraysTop = freedArraysTop + 1;
              ip = 3152;
      end

       3152 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1417] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1417] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1417]] = 0;
              ip = 3153;
      end

       3153 :
      begin                                                                     // label
              ip = 3154;
      end

       3154 :
      begin                                                                     // mov
              localMem[0 + 1418] = heapMem[localMem[0+0]*10 + 3];
              ip = 3155;
      end

       3155 :
      begin                                                                     // jNe
              ip = localMem[0+1418] != 0 ? 3174 : 3156;
      end

       3156 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1419] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1419] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1419]] = 0;
              ip = 3157;
      end

       3157 :
      begin                                                                     // mov
              heapMem[localMem[0+1419]*10 + 0] = 1;
              ip = 3158;
      end

       3158 :
      begin                                                                     // mov
              heapMem[localMem[0+1419]*10 + 2] = 0;
              ip = 3159;
      end

       3159 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1420] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1420] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1420]] = 0;
              ip = 3160;
      end

       3160 :
      begin                                                                     // mov
              heapMem[localMem[0+1419]*10 + 4] = localMem[0+1420];
              ip = 3161;
      end

       3161 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1421] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1421] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1421]] = 0;
              ip = 3162;
      end

       3162 :
      begin                                                                     // mov
              heapMem[localMem[0+1419]*10 + 5] = localMem[0+1421];
              ip = 3163;
      end

       3163 :
      begin                                                                     // mov
              heapMem[localMem[0+1419]*10 + 6] = 0;
              ip = 3164;
      end

       3164 :
      begin                                                                     // mov
              heapMem[localMem[0+1419]*10 + 3] = localMem[0+0];
              ip = 3165;
      end

       3165 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 1] = heapMem[localMem[0+0]*10 + 1] + 1;
              ip = 3166;
      end

       3166 :
      begin                                                                     // mov
              heapMem[localMem[0+1419]*10 + 1] = heapMem[localMem[0+0]*10 + 1];
              ip = 3167;
      end

       3167 :
      begin                                                                     // mov
              localMem[0 + 1422] = heapMem[localMem[0+1419]*10 + 4];
              ip = 3168;
      end

       3168 :
      begin                                                                     // mov
              heapMem[localMem[0+1422]*10 + 0] = 4;
              ip = 3169;
      end

       3169 :
      begin                                                                     // mov
              localMem[0 + 1423] = heapMem[localMem[0+1419]*10 + 5];
              ip = 3170;
      end

       3170 :
      begin                                                                     // mov
              heapMem[localMem[0+1423]*10 + 0] = 44;
              ip = 3171;
      end

       3171 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 3172;
      end

       3172 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 3] = localMem[0+1419];
              ip = 3173;
      end

       3173 :
      begin                                                                     // jmp
              ip = 4199;
      end

       3174 :
      begin                                                                     // label
              ip = 3175;
      end

       3175 :
      begin                                                                     // mov
              localMem[0 + 1424] = heapMem[localMem[0+1418]*10 + 0];
              ip = 3176;
      end

       3176 :
      begin                                                                     // mov
              localMem[0 + 1425] = heapMem[localMem[0+0]*10 + 2];
              ip = 3177;
      end

       3177 :
      begin                                                                     // jGe
              ip = localMem[0+1424] >= localMem[0+1425] ? 3210 : 3178;
      end

       3178 :
      begin                                                                     // mov
              localMem[0 + 1426] = heapMem[localMem[0+1418]*10 + 2];
              ip = 3179;
      end

       3179 :
      begin                                                                     // jNe
              ip = localMem[0+1426] != 0 ? 3209 : 3180;
      end

       3180 :
      begin                                                                     // not
              localMem[0 + 1427] = !heapMem[localMem[0+1418]*10 + 6];
              ip = 3181;
      end

       3181 :
      begin                                                                     // jEq
              ip = localMem[0+1427] == 0 ? 3208 : 3182;
      end

       3182 :
      begin                                                                     // mov
              localMem[0 + 1428] = heapMem[localMem[0+1418]*10 + 4];
              ip = 3183;
      end

       3183 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+1428] * NArea + i] == 4) localMem[0 + 1429] = i + 1;
              end
              ip = 3184;
      end

       3184 :
      begin                                                                     // jEq
              ip = localMem[0+1429] == 0 ? 3189 : 3185;
      end

       3185 :
      begin                                                                     // subtract
              localMem[0 + 1429] = localMem[0+1429] - 1;
              ip = 3186;
      end

       3186 :
      begin                                                                     // mov
              localMem[0 + 1430] = heapMem[localMem[0+1418]*10 + 5];
              ip = 3187;
      end

       3187 :
      begin                                                                     // mov
              heapMem[localMem[0+1430]*10 + localMem[0+1429]] = 44;
              ip = 3188;
      end

       3188 :
      begin                                                                     // jmp
              ip = 4199;
      end

       3189 :
      begin                                                                     // label
              ip = 3190;
      end

       3190 :
      begin                                                                     // arrayCountGreater
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+1428] * NArea + i] > 4) j = j + 1;
              end
              localMem[0 + 1431] = j;
              ip = 3191;
      end

       3191 :
      begin                                                                     // jNe
              ip = localMem[0+1431] != 0 ? 3199 : 3192;
      end

       3192 :
      begin                                                                     // mov
              localMem[0 + 1432] = heapMem[localMem[0+1418]*10 + 4];
              ip = 3193;
      end

       3193 :
      begin                                                                     // mov
              heapMem[localMem[0+1432]*10 + localMem[0+1424]] = 4;
              ip = 3194;
      end

       3194 :
      begin                                                                     // mov
              localMem[0 + 1433] = heapMem[localMem[0+1418]*10 + 5];
              ip = 3195;
      end

       3195 :
      begin                                                                     // mov
              heapMem[localMem[0+1433]*10 + localMem[0+1424]] = 44;
              ip = 3196;
      end

       3196 :
      begin                                                                     // add
              heapMem[localMem[0+1418]*10 + 0] = localMem[0+1424] + 1;
              ip = 3197;
      end

       3197 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 3198;
      end

       3198 :
      begin                                                                     // jmp
              ip = 4199;
      end

       3199 :
      begin                                                                     // label
              ip = 3200;
      end

       3200 :
      begin                                                                     // arrayCountLess
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+1428] * NArea + i] < 4) j = j + 1;
              end
              localMem[0 + 1434] = j;
              ip = 3201;
      end

       3201 :
      begin                                                                     // mov
              localMem[0 + 1435] = heapMem[localMem[0+1418]*10 + 4];
              ip = 3202;
      end

       3202 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1435] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1434]) begin
                  heapMem[NArea * localMem[0+1435] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1435] + localMem[1434]] = 4;                                    // Insert new value
              arraySizes[localMem[0+1435]] = arraySizes[localMem[0+1435]] + 1;                              // Increase array size
              ip = 3203;
      end

       3203 :
      begin                                                                     // mov
              localMem[0 + 1436] = heapMem[localMem[0+1418]*10 + 5];
              ip = 3204;
      end

       3204 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1436] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1434]) begin
                  heapMem[NArea * localMem[0+1436] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1436] + localMem[1434]] = 44;                                    // Insert new value
              arraySizes[localMem[0+1436]] = arraySizes[localMem[0+1436]] + 1;                              // Increase array size
              ip = 3205;
      end

       3205 :
      begin                                                                     // add
              heapMem[localMem[0+1418]*10 + 0] = heapMem[localMem[0+1418]*10 + 0] + 1;
              ip = 3206;
      end

       3206 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 3207;
      end

       3207 :
      begin                                                                     // jmp
              ip = 4199;
      end

       3208 :
      begin                                                                     // label
              ip = 3209;
      end

       3209 :
      begin                                                                     // label
              ip = 3210;
      end

       3210 :
      begin                                                                     // label
              ip = 3211;
      end

       3211 :
      begin                                                                     // mov
              localMem[0 + 1437] = heapMem[localMem[0+0]*10 + 3];
              ip = 3212;
      end

       3212 :
      begin                                                                     // label
              ip = 3213;
      end

       3213 :
      begin                                                                     // mov
              localMem[0 + 1439] = heapMem[localMem[0+1437]*10 + 0];
              ip = 3214;
      end

       3214 :
      begin                                                                     // mov
              localMem[0 + 1440] = heapMem[localMem[0+1437]*10 + 3];
              ip = 3215;
      end

       3215 :
      begin                                                                     // mov
              localMem[0 + 1441] = heapMem[localMem[0+1440]*10 + 2];
              ip = 3216;
      end

       3216 :
      begin                                                                     // jLt
              ip = localMem[0+1439] <  localMem[0+1441] ? 3436 : 3217;
      end

       3217 :
      begin                                                                     // mov
              localMem[0 + 1442] = localMem[0+1441];
              ip = 3218;
      end

       3218 :
      begin                                                                     // shiftRight
              localMem[0 + 1442] = localMem[0+1442] >> 1;
              ip = 3219;
      end

       3219 :
      begin                                                                     // add
              localMem[0 + 1443] = localMem[0+1442] + 1;
              ip = 3220;
      end

       3220 :
      begin                                                                     // mov
              localMem[0 + 1444] = heapMem[localMem[0+1437]*10 + 2];
              ip = 3221;
      end

       3221 :
      begin                                                                     // jEq
              ip = localMem[0+1444] == 0 ? 3318 : 3222;
      end

       3222 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1445] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1445] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1445]] = 0;
              ip = 3223;
      end

       3223 :
      begin                                                                     // mov
              heapMem[localMem[0+1445]*10 + 0] = localMem[0+1442];
              ip = 3224;
      end

       3224 :
      begin                                                                     // mov
              heapMem[localMem[0+1445]*10 + 2] = 0;
              ip = 3225;
      end

       3225 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1446] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1446] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1446]] = 0;
              ip = 3226;
      end

       3226 :
      begin                                                                     // mov
              heapMem[localMem[0+1445]*10 + 4] = localMem[0+1446];
              ip = 3227;
      end

       3227 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1447] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1447] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1447]] = 0;
              ip = 3228;
      end

       3228 :
      begin                                                                     // mov
              heapMem[localMem[0+1445]*10 + 5] = localMem[0+1447];
              ip = 3229;
      end

       3229 :
      begin                                                                     // mov
              heapMem[localMem[0+1445]*10 + 6] = 0;
              ip = 3230;
      end

       3230 :
      begin                                                                     // mov
              heapMem[localMem[0+1445]*10 + 3] = localMem[0+1440];
              ip = 3231;
      end

       3231 :
      begin                                                                     // add
              heapMem[localMem[0+1440]*10 + 1] = heapMem[localMem[0+1440]*10 + 1] + 1;
              ip = 3232;
      end

       3232 :
      begin                                                                     // mov
              heapMem[localMem[0+1445]*10 + 1] = heapMem[localMem[0+1440]*10 + 1];
              ip = 3233;
      end

       3233 :
      begin                                                                     // not
              localMem[0 + 1448] = !heapMem[localMem[0+1437]*10 + 6];
              ip = 3234;
      end

       3234 :
      begin                                                                     // jNe
              ip = localMem[0+1448] != 0 ? 3263 : 3235;
      end

       3235 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1449] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1449] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1449]] = 0;
              ip = 3236;
      end

       3236 :
      begin                                                                     // mov
              heapMem[localMem[0+1445]*10 + 6] = localMem[0+1449];
              ip = 3237;
      end

       3237 :
      begin                                                                     // mov
              localMem[0 + 1450] = heapMem[localMem[0+1437]*10 + 4];
              ip = 3238;
      end

       3238 :
      begin                                                                     // mov
              localMem[0 + 1451] = heapMem[localMem[0+1445]*10 + 4];
              ip = 3239;
      end

       3239 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1442]) begin
                  heapMem[NArea * localMem[0+1451] + 0 + i] = heapMem[NArea * localMem[0+1450] + localMem[1443] + i];
                end
              end
              ip = 3240;
      end

       3240 :
      begin                                                                     // mov
              localMem[0 + 1452] = heapMem[localMem[0+1437]*10 + 5];
              ip = 3241;
      end

       3241 :
      begin                                                                     // mov
              localMem[0 + 1453] = heapMem[localMem[0+1445]*10 + 5];
              ip = 3242;
      end

       3242 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1442]) begin
                  heapMem[NArea * localMem[0+1453] + 0 + i] = heapMem[NArea * localMem[0+1452] + localMem[1443] + i];
                end
              end
              ip = 3243;
      end

       3243 :
      begin                                                                     // mov
              localMem[0 + 1454] = heapMem[localMem[0+1437]*10 + 6];
              ip = 3244;
      end

       3244 :
      begin                                                                     // mov
              localMem[0 + 1455] = heapMem[localMem[0+1445]*10 + 6];
              ip = 3245;
      end

       3245 :
      begin                                                                     // add
              localMem[0 + 1456] = localMem[0+1442] + 1;
              ip = 3246;
      end

       3246 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1456]) begin
                  heapMem[NArea * localMem[0+1455] + 0 + i] = heapMem[NArea * localMem[0+1454] + localMem[1443] + i];
                end
              end
              ip = 3247;
      end

       3247 :
      begin                                                                     // mov
              localMem[0 + 1457] = heapMem[localMem[0+1445]*10 + 0];
              ip = 3248;
      end

       3248 :
      begin                                                                     // add
              localMem[0 + 1458] = localMem[0+1457] + 1;
              ip = 3249;
      end

       3249 :
      begin                                                                     // mov
              localMem[0 + 1459] = heapMem[localMem[0+1445]*10 + 6];
              ip = 3250;
      end

       3250 :
      begin                                                                     // label
              ip = 3251;
      end

       3251 :
      begin                                                                     // mov
              localMem[0 + 1460] = 0;
              ip = 3252;
      end

       3252 :
      begin                                                                     // label
              ip = 3253;
      end

       3253 :
      begin                                                                     // jGe
              ip = localMem[0+1460] >= localMem[0+1458] ? 3259 : 3254;
      end

       3254 :
      begin                                                                     // mov
              localMem[0 + 1461] = heapMem[localMem[0+1459]*10 + localMem[0+1460]];
              ip = 3255;
      end

       3255 :
      begin                                                                     // mov
              heapMem[localMem[0+1461]*10 + 2] = localMem[0+1445];
              ip = 3256;
      end

       3256 :
      begin                                                                     // label
              ip = 3257;
      end

       3257 :
      begin                                                                     // add
              localMem[0 + 1460] = localMem[0+1460] + 1;
              ip = 3258;
      end

       3258 :
      begin                                                                     // jmp
              ip = 3252;
      end

       3259 :
      begin                                                                     // label
              ip = 3260;
      end

       3260 :
      begin                                                                     // mov
              localMem[0 + 1462] = heapMem[localMem[0+1437]*10 + 6];
              ip = 3261;
      end

       3261 :
      begin                                                                     // resize
              arraySizes[localMem[0+1462]] = localMem[0+1443];
              ip = 3262;
      end

       3262 :
      begin                                                                     // jmp
              ip = 3270;
      end

       3263 :
      begin                                                                     // label
              ip = 3264;
      end

       3264 :
      begin                                                                     // mov
              localMem[0 + 1463] = heapMem[localMem[0+1437]*10 + 4];
              ip = 3265;
      end

       3265 :
      begin                                                                     // mov
              localMem[0 + 1464] = heapMem[localMem[0+1445]*10 + 4];
              ip = 3266;
      end

       3266 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1442]) begin
                  heapMem[NArea * localMem[0+1464] + 0 + i] = heapMem[NArea * localMem[0+1463] + localMem[1443] + i];
                end
              end
              ip = 3267;
      end

       3267 :
      begin                                                                     // mov
              localMem[0 + 1465] = heapMem[localMem[0+1437]*10 + 5];
              ip = 3268;
      end

       3268 :
      begin                                                                     // mov
              localMem[0 + 1466] = heapMem[localMem[0+1445]*10 + 5];
              ip = 3269;
      end

       3269 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1442]) begin
                  heapMem[NArea * localMem[0+1466] + 0 + i] = heapMem[NArea * localMem[0+1465] + localMem[1443] + i];
                end
              end
              ip = 3270;
      end

       3270 :
      begin                                                                     // label
              ip = 3271;
      end

       3271 :
      begin                                                                     // mov
              heapMem[localMem[0+1437]*10 + 0] = localMem[0+1442];
              ip = 3272;
      end

       3272 :
      begin                                                                     // mov
              heapMem[localMem[0+1445]*10 + 2] = localMem[0+1444];
              ip = 3273;
      end

       3273 :
      begin                                                                     // mov
              localMem[0 + 1467] = heapMem[localMem[0+1444]*10 + 0];
              ip = 3274;
      end

       3274 :
      begin                                                                     // mov
              localMem[0 + 1468] = heapMem[localMem[0+1444]*10 + 6];
              ip = 3275;
      end

       3275 :
      begin                                                                     // mov
              localMem[0 + 1469] = heapMem[localMem[0+1468]*10 + localMem[0+1467]];
              ip = 3276;
      end

       3276 :
      begin                                                                     // jNe
              ip = localMem[0+1469] != localMem[0+1437] ? 3295 : 3277;
      end

       3277 :
      begin                                                                     // mov
              localMem[0 + 1470] = heapMem[localMem[0+1437]*10 + 4];
              ip = 3278;
      end

       3278 :
      begin                                                                     // mov
              localMem[0 + 1471] = heapMem[localMem[0+1470]*10 + localMem[0+1442]];
              ip = 3279;
      end

       3279 :
      begin                                                                     // mov
              localMem[0 + 1472] = heapMem[localMem[0+1444]*10 + 4];
              ip = 3280;
      end

       3280 :
      begin                                                                     // mov
              heapMem[localMem[0+1472]*10 + localMem[0+1467]] = localMem[0+1471];
              ip = 3281;
      end

       3281 :
      begin                                                                     // mov
              localMem[0 + 1473] = heapMem[localMem[0+1437]*10 + 5];
              ip = 3282;
      end

       3282 :
      begin                                                                     // mov
              localMem[0 + 1474] = heapMem[localMem[0+1473]*10 + localMem[0+1442]];
              ip = 3283;
      end

       3283 :
      begin                                                                     // mov
              localMem[0 + 1475] = heapMem[localMem[0+1444]*10 + 5];
              ip = 3284;
      end

       3284 :
      begin                                                                     // mov
              heapMem[localMem[0+1475]*10 + localMem[0+1467]] = localMem[0+1474];
              ip = 3285;
      end

       3285 :
      begin                                                                     // mov
              localMem[0 + 1476] = heapMem[localMem[0+1437]*10 + 4];
              ip = 3286;
      end

       3286 :
      begin                                                                     // resize
              arraySizes[localMem[0+1476]] = localMem[0+1442];
              ip = 3287;
      end

       3287 :
      begin                                                                     // mov
              localMem[0 + 1477] = heapMem[localMem[0+1437]*10 + 5];
              ip = 3288;
      end

       3288 :
      begin                                                                     // resize
              arraySizes[localMem[0+1477]] = localMem[0+1442];
              ip = 3289;
      end

       3289 :
      begin                                                                     // add
              localMem[0 + 1478] = localMem[0+1467] + 1;
              ip = 3290;
      end

       3290 :
      begin                                                                     // mov
              heapMem[localMem[0+1444]*10 + 0] = localMem[0+1478];
              ip = 3291;
      end

       3291 :
      begin                                                                     // mov
              localMem[0 + 1479] = heapMem[localMem[0+1444]*10 + 6];
              ip = 3292;
      end

       3292 :
      begin                                                                     // mov
              heapMem[localMem[0+1479]*10 + localMem[0+1478]] = localMem[0+1445];
              ip = 3293;
      end

       3293 :
      begin                                                                     // jmp
              ip = 3433;
      end

       3294 :
      begin                                                                     // jmp
              ip = 3317;
      end

       3295 :
      begin                                                                     // label
              ip = 3296;
      end

       3296 :
      begin                                                                     // assertNe
            ip = 3297;
      end

       3297 :
      begin                                                                     // mov
              localMem[0 + 1480] = heapMem[localMem[0+1444]*10 + 6];
              ip = 3298;
      end

       3298 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+1480] * NArea + i] == localMem[0+1437]) localMem[0 + 1481] = i + 1;
              end
              ip = 3299;
      end

       3299 :
      begin                                                                     // subtract
              localMem[0 + 1481] = localMem[0+1481] - 1;
              ip = 3300;
      end

       3300 :
      begin                                                                     // mov
              localMem[0 + 1482] = heapMem[localMem[0+1437]*10 + 4];
              ip = 3301;
      end

       3301 :
      begin                                                                     // mov
              localMem[0 + 1483] = heapMem[localMem[0+1482]*10 + localMem[0+1442]];
              ip = 3302;
      end

       3302 :
      begin                                                                     // mov
              localMem[0 + 1484] = heapMem[localMem[0+1437]*10 + 5];
              ip = 3303;
      end

       3303 :
      begin                                                                     // mov
              localMem[0 + 1485] = heapMem[localMem[0+1484]*10 + localMem[0+1442]];
              ip = 3304;
      end

       3304 :
      begin                                                                     // mov
              localMem[0 + 1486] = heapMem[localMem[0+1437]*10 + 4];
              ip = 3305;
      end

       3305 :
      begin                                                                     // resize
              arraySizes[localMem[0+1486]] = localMem[0+1442];
              ip = 3306;
      end

       3306 :
      begin                                                                     // mov
              localMem[0 + 1487] = heapMem[localMem[0+1437]*10 + 5];
              ip = 3307;
      end

       3307 :
      begin                                                                     // resize
              arraySizes[localMem[0+1487]] = localMem[0+1442];
              ip = 3308;
      end

       3308 :
      begin                                                                     // mov
              localMem[0 + 1488] = heapMem[localMem[0+1444]*10 + 4];
              ip = 3309;
      end

       3309 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1488] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1481]) begin
                  heapMem[NArea * localMem[0+1488] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1488] + localMem[1481]] = localMem[0+1483];                                    // Insert new value
              arraySizes[localMem[0+1488]] = arraySizes[localMem[0+1488]] + 1;                              // Increase array size
              ip = 3310;
      end

       3310 :
      begin                                                                     // mov
              localMem[0 + 1489] = heapMem[localMem[0+1444]*10 + 5];
              ip = 3311;
      end

       3311 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1489] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1481]) begin
                  heapMem[NArea * localMem[0+1489] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1489] + localMem[1481]] = localMem[0+1485];                                    // Insert new value
              arraySizes[localMem[0+1489]] = arraySizes[localMem[0+1489]] + 1;                              // Increase array size
              ip = 3312;
      end

       3312 :
      begin                                                                     // mov
              localMem[0 + 1490] = heapMem[localMem[0+1444]*10 + 6];
              ip = 3313;
      end

       3313 :
      begin                                                                     // add
              localMem[0 + 1491] = localMem[0+1481] + 1;
              ip = 3314;
      end

       3314 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1490] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1491]) begin
                  heapMem[NArea * localMem[0+1490] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1490] + localMem[1491]] = localMem[0+1445];                                    // Insert new value
              arraySizes[localMem[0+1490]] = arraySizes[localMem[0+1490]] + 1;                              // Increase array size
              ip = 3315;
      end

       3315 :
      begin                                                                     // add
              heapMem[localMem[0+1444]*10 + 0] = heapMem[localMem[0+1444]*10 + 0] + 1;
              ip = 3316;
      end

       3316 :
      begin                                                                     // jmp
              ip = 3433;
      end

       3317 :
      begin                                                                     // label
              ip = 3318;
      end

       3318 :
      begin                                                                     // label
              ip = 3319;
      end

       3319 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1492] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1492] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1492]] = 0;
              ip = 3320;
      end

       3320 :
      begin                                                                     // mov
              heapMem[localMem[0+1492]*10 + 0] = localMem[0+1442];
              ip = 3321;
      end

       3321 :
      begin                                                                     // mov
              heapMem[localMem[0+1492]*10 + 2] = 0;
              ip = 3322;
      end

       3322 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1493] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1493] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1493]] = 0;
              ip = 3323;
      end

       3323 :
      begin                                                                     // mov
              heapMem[localMem[0+1492]*10 + 4] = localMem[0+1493];
              ip = 3324;
      end

       3324 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1494] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1494] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1494]] = 0;
              ip = 3325;
      end

       3325 :
      begin                                                                     // mov
              heapMem[localMem[0+1492]*10 + 5] = localMem[0+1494];
              ip = 3326;
      end

       3326 :
      begin                                                                     // mov
              heapMem[localMem[0+1492]*10 + 6] = 0;
              ip = 3327;
      end

       3327 :
      begin                                                                     // mov
              heapMem[localMem[0+1492]*10 + 3] = localMem[0+1440];
              ip = 3328;
      end

       3328 :
      begin                                                                     // add
              heapMem[localMem[0+1440]*10 + 1] = heapMem[localMem[0+1440]*10 + 1] + 1;
              ip = 3329;
      end

       3329 :
      begin                                                                     // mov
              heapMem[localMem[0+1492]*10 + 1] = heapMem[localMem[0+1440]*10 + 1];
              ip = 3330;
      end

       3330 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1495] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1495] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1495]] = 0;
              ip = 3331;
      end

       3331 :
      begin                                                                     // mov
              heapMem[localMem[0+1495]*10 + 0] = localMem[0+1442];
              ip = 3332;
      end

       3332 :
      begin                                                                     // mov
              heapMem[localMem[0+1495]*10 + 2] = 0;
              ip = 3333;
      end

       3333 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1496] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1496] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1496]] = 0;
              ip = 3334;
      end

       3334 :
      begin                                                                     // mov
              heapMem[localMem[0+1495]*10 + 4] = localMem[0+1496];
              ip = 3335;
      end

       3335 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1497] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1497] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1497]] = 0;
              ip = 3336;
      end

       3336 :
      begin                                                                     // mov
              heapMem[localMem[0+1495]*10 + 5] = localMem[0+1497];
              ip = 3337;
      end

       3337 :
      begin                                                                     // mov
              heapMem[localMem[0+1495]*10 + 6] = 0;
              ip = 3338;
      end

       3338 :
      begin                                                                     // mov
              heapMem[localMem[0+1495]*10 + 3] = localMem[0+1440];
              ip = 3339;
      end

       3339 :
      begin                                                                     // add
              heapMem[localMem[0+1440]*10 + 1] = heapMem[localMem[0+1440]*10 + 1] + 1;
              ip = 3340;
      end

       3340 :
      begin                                                                     // mov
              heapMem[localMem[0+1495]*10 + 1] = heapMem[localMem[0+1440]*10 + 1];
              ip = 3341;
      end

       3341 :
      begin                                                                     // not
              localMem[0 + 1498] = !heapMem[localMem[0+1437]*10 + 6];
              ip = 3342;
      end

       3342 :
      begin                                                                     // jNe
              ip = localMem[0+1498] != 0 ? 3394 : 3343;
      end

       3343 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1499] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1499] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1499]] = 0;
              ip = 3344;
      end

       3344 :
      begin                                                                     // mov
              heapMem[localMem[0+1492]*10 + 6] = localMem[0+1499];
              ip = 3345;
      end

       3345 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1500] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1500] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1500]] = 0;
              ip = 3346;
      end

       3346 :
      begin                                                                     // mov
              heapMem[localMem[0+1495]*10 + 6] = localMem[0+1500];
              ip = 3347;
      end

       3347 :
      begin                                                                     // mov
              localMem[0 + 1501] = heapMem[localMem[0+1437]*10 + 4];
              ip = 3348;
      end

       3348 :
      begin                                                                     // mov
              localMem[0 + 1502] = heapMem[localMem[0+1492]*10 + 4];
              ip = 3349;
      end

       3349 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1442]) begin
                  heapMem[NArea * localMem[0+1502] + 0 + i] = heapMem[NArea * localMem[0+1501] + 0 + i];
                end
              end
              ip = 3350;
      end

       3350 :
      begin                                                                     // mov
              localMem[0 + 1503] = heapMem[localMem[0+1437]*10 + 5];
              ip = 3351;
      end

       3351 :
      begin                                                                     // mov
              localMem[0 + 1504] = heapMem[localMem[0+1492]*10 + 5];
              ip = 3352;
      end

       3352 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1442]) begin
                  heapMem[NArea * localMem[0+1504] + 0 + i] = heapMem[NArea * localMem[0+1503] + 0 + i];
                end
              end
              ip = 3353;
      end

       3353 :
      begin                                                                     // mov
              localMem[0 + 1505] = heapMem[localMem[0+1437]*10 + 6];
              ip = 3354;
      end

       3354 :
      begin                                                                     // mov
              localMem[0 + 1506] = heapMem[localMem[0+1492]*10 + 6];
              ip = 3355;
      end

       3355 :
      begin                                                                     // add
              localMem[0 + 1507] = localMem[0+1442] + 1;
              ip = 3356;
      end

       3356 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1507]) begin
                  heapMem[NArea * localMem[0+1506] + 0 + i] = heapMem[NArea * localMem[0+1505] + 0 + i];
                end
              end
              ip = 3357;
      end

       3357 :
      begin                                                                     // mov
              localMem[0 + 1508] = heapMem[localMem[0+1437]*10 + 4];
              ip = 3358;
      end

       3358 :
      begin                                                                     // mov
              localMem[0 + 1509] = heapMem[localMem[0+1495]*10 + 4];
              ip = 3359;
      end

       3359 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1442]) begin
                  heapMem[NArea * localMem[0+1509] + 0 + i] = heapMem[NArea * localMem[0+1508] + localMem[1443] + i];
                end
              end
              ip = 3360;
      end

       3360 :
      begin                                                                     // mov
              localMem[0 + 1510] = heapMem[localMem[0+1437]*10 + 5];
              ip = 3361;
      end

       3361 :
      begin                                                                     // mov
              localMem[0 + 1511] = heapMem[localMem[0+1495]*10 + 5];
              ip = 3362;
      end

       3362 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1442]) begin
                  heapMem[NArea * localMem[0+1511] + 0 + i] = heapMem[NArea * localMem[0+1510] + localMem[1443] + i];
                end
              end
              ip = 3363;
      end

       3363 :
      begin                                                                     // mov
              localMem[0 + 1512] = heapMem[localMem[0+1437]*10 + 6];
              ip = 3364;
      end

       3364 :
      begin                                                                     // mov
              localMem[0 + 1513] = heapMem[localMem[0+1495]*10 + 6];
              ip = 3365;
      end

       3365 :
      begin                                                                     // add
              localMem[0 + 1514] = localMem[0+1442] + 1;
              ip = 3366;
      end

       3366 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1514]) begin
                  heapMem[NArea * localMem[0+1513] + 0 + i] = heapMem[NArea * localMem[0+1512] + localMem[1443] + i];
                end
              end
              ip = 3367;
      end

       3367 :
      begin                                                                     // mov
              localMem[0 + 1515] = heapMem[localMem[0+1492]*10 + 0];
              ip = 3368;
      end

       3368 :
      begin                                                                     // add
              localMem[0 + 1516] = localMem[0+1515] + 1;
              ip = 3369;
      end

       3369 :
      begin                                                                     // mov
              localMem[0 + 1517] = heapMem[localMem[0+1492]*10 + 6];
              ip = 3370;
      end

       3370 :
      begin                                                                     // label
              ip = 3371;
      end

       3371 :
      begin                                                                     // mov
              localMem[0 + 1518] = 0;
              ip = 3372;
      end

       3372 :
      begin                                                                     // label
              ip = 3373;
      end

       3373 :
      begin                                                                     // jGe
              ip = localMem[0+1518] >= localMem[0+1516] ? 3379 : 3374;
      end

       3374 :
      begin                                                                     // mov
              localMem[0 + 1519] = heapMem[localMem[0+1517]*10 + localMem[0+1518]];
              ip = 3375;
      end

       3375 :
      begin                                                                     // mov
              heapMem[localMem[0+1519]*10 + 2] = localMem[0+1492];
              ip = 3376;
      end

       3376 :
      begin                                                                     // label
              ip = 3377;
      end

       3377 :
      begin                                                                     // add
              localMem[0 + 1518] = localMem[0+1518] + 1;
              ip = 3378;
      end

       3378 :
      begin                                                                     // jmp
              ip = 3372;
      end

       3379 :
      begin                                                                     // label
              ip = 3380;
      end

       3380 :
      begin                                                                     // mov
              localMem[0 + 1520] = heapMem[localMem[0+1495]*10 + 0];
              ip = 3381;
      end

       3381 :
      begin                                                                     // add
              localMem[0 + 1521] = localMem[0+1520] + 1;
              ip = 3382;
      end

       3382 :
      begin                                                                     // mov
              localMem[0 + 1522] = heapMem[localMem[0+1495]*10 + 6];
              ip = 3383;
      end

       3383 :
      begin                                                                     // label
              ip = 3384;
      end

       3384 :
      begin                                                                     // mov
              localMem[0 + 1523] = 0;
              ip = 3385;
      end

       3385 :
      begin                                                                     // label
              ip = 3386;
      end

       3386 :
      begin                                                                     // jGe
              ip = localMem[0+1523] >= localMem[0+1521] ? 3392 : 3387;
      end

       3387 :
      begin                                                                     // mov
              localMem[0 + 1524] = heapMem[localMem[0+1522]*10 + localMem[0+1523]];
              ip = 3388;
      end

       3388 :
      begin                                                                     // mov
              heapMem[localMem[0+1524]*10 + 2] = localMem[0+1495];
              ip = 3389;
      end

       3389 :
      begin                                                                     // label
              ip = 3390;
      end

       3390 :
      begin                                                                     // add
              localMem[0 + 1523] = localMem[0+1523] + 1;
              ip = 3391;
      end

       3391 :
      begin                                                                     // jmp
              ip = 3385;
      end

       3392 :
      begin                                                                     // label
              ip = 3393;
      end

       3393 :
      begin                                                                     // jmp
              ip = 3409;
      end

       3394 :
      begin                                                                     // label
              ip = 3395;
      end

       3395 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1525] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1525] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1525]] = 0;
              ip = 3396;
      end

       3396 :
      begin                                                                     // mov
              heapMem[localMem[0+1437]*10 + 6] = localMem[0+1525];
              ip = 3397;
      end

       3397 :
      begin                                                                     // mov
              localMem[0 + 1526] = heapMem[localMem[0+1437]*10 + 4];
              ip = 3398;
      end

       3398 :
      begin                                                                     // mov
              localMem[0 + 1527] = heapMem[localMem[0+1492]*10 + 4];
              ip = 3399;
      end

       3399 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1442]) begin
                  heapMem[NArea * localMem[0+1527] + 0 + i] = heapMem[NArea * localMem[0+1526] + 0 + i];
                end
              end
              ip = 3400;
      end

       3400 :
      begin                                                                     // mov
              localMem[0 + 1528] = heapMem[localMem[0+1437]*10 + 5];
              ip = 3401;
      end

       3401 :
      begin                                                                     // mov
              localMem[0 + 1529] = heapMem[localMem[0+1492]*10 + 5];
              ip = 3402;
      end

       3402 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1442]) begin
                  heapMem[NArea * localMem[0+1529] + 0 + i] = heapMem[NArea * localMem[0+1528] + 0 + i];
                end
              end
              ip = 3403;
      end

       3403 :
      begin                                                                     // mov
              localMem[0 + 1530] = heapMem[localMem[0+1437]*10 + 4];
              ip = 3404;
      end

       3404 :
      begin                                                                     // mov
              localMem[0 + 1531] = heapMem[localMem[0+1495]*10 + 4];
              ip = 3405;
      end

       3405 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1442]) begin
                  heapMem[NArea * localMem[0+1531] + 0 + i] = heapMem[NArea * localMem[0+1530] + localMem[1443] + i];
                end
              end
              ip = 3406;
      end

       3406 :
      begin                                                                     // mov
              localMem[0 + 1532] = heapMem[localMem[0+1437]*10 + 5];
              ip = 3407;
      end

       3407 :
      begin                                                                     // mov
              localMem[0 + 1533] = heapMem[localMem[0+1495]*10 + 5];
              ip = 3408;
      end

       3408 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1442]) begin
                  heapMem[NArea * localMem[0+1533] + 0 + i] = heapMem[NArea * localMem[0+1532] + localMem[1443] + i];
                end
              end
              ip = 3409;
      end

       3409 :
      begin                                                                     // label
              ip = 3410;
      end

       3410 :
      begin                                                                     // mov
              heapMem[localMem[0+1492]*10 + 2] = localMem[0+1437];
              ip = 3411;
      end

       3411 :
      begin                                                                     // mov
              heapMem[localMem[0+1495]*10 + 2] = localMem[0+1437];
              ip = 3412;
      end

       3412 :
      begin                                                                     // mov
              localMem[0 + 1534] = heapMem[localMem[0+1437]*10 + 4];
              ip = 3413;
      end

       3413 :
      begin                                                                     // mov
              localMem[0 + 1535] = heapMem[localMem[0+1534]*10 + localMem[0+1442]];
              ip = 3414;
      end

       3414 :
      begin                                                                     // mov
              localMem[0 + 1536] = heapMem[localMem[0+1437]*10 + 5];
              ip = 3415;
      end

       3415 :
      begin                                                                     // mov
              localMem[0 + 1537] = heapMem[localMem[0+1536]*10 + localMem[0+1442]];
              ip = 3416;
      end

       3416 :
      begin                                                                     // mov
              localMem[0 + 1538] = heapMem[localMem[0+1437]*10 + 4];
              ip = 3417;
      end

       3417 :
      begin                                                                     // mov
              heapMem[localMem[0+1538]*10 + 0] = localMem[0+1535];
              ip = 3418;
      end

       3418 :
      begin                                                                     // mov
              localMem[0 + 1539] = heapMem[localMem[0+1437]*10 + 5];
              ip = 3419;
      end

       3419 :
      begin                                                                     // mov
              heapMem[localMem[0+1539]*10 + 0] = localMem[0+1537];
              ip = 3420;
      end

       3420 :
      begin                                                                     // mov
              localMem[0 + 1540] = heapMem[localMem[0+1437]*10 + 6];
              ip = 3421;
      end

       3421 :
      begin                                                                     // mov
              heapMem[localMem[0+1540]*10 + 0] = localMem[0+1492];
              ip = 3422;
      end

       3422 :
      begin                                                                     // mov
              localMem[0 + 1541] = heapMem[localMem[0+1437]*10 + 6];
              ip = 3423;
      end

       3423 :
      begin                                                                     // mov
              heapMem[localMem[0+1541]*10 + 1] = localMem[0+1495];
              ip = 3424;
      end

       3424 :
      begin                                                                     // mov
              heapMem[localMem[0+1437]*10 + 0] = 1;
              ip = 3425;
      end

       3425 :
      begin                                                                     // mov
              localMem[0 + 1542] = heapMem[localMem[0+1437]*10 + 4];
              ip = 3426;
      end

       3426 :
      begin                                                                     // resize
              arraySizes[localMem[0+1542]] = 1;
              ip = 3427;
      end

       3427 :
      begin                                                                     // mov
              localMem[0 + 1543] = heapMem[localMem[0+1437]*10 + 5];
              ip = 3428;
      end

       3428 :
      begin                                                                     // resize
              arraySizes[localMem[0+1543]] = 1;
              ip = 3429;
      end

       3429 :
      begin                                                                     // mov
              localMem[0 + 1544] = heapMem[localMem[0+1437]*10 + 6];
              ip = 3430;
      end

       3430 :
      begin                                                                     // resize
              arraySizes[localMem[0+1544]] = 2;
              ip = 3431;
      end

       3431 :
      begin                                                                     // jmp
              ip = 3433;
      end

       3432 :
      begin                                                                     // jmp
              ip = 3438;
      end

       3433 :
      begin                                                                     // label
              ip = 3434;
      end

       3434 :
      begin                                                                     // mov
              localMem[0 + 1438] = 1;
              ip = 3435;
      end

       3435 :
      begin                                                                     // jmp
              ip = 3438;
      end

       3436 :
      begin                                                                     // label
              ip = 3437;
      end

       3437 :
      begin                                                                     // mov
              localMem[0 + 1438] = 0;
              ip = 3438;
      end

       3438 :
      begin                                                                     // label
              ip = 3439;
      end

       3439 :
      begin                                                                     // label
              ip = 3440;
      end

       3440 :
      begin                                                                     // label
              ip = 3441;
      end

       3441 :
      begin                                                                     // mov
              localMem[0 + 1545] = 0;
              ip = 3442;
      end

       3442 :
      begin                                                                     // label
              ip = 3443;
      end

       3443 :
      begin                                                                     // jGe
              ip = localMem[0+1545] >= 99 ? 3941 : 3444;
      end

       3444 :
      begin                                                                     // mov
              localMem[0 + 1546] = heapMem[localMem[0+1437]*10 + 0];
              ip = 3445;
      end

       3445 :
      begin                                                                     // subtract
              localMem[0 + 1547] = localMem[0+1546] - 1;
              ip = 3446;
      end

       3446 :
      begin                                                                     // mov
              localMem[0 + 1548] = heapMem[localMem[0+1437]*10 + 4];
              ip = 3447;
      end

       3447 :
      begin                                                                     // mov
              localMem[0 + 1549] = heapMem[localMem[0+1548]*10 + localMem[0+1547]];
              ip = 3448;
      end

       3448 :
      begin                                                                     // jLe
              ip = 4 <= localMem[0+1549] ? 3689 : 3449;
      end

       3449 :
      begin                                                                     // not
              localMem[0 + 1550] = !heapMem[localMem[0+1437]*10 + 6];
              ip = 3450;
      end

       3450 :
      begin                                                                     // jEq
              ip = localMem[0+1550] == 0 ? 3455 : 3451;
      end

       3451 :
      begin                                                                     // mov
              heapMem[localMem[0+1417]*10 + 0] = localMem[0+1437];
              ip = 3452;
      end

       3452 :
      begin                                                                     // mov
              heapMem[localMem[0+1417]*10 + 1] = 2;
              ip = 3453;
      end

       3453 :
      begin                                                                     // subtract
              heapMem[localMem[0+1417]*10 + 2] = localMem[0+1546] - 1;
              ip = 3454;
      end

       3454 :
      begin                                                                     // jmp
              ip = 3945;
      end

       3455 :
      begin                                                                     // label
              ip = 3456;
      end

       3456 :
      begin                                                                     // mov
              localMem[0 + 1551] = heapMem[localMem[0+1437]*10 + 6];
              ip = 3457;
      end

       3457 :
      begin                                                                     // mov
              localMem[0 + 1552] = heapMem[localMem[0+1551]*10 + localMem[0+1546]];
              ip = 3458;
      end

       3458 :
      begin                                                                     // label
              ip = 3459;
      end

       3459 :
      begin                                                                     // mov
              localMem[0 + 1554] = heapMem[localMem[0+1552]*10 + 0];
              ip = 3460;
      end

       3460 :
      begin                                                                     // mov
              localMem[0 + 1555] = heapMem[localMem[0+1552]*10 + 3];
              ip = 3461;
      end

       3461 :
      begin                                                                     // mov
              localMem[0 + 1556] = heapMem[localMem[0+1555]*10 + 2];
              ip = 3462;
      end

       3462 :
      begin                                                                     // jLt
              ip = localMem[0+1554] <  localMem[0+1556] ? 3682 : 3463;
      end

       3463 :
      begin                                                                     // mov
              localMem[0 + 1557] = localMem[0+1556];
              ip = 3464;
      end

       3464 :
      begin                                                                     // shiftRight
              localMem[0 + 1557] = localMem[0+1557] >> 1;
              ip = 3465;
      end

       3465 :
      begin                                                                     // add
              localMem[0 + 1558] = localMem[0+1557] + 1;
              ip = 3466;
      end

       3466 :
      begin                                                                     // mov
              localMem[0 + 1559] = heapMem[localMem[0+1552]*10 + 2];
              ip = 3467;
      end

       3467 :
      begin                                                                     // jEq
              ip = localMem[0+1559] == 0 ? 3564 : 3468;
      end

       3468 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1560] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1560] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1560]] = 0;
              ip = 3469;
      end

       3469 :
      begin                                                                     // mov
              heapMem[localMem[0+1560]*10 + 0] = localMem[0+1557];
              ip = 3470;
      end

       3470 :
      begin                                                                     // mov
              heapMem[localMem[0+1560]*10 + 2] = 0;
              ip = 3471;
      end

       3471 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1561] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1561] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1561]] = 0;
              ip = 3472;
      end

       3472 :
      begin                                                                     // mov
              heapMem[localMem[0+1560]*10 + 4] = localMem[0+1561];
              ip = 3473;
      end

       3473 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1562] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1562] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1562]] = 0;
              ip = 3474;
      end

       3474 :
      begin                                                                     // mov
              heapMem[localMem[0+1560]*10 + 5] = localMem[0+1562];
              ip = 3475;
      end

       3475 :
      begin                                                                     // mov
              heapMem[localMem[0+1560]*10 + 6] = 0;
              ip = 3476;
      end

       3476 :
      begin                                                                     // mov
              heapMem[localMem[0+1560]*10 + 3] = localMem[0+1555];
              ip = 3477;
      end

       3477 :
      begin                                                                     // add
              heapMem[localMem[0+1555]*10 + 1] = heapMem[localMem[0+1555]*10 + 1] + 1;
              ip = 3478;
      end

       3478 :
      begin                                                                     // mov
              heapMem[localMem[0+1560]*10 + 1] = heapMem[localMem[0+1555]*10 + 1];
              ip = 3479;
      end

       3479 :
      begin                                                                     // not
              localMem[0 + 1563] = !heapMem[localMem[0+1552]*10 + 6];
              ip = 3480;
      end

       3480 :
      begin                                                                     // jNe
              ip = localMem[0+1563] != 0 ? 3509 : 3481;
      end

       3481 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1564] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1564] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1564]] = 0;
              ip = 3482;
      end

       3482 :
      begin                                                                     // mov
              heapMem[localMem[0+1560]*10 + 6] = localMem[0+1564];
              ip = 3483;
      end

       3483 :
      begin                                                                     // mov
              localMem[0 + 1565] = heapMem[localMem[0+1552]*10 + 4];
              ip = 3484;
      end

       3484 :
      begin                                                                     // mov
              localMem[0 + 1566] = heapMem[localMem[0+1560]*10 + 4];
              ip = 3485;
      end

       3485 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1557]) begin
                  heapMem[NArea * localMem[0+1566] + 0 + i] = heapMem[NArea * localMem[0+1565] + localMem[1558] + i];
                end
              end
              ip = 3486;
      end

       3486 :
      begin                                                                     // mov
              localMem[0 + 1567] = heapMem[localMem[0+1552]*10 + 5];
              ip = 3487;
      end

       3487 :
      begin                                                                     // mov
              localMem[0 + 1568] = heapMem[localMem[0+1560]*10 + 5];
              ip = 3488;
      end

       3488 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1557]) begin
                  heapMem[NArea * localMem[0+1568] + 0 + i] = heapMem[NArea * localMem[0+1567] + localMem[1558] + i];
                end
              end
              ip = 3489;
      end

       3489 :
      begin                                                                     // mov
              localMem[0 + 1569] = heapMem[localMem[0+1552]*10 + 6];
              ip = 3490;
      end

       3490 :
      begin                                                                     // mov
              localMem[0 + 1570] = heapMem[localMem[0+1560]*10 + 6];
              ip = 3491;
      end

       3491 :
      begin                                                                     // add
              localMem[0 + 1571] = localMem[0+1557] + 1;
              ip = 3492;
      end

       3492 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1571]) begin
                  heapMem[NArea * localMem[0+1570] + 0 + i] = heapMem[NArea * localMem[0+1569] + localMem[1558] + i];
                end
              end
              ip = 3493;
      end

       3493 :
      begin                                                                     // mov
              localMem[0 + 1572] = heapMem[localMem[0+1560]*10 + 0];
              ip = 3494;
      end

       3494 :
      begin                                                                     // add
              localMem[0 + 1573] = localMem[0+1572] + 1;
              ip = 3495;
      end

       3495 :
      begin                                                                     // mov
              localMem[0 + 1574] = heapMem[localMem[0+1560]*10 + 6];
              ip = 3496;
      end

       3496 :
      begin                                                                     // label
              ip = 3497;
      end

       3497 :
      begin                                                                     // mov
              localMem[0 + 1575] = 0;
              ip = 3498;
      end

       3498 :
      begin                                                                     // label
              ip = 3499;
      end

       3499 :
      begin                                                                     // jGe
              ip = localMem[0+1575] >= localMem[0+1573] ? 3505 : 3500;
      end

       3500 :
      begin                                                                     // mov
              localMem[0 + 1576] = heapMem[localMem[0+1574]*10 + localMem[0+1575]];
              ip = 3501;
      end

       3501 :
      begin                                                                     // mov
              heapMem[localMem[0+1576]*10 + 2] = localMem[0+1560];
              ip = 3502;
      end

       3502 :
      begin                                                                     // label
              ip = 3503;
      end

       3503 :
      begin                                                                     // add
              localMem[0 + 1575] = localMem[0+1575] + 1;
              ip = 3504;
      end

       3504 :
      begin                                                                     // jmp
              ip = 3498;
      end

       3505 :
      begin                                                                     // label
              ip = 3506;
      end

       3506 :
      begin                                                                     // mov
              localMem[0 + 1577] = heapMem[localMem[0+1552]*10 + 6];
              ip = 3507;
      end

       3507 :
      begin                                                                     // resize
              arraySizes[localMem[0+1577]] = localMem[0+1558];
              ip = 3508;
      end

       3508 :
      begin                                                                     // jmp
              ip = 3516;
      end

       3509 :
      begin                                                                     // label
              ip = 3510;
      end

       3510 :
      begin                                                                     // mov
              localMem[0 + 1578] = heapMem[localMem[0+1552]*10 + 4];
              ip = 3511;
      end

       3511 :
      begin                                                                     // mov
              localMem[0 + 1579] = heapMem[localMem[0+1560]*10 + 4];
              ip = 3512;
      end

       3512 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1557]) begin
                  heapMem[NArea * localMem[0+1579] + 0 + i] = heapMem[NArea * localMem[0+1578] + localMem[1558] + i];
                end
              end
              ip = 3513;
      end

       3513 :
      begin                                                                     // mov
              localMem[0 + 1580] = heapMem[localMem[0+1552]*10 + 5];
              ip = 3514;
      end

       3514 :
      begin                                                                     // mov
              localMem[0 + 1581] = heapMem[localMem[0+1560]*10 + 5];
              ip = 3515;
      end

       3515 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1557]) begin
                  heapMem[NArea * localMem[0+1581] + 0 + i] = heapMem[NArea * localMem[0+1580] + localMem[1558] + i];
                end
              end
              ip = 3516;
      end

       3516 :
      begin                                                                     // label
              ip = 3517;
      end

       3517 :
      begin                                                                     // mov
              heapMem[localMem[0+1552]*10 + 0] = localMem[0+1557];
              ip = 3518;
      end

       3518 :
      begin                                                                     // mov
              heapMem[localMem[0+1560]*10 + 2] = localMem[0+1559];
              ip = 3519;
      end

       3519 :
      begin                                                                     // mov
              localMem[0 + 1582] = heapMem[localMem[0+1559]*10 + 0];
              ip = 3520;
      end

       3520 :
      begin                                                                     // mov
              localMem[0 + 1583] = heapMem[localMem[0+1559]*10 + 6];
              ip = 3521;
      end

       3521 :
      begin                                                                     // mov
              localMem[0 + 1584] = heapMem[localMem[0+1583]*10 + localMem[0+1582]];
              ip = 3522;
      end

       3522 :
      begin                                                                     // jNe
              ip = localMem[0+1584] != localMem[0+1552] ? 3541 : 3523;
      end

       3523 :
      begin                                                                     // mov
              localMem[0 + 1585] = heapMem[localMem[0+1552]*10 + 4];
              ip = 3524;
      end

       3524 :
      begin                                                                     // mov
              localMem[0 + 1586] = heapMem[localMem[0+1585]*10 + localMem[0+1557]];
              ip = 3525;
      end

       3525 :
      begin                                                                     // mov
              localMem[0 + 1587] = heapMem[localMem[0+1559]*10 + 4];
              ip = 3526;
      end

       3526 :
      begin                                                                     // mov
              heapMem[localMem[0+1587]*10 + localMem[0+1582]] = localMem[0+1586];
              ip = 3527;
      end

       3527 :
      begin                                                                     // mov
              localMem[0 + 1588] = heapMem[localMem[0+1552]*10 + 5];
              ip = 3528;
      end

       3528 :
      begin                                                                     // mov
              localMem[0 + 1589] = heapMem[localMem[0+1588]*10 + localMem[0+1557]];
              ip = 3529;
      end

       3529 :
      begin                                                                     // mov
              localMem[0 + 1590] = heapMem[localMem[0+1559]*10 + 5];
              ip = 3530;
      end

       3530 :
      begin                                                                     // mov
              heapMem[localMem[0+1590]*10 + localMem[0+1582]] = localMem[0+1589];
              ip = 3531;
      end

       3531 :
      begin                                                                     // mov
              localMem[0 + 1591] = heapMem[localMem[0+1552]*10 + 4];
              ip = 3532;
      end

       3532 :
      begin                                                                     // resize
              arraySizes[localMem[0+1591]] = localMem[0+1557];
              ip = 3533;
      end

       3533 :
      begin                                                                     // mov
              localMem[0 + 1592] = heapMem[localMem[0+1552]*10 + 5];
              ip = 3534;
      end

       3534 :
      begin                                                                     // resize
              arraySizes[localMem[0+1592]] = localMem[0+1557];
              ip = 3535;
      end

       3535 :
      begin                                                                     // add
              localMem[0 + 1593] = localMem[0+1582] + 1;
              ip = 3536;
      end

       3536 :
      begin                                                                     // mov
              heapMem[localMem[0+1559]*10 + 0] = localMem[0+1593];
              ip = 3537;
      end

       3537 :
      begin                                                                     // mov
              localMem[0 + 1594] = heapMem[localMem[0+1559]*10 + 6];
              ip = 3538;
      end

       3538 :
      begin                                                                     // mov
              heapMem[localMem[0+1594]*10 + localMem[0+1593]] = localMem[0+1560];
              ip = 3539;
      end

       3539 :
      begin                                                                     // jmp
              ip = 3679;
      end

       3540 :
      begin                                                                     // jmp
              ip = 3563;
      end

       3541 :
      begin                                                                     // label
              ip = 3542;
      end

       3542 :
      begin                                                                     // assertNe
            ip = 3543;
      end

       3543 :
      begin                                                                     // mov
              localMem[0 + 1595] = heapMem[localMem[0+1559]*10 + 6];
              ip = 3544;
      end

       3544 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+1595] * NArea + i] == localMem[0+1552]) localMem[0 + 1596] = i + 1;
              end
              ip = 3545;
      end

       3545 :
      begin                                                                     // subtract
              localMem[0 + 1596] = localMem[0+1596] - 1;
              ip = 3546;
      end

       3546 :
      begin                                                                     // mov
              localMem[0 + 1597] = heapMem[localMem[0+1552]*10 + 4];
              ip = 3547;
      end

       3547 :
      begin                                                                     // mov
              localMem[0 + 1598] = heapMem[localMem[0+1597]*10 + localMem[0+1557]];
              ip = 3548;
      end

       3548 :
      begin                                                                     // mov
              localMem[0 + 1599] = heapMem[localMem[0+1552]*10 + 5];
              ip = 3549;
      end

       3549 :
      begin                                                                     // mov
              localMem[0 + 1600] = heapMem[localMem[0+1599]*10 + localMem[0+1557]];
              ip = 3550;
      end

       3550 :
      begin                                                                     // mov
              localMem[0 + 1601] = heapMem[localMem[0+1552]*10 + 4];
              ip = 3551;
      end

       3551 :
      begin                                                                     // resize
              arraySizes[localMem[0+1601]] = localMem[0+1557];
              ip = 3552;
      end

       3552 :
      begin                                                                     // mov
              localMem[0 + 1602] = heapMem[localMem[0+1552]*10 + 5];
              ip = 3553;
      end

       3553 :
      begin                                                                     // resize
              arraySizes[localMem[0+1602]] = localMem[0+1557];
              ip = 3554;
      end

       3554 :
      begin                                                                     // mov
              localMem[0 + 1603] = heapMem[localMem[0+1559]*10 + 4];
              ip = 3555;
      end

       3555 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1603] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1596]) begin
                  heapMem[NArea * localMem[0+1603] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1603] + localMem[1596]] = localMem[0+1598];                                    // Insert new value
              arraySizes[localMem[0+1603]] = arraySizes[localMem[0+1603]] + 1;                              // Increase array size
              ip = 3556;
      end

       3556 :
      begin                                                                     // mov
              localMem[0 + 1604] = heapMem[localMem[0+1559]*10 + 5];
              ip = 3557;
      end

       3557 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1604] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1596]) begin
                  heapMem[NArea * localMem[0+1604] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1604] + localMem[1596]] = localMem[0+1600];                                    // Insert new value
              arraySizes[localMem[0+1604]] = arraySizes[localMem[0+1604]] + 1;                              // Increase array size
              ip = 3558;
      end

       3558 :
      begin                                                                     // mov
              localMem[0 + 1605] = heapMem[localMem[0+1559]*10 + 6];
              ip = 3559;
      end

       3559 :
      begin                                                                     // add
              localMem[0 + 1606] = localMem[0+1596] + 1;
              ip = 3560;
      end

       3560 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1605] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1606]) begin
                  heapMem[NArea * localMem[0+1605] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1605] + localMem[1606]] = localMem[0+1560];                                    // Insert new value
              arraySizes[localMem[0+1605]] = arraySizes[localMem[0+1605]] + 1;                              // Increase array size
              ip = 3561;
      end

       3561 :
      begin                                                                     // add
              heapMem[localMem[0+1559]*10 + 0] = heapMem[localMem[0+1559]*10 + 0] + 1;
              ip = 3562;
      end

       3562 :
      begin                                                                     // jmp
              ip = 3679;
      end

       3563 :
      begin                                                                     // label
              ip = 3564;
      end

       3564 :
      begin                                                                     // label
              ip = 3565;
      end

       3565 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1607] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1607] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1607]] = 0;
              ip = 3566;
      end

       3566 :
      begin                                                                     // mov
              heapMem[localMem[0+1607]*10 + 0] = localMem[0+1557];
              ip = 3567;
      end

       3567 :
      begin                                                                     // mov
              heapMem[localMem[0+1607]*10 + 2] = 0;
              ip = 3568;
      end

       3568 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1608] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1608] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1608]] = 0;
              ip = 3569;
      end

       3569 :
      begin                                                                     // mov
              heapMem[localMem[0+1607]*10 + 4] = localMem[0+1608];
              ip = 3570;
      end

       3570 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1609] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1609] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1609]] = 0;
              ip = 3571;
      end

       3571 :
      begin                                                                     // mov
              heapMem[localMem[0+1607]*10 + 5] = localMem[0+1609];
              ip = 3572;
      end

       3572 :
      begin                                                                     // mov
              heapMem[localMem[0+1607]*10 + 6] = 0;
              ip = 3573;
      end

       3573 :
      begin                                                                     // mov
              heapMem[localMem[0+1607]*10 + 3] = localMem[0+1555];
              ip = 3574;
      end

       3574 :
      begin                                                                     // add
              heapMem[localMem[0+1555]*10 + 1] = heapMem[localMem[0+1555]*10 + 1] + 1;
              ip = 3575;
      end

       3575 :
      begin                                                                     // mov
              heapMem[localMem[0+1607]*10 + 1] = heapMem[localMem[0+1555]*10 + 1];
              ip = 3576;
      end

       3576 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1610] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1610] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1610]] = 0;
              ip = 3577;
      end

       3577 :
      begin                                                                     // mov
              heapMem[localMem[0+1610]*10 + 0] = localMem[0+1557];
              ip = 3578;
      end

       3578 :
      begin                                                                     // mov
              heapMem[localMem[0+1610]*10 + 2] = 0;
              ip = 3579;
      end

       3579 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1611] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1611] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1611]] = 0;
              ip = 3580;
      end

       3580 :
      begin                                                                     // mov
              heapMem[localMem[0+1610]*10 + 4] = localMem[0+1611];
              ip = 3581;
      end

       3581 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1612] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1612] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1612]] = 0;
              ip = 3582;
      end

       3582 :
      begin                                                                     // mov
              heapMem[localMem[0+1610]*10 + 5] = localMem[0+1612];
              ip = 3583;
      end

       3583 :
      begin                                                                     // mov
              heapMem[localMem[0+1610]*10 + 6] = 0;
              ip = 3584;
      end

       3584 :
      begin                                                                     // mov
              heapMem[localMem[0+1610]*10 + 3] = localMem[0+1555];
              ip = 3585;
      end

       3585 :
      begin                                                                     // add
              heapMem[localMem[0+1555]*10 + 1] = heapMem[localMem[0+1555]*10 + 1] + 1;
              ip = 3586;
      end

       3586 :
      begin                                                                     // mov
              heapMem[localMem[0+1610]*10 + 1] = heapMem[localMem[0+1555]*10 + 1];
              ip = 3587;
      end

       3587 :
      begin                                                                     // not
              localMem[0 + 1613] = !heapMem[localMem[0+1552]*10 + 6];
              ip = 3588;
      end

       3588 :
      begin                                                                     // jNe
              ip = localMem[0+1613] != 0 ? 3640 : 3589;
      end

       3589 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1614] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1614] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1614]] = 0;
              ip = 3590;
      end

       3590 :
      begin                                                                     // mov
              heapMem[localMem[0+1607]*10 + 6] = localMem[0+1614];
              ip = 3591;
      end

       3591 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1615] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1615] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1615]] = 0;
              ip = 3592;
      end

       3592 :
      begin                                                                     // mov
              heapMem[localMem[0+1610]*10 + 6] = localMem[0+1615];
              ip = 3593;
      end

       3593 :
      begin                                                                     // mov
              localMem[0 + 1616] = heapMem[localMem[0+1552]*10 + 4];
              ip = 3594;
      end

       3594 :
      begin                                                                     // mov
              localMem[0 + 1617] = heapMem[localMem[0+1607]*10 + 4];
              ip = 3595;
      end

       3595 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1557]) begin
                  heapMem[NArea * localMem[0+1617] + 0 + i] = heapMem[NArea * localMem[0+1616] + 0 + i];
                end
              end
              ip = 3596;
      end

       3596 :
      begin                                                                     // mov
              localMem[0 + 1618] = heapMem[localMem[0+1552]*10 + 5];
              ip = 3597;
      end

       3597 :
      begin                                                                     // mov
              localMem[0 + 1619] = heapMem[localMem[0+1607]*10 + 5];
              ip = 3598;
      end

       3598 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1557]) begin
                  heapMem[NArea * localMem[0+1619] + 0 + i] = heapMem[NArea * localMem[0+1618] + 0 + i];
                end
              end
              ip = 3599;
      end

       3599 :
      begin                                                                     // mov
              localMem[0 + 1620] = heapMem[localMem[0+1552]*10 + 6];
              ip = 3600;
      end

       3600 :
      begin                                                                     // mov
              localMem[0 + 1621] = heapMem[localMem[0+1607]*10 + 6];
              ip = 3601;
      end

       3601 :
      begin                                                                     // add
              localMem[0 + 1622] = localMem[0+1557] + 1;
              ip = 3602;
      end

       3602 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1622]) begin
                  heapMem[NArea * localMem[0+1621] + 0 + i] = heapMem[NArea * localMem[0+1620] + 0 + i];
                end
              end
              ip = 3603;
      end

       3603 :
      begin                                                                     // mov
              localMem[0 + 1623] = heapMem[localMem[0+1552]*10 + 4];
              ip = 3604;
      end

       3604 :
      begin                                                                     // mov
              localMem[0 + 1624] = heapMem[localMem[0+1610]*10 + 4];
              ip = 3605;
      end

       3605 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1557]) begin
                  heapMem[NArea * localMem[0+1624] + 0 + i] = heapMem[NArea * localMem[0+1623] + localMem[1558] + i];
                end
              end
              ip = 3606;
      end

       3606 :
      begin                                                                     // mov
              localMem[0 + 1625] = heapMem[localMem[0+1552]*10 + 5];
              ip = 3607;
      end

       3607 :
      begin                                                                     // mov
              localMem[0 + 1626] = heapMem[localMem[0+1610]*10 + 5];
              ip = 3608;
      end

       3608 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1557]) begin
                  heapMem[NArea * localMem[0+1626] + 0 + i] = heapMem[NArea * localMem[0+1625] + localMem[1558] + i];
                end
              end
              ip = 3609;
      end

       3609 :
      begin                                                                     // mov
              localMem[0 + 1627] = heapMem[localMem[0+1552]*10 + 6];
              ip = 3610;
      end

       3610 :
      begin                                                                     // mov
              localMem[0 + 1628] = heapMem[localMem[0+1610]*10 + 6];
              ip = 3611;
      end

       3611 :
      begin                                                                     // add
              localMem[0 + 1629] = localMem[0+1557] + 1;
              ip = 3612;
      end

       3612 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1629]) begin
                  heapMem[NArea * localMem[0+1628] + 0 + i] = heapMem[NArea * localMem[0+1627] + localMem[1558] + i];
                end
              end
              ip = 3613;
      end

       3613 :
      begin                                                                     // mov
              localMem[0 + 1630] = heapMem[localMem[0+1607]*10 + 0];
              ip = 3614;
      end

       3614 :
      begin                                                                     // add
              localMem[0 + 1631] = localMem[0+1630] + 1;
              ip = 3615;
      end

       3615 :
      begin                                                                     // mov
              localMem[0 + 1632] = heapMem[localMem[0+1607]*10 + 6];
              ip = 3616;
      end

       3616 :
      begin                                                                     // label
              ip = 3617;
      end

       3617 :
      begin                                                                     // mov
              localMem[0 + 1633] = 0;
              ip = 3618;
      end

       3618 :
      begin                                                                     // label
              ip = 3619;
      end

       3619 :
      begin                                                                     // jGe
              ip = localMem[0+1633] >= localMem[0+1631] ? 3625 : 3620;
      end

       3620 :
      begin                                                                     // mov
              localMem[0 + 1634] = heapMem[localMem[0+1632]*10 + localMem[0+1633]];
              ip = 3621;
      end

       3621 :
      begin                                                                     // mov
              heapMem[localMem[0+1634]*10 + 2] = localMem[0+1607];
              ip = 3622;
      end

       3622 :
      begin                                                                     // label
              ip = 3623;
      end

       3623 :
      begin                                                                     // add
              localMem[0 + 1633] = localMem[0+1633] + 1;
              ip = 3624;
      end

       3624 :
      begin                                                                     // jmp
              ip = 3618;
      end

       3625 :
      begin                                                                     // label
              ip = 3626;
      end

       3626 :
      begin                                                                     // mov
              localMem[0 + 1635] = heapMem[localMem[0+1610]*10 + 0];
              ip = 3627;
      end

       3627 :
      begin                                                                     // add
              localMem[0 + 1636] = localMem[0+1635] + 1;
              ip = 3628;
      end

       3628 :
      begin                                                                     // mov
              localMem[0 + 1637] = heapMem[localMem[0+1610]*10 + 6];
              ip = 3629;
      end

       3629 :
      begin                                                                     // label
              ip = 3630;
      end

       3630 :
      begin                                                                     // mov
              localMem[0 + 1638] = 0;
              ip = 3631;
      end

       3631 :
      begin                                                                     // label
              ip = 3632;
      end

       3632 :
      begin                                                                     // jGe
              ip = localMem[0+1638] >= localMem[0+1636] ? 3638 : 3633;
      end

       3633 :
      begin                                                                     // mov
              localMem[0 + 1639] = heapMem[localMem[0+1637]*10 + localMem[0+1638]];
              ip = 3634;
      end

       3634 :
      begin                                                                     // mov
              heapMem[localMem[0+1639]*10 + 2] = localMem[0+1610];
              ip = 3635;
      end

       3635 :
      begin                                                                     // label
              ip = 3636;
      end

       3636 :
      begin                                                                     // add
              localMem[0 + 1638] = localMem[0+1638] + 1;
              ip = 3637;
      end

       3637 :
      begin                                                                     // jmp
              ip = 3631;
      end

       3638 :
      begin                                                                     // label
              ip = 3639;
      end

       3639 :
      begin                                                                     // jmp
              ip = 3655;
      end

       3640 :
      begin                                                                     // label
              ip = 3641;
      end

       3641 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1640] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1640] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1640]] = 0;
              ip = 3642;
      end

       3642 :
      begin                                                                     // mov
              heapMem[localMem[0+1552]*10 + 6] = localMem[0+1640];
              ip = 3643;
      end

       3643 :
      begin                                                                     // mov
              localMem[0 + 1641] = heapMem[localMem[0+1552]*10 + 4];
              ip = 3644;
      end

       3644 :
      begin                                                                     // mov
              localMem[0 + 1642] = heapMem[localMem[0+1607]*10 + 4];
              ip = 3645;
      end

       3645 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1557]) begin
                  heapMem[NArea * localMem[0+1642] + 0 + i] = heapMem[NArea * localMem[0+1641] + 0 + i];
                end
              end
              ip = 3646;
      end

       3646 :
      begin                                                                     // mov
              localMem[0 + 1643] = heapMem[localMem[0+1552]*10 + 5];
              ip = 3647;
      end

       3647 :
      begin                                                                     // mov
              localMem[0 + 1644] = heapMem[localMem[0+1607]*10 + 5];
              ip = 3648;
      end

       3648 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1557]) begin
                  heapMem[NArea * localMem[0+1644] + 0 + i] = heapMem[NArea * localMem[0+1643] + 0 + i];
                end
              end
              ip = 3649;
      end

       3649 :
      begin                                                                     // mov
              localMem[0 + 1645] = heapMem[localMem[0+1552]*10 + 4];
              ip = 3650;
      end

       3650 :
      begin                                                                     // mov
              localMem[0 + 1646] = heapMem[localMem[0+1610]*10 + 4];
              ip = 3651;
      end

       3651 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1557]) begin
                  heapMem[NArea * localMem[0+1646] + 0 + i] = heapMem[NArea * localMem[0+1645] + localMem[1558] + i];
                end
              end
              ip = 3652;
      end

       3652 :
      begin                                                                     // mov
              localMem[0 + 1647] = heapMem[localMem[0+1552]*10 + 5];
              ip = 3653;
      end

       3653 :
      begin                                                                     // mov
              localMem[0 + 1648] = heapMem[localMem[0+1610]*10 + 5];
              ip = 3654;
      end

       3654 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1557]) begin
                  heapMem[NArea * localMem[0+1648] + 0 + i] = heapMem[NArea * localMem[0+1647] + localMem[1558] + i];
                end
              end
              ip = 3655;
      end

       3655 :
      begin                                                                     // label
              ip = 3656;
      end

       3656 :
      begin                                                                     // mov
              heapMem[localMem[0+1607]*10 + 2] = localMem[0+1552];
              ip = 3657;
      end

       3657 :
      begin                                                                     // mov
              heapMem[localMem[0+1610]*10 + 2] = localMem[0+1552];
              ip = 3658;
      end

       3658 :
      begin                                                                     // mov
              localMem[0 + 1649] = heapMem[localMem[0+1552]*10 + 4];
              ip = 3659;
      end

       3659 :
      begin                                                                     // mov
              localMem[0 + 1650] = heapMem[localMem[0+1649]*10 + localMem[0+1557]];
              ip = 3660;
      end

       3660 :
      begin                                                                     // mov
              localMem[0 + 1651] = heapMem[localMem[0+1552]*10 + 5];
              ip = 3661;
      end

       3661 :
      begin                                                                     // mov
              localMem[0 + 1652] = heapMem[localMem[0+1651]*10 + localMem[0+1557]];
              ip = 3662;
      end

       3662 :
      begin                                                                     // mov
              localMem[0 + 1653] = heapMem[localMem[0+1552]*10 + 4];
              ip = 3663;
      end

       3663 :
      begin                                                                     // mov
              heapMem[localMem[0+1653]*10 + 0] = localMem[0+1650];
              ip = 3664;
      end

       3664 :
      begin                                                                     // mov
              localMem[0 + 1654] = heapMem[localMem[0+1552]*10 + 5];
              ip = 3665;
      end

       3665 :
      begin                                                                     // mov
              heapMem[localMem[0+1654]*10 + 0] = localMem[0+1652];
              ip = 3666;
      end

       3666 :
      begin                                                                     // mov
              localMem[0 + 1655] = heapMem[localMem[0+1552]*10 + 6];
              ip = 3667;
      end

       3667 :
      begin                                                                     // mov
              heapMem[localMem[0+1655]*10 + 0] = localMem[0+1607];
              ip = 3668;
      end

       3668 :
      begin                                                                     // mov
              localMem[0 + 1656] = heapMem[localMem[0+1552]*10 + 6];
              ip = 3669;
      end

       3669 :
      begin                                                                     // mov
              heapMem[localMem[0+1656]*10 + 1] = localMem[0+1610];
              ip = 3670;
      end

       3670 :
      begin                                                                     // mov
              heapMem[localMem[0+1552]*10 + 0] = 1;
              ip = 3671;
      end

       3671 :
      begin                                                                     // mov
              localMem[0 + 1657] = heapMem[localMem[0+1552]*10 + 4];
              ip = 3672;
      end

       3672 :
      begin                                                                     // resize
              arraySizes[localMem[0+1657]] = 1;
              ip = 3673;
      end

       3673 :
      begin                                                                     // mov
              localMem[0 + 1658] = heapMem[localMem[0+1552]*10 + 5];
              ip = 3674;
      end

       3674 :
      begin                                                                     // resize
              arraySizes[localMem[0+1658]] = 1;
              ip = 3675;
      end

       3675 :
      begin                                                                     // mov
              localMem[0 + 1659] = heapMem[localMem[0+1552]*10 + 6];
              ip = 3676;
      end

       3676 :
      begin                                                                     // resize
              arraySizes[localMem[0+1659]] = 2;
              ip = 3677;
      end

       3677 :
      begin                                                                     // jmp
              ip = 3679;
      end

       3678 :
      begin                                                                     // jmp
              ip = 3684;
      end

       3679 :
      begin                                                                     // label
              ip = 3680;
      end

       3680 :
      begin                                                                     // mov
              localMem[0 + 1553] = 1;
              ip = 3681;
      end

       3681 :
      begin                                                                     // jmp
              ip = 3684;
      end

       3682 :
      begin                                                                     // label
              ip = 3683;
      end

       3683 :
      begin                                                                     // mov
              localMem[0 + 1553] = 0;
              ip = 3684;
      end

       3684 :
      begin                                                                     // label
              ip = 3685;
      end

       3685 :
      begin                                                                     // jNe
              ip = localMem[0+1553] != 0 ? 3687 : 3686;
      end

       3686 :
      begin                                                                     // mov
              localMem[0 + 1437] = localMem[0+1552];
              ip = 3687;
      end

       3687 :
      begin                                                                     // label
              ip = 3688;
      end

       3688 :
      begin                                                                     // jmp
              ip = 3938;
      end

       3689 :
      begin                                                                     // label
              ip = 3690;
      end

       3690 :
      begin                                                                     // mov
              localMem[0 + 1660] = heapMem[localMem[0+1437]*10 + 4];
              ip = 3691;
      end

       3691 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+1660] * NArea + i] == 4) localMem[0 + 1661] = i + 1;
              end
              ip = 3692;
      end

       3692 :
      begin                                                                     // jEq
              ip = localMem[0+1661] == 0 ? 3697 : 3693;
      end

       3693 :
      begin                                                                     // mov
              heapMem[localMem[0+1417]*10 + 0] = localMem[0+1437];
              ip = 3694;
      end

       3694 :
      begin                                                                     // mov
              heapMem[localMem[0+1417]*10 + 1] = 1;
              ip = 3695;
      end

       3695 :
      begin                                                                     // subtract
              heapMem[localMem[0+1417]*10 + 2] = localMem[0+1661] - 1;
              ip = 3696;
      end

       3696 :
      begin                                                                     // jmp
              ip = 3945;
      end

       3697 :
      begin                                                                     // label
              ip = 3698;
      end

       3698 :
      begin                                                                     // arrayCountLess
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+1660] * NArea + i] < 4) j = j + 1;
              end
              localMem[0 + 1662] = j;
              ip = 3699;
      end

       3699 :
      begin                                                                     // not
              localMem[0 + 1663] = !heapMem[localMem[0+1437]*10 + 6];
              ip = 3700;
      end

       3700 :
      begin                                                                     // jEq
              ip = localMem[0+1663] == 0 ? 3705 : 3701;
      end

       3701 :
      begin                                                                     // mov
              heapMem[localMem[0+1417]*10 + 0] = localMem[0+1437];
              ip = 3702;
      end

       3702 :
      begin                                                                     // mov
              heapMem[localMem[0+1417]*10 + 1] = 0;
              ip = 3703;
      end

       3703 :
      begin                                                                     // mov
              heapMem[localMem[0+1417]*10 + 2] = localMem[0+1662];
              ip = 3704;
      end

       3704 :
      begin                                                                     // jmp
              ip = 3945;
      end

       3705 :
      begin                                                                     // label
              ip = 3706;
      end

       3706 :
      begin                                                                     // mov
              localMem[0 + 1664] = heapMem[localMem[0+1437]*10 + 6];
              ip = 3707;
      end

       3707 :
      begin                                                                     // mov
              localMem[0 + 1665] = heapMem[localMem[0+1664]*10 + localMem[0+1662]];
              ip = 3708;
      end

       3708 :
      begin                                                                     // label
              ip = 3709;
      end

       3709 :
      begin                                                                     // mov
              localMem[0 + 1667] = heapMem[localMem[0+1665]*10 + 0];
              ip = 3710;
      end

       3710 :
      begin                                                                     // mov
              localMem[0 + 1668] = heapMem[localMem[0+1665]*10 + 3];
              ip = 3711;
      end

       3711 :
      begin                                                                     // mov
              localMem[0 + 1669] = heapMem[localMem[0+1668]*10 + 2];
              ip = 3712;
      end

       3712 :
      begin                                                                     // jLt
              ip = localMem[0+1667] <  localMem[0+1669] ? 3932 : 3713;
      end

       3713 :
      begin                                                                     // mov
              localMem[0 + 1670] = localMem[0+1669];
              ip = 3714;
      end

       3714 :
      begin                                                                     // shiftRight
              localMem[0 + 1670] = localMem[0+1670] >> 1;
              ip = 3715;
      end

       3715 :
      begin                                                                     // add
              localMem[0 + 1671] = localMem[0+1670] + 1;
              ip = 3716;
      end

       3716 :
      begin                                                                     // mov
              localMem[0 + 1672] = heapMem[localMem[0+1665]*10 + 2];
              ip = 3717;
      end

       3717 :
      begin                                                                     // jEq
              ip = localMem[0+1672] == 0 ? 3814 : 3718;
      end

       3718 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1673] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1673] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1673]] = 0;
              ip = 3719;
      end

       3719 :
      begin                                                                     // mov
              heapMem[localMem[0+1673]*10 + 0] = localMem[0+1670];
              ip = 3720;
      end

       3720 :
      begin                                                                     // mov
              heapMem[localMem[0+1673]*10 + 2] = 0;
              ip = 3721;
      end

       3721 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1674] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1674] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1674]] = 0;
              ip = 3722;
      end

       3722 :
      begin                                                                     // mov
              heapMem[localMem[0+1673]*10 + 4] = localMem[0+1674];
              ip = 3723;
      end

       3723 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1675] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1675] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1675]] = 0;
              ip = 3724;
      end

       3724 :
      begin                                                                     // mov
              heapMem[localMem[0+1673]*10 + 5] = localMem[0+1675];
              ip = 3725;
      end

       3725 :
      begin                                                                     // mov
              heapMem[localMem[0+1673]*10 + 6] = 0;
              ip = 3726;
      end

       3726 :
      begin                                                                     // mov
              heapMem[localMem[0+1673]*10 + 3] = localMem[0+1668];
              ip = 3727;
      end

       3727 :
      begin                                                                     // add
              heapMem[localMem[0+1668]*10 + 1] = heapMem[localMem[0+1668]*10 + 1] + 1;
              ip = 3728;
      end

       3728 :
      begin                                                                     // mov
              heapMem[localMem[0+1673]*10 + 1] = heapMem[localMem[0+1668]*10 + 1];
              ip = 3729;
      end

       3729 :
      begin                                                                     // not
              localMem[0 + 1676] = !heapMem[localMem[0+1665]*10 + 6];
              ip = 3730;
      end

       3730 :
      begin                                                                     // jNe
              ip = localMem[0+1676] != 0 ? 3759 : 3731;
      end

       3731 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1677] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1677] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1677]] = 0;
              ip = 3732;
      end

       3732 :
      begin                                                                     // mov
              heapMem[localMem[0+1673]*10 + 6] = localMem[0+1677];
              ip = 3733;
      end

       3733 :
      begin                                                                     // mov
              localMem[0 + 1678] = heapMem[localMem[0+1665]*10 + 4];
              ip = 3734;
      end

       3734 :
      begin                                                                     // mov
              localMem[0 + 1679] = heapMem[localMem[0+1673]*10 + 4];
              ip = 3735;
      end

       3735 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1670]) begin
                  heapMem[NArea * localMem[0+1679] + 0 + i] = heapMem[NArea * localMem[0+1678] + localMem[1671] + i];
                end
              end
              ip = 3736;
      end

       3736 :
      begin                                                                     // mov
              localMem[0 + 1680] = heapMem[localMem[0+1665]*10 + 5];
              ip = 3737;
      end

       3737 :
      begin                                                                     // mov
              localMem[0 + 1681] = heapMem[localMem[0+1673]*10 + 5];
              ip = 3738;
      end

       3738 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1670]) begin
                  heapMem[NArea * localMem[0+1681] + 0 + i] = heapMem[NArea * localMem[0+1680] + localMem[1671] + i];
                end
              end
              ip = 3739;
      end

       3739 :
      begin                                                                     // mov
              localMem[0 + 1682] = heapMem[localMem[0+1665]*10 + 6];
              ip = 3740;
      end

       3740 :
      begin                                                                     // mov
              localMem[0 + 1683] = heapMem[localMem[0+1673]*10 + 6];
              ip = 3741;
      end

       3741 :
      begin                                                                     // add
              localMem[0 + 1684] = localMem[0+1670] + 1;
              ip = 3742;
      end

       3742 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1684]) begin
                  heapMem[NArea * localMem[0+1683] + 0 + i] = heapMem[NArea * localMem[0+1682] + localMem[1671] + i];
                end
              end
              ip = 3743;
      end

       3743 :
      begin                                                                     // mov
              localMem[0 + 1685] = heapMem[localMem[0+1673]*10 + 0];
              ip = 3744;
      end

       3744 :
      begin                                                                     // add
              localMem[0 + 1686] = localMem[0+1685] + 1;
              ip = 3745;
      end

       3745 :
      begin                                                                     // mov
              localMem[0 + 1687] = heapMem[localMem[0+1673]*10 + 6];
              ip = 3746;
      end

       3746 :
      begin                                                                     // label
              ip = 3747;
      end

       3747 :
      begin                                                                     // mov
              localMem[0 + 1688] = 0;
              ip = 3748;
      end

       3748 :
      begin                                                                     // label
              ip = 3749;
      end

       3749 :
      begin                                                                     // jGe
              ip = localMem[0+1688] >= localMem[0+1686] ? 3755 : 3750;
      end

       3750 :
      begin                                                                     // mov
              localMem[0 + 1689] = heapMem[localMem[0+1687]*10 + localMem[0+1688]];
              ip = 3751;
      end

       3751 :
      begin                                                                     // mov
              heapMem[localMem[0+1689]*10 + 2] = localMem[0+1673];
              ip = 3752;
      end

       3752 :
      begin                                                                     // label
              ip = 3753;
      end

       3753 :
      begin                                                                     // add
              localMem[0 + 1688] = localMem[0+1688] + 1;
              ip = 3754;
      end

       3754 :
      begin                                                                     // jmp
              ip = 3748;
      end

       3755 :
      begin                                                                     // label
              ip = 3756;
      end

       3756 :
      begin                                                                     // mov
              localMem[0 + 1690] = heapMem[localMem[0+1665]*10 + 6];
              ip = 3757;
      end

       3757 :
      begin                                                                     // resize
              arraySizes[localMem[0+1690]] = localMem[0+1671];
              ip = 3758;
      end

       3758 :
      begin                                                                     // jmp
              ip = 3766;
      end

       3759 :
      begin                                                                     // label
              ip = 3760;
      end

       3760 :
      begin                                                                     // mov
              localMem[0 + 1691] = heapMem[localMem[0+1665]*10 + 4];
              ip = 3761;
      end

       3761 :
      begin                                                                     // mov
              localMem[0 + 1692] = heapMem[localMem[0+1673]*10 + 4];
              ip = 3762;
      end

       3762 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1670]) begin
                  heapMem[NArea * localMem[0+1692] + 0 + i] = heapMem[NArea * localMem[0+1691] + localMem[1671] + i];
                end
              end
              ip = 3763;
      end

       3763 :
      begin                                                                     // mov
              localMem[0 + 1693] = heapMem[localMem[0+1665]*10 + 5];
              ip = 3764;
      end

       3764 :
      begin                                                                     // mov
              localMem[0 + 1694] = heapMem[localMem[0+1673]*10 + 5];
              ip = 3765;
      end

       3765 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1670]) begin
                  heapMem[NArea * localMem[0+1694] + 0 + i] = heapMem[NArea * localMem[0+1693] + localMem[1671] + i];
                end
              end
              ip = 3766;
      end

       3766 :
      begin                                                                     // label
              ip = 3767;
      end

       3767 :
      begin                                                                     // mov
              heapMem[localMem[0+1665]*10 + 0] = localMem[0+1670];
              ip = 3768;
      end

       3768 :
      begin                                                                     // mov
              heapMem[localMem[0+1673]*10 + 2] = localMem[0+1672];
              ip = 3769;
      end

       3769 :
      begin                                                                     // mov
              localMem[0 + 1695] = heapMem[localMem[0+1672]*10 + 0];
              ip = 3770;
      end

       3770 :
      begin                                                                     // mov
              localMem[0 + 1696] = heapMem[localMem[0+1672]*10 + 6];
              ip = 3771;
      end

       3771 :
      begin                                                                     // mov
              localMem[0 + 1697] = heapMem[localMem[0+1696]*10 + localMem[0+1695]];
              ip = 3772;
      end

       3772 :
      begin                                                                     // jNe
              ip = localMem[0+1697] != localMem[0+1665] ? 3791 : 3773;
      end

       3773 :
      begin                                                                     // mov
              localMem[0 + 1698] = heapMem[localMem[0+1665]*10 + 4];
              ip = 3774;
      end

       3774 :
      begin                                                                     // mov
              localMem[0 + 1699] = heapMem[localMem[0+1698]*10 + localMem[0+1670]];
              ip = 3775;
      end

       3775 :
      begin                                                                     // mov
              localMem[0 + 1700] = heapMem[localMem[0+1672]*10 + 4];
              ip = 3776;
      end

       3776 :
      begin                                                                     // mov
              heapMem[localMem[0+1700]*10 + localMem[0+1695]] = localMem[0+1699];
              ip = 3777;
      end

       3777 :
      begin                                                                     // mov
              localMem[0 + 1701] = heapMem[localMem[0+1665]*10 + 5];
              ip = 3778;
      end

       3778 :
      begin                                                                     // mov
              localMem[0 + 1702] = heapMem[localMem[0+1701]*10 + localMem[0+1670]];
              ip = 3779;
      end

       3779 :
      begin                                                                     // mov
              localMem[0 + 1703] = heapMem[localMem[0+1672]*10 + 5];
              ip = 3780;
      end

       3780 :
      begin                                                                     // mov
              heapMem[localMem[0+1703]*10 + localMem[0+1695]] = localMem[0+1702];
              ip = 3781;
      end

       3781 :
      begin                                                                     // mov
              localMem[0 + 1704] = heapMem[localMem[0+1665]*10 + 4];
              ip = 3782;
      end

       3782 :
      begin                                                                     // resize
              arraySizes[localMem[0+1704]] = localMem[0+1670];
              ip = 3783;
      end

       3783 :
      begin                                                                     // mov
              localMem[0 + 1705] = heapMem[localMem[0+1665]*10 + 5];
              ip = 3784;
      end

       3784 :
      begin                                                                     // resize
              arraySizes[localMem[0+1705]] = localMem[0+1670];
              ip = 3785;
      end

       3785 :
      begin                                                                     // add
              localMem[0 + 1706] = localMem[0+1695] + 1;
              ip = 3786;
      end

       3786 :
      begin                                                                     // mov
              heapMem[localMem[0+1672]*10 + 0] = localMem[0+1706];
              ip = 3787;
      end

       3787 :
      begin                                                                     // mov
              localMem[0 + 1707] = heapMem[localMem[0+1672]*10 + 6];
              ip = 3788;
      end

       3788 :
      begin                                                                     // mov
              heapMem[localMem[0+1707]*10 + localMem[0+1706]] = localMem[0+1673];
              ip = 3789;
      end

       3789 :
      begin                                                                     // jmp
              ip = 3929;
      end

       3790 :
      begin                                                                     // jmp
              ip = 3813;
      end

       3791 :
      begin                                                                     // label
              ip = 3792;
      end

       3792 :
      begin                                                                     // assertNe
            ip = 3793;
      end

       3793 :
      begin                                                                     // mov
              localMem[0 + 1708] = heapMem[localMem[0+1672]*10 + 6];
              ip = 3794;
      end

       3794 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+1708] * NArea + i] == localMem[0+1665]) localMem[0 + 1709] = i + 1;
              end
              ip = 3795;
      end

       3795 :
      begin                                                                     // subtract
              localMem[0 + 1709] = localMem[0+1709] - 1;
              ip = 3796;
      end

       3796 :
      begin                                                                     // mov
              localMem[0 + 1710] = heapMem[localMem[0+1665]*10 + 4];
              ip = 3797;
      end

       3797 :
      begin                                                                     // mov
              localMem[0 + 1711] = heapMem[localMem[0+1710]*10 + localMem[0+1670]];
              ip = 3798;
      end

       3798 :
      begin                                                                     // mov
              localMem[0 + 1712] = heapMem[localMem[0+1665]*10 + 5];
              ip = 3799;
      end

       3799 :
      begin                                                                     // mov
              localMem[0 + 1713] = heapMem[localMem[0+1712]*10 + localMem[0+1670]];
              ip = 3800;
      end

       3800 :
      begin                                                                     // mov
              localMem[0 + 1714] = heapMem[localMem[0+1665]*10 + 4];
              ip = 3801;
      end

       3801 :
      begin                                                                     // resize
              arraySizes[localMem[0+1714]] = localMem[0+1670];
              ip = 3802;
      end

       3802 :
      begin                                                                     // mov
              localMem[0 + 1715] = heapMem[localMem[0+1665]*10 + 5];
              ip = 3803;
      end

       3803 :
      begin                                                                     // resize
              arraySizes[localMem[0+1715]] = localMem[0+1670];
              ip = 3804;
      end

       3804 :
      begin                                                                     // mov
              localMem[0 + 1716] = heapMem[localMem[0+1672]*10 + 4];
              ip = 3805;
      end

       3805 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1716] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1709]) begin
                  heapMem[NArea * localMem[0+1716] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1716] + localMem[1709]] = localMem[0+1711];                                    // Insert new value
              arraySizes[localMem[0+1716]] = arraySizes[localMem[0+1716]] + 1;                              // Increase array size
              ip = 3806;
      end

       3806 :
      begin                                                                     // mov
              localMem[0 + 1717] = heapMem[localMem[0+1672]*10 + 5];
              ip = 3807;
      end

       3807 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1717] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1709]) begin
                  heapMem[NArea * localMem[0+1717] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1717] + localMem[1709]] = localMem[0+1713];                                    // Insert new value
              arraySizes[localMem[0+1717]] = arraySizes[localMem[0+1717]] + 1;                              // Increase array size
              ip = 3808;
      end

       3808 :
      begin                                                                     // mov
              localMem[0 + 1718] = heapMem[localMem[0+1672]*10 + 6];
              ip = 3809;
      end

       3809 :
      begin                                                                     // add
              localMem[0 + 1719] = localMem[0+1709] + 1;
              ip = 3810;
      end

       3810 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1718] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1719]) begin
                  heapMem[NArea * localMem[0+1718] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1718] + localMem[1719]] = localMem[0+1673];                                    // Insert new value
              arraySizes[localMem[0+1718]] = arraySizes[localMem[0+1718]] + 1;                              // Increase array size
              ip = 3811;
      end

       3811 :
      begin                                                                     // add
              heapMem[localMem[0+1672]*10 + 0] = heapMem[localMem[0+1672]*10 + 0] + 1;
              ip = 3812;
      end

       3812 :
      begin                                                                     // jmp
              ip = 3929;
      end

       3813 :
      begin                                                                     // label
              ip = 3814;
      end

       3814 :
      begin                                                                     // label
              ip = 3815;
      end

       3815 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1720] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1720] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1720]] = 0;
              ip = 3816;
      end

       3816 :
      begin                                                                     // mov
              heapMem[localMem[0+1720]*10 + 0] = localMem[0+1670];
              ip = 3817;
      end

       3817 :
      begin                                                                     // mov
              heapMem[localMem[0+1720]*10 + 2] = 0;
              ip = 3818;
      end

       3818 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1721] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1721] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1721]] = 0;
              ip = 3819;
      end

       3819 :
      begin                                                                     // mov
              heapMem[localMem[0+1720]*10 + 4] = localMem[0+1721];
              ip = 3820;
      end

       3820 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1722] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1722] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1722]] = 0;
              ip = 3821;
      end

       3821 :
      begin                                                                     // mov
              heapMem[localMem[0+1720]*10 + 5] = localMem[0+1722];
              ip = 3822;
      end

       3822 :
      begin                                                                     // mov
              heapMem[localMem[0+1720]*10 + 6] = 0;
              ip = 3823;
      end

       3823 :
      begin                                                                     // mov
              heapMem[localMem[0+1720]*10 + 3] = localMem[0+1668];
              ip = 3824;
      end

       3824 :
      begin                                                                     // add
              heapMem[localMem[0+1668]*10 + 1] = heapMem[localMem[0+1668]*10 + 1] + 1;
              ip = 3825;
      end

       3825 :
      begin                                                                     // mov
              heapMem[localMem[0+1720]*10 + 1] = heapMem[localMem[0+1668]*10 + 1];
              ip = 3826;
      end

       3826 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1723] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1723] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1723]] = 0;
              ip = 3827;
      end

       3827 :
      begin                                                                     // mov
              heapMem[localMem[0+1723]*10 + 0] = localMem[0+1670];
              ip = 3828;
      end

       3828 :
      begin                                                                     // mov
              heapMem[localMem[0+1723]*10 + 2] = 0;
              ip = 3829;
      end

       3829 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1724] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1724] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1724]] = 0;
              ip = 3830;
      end

       3830 :
      begin                                                                     // mov
              heapMem[localMem[0+1723]*10 + 4] = localMem[0+1724];
              ip = 3831;
      end

       3831 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1725] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1725] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1725]] = 0;
              ip = 3832;
      end

       3832 :
      begin                                                                     // mov
              heapMem[localMem[0+1723]*10 + 5] = localMem[0+1725];
              ip = 3833;
      end

       3833 :
      begin                                                                     // mov
              heapMem[localMem[0+1723]*10 + 6] = 0;
              ip = 3834;
      end

       3834 :
      begin                                                                     // mov
              heapMem[localMem[0+1723]*10 + 3] = localMem[0+1668];
              ip = 3835;
      end

       3835 :
      begin                                                                     // add
              heapMem[localMem[0+1668]*10 + 1] = heapMem[localMem[0+1668]*10 + 1] + 1;
              ip = 3836;
      end

       3836 :
      begin                                                                     // mov
              heapMem[localMem[0+1723]*10 + 1] = heapMem[localMem[0+1668]*10 + 1];
              ip = 3837;
      end

       3837 :
      begin                                                                     // not
              localMem[0 + 1726] = !heapMem[localMem[0+1665]*10 + 6];
              ip = 3838;
      end

       3838 :
      begin                                                                     // jNe
              ip = localMem[0+1726] != 0 ? 3890 : 3839;
      end

       3839 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1727] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1727] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1727]] = 0;
              ip = 3840;
      end

       3840 :
      begin                                                                     // mov
              heapMem[localMem[0+1720]*10 + 6] = localMem[0+1727];
              ip = 3841;
      end

       3841 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1728] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1728] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1728]] = 0;
              ip = 3842;
      end

       3842 :
      begin                                                                     // mov
              heapMem[localMem[0+1723]*10 + 6] = localMem[0+1728];
              ip = 3843;
      end

       3843 :
      begin                                                                     // mov
              localMem[0 + 1729] = heapMem[localMem[0+1665]*10 + 4];
              ip = 3844;
      end

       3844 :
      begin                                                                     // mov
              localMem[0 + 1730] = heapMem[localMem[0+1720]*10 + 4];
              ip = 3845;
      end

       3845 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1670]) begin
                  heapMem[NArea * localMem[0+1730] + 0 + i] = heapMem[NArea * localMem[0+1729] + 0 + i];
                end
              end
              ip = 3846;
      end

       3846 :
      begin                                                                     // mov
              localMem[0 + 1731] = heapMem[localMem[0+1665]*10 + 5];
              ip = 3847;
      end

       3847 :
      begin                                                                     // mov
              localMem[0 + 1732] = heapMem[localMem[0+1720]*10 + 5];
              ip = 3848;
      end

       3848 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1670]) begin
                  heapMem[NArea * localMem[0+1732] + 0 + i] = heapMem[NArea * localMem[0+1731] + 0 + i];
                end
              end
              ip = 3849;
      end

       3849 :
      begin                                                                     // mov
              localMem[0 + 1733] = heapMem[localMem[0+1665]*10 + 6];
              ip = 3850;
      end

       3850 :
      begin                                                                     // mov
              localMem[0 + 1734] = heapMem[localMem[0+1720]*10 + 6];
              ip = 3851;
      end

       3851 :
      begin                                                                     // add
              localMem[0 + 1735] = localMem[0+1670] + 1;
              ip = 3852;
      end

       3852 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1735]) begin
                  heapMem[NArea * localMem[0+1734] + 0 + i] = heapMem[NArea * localMem[0+1733] + 0 + i];
                end
              end
              ip = 3853;
      end

       3853 :
      begin                                                                     // mov
              localMem[0 + 1736] = heapMem[localMem[0+1665]*10 + 4];
              ip = 3854;
      end

       3854 :
      begin                                                                     // mov
              localMem[0 + 1737] = heapMem[localMem[0+1723]*10 + 4];
              ip = 3855;
      end

       3855 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1670]) begin
                  heapMem[NArea * localMem[0+1737] + 0 + i] = heapMem[NArea * localMem[0+1736] + localMem[1671] + i];
                end
              end
              ip = 3856;
      end

       3856 :
      begin                                                                     // mov
              localMem[0 + 1738] = heapMem[localMem[0+1665]*10 + 5];
              ip = 3857;
      end

       3857 :
      begin                                                                     // mov
              localMem[0 + 1739] = heapMem[localMem[0+1723]*10 + 5];
              ip = 3858;
      end

       3858 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1670]) begin
                  heapMem[NArea * localMem[0+1739] + 0 + i] = heapMem[NArea * localMem[0+1738] + localMem[1671] + i];
                end
              end
              ip = 3859;
      end

       3859 :
      begin                                                                     // mov
              localMem[0 + 1740] = heapMem[localMem[0+1665]*10 + 6];
              ip = 3860;
      end

       3860 :
      begin                                                                     // mov
              localMem[0 + 1741] = heapMem[localMem[0+1723]*10 + 6];
              ip = 3861;
      end

       3861 :
      begin                                                                     // add
              localMem[0 + 1742] = localMem[0+1670] + 1;
              ip = 3862;
      end

       3862 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1742]) begin
                  heapMem[NArea * localMem[0+1741] + 0 + i] = heapMem[NArea * localMem[0+1740] + localMem[1671] + i];
                end
              end
              ip = 3863;
      end

       3863 :
      begin                                                                     // mov
              localMem[0 + 1743] = heapMem[localMem[0+1720]*10 + 0];
              ip = 3864;
      end

       3864 :
      begin                                                                     // add
              localMem[0 + 1744] = localMem[0+1743] + 1;
              ip = 3865;
      end

       3865 :
      begin                                                                     // mov
              localMem[0 + 1745] = heapMem[localMem[0+1720]*10 + 6];
              ip = 3866;
      end

       3866 :
      begin                                                                     // label
              ip = 3867;
      end

       3867 :
      begin                                                                     // mov
              localMem[0 + 1746] = 0;
              ip = 3868;
      end

       3868 :
      begin                                                                     // label
              ip = 3869;
      end

       3869 :
      begin                                                                     // jGe
              ip = localMem[0+1746] >= localMem[0+1744] ? 3875 : 3870;
      end

       3870 :
      begin                                                                     // mov
              localMem[0 + 1747] = heapMem[localMem[0+1745]*10 + localMem[0+1746]];
              ip = 3871;
      end

       3871 :
      begin                                                                     // mov
              heapMem[localMem[0+1747]*10 + 2] = localMem[0+1720];
              ip = 3872;
      end

       3872 :
      begin                                                                     // label
              ip = 3873;
      end

       3873 :
      begin                                                                     // add
              localMem[0 + 1746] = localMem[0+1746] + 1;
              ip = 3874;
      end

       3874 :
      begin                                                                     // jmp
              ip = 3868;
      end

       3875 :
      begin                                                                     // label
              ip = 3876;
      end

       3876 :
      begin                                                                     // mov
              localMem[0 + 1748] = heapMem[localMem[0+1723]*10 + 0];
              ip = 3877;
      end

       3877 :
      begin                                                                     // add
              localMem[0 + 1749] = localMem[0+1748] + 1;
              ip = 3878;
      end

       3878 :
      begin                                                                     // mov
              localMem[0 + 1750] = heapMem[localMem[0+1723]*10 + 6];
              ip = 3879;
      end

       3879 :
      begin                                                                     // label
              ip = 3880;
      end

       3880 :
      begin                                                                     // mov
              localMem[0 + 1751] = 0;
              ip = 3881;
      end

       3881 :
      begin                                                                     // label
              ip = 3882;
      end

       3882 :
      begin                                                                     // jGe
              ip = localMem[0+1751] >= localMem[0+1749] ? 3888 : 3883;
      end

       3883 :
      begin                                                                     // mov
              localMem[0 + 1752] = heapMem[localMem[0+1750]*10 + localMem[0+1751]];
              ip = 3884;
      end

       3884 :
      begin                                                                     // mov
              heapMem[localMem[0+1752]*10 + 2] = localMem[0+1723];
              ip = 3885;
      end

       3885 :
      begin                                                                     // label
              ip = 3886;
      end

       3886 :
      begin                                                                     // add
              localMem[0 + 1751] = localMem[0+1751] + 1;
              ip = 3887;
      end

       3887 :
      begin                                                                     // jmp
              ip = 3881;
      end

       3888 :
      begin                                                                     // label
              ip = 3889;
      end

       3889 :
      begin                                                                     // jmp
              ip = 3905;
      end

       3890 :
      begin                                                                     // label
              ip = 3891;
      end

       3891 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1753] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1753] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1753]] = 0;
              ip = 3892;
      end

       3892 :
      begin                                                                     // mov
              heapMem[localMem[0+1665]*10 + 6] = localMem[0+1753];
              ip = 3893;
      end

       3893 :
      begin                                                                     // mov
              localMem[0 + 1754] = heapMem[localMem[0+1665]*10 + 4];
              ip = 3894;
      end

       3894 :
      begin                                                                     // mov
              localMem[0 + 1755] = heapMem[localMem[0+1720]*10 + 4];
              ip = 3895;
      end

       3895 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1670]) begin
                  heapMem[NArea * localMem[0+1755] + 0 + i] = heapMem[NArea * localMem[0+1754] + 0 + i];
                end
              end
              ip = 3896;
      end

       3896 :
      begin                                                                     // mov
              localMem[0 + 1756] = heapMem[localMem[0+1665]*10 + 5];
              ip = 3897;
      end

       3897 :
      begin                                                                     // mov
              localMem[0 + 1757] = heapMem[localMem[0+1720]*10 + 5];
              ip = 3898;
      end

       3898 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1670]) begin
                  heapMem[NArea * localMem[0+1757] + 0 + i] = heapMem[NArea * localMem[0+1756] + 0 + i];
                end
              end
              ip = 3899;
      end

       3899 :
      begin                                                                     // mov
              localMem[0 + 1758] = heapMem[localMem[0+1665]*10 + 4];
              ip = 3900;
      end

       3900 :
      begin                                                                     // mov
              localMem[0 + 1759] = heapMem[localMem[0+1723]*10 + 4];
              ip = 3901;
      end

       3901 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1670]) begin
                  heapMem[NArea * localMem[0+1759] + 0 + i] = heapMem[NArea * localMem[0+1758] + localMem[1671] + i];
                end
              end
              ip = 3902;
      end

       3902 :
      begin                                                                     // mov
              localMem[0 + 1760] = heapMem[localMem[0+1665]*10 + 5];
              ip = 3903;
      end

       3903 :
      begin                                                                     // mov
              localMem[0 + 1761] = heapMem[localMem[0+1723]*10 + 5];
              ip = 3904;
      end

       3904 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1670]) begin
                  heapMem[NArea * localMem[0+1761] + 0 + i] = heapMem[NArea * localMem[0+1760] + localMem[1671] + i];
                end
              end
              ip = 3905;
      end

       3905 :
      begin                                                                     // label
              ip = 3906;
      end

       3906 :
      begin                                                                     // mov
              heapMem[localMem[0+1720]*10 + 2] = localMem[0+1665];
              ip = 3907;
      end

       3907 :
      begin                                                                     // mov
              heapMem[localMem[0+1723]*10 + 2] = localMem[0+1665];
              ip = 3908;
      end

       3908 :
      begin                                                                     // mov
              localMem[0 + 1762] = heapMem[localMem[0+1665]*10 + 4];
              ip = 3909;
      end

       3909 :
      begin                                                                     // mov
              localMem[0 + 1763] = heapMem[localMem[0+1762]*10 + localMem[0+1670]];
              ip = 3910;
      end

       3910 :
      begin                                                                     // mov
              localMem[0 + 1764] = heapMem[localMem[0+1665]*10 + 5];
              ip = 3911;
      end

       3911 :
      begin                                                                     // mov
              localMem[0 + 1765] = heapMem[localMem[0+1764]*10 + localMem[0+1670]];
              ip = 3912;
      end

       3912 :
      begin                                                                     // mov
              localMem[0 + 1766] = heapMem[localMem[0+1665]*10 + 4];
              ip = 3913;
      end

       3913 :
      begin                                                                     // mov
              heapMem[localMem[0+1766]*10 + 0] = localMem[0+1763];
              ip = 3914;
      end

       3914 :
      begin                                                                     // mov
              localMem[0 + 1767] = heapMem[localMem[0+1665]*10 + 5];
              ip = 3915;
      end

       3915 :
      begin                                                                     // mov
              heapMem[localMem[0+1767]*10 + 0] = localMem[0+1765];
              ip = 3916;
      end

       3916 :
      begin                                                                     // mov
              localMem[0 + 1768] = heapMem[localMem[0+1665]*10 + 6];
              ip = 3917;
      end

       3917 :
      begin                                                                     // mov
              heapMem[localMem[0+1768]*10 + 0] = localMem[0+1720];
              ip = 3918;
      end

       3918 :
      begin                                                                     // mov
              localMem[0 + 1769] = heapMem[localMem[0+1665]*10 + 6];
              ip = 3919;
      end

       3919 :
      begin                                                                     // mov
              heapMem[localMem[0+1769]*10 + 1] = localMem[0+1723];
              ip = 3920;
      end

       3920 :
      begin                                                                     // mov
              heapMem[localMem[0+1665]*10 + 0] = 1;
              ip = 3921;
      end

       3921 :
      begin                                                                     // mov
              localMem[0 + 1770] = heapMem[localMem[0+1665]*10 + 4];
              ip = 3922;
      end

       3922 :
      begin                                                                     // resize
              arraySizes[localMem[0+1770]] = 1;
              ip = 3923;
      end

       3923 :
      begin                                                                     // mov
              localMem[0 + 1771] = heapMem[localMem[0+1665]*10 + 5];
              ip = 3924;
      end

       3924 :
      begin                                                                     // resize
              arraySizes[localMem[0+1771]] = 1;
              ip = 3925;
      end

       3925 :
      begin                                                                     // mov
              localMem[0 + 1772] = heapMem[localMem[0+1665]*10 + 6];
              ip = 3926;
      end

       3926 :
      begin                                                                     // resize
              arraySizes[localMem[0+1772]] = 2;
              ip = 3927;
      end

       3927 :
      begin                                                                     // jmp
              ip = 3929;
      end

       3928 :
      begin                                                                     // jmp
              ip = 3934;
      end

       3929 :
      begin                                                                     // label
              ip = 3930;
      end

       3930 :
      begin                                                                     // mov
              localMem[0 + 1666] = 1;
              ip = 3931;
      end

       3931 :
      begin                                                                     // jmp
              ip = 3934;
      end

       3932 :
      begin                                                                     // label
              ip = 3933;
      end

       3933 :
      begin                                                                     // mov
              localMem[0 + 1666] = 0;
              ip = 3934;
      end

       3934 :
      begin                                                                     // label
              ip = 3935;
      end

       3935 :
      begin                                                                     // jNe
              ip = localMem[0+1666] != 0 ? 3937 : 3936;
      end

       3936 :
      begin                                                                     // mov
              localMem[0 + 1437] = localMem[0+1665];
              ip = 3937;
      end

       3937 :
      begin                                                                     // label
              ip = 3938;
      end

       3938 :
      begin                                                                     // label
              ip = 3939;
      end

       3939 :
      begin                                                                     // add
              localMem[0 + 1545] = localMem[0+1545] + 1;
              ip = 3940;
      end

       3940 :
      begin                                                                     // jmp
              ip = 3442;
      end

       3941 :
      begin                                                                     // label
              ip = 3942;
      end

       3942 :
      begin                                                                     // assert
            ip = 3943;
      end

       3943 :
      begin                                                                     // label
              ip = 3944;
      end

       3944 :
      begin                                                                     // label
              ip = 3945;
      end

       3945 :
      begin                                                                     // label
              ip = 3946;
      end

       3946 :
      begin                                                                     // mov
              localMem[0 + 1773] = heapMem[localMem[0+1417]*10 + 0];
              ip = 3947;
      end

       3947 :
      begin                                                                     // mov
              localMem[0 + 1774] = heapMem[localMem[0+1417]*10 + 1];
              ip = 3948;
      end

       3948 :
      begin                                                                     // mov
              localMem[0 + 1775] = heapMem[localMem[0+1417]*10 + 2];
              ip = 3949;
      end

       3949 :
      begin                                                                     // jNe
              ip = localMem[0+1774] != 1 ? 3953 : 3950;
      end

       3950 :
      begin                                                                     // mov
              localMem[0 + 1776] = heapMem[localMem[0+1773]*10 + 5];
              ip = 3951;
      end

       3951 :
      begin                                                                     // mov
              heapMem[localMem[0+1776]*10 + localMem[0+1775]] = 44;
              ip = 3952;
      end

       3952 :
      begin                                                                     // jmp
              ip = 4199;
      end

       3953 :
      begin                                                                     // label
              ip = 3954;
      end

       3954 :
      begin                                                                     // jNe
              ip = localMem[0+1774] != 2 ? 3962 : 3955;
      end

       3955 :
      begin                                                                     // add
              localMem[0 + 1777] = localMem[0+1775] + 1;
              ip = 3956;
      end

       3956 :
      begin                                                                     // mov
              localMem[0 + 1778] = heapMem[localMem[0+1773]*10 + 4];
              ip = 3957;
      end

       3957 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1778] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1777]) begin
                  heapMem[NArea * localMem[0+1778] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1778] + localMem[1777]] = 4;                                    // Insert new value
              arraySizes[localMem[0+1778]] = arraySizes[localMem[0+1778]] + 1;                              // Increase array size
              ip = 3958;
      end

       3958 :
      begin                                                                     // mov
              localMem[0 + 1779] = heapMem[localMem[0+1773]*10 + 5];
              ip = 3959;
      end

       3959 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1779] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1777]) begin
                  heapMem[NArea * localMem[0+1779] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1779] + localMem[1777]] = 44;                                    // Insert new value
              arraySizes[localMem[0+1779]] = arraySizes[localMem[0+1779]] + 1;                              // Increase array size
              ip = 3960;
      end

       3960 :
      begin                                                                     // add
              heapMem[localMem[0+1773]*10 + 0] = heapMem[localMem[0+1773]*10 + 0] + 1;
              ip = 3961;
      end

       3961 :
      begin                                                                     // jmp
              ip = 3968;
      end

       3962 :
      begin                                                                     // label
              ip = 3963;
      end

       3963 :
      begin                                                                     // mov
              localMem[0 + 1780] = heapMem[localMem[0+1773]*10 + 4];
              ip = 3964;
      end

       3964 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1780] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1775]) begin
                  heapMem[NArea * localMem[0+1780] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1780] + localMem[1775]] = 4;                                    // Insert new value
              arraySizes[localMem[0+1780]] = arraySizes[localMem[0+1780]] + 1;                              // Increase array size
              ip = 3965;
      end

       3965 :
      begin                                                                     // mov
              localMem[0 + 1781] = heapMem[localMem[0+1773]*10 + 5];
              ip = 3966;
      end

       3966 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1781] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1775]) begin
                  heapMem[NArea * localMem[0+1781] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1781] + localMem[1775]] = 44;                                    // Insert new value
              arraySizes[localMem[0+1781]] = arraySizes[localMem[0+1781]] + 1;                              // Increase array size
              ip = 3967;
      end

       3967 :
      begin                                                                     // add
              heapMem[localMem[0+1773]*10 + 0] = heapMem[localMem[0+1773]*10 + 0] + 1;
              ip = 3968;
      end

       3968 :
      begin                                                                     // label
              ip = 3969;
      end

       3969 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 3970;
      end

       3970 :
      begin                                                                     // label
              ip = 3971;
      end

       3971 :
      begin                                                                     // mov
              localMem[0 + 1783] = heapMem[localMem[0+1773]*10 + 0];
              ip = 3972;
      end

       3972 :
      begin                                                                     // mov
              localMem[0 + 1784] = heapMem[localMem[0+1773]*10 + 3];
              ip = 3973;
      end

       3973 :
      begin                                                                     // mov
              localMem[0 + 1785] = heapMem[localMem[0+1784]*10 + 2];
              ip = 3974;
      end

       3974 :
      begin                                                                     // jLt
              ip = localMem[0+1783] <  localMem[0+1785] ? 4194 : 3975;
      end

       3975 :
      begin                                                                     // mov
              localMem[0 + 1786] = localMem[0+1785];
              ip = 3976;
      end

       3976 :
      begin                                                                     // shiftRight
              localMem[0 + 1786] = localMem[0+1786] >> 1;
              ip = 3977;
      end

       3977 :
      begin                                                                     // add
              localMem[0 + 1787] = localMem[0+1786] + 1;
              ip = 3978;
      end

       3978 :
      begin                                                                     // mov
              localMem[0 + 1788] = heapMem[localMem[0+1773]*10 + 2];
              ip = 3979;
      end

       3979 :
      begin                                                                     // jEq
              ip = localMem[0+1788] == 0 ? 4076 : 3980;
      end

       3980 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1789] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1789] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1789]] = 0;
              ip = 3981;
      end

       3981 :
      begin                                                                     // mov
              heapMem[localMem[0+1789]*10 + 0] = localMem[0+1786];
              ip = 3982;
      end

       3982 :
      begin                                                                     // mov
              heapMem[localMem[0+1789]*10 + 2] = 0;
              ip = 3983;
      end

       3983 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1790] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1790] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1790]] = 0;
              ip = 3984;
      end

       3984 :
      begin                                                                     // mov
              heapMem[localMem[0+1789]*10 + 4] = localMem[0+1790];
              ip = 3985;
      end

       3985 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1791] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1791] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1791]] = 0;
              ip = 3986;
      end

       3986 :
      begin                                                                     // mov
              heapMem[localMem[0+1789]*10 + 5] = localMem[0+1791];
              ip = 3987;
      end

       3987 :
      begin                                                                     // mov
              heapMem[localMem[0+1789]*10 + 6] = 0;
              ip = 3988;
      end

       3988 :
      begin                                                                     // mov
              heapMem[localMem[0+1789]*10 + 3] = localMem[0+1784];
              ip = 3989;
      end

       3989 :
      begin                                                                     // add
              heapMem[localMem[0+1784]*10 + 1] = heapMem[localMem[0+1784]*10 + 1] + 1;
              ip = 3990;
      end

       3990 :
      begin                                                                     // mov
              heapMem[localMem[0+1789]*10 + 1] = heapMem[localMem[0+1784]*10 + 1];
              ip = 3991;
      end

       3991 :
      begin                                                                     // not
              localMem[0 + 1792] = !heapMem[localMem[0+1773]*10 + 6];
              ip = 3992;
      end

       3992 :
      begin                                                                     // jNe
              ip = localMem[0+1792] != 0 ? 4021 : 3993;
      end

       3993 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1793] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1793] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1793]] = 0;
              ip = 3994;
      end

       3994 :
      begin                                                                     // mov
              heapMem[localMem[0+1789]*10 + 6] = localMem[0+1793];
              ip = 3995;
      end

       3995 :
      begin                                                                     // mov
              localMem[0 + 1794] = heapMem[localMem[0+1773]*10 + 4];
              ip = 3996;
      end

       3996 :
      begin                                                                     // mov
              localMem[0 + 1795] = heapMem[localMem[0+1789]*10 + 4];
              ip = 3997;
      end

       3997 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1786]) begin
                  heapMem[NArea * localMem[0+1795] + 0 + i] = heapMem[NArea * localMem[0+1794] + localMem[1787] + i];
                end
              end
              ip = 3998;
      end

       3998 :
      begin                                                                     // mov
              localMem[0 + 1796] = heapMem[localMem[0+1773]*10 + 5];
              ip = 3999;
      end

       3999 :
      begin                                                                     // mov
              localMem[0 + 1797] = heapMem[localMem[0+1789]*10 + 5];
              ip = 4000;
      end

       4000 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1786]) begin
                  heapMem[NArea * localMem[0+1797] + 0 + i] = heapMem[NArea * localMem[0+1796] + localMem[1787] + i];
                end
              end
              ip = 4001;
      end

       4001 :
      begin                                                                     // mov
              localMem[0 + 1798] = heapMem[localMem[0+1773]*10 + 6];
              ip = 4002;
      end

       4002 :
      begin                                                                     // mov
              localMem[0 + 1799] = heapMem[localMem[0+1789]*10 + 6];
              ip = 4003;
      end

       4003 :
      begin                                                                     // add
              localMem[0 + 1800] = localMem[0+1786] + 1;
              ip = 4004;
      end

       4004 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1800]) begin
                  heapMem[NArea * localMem[0+1799] + 0 + i] = heapMem[NArea * localMem[0+1798] + localMem[1787] + i];
                end
              end
              ip = 4005;
      end

       4005 :
      begin                                                                     // mov
              localMem[0 + 1801] = heapMem[localMem[0+1789]*10 + 0];
              ip = 4006;
      end

       4006 :
      begin                                                                     // add
              localMem[0 + 1802] = localMem[0+1801] + 1;
              ip = 4007;
      end

       4007 :
      begin                                                                     // mov
              localMem[0 + 1803] = heapMem[localMem[0+1789]*10 + 6];
              ip = 4008;
      end

       4008 :
      begin                                                                     // label
              ip = 4009;
      end

       4009 :
      begin                                                                     // mov
              localMem[0 + 1804] = 0;
              ip = 4010;
      end

       4010 :
      begin                                                                     // label
              ip = 4011;
      end

       4011 :
      begin                                                                     // jGe
              ip = localMem[0+1804] >= localMem[0+1802] ? 4017 : 4012;
      end

       4012 :
      begin                                                                     // mov
              localMem[0 + 1805] = heapMem[localMem[0+1803]*10 + localMem[0+1804]];
              ip = 4013;
      end

       4013 :
      begin                                                                     // mov
              heapMem[localMem[0+1805]*10 + 2] = localMem[0+1789];
              ip = 4014;
      end

       4014 :
      begin                                                                     // label
              ip = 4015;
      end

       4015 :
      begin                                                                     // add
              localMem[0 + 1804] = localMem[0+1804] + 1;
              ip = 4016;
      end

       4016 :
      begin                                                                     // jmp
              ip = 4010;
      end

       4017 :
      begin                                                                     // label
              ip = 4018;
      end

       4018 :
      begin                                                                     // mov
              localMem[0 + 1806] = heapMem[localMem[0+1773]*10 + 6];
              ip = 4019;
      end

       4019 :
      begin                                                                     // resize
              arraySizes[localMem[0+1806]] = localMem[0+1787];
              ip = 4020;
      end

       4020 :
      begin                                                                     // jmp
              ip = 4028;
      end

       4021 :
      begin                                                                     // label
              ip = 4022;
      end

       4022 :
      begin                                                                     // mov
              localMem[0 + 1807] = heapMem[localMem[0+1773]*10 + 4];
              ip = 4023;
      end

       4023 :
      begin                                                                     // mov
              localMem[0 + 1808] = heapMem[localMem[0+1789]*10 + 4];
              ip = 4024;
      end

       4024 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1786]) begin
                  heapMem[NArea * localMem[0+1808] + 0 + i] = heapMem[NArea * localMem[0+1807] + localMem[1787] + i];
                end
              end
              ip = 4025;
      end

       4025 :
      begin                                                                     // mov
              localMem[0 + 1809] = heapMem[localMem[0+1773]*10 + 5];
              ip = 4026;
      end

       4026 :
      begin                                                                     // mov
              localMem[0 + 1810] = heapMem[localMem[0+1789]*10 + 5];
              ip = 4027;
      end

       4027 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1786]) begin
                  heapMem[NArea * localMem[0+1810] + 0 + i] = heapMem[NArea * localMem[0+1809] + localMem[1787] + i];
                end
              end
              ip = 4028;
      end

       4028 :
      begin                                                                     // label
              ip = 4029;
      end

       4029 :
      begin                                                                     // mov
              heapMem[localMem[0+1773]*10 + 0] = localMem[0+1786];
              ip = 4030;
      end

       4030 :
      begin                                                                     // mov
              heapMem[localMem[0+1789]*10 + 2] = localMem[0+1788];
              ip = 4031;
      end

       4031 :
      begin                                                                     // mov
              localMem[0 + 1811] = heapMem[localMem[0+1788]*10 + 0];
              ip = 4032;
      end

       4032 :
      begin                                                                     // mov
              localMem[0 + 1812] = heapMem[localMem[0+1788]*10 + 6];
              ip = 4033;
      end

       4033 :
      begin                                                                     // mov
              localMem[0 + 1813] = heapMem[localMem[0+1812]*10 + localMem[0+1811]];
              ip = 4034;
      end

       4034 :
      begin                                                                     // jNe
              ip = localMem[0+1813] != localMem[0+1773] ? 4053 : 4035;
      end

       4035 :
      begin                                                                     // mov
              localMem[0 + 1814] = heapMem[localMem[0+1773]*10 + 4];
              ip = 4036;
      end

       4036 :
      begin                                                                     // mov
              localMem[0 + 1815] = heapMem[localMem[0+1814]*10 + localMem[0+1786]];
              ip = 4037;
      end

       4037 :
      begin                                                                     // mov
              localMem[0 + 1816] = heapMem[localMem[0+1788]*10 + 4];
              ip = 4038;
      end

       4038 :
      begin                                                                     // mov
              heapMem[localMem[0+1816]*10 + localMem[0+1811]] = localMem[0+1815];
              ip = 4039;
      end

       4039 :
      begin                                                                     // mov
              localMem[0 + 1817] = heapMem[localMem[0+1773]*10 + 5];
              ip = 4040;
      end

       4040 :
      begin                                                                     // mov
              localMem[0 + 1818] = heapMem[localMem[0+1817]*10 + localMem[0+1786]];
              ip = 4041;
      end

       4041 :
      begin                                                                     // mov
              localMem[0 + 1819] = heapMem[localMem[0+1788]*10 + 5];
              ip = 4042;
      end

       4042 :
      begin                                                                     // mov
              heapMem[localMem[0+1819]*10 + localMem[0+1811]] = localMem[0+1818];
              ip = 4043;
      end

       4043 :
      begin                                                                     // mov
              localMem[0 + 1820] = heapMem[localMem[0+1773]*10 + 4];
              ip = 4044;
      end

       4044 :
      begin                                                                     // resize
              arraySizes[localMem[0+1820]] = localMem[0+1786];
              ip = 4045;
      end

       4045 :
      begin                                                                     // mov
              localMem[0 + 1821] = heapMem[localMem[0+1773]*10 + 5];
              ip = 4046;
      end

       4046 :
      begin                                                                     // resize
              arraySizes[localMem[0+1821]] = localMem[0+1786];
              ip = 4047;
      end

       4047 :
      begin                                                                     // add
              localMem[0 + 1822] = localMem[0+1811] + 1;
              ip = 4048;
      end

       4048 :
      begin                                                                     // mov
              heapMem[localMem[0+1788]*10 + 0] = localMem[0+1822];
              ip = 4049;
      end

       4049 :
      begin                                                                     // mov
              localMem[0 + 1823] = heapMem[localMem[0+1788]*10 + 6];
              ip = 4050;
      end

       4050 :
      begin                                                                     // mov
              heapMem[localMem[0+1823]*10 + localMem[0+1822]] = localMem[0+1789];
              ip = 4051;
      end

       4051 :
      begin                                                                     // jmp
              ip = 4191;
      end

       4052 :
      begin                                                                     // jmp
              ip = 4075;
      end

       4053 :
      begin                                                                     // label
              ip = 4054;
      end

       4054 :
      begin                                                                     // assertNe
            ip = 4055;
      end

       4055 :
      begin                                                                     // mov
              localMem[0 + 1824] = heapMem[localMem[0+1788]*10 + 6];
              ip = 4056;
      end

       4056 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+1824] * NArea + i] == localMem[0+1773]) localMem[0 + 1825] = i + 1;
              end
              ip = 4057;
      end

       4057 :
      begin                                                                     // subtract
              localMem[0 + 1825] = localMem[0+1825] - 1;
              ip = 4058;
      end

       4058 :
      begin                                                                     // mov
              localMem[0 + 1826] = heapMem[localMem[0+1773]*10 + 4];
              ip = 4059;
      end

       4059 :
      begin                                                                     // mov
              localMem[0 + 1827] = heapMem[localMem[0+1826]*10 + localMem[0+1786]];
              ip = 4060;
      end

       4060 :
      begin                                                                     // mov
              localMem[0 + 1828] = heapMem[localMem[0+1773]*10 + 5];
              ip = 4061;
      end

       4061 :
      begin                                                                     // mov
              localMem[0 + 1829] = heapMem[localMem[0+1828]*10 + localMem[0+1786]];
              ip = 4062;
      end

       4062 :
      begin                                                                     // mov
              localMem[0 + 1830] = heapMem[localMem[0+1773]*10 + 4];
              ip = 4063;
      end

       4063 :
      begin                                                                     // resize
              arraySizes[localMem[0+1830]] = localMem[0+1786];
              ip = 4064;
      end

       4064 :
      begin                                                                     // mov
              localMem[0 + 1831] = heapMem[localMem[0+1773]*10 + 5];
              ip = 4065;
      end

       4065 :
      begin                                                                     // resize
              arraySizes[localMem[0+1831]] = localMem[0+1786];
              ip = 4066;
      end

       4066 :
      begin                                                                     // mov
              localMem[0 + 1832] = heapMem[localMem[0+1788]*10 + 4];
              ip = 4067;
      end

       4067 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1832] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1825]) begin
                  heapMem[NArea * localMem[0+1832] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1832] + localMem[1825]] = localMem[0+1827];                                    // Insert new value
              arraySizes[localMem[0+1832]] = arraySizes[localMem[0+1832]] + 1;                              // Increase array size
              ip = 4068;
      end

       4068 :
      begin                                                                     // mov
              localMem[0 + 1833] = heapMem[localMem[0+1788]*10 + 5];
              ip = 4069;
      end

       4069 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1833] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1825]) begin
                  heapMem[NArea * localMem[0+1833] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1833] + localMem[1825]] = localMem[0+1829];                                    // Insert new value
              arraySizes[localMem[0+1833]] = arraySizes[localMem[0+1833]] + 1;                              // Increase array size
              ip = 4070;
      end

       4070 :
      begin                                                                     // mov
              localMem[0 + 1834] = heapMem[localMem[0+1788]*10 + 6];
              ip = 4071;
      end

       4071 :
      begin                                                                     // add
              localMem[0 + 1835] = localMem[0+1825] + 1;
              ip = 4072;
      end

       4072 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1834] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1835]) begin
                  heapMem[NArea * localMem[0+1834] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1834] + localMem[1835]] = localMem[0+1789];                                    // Insert new value
              arraySizes[localMem[0+1834]] = arraySizes[localMem[0+1834]] + 1;                              // Increase array size
              ip = 4073;
      end

       4073 :
      begin                                                                     // add
              heapMem[localMem[0+1788]*10 + 0] = heapMem[localMem[0+1788]*10 + 0] + 1;
              ip = 4074;
      end

       4074 :
      begin                                                                     // jmp
              ip = 4191;
      end

       4075 :
      begin                                                                     // label
              ip = 4076;
      end

       4076 :
      begin                                                                     // label
              ip = 4077;
      end

       4077 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1836] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1836] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1836]] = 0;
              ip = 4078;
      end

       4078 :
      begin                                                                     // mov
              heapMem[localMem[0+1836]*10 + 0] = localMem[0+1786];
              ip = 4079;
      end

       4079 :
      begin                                                                     // mov
              heapMem[localMem[0+1836]*10 + 2] = 0;
              ip = 4080;
      end

       4080 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1837] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1837] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1837]] = 0;
              ip = 4081;
      end

       4081 :
      begin                                                                     // mov
              heapMem[localMem[0+1836]*10 + 4] = localMem[0+1837];
              ip = 4082;
      end

       4082 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1838] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1838] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1838]] = 0;
              ip = 4083;
      end

       4083 :
      begin                                                                     // mov
              heapMem[localMem[0+1836]*10 + 5] = localMem[0+1838];
              ip = 4084;
      end

       4084 :
      begin                                                                     // mov
              heapMem[localMem[0+1836]*10 + 6] = 0;
              ip = 4085;
      end

       4085 :
      begin                                                                     // mov
              heapMem[localMem[0+1836]*10 + 3] = localMem[0+1784];
              ip = 4086;
      end

       4086 :
      begin                                                                     // add
              heapMem[localMem[0+1784]*10 + 1] = heapMem[localMem[0+1784]*10 + 1] + 1;
              ip = 4087;
      end

       4087 :
      begin                                                                     // mov
              heapMem[localMem[0+1836]*10 + 1] = heapMem[localMem[0+1784]*10 + 1];
              ip = 4088;
      end

       4088 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1839] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1839] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1839]] = 0;
              ip = 4089;
      end

       4089 :
      begin                                                                     // mov
              heapMem[localMem[0+1839]*10 + 0] = localMem[0+1786];
              ip = 4090;
      end

       4090 :
      begin                                                                     // mov
              heapMem[localMem[0+1839]*10 + 2] = 0;
              ip = 4091;
      end

       4091 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1840] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1840] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1840]] = 0;
              ip = 4092;
      end

       4092 :
      begin                                                                     // mov
              heapMem[localMem[0+1839]*10 + 4] = localMem[0+1840];
              ip = 4093;
      end

       4093 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1841] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1841] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1841]] = 0;
              ip = 4094;
      end

       4094 :
      begin                                                                     // mov
              heapMem[localMem[0+1839]*10 + 5] = localMem[0+1841];
              ip = 4095;
      end

       4095 :
      begin                                                                     // mov
              heapMem[localMem[0+1839]*10 + 6] = 0;
              ip = 4096;
      end

       4096 :
      begin                                                                     // mov
              heapMem[localMem[0+1839]*10 + 3] = localMem[0+1784];
              ip = 4097;
      end

       4097 :
      begin                                                                     // add
              heapMem[localMem[0+1784]*10 + 1] = heapMem[localMem[0+1784]*10 + 1] + 1;
              ip = 4098;
      end

       4098 :
      begin                                                                     // mov
              heapMem[localMem[0+1839]*10 + 1] = heapMem[localMem[0+1784]*10 + 1];
              ip = 4099;
      end

       4099 :
      begin                                                                     // not
              localMem[0 + 1842] = !heapMem[localMem[0+1773]*10 + 6];
              ip = 4100;
      end

       4100 :
      begin                                                                     // jNe
              ip = localMem[0+1842] != 0 ? 4152 : 4101;
      end

       4101 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1843] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1843] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1843]] = 0;
              ip = 4102;
      end

       4102 :
      begin                                                                     // mov
              heapMem[localMem[0+1836]*10 + 6] = localMem[0+1843];
              ip = 4103;
      end

       4103 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1844] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1844] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1844]] = 0;
              ip = 4104;
      end

       4104 :
      begin                                                                     // mov
              heapMem[localMem[0+1839]*10 + 6] = localMem[0+1844];
              ip = 4105;
      end

       4105 :
      begin                                                                     // mov
              localMem[0 + 1845] = heapMem[localMem[0+1773]*10 + 4];
              ip = 4106;
      end

       4106 :
      begin                                                                     // mov
              localMem[0 + 1846] = heapMem[localMem[0+1836]*10 + 4];
              ip = 4107;
      end

       4107 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1786]) begin
                  heapMem[NArea * localMem[0+1846] + 0 + i] = heapMem[NArea * localMem[0+1845] + 0 + i];
                end
              end
              ip = 4108;
      end

       4108 :
      begin                                                                     // mov
              localMem[0 + 1847] = heapMem[localMem[0+1773]*10 + 5];
              ip = 4109;
      end

       4109 :
      begin                                                                     // mov
              localMem[0 + 1848] = heapMem[localMem[0+1836]*10 + 5];
              ip = 4110;
      end

       4110 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1786]) begin
                  heapMem[NArea * localMem[0+1848] + 0 + i] = heapMem[NArea * localMem[0+1847] + 0 + i];
                end
              end
              ip = 4111;
      end

       4111 :
      begin                                                                     // mov
              localMem[0 + 1849] = heapMem[localMem[0+1773]*10 + 6];
              ip = 4112;
      end

       4112 :
      begin                                                                     // mov
              localMem[0 + 1850] = heapMem[localMem[0+1836]*10 + 6];
              ip = 4113;
      end

       4113 :
      begin                                                                     // add
              localMem[0 + 1851] = localMem[0+1786] + 1;
              ip = 4114;
      end

       4114 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1851]) begin
                  heapMem[NArea * localMem[0+1850] + 0 + i] = heapMem[NArea * localMem[0+1849] + 0 + i];
                end
              end
              ip = 4115;
      end

       4115 :
      begin                                                                     // mov
              localMem[0 + 1852] = heapMem[localMem[0+1773]*10 + 4];
              ip = 4116;
      end

       4116 :
      begin                                                                     // mov
              localMem[0 + 1853] = heapMem[localMem[0+1839]*10 + 4];
              ip = 4117;
      end

       4117 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1786]) begin
                  heapMem[NArea * localMem[0+1853] + 0 + i] = heapMem[NArea * localMem[0+1852] + localMem[1787] + i];
                end
              end
              ip = 4118;
      end

       4118 :
      begin                                                                     // mov
              localMem[0 + 1854] = heapMem[localMem[0+1773]*10 + 5];
              ip = 4119;
      end

       4119 :
      begin                                                                     // mov
              localMem[0 + 1855] = heapMem[localMem[0+1839]*10 + 5];
              ip = 4120;
      end

       4120 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1786]) begin
                  heapMem[NArea * localMem[0+1855] + 0 + i] = heapMem[NArea * localMem[0+1854] + localMem[1787] + i];
                end
              end
              ip = 4121;
      end

       4121 :
      begin                                                                     // mov
              localMem[0 + 1856] = heapMem[localMem[0+1773]*10 + 6];
              ip = 4122;
      end

       4122 :
      begin                                                                     // mov
              localMem[0 + 1857] = heapMem[localMem[0+1839]*10 + 6];
              ip = 4123;
      end

       4123 :
      begin                                                                     // add
              localMem[0 + 1858] = localMem[0+1786] + 1;
              ip = 4124;
      end

       4124 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1858]) begin
                  heapMem[NArea * localMem[0+1857] + 0 + i] = heapMem[NArea * localMem[0+1856] + localMem[1787] + i];
                end
              end
              ip = 4125;
      end

       4125 :
      begin                                                                     // mov
              localMem[0 + 1859] = heapMem[localMem[0+1836]*10 + 0];
              ip = 4126;
      end

       4126 :
      begin                                                                     // add
              localMem[0 + 1860] = localMem[0+1859] + 1;
              ip = 4127;
      end

       4127 :
      begin                                                                     // mov
              localMem[0 + 1861] = heapMem[localMem[0+1836]*10 + 6];
              ip = 4128;
      end

       4128 :
      begin                                                                     // label
              ip = 4129;
      end

       4129 :
      begin                                                                     // mov
              localMem[0 + 1862] = 0;
              ip = 4130;
      end

       4130 :
      begin                                                                     // label
              ip = 4131;
      end

       4131 :
      begin                                                                     // jGe
              ip = localMem[0+1862] >= localMem[0+1860] ? 4137 : 4132;
      end

       4132 :
      begin                                                                     // mov
              localMem[0 + 1863] = heapMem[localMem[0+1861]*10 + localMem[0+1862]];
              ip = 4133;
      end

       4133 :
      begin                                                                     // mov
              heapMem[localMem[0+1863]*10 + 2] = localMem[0+1836];
              ip = 4134;
      end

       4134 :
      begin                                                                     // label
              ip = 4135;
      end

       4135 :
      begin                                                                     // add
              localMem[0 + 1862] = localMem[0+1862] + 1;
              ip = 4136;
      end

       4136 :
      begin                                                                     // jmp
              ip = 4130;
      end

       4137 :
      begin                                                                     // label
              ip = 4138;
      end

       4138 :
      begin                                                                     // mov
              localMem[0 + 1864] = heapMem[localMem[0+1839]*10 + 0];
              ip = 4139;
      end

       4139 :
      begin                                                                     // add
              localMem[0 + 1865] = localMem[0+1864] + 1;
              ip = 4140;
      end

       4140 :
      begin                                                                     // mov
              localMem[0 + 1866] = heapMem[localMem[0+1839]*10 + 6];
              ip = 4141;
      end

       4141 :
      begin                                                                     // label
              ip = 4142;
      end

       4142 :
      begin                                                                     // mov
              localMem[0 + 1867] = 0;
              ip = 4143;
      end

       4143 :
      begin                                                                     // label
              ip = 4144;
      end

       4144 :
      begin                                                                     // jGe
              ip = localMem[0+1867] >= localMem[0+1865] ? 4150 : 4145;
      end

       4145 :
      begin                                                                     // mov
              localMem[0 + 1868] = heapMem[localMem[0+1866]*10 + localMem[0+1867]];
              ip = 4146;
      end

       4146 :
      begin                                                                     // mov
              heapMem[localMem[0+1868]*10 + 2] = localMem[0+1839];
              ip = 4147;
      end

       4147 :
      begin                                                                     // label
              ip = 4148;
      end

       4148 :
      begin                                                                     // add
              localMem[0 + 1867] = localMem[0+1867] + 1;
              ip = 4149;
      end

       4149 :
      begin                                                                     // jmp
              ip = 4143;
      end

       4150 :
      begin                                                                     // label
              ip = 4151;
      end

       4151 :
      begin                                                                     // jmp
              ip = 4167;
      end

       4152 :
      begin                                                                     // label
              ip = 4153;
      end

       4153 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1869] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1869] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1869]] = 0;
              ip = 4154;
      end

       4154 :
      begin                                                                     // mov
              heapMem[localMem[0+1773]*10 + 6] = localMem[0+1869];
              ip = 4155;
      end

       4155 :
      begin                                                                     // mov
              localMem[0 + 1870] = heapMem[localMem[0+1773]*10 + 4];
              ip = 4156;
      end

       4156 :
      begin                                                                     // mov
              localMem[0 + 1871] = heapMem[localMem[0+1836]*10 + 4];
              ip = 4157;
      end

       4157 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1786]) begin
                  heapMem[NArea * localMem[0+1871] + 0 + i] = heapMem[NArea * localMem[0+1870] + 0 + i];
                end
              end
              ip = 4158;
      end

       4158 :
      begin                                                                     // mov
              localMem[0 + 1872] = heapMem[localMem[0+1773]*10 + 5];
              ip = 4159;
      end

       4159 :
      begin                                                                     // mov
              localMem[0 + 1873] = heapMem[localMem[0+1836]*10 + 5];
              ip = 4160;
      end

       4160 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1786]) begin
                  heapMem[NArea * localMem[0+1873] + 0 + i] = heapMem[NArea * localMem[0+1872] + 0 + i];
                end
              end
              ip = 4161;
      end

       4161 :
      begin                                                                     // mov
              localMem[0 + 1874] = heapMem[localMem[0+1773]*10 + 4];
              ip = 4162;
      end

       4162 :
      begin                                                                     // mov
              localMem[0 + 1875] = heapMem[localMem[0+1839]*10 + 4];
              ip = 4163;
      end

       4163 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1786]) begin
                  heapMem[NArea * localMem[0+1875] + 0 + i] = heapMem[NArea * localMem[0+1874] + localMem[1787] + i];
                end
              end
              ip = 4164;
      end

       4164 :
      begin                                                                     // mov
              localMem[0 + 1876] = heapMem[localMem[0+1773]*10 + 5];
              ip = 4165;
      end

       4165 :
      begin                                                                     // mov
              localMem[0 + 1877] = heapMem[localMem[0+1839]*10 + 5];
              ip = 4166;
      end

       4166 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+1786]) begin
                  heapMem[NArea * localMem[0+1877] + 0 + i] = heapMem[NArea * localMem[0+1876] + localMem[1787] + i];
                end
              end
              ip = 4167;
      end

       4167 :
      begin                                                                     // label
              ip = 4168;
      end

       4168 :
      begin                                                                     // mov
              heapMem[localMem[0+1836]*10 + 2] = localMem[0+1773];
              ip = 4169;
      end

       4169 :
      begin                                                                     // mov
              heapMem[localMem[0+1839]*10 + 2] = localMem[0+1773];
              ip = 4170;
      end

       4170 :
      begin                                                                     // mov
              localMem[0 + 1878] = heapMem[localMem[0+1773]*10 + 4];
              ip = 4171;
      end

       4171 :
      begin                                                                     // mov
              localMem[0 + 1879] = heapMem[localMem[0+1878]*10 + localMem[0+1786]];
              ip = 4172;
      end

       4172 :
      begin                                                                     // mov
              localMem[0 + 1880] = heapMem[localMem[0+1773]*10 + 5];
              ip = 4173;
      end

       4173 :
      begin                                                                     // mov
              localMem[0 + 1881] = heapMem[localMem[0+1880]*10 + localMem[0+1786]];
              ip = 4174;
      end

       4174 :
      begin                                                                     // mov
              localMem[0 + 1882] = heapMem[localMem[0+1773]*10 + 4];
              ip = 4175;
      end

       4175 :
      begin                                                                     // mov
              heapMem[localMem[0+1882]*10 + 0] = localMem[0+1879];
              ip = 4176;
      end

       4176 :
      begin                                                                     // mov
              localMem[0 + 1883] = heapMem[localMem[0+1773]*10 + 5];
              ip = 4177;
      end

       4177 :
      begin                                                                     // mov
              heapMem[localMem[0+1883]*10 + 0] = localMem[0+1881];
              ip = 4178;
      end

       4178 :
      begin                                                                     // mov
              localMem[0 + 1884] = heapMem[localMem[0+1773]*10 + 6];
              ip = 4179;
      end

       4179 :
      begin                                                                     // mov
              heapMem[localMem[0+1884]*10 + 0] = localMem[0+1836];
              ip = 4180;
      end

       4180 :
      begin                                                                     // mov
              localMem[0 + 1885] = heapMem[localMem[0+1773]*10 + 6];
              ip = 4181;
      end

       4181 :
      begin                                                                     // mov
              heapMem[localMem[0+1885]*10 + 1] = localMem[0+1839];
              ip = 4182;
      end

       4182 :
      begin                                                                     // mov
              heapMem[localMem[0+1773]*10 + 0] = 1;
              ip = 4183;
      end

       4183 :
      begin                                                                     // mov
              localMem[0 + 1886] = heapMem[localMem[0+1773]*10 + 4];
              ip = 4184;
      end

       4184 :
      begin                                                                     // resize
              arraySizes[localMem[0+1886]] = 1;
              ip = 4185;
      end

       4185 :
      begin                                                                     // mov
              localMem[0 + 1887] = heapMem[localMem[0+1773]*10 + 5];
              ip = 4186;
      end

       4186 :
      begin                                                                     // resize
              arraySizes[localMem[0+1887]] = 1;
              ip = 4187;
      end

       4187 :
      begin                                                                     // mov
              localMem[0 + 1888] = heapMem[localMem[0+1773]*10 + 6];
              ip = 4188;
      end

       4188 :
      begin                                                                     // resize
              arraySizes[localMem[0+1888]] = 2;
              ip = 4189;
      end

       4189 :
      begin                                                                     // jmp
              ip = 4191;
      end

       4190 :
      begin                                                                     // jmp
              ip = 4196;
      end

       4191 :
      begin                                                                     // label
              ip = 4192;
      end

       4192 :
      begin                                                                     // mov
              localMem[0 + 1782] = 1;
              ip = 4193;
      end

       4193 :
      begin                                                                     // jmp
              ip = 4196;
      end

       4194 :
      begin                                                                     // label
              ip = 4195;
      end

       4195 :
      begin                                                                     // mov
              localMem[0 + 1782] = 0;
              ip = 4196;
      end

       4196 :
      begin                                                                     // label
              ip = 4197;
      end

       4197 :
      begin                                                                     // label
              ip = 4198;
      end

       4198 :
      begin                                                                     // label
              ip = 4199;
      end

       4199 :
      begin                                                                     // label
              ip = 4200;
      end

       4200 :
      begin                                                                     // free
              freedArrays[freedArraysTop] = localMem[0+1417];
              freedArraysTop = freedArraysTop + 1;
              ip = 4201;
      end
      default: begin
        success  = 1;
        finished = 1;
      end
    endcase
    if (steps <=    242) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
  end
endmodule
