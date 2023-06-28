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
  parameter integer NIn            =   107;                                     // Size of input area
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
    inMem[0] = 72;
    inMem[1] = 103;
    inMem[2] = 3;
    inMem[3] = 89;
    inMem[4] = 49;
    inMem[5] = 6;
    inMem[6] = 38;
    inMem[7] = 91;
    inMem[8] = 21;
    inMem[9] = 39;
    inMem[10] = 52;
    inMem[11] = 62;
    inMem[12] = 19;
    inMem[13] = 83;
    inMem[14] = 7;
    inMem[15] = 70;
    inMem[16] = 73;
    inMem[17] = 18;
    inMem[18] = 40;
    inMem[19] = 67;
    inMem[20] = 59;
    inMem[21] = 10;
    inMem[22] = 20;
    inMem[23] = 56;
    inMem[24] = 86;
    inMem[25] = 90;
    inMem[26] = 27;
    inMem[27] = 98;
    inMem[28] = 45;
    inMem[29] = 15;
    inMem[30] = 1;
    inMem[31] = 48;
    inMem[32] = 33;
    inMem[33] = 4;
    inMem[34] = 28;
    inMem[35] = 87;
    inMem[36] = 24;
    inMem[37] = 66;
    inMem[38] = 84;
    inMem[39] = 80;
    inMem[40] = 65;
    inMem[41] = 75;
    inMem[42] = 97;
    inMem[43] = 85;
    inMem[44] = 63;
    inMem[45] = 54;
    inMem[46] = 12;
    inMem[47] = 101;
    inMem[48] = 31;
    inMem[49] = 41;
    inMem[50] = 30;
    inMem[51] = 106;
    inMem[52] = 26;
    inMem[53] = 68;
    inMem[54] = 60;
    inMem[55] = 95;
    inMem[56] = 35;
    inMem[57] = 76;
    inMem[58] = 96;
    inMem[59] = 61;
    inMem[60] = 105;
    inMem[61] = 32;
    inMem[62] = 42;
    inMem[63] = 37;
    inMem[64] = 43;
    inMem[65] = 57;
    inMem[66] = 102;
    inMem[67] = 93;
    inMem[68] = 29;
    inMem[69] = 78;
    inMem[70] = 55;
    inMem[71] = 82;
    inMem[72] = 23;
    inMem[73] = 22;
    inMem[74] = 44;
    inMem[75] = 9;
    inMem[76] = 81;
    inMem[77] = 5;
    inMem[78] = 79;
    inMem[79] = 14;
    inMem[80] = 13;
    inMem[81] = 51;
    inMem[82] = 88;
    inMem[83] = 74;
    inMem[84] = 94;
    inMem[85] = 17;
    inMem[86] = 16;
    inMem[87] = 2;
    inMem[88] = 47;
    inMem[89] = 36;
    inMem[90] = 8;
    inMem[91] = 100;
    inMem[92] = 53;
    inMem[93] = 25;
    inMem[94] = 34;
    inMem[95] = 64;
    inMem[96] = 77;
    inMem[97] = 46;
    inMem[98] = 99;
    inMem[99] = 11;
    inMem[100] = 50;
    inMem[101] = 69;
    inMem[102] = 58;
    inMem[103] = 104;
    inMem[104] = 71;
    inMem[105] = 92;
    inMem[106] = 107;
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
      begin                                                                     // inSize
              localMem[0 + 2] = NIn - inMemPos;
              ip = 8;
      end

          8 :
      begin                                                                     // jFalse
              ip = localMem[0+2] == 0 ? 1047 : 9;
      end

          9 :
      begin                                                                     // in
              if (inMemPos < NIn) begin
                localMem[0 + 3] = inMem[inMemPos];
                inMemPos = inMemPos + 1;
              end
              ip = 10;
      end

         10 :
      begin                                                                     // mov
              localMem[0 + 4] = heapMem[localMem[0+0]*10 + 0];
              ip = 11;
      end

         11 :
      begin                                                                     // add
              localMem[0 + 5] = localMem[0+3] + localMem[0+3];
              ip = 12;
      end

         12 :
      begin                                                                     // tally
            ip = 13;
      end

         13 :
      begin                                                                     // label
              ip = 14;
      end

         14 :
      begin                                                                     // mov
              localMem[0 + 6] = heapMem[localMem[0+0]*10 + 3];
              ip = 15;
      end

         15 :
      begin                                                                     // jNe
              ip = localMem[0+6] != 0 ? 34 : 16;
      end

         16 :
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
              ip = 17;
      end

         17 :
      begin                                                                     // mov
              heapMem[localMem[0+7]*10 + 0] = 1;
              ip = 18;
      end

         18 :
      begin                                                                     // mov
              heapMem[localMem[0+7]*10 + 2] = 0;
              ip = 19;
      end

         19 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 8] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 8] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 8]] = 0;
              ip = 20;
      end

         20 :
      begin                                                                     // mov
              heapMem[localMem[0+7]*10 + 4] = localMem[0+8];
              ip = 21;
      end

         21 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 9] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 9] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 9]] = 0;
              ip = 22;
      end

         22 :
      begin                                                                     // mov
              heapMem[localMem[0+7]*10 + 5] = localMem[0+9];
              ip = 23;
      end

         23 :
      begin                                                                     // mov
              heapMem[localMem[0+7]*10 + 6] = 0;
              ip = 24;
      end

         24 :
      begin                                                                     // mov
              heapMem[localMem[0+7]*10 + 3] = localMem[0+0];
              ip = 25;
      end

         25 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 1] = heapMem[localMem[0+0]*10 + 1] + 1;
              ip = 26;
      end

         26 :
      begin                                                                     // mov
              heapMem[localMem[0+7]*10 + 1] = heapMem[localMem[0+0]*10 + 1];
              ip = 27;
      end

         27 :
      begin                                                                     // mov
              localMem[0 + 10] = heapMem[localMem[0+7]*10 + 4];
              ip = 28;
      end

         28 :
      begin                                                                     // mov
              heapMem[localMem[0+10]*10 + 0] = localMem[0+3];
              ip = 29;
      end

         29 :
      begin                                                                     // mov
              localMem[0 + 11] = heapMem[localMem[0+7]*10 + 5];
              ip = 30;
      end

         30 :
      begin                                                                     // mov
              heapMem[localMem[0+11]*10 + 0] = localMem[0+5];
              ip = 31;
      end

         31 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 32;
      end

         32 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 3] = localMem[0+7];
              ip = 33;
      end

         33 :
      begin                                                                     // jmp
              ip = 1043;
      end

         34 :
      begin                                                                     // label
              ip = 35;
      end

         35 :
      begin                                                                     // mov
              localMem[0 + 12] = heapMem[localMem[0+6]*10 + 0];
              ip = 36;
      end

         36 :
      begin                                                                     // mov
              localMem[0 + 13] = heapMem[localMem[0+0]*10 + 2];
              ip = 37;
      end

         37 :
      begin                                                                     // jGe
              ip = localMem[0+12] >= localMem[0+13] ? 70 : 38;
      end

         38 :
      begin                                                                     // mov
              localMem[0 + 14] = heapMem[localMem[0+6]*10 + 2];
              ip = 39;
      end

         39 :
      begin                                                                     // jNe
              ip = localMem[0+14] != 0 ? 69 : 40;
      end

         40 :
      begin                                                                     // not
              localMem[0 + 15] = !heapMem[localMem[0+6]*10 + 6];
              ip = 41;
      end

         41 :
      begin                                                                     // jEq
              ip = localMem[0+15] == 0 ? 68 : 42;
      end

         42 :
      begin                                                                     // mov
              localMem[0 + 16] = heapMem[localMem[0+6]*10 + 4];
              ip = 43;
      end

         43 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+16] * NArea + i] == localMem[0+3]) localMem[0 + 17] = i + 1;
              end
              ip = 44;
      end

         44 :
      begin                                                                     // jEq
              ip = localMem[0+17] == 0 ? 49 : 45;
      end

         45 :
      begin                                                                     // subtract
              localMem[0 + 17] = localMem[0+17] - 1;
              ip = 46;
      end

         46 :
      begin                                                                     // mov
              localMem[0 + 18] = heapMem[localMem[0+6]*10 + 5];
              ip = 47;
      end

         47 :
      begin                                                                     // mov
              heapMem[localMem[0+18]*10 + localMem[0+17]] = localMem[0+5];
              ip = 48;
      end

         48 :
      begin                                                                     // jmp
              ip = 1043;
      end

         49 :
      begin                                                                     // label
              ip = 50;
      end

         50 :
      begin                                                                     // arrayCountGreater
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+16] * NArea + i] > localMem[0+3]) j = j + 1;
              end
              localMem[0 + 19] = j;
              ip = 51;
      end

         51 :
      begin                                                                     // jNe
              ip = localMem[0+19] != 0 ? 59 : 52;
      end

         52 :
      begin                                                                     // mov
              localMem[0 + 20] = heapMem[localMem[0+6]*10 + 4];
              ip = 53;
      end

         53 :
      begin                                                                     // mov
              heapMem[localMem[0+20]*10 + localMem[0+12]] = localMem[0+3];
              ip = 54;
      end

         54 :
      begin                                                                     // mov
              localMem[0 + 21] = heapMem[localMem[0+6]*10 + 5];
              ip = 55;
      end

         55 :
      begin                                                                     // mov
              heapMem[localMem[0+21]*10 + localMem[0+12]] = localMem[0+5];
              ip = 56;
      end

         56 :
      begin                                                                     // add
              heapMem[localMem[0+6]*10 + 0] = localMem[0+12] + 1;
              ip = 57;
      end

         57 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 58;
      end

         58 :
      begin                                                                     // jmp
              ip = 1043;
      end

         59 :
      begin                                                                     // label
              ip = 60;
      end

         60 :
      begin                                                                     // arrayCountLess
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+16] * NArea + i] < localMem[0+3]) j = j + 1;
              end
              localMem[0 + 22] = j;
              ip = 61;
      end

         61 :
      begin                                                                     // mov
              localMem[0 + 23] = heapMem[localMem[0+6]*10 + 4];
              ip = 62;
      end

         62 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+23] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[22]) begin
                  heapMem[NArea * localMem[0+23] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+23] + localMem[22]] = localMem[0+3];                                    // Insert new value
              arraySizes[localMem[0+23]] = arraySizes[localMem[0+23]] + 1;                              // Increase array size
              ip = 63;
      end

         63 :
      begin                                                                     // mov
              localMem[0 + 24] = heapMem[localMem[0+6]*10 + 5];
              ip = 64;
      end

         64 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+24] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[22]) begin
                  heapMem[NArea * localMem[0+24] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+24] + localMem[22]] = localMem[0+5];                                    // Insert new value
              arraySizes[localMem[0+24]] = arraySizes[localMem[0+24]] + 1;                              // Increase array size
              ip = 65;
      end

         65 :
      begin                                                                     // add
              heapMem[localMem[0+6]*10 + 0] = heapMem[localMem[0+6]*10 + 0] + 1;
              ip = 66;
      end

         66 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 67;
      end

         67 :
      begin                                                                     // jmp
              ip = 1043;
      end

         68 :
      begin                                                                     // label
              ip = 69;
      end

         69 :
      begin                                                                     // label
              ip = 70;
      end

         70 :
      begin                                                                     // label
              ip = 71;
      end

         71 :
      begin                                                                     // mov
              localMem[0 + 25] = heapMem[localMem[0+0]*10 + 3];
              ip = 72;
      end

         72 :
      begin                                                                     // label
              ip = 73;
      end

         73 :
      begin                                                                     // mov
              localMem[0 + 27] = heapMem[localMem[0+25]*10 + 0];
              ip = 74;
      end

         74 :
      begin                                                                     // jLt
              ip = localMem[0+27] <  3 ? 292 : 75;
      end

         75 :
      begin                                                                     // mov
              localMem[0 + 28] = heapMem[localMem[0+25]*10 + 3];
              ip = 76;
      end

         76 :
      begin                                                                     // mov
              localMem[0 + 29] = heapMem[localMem[0+25]*10 + 2];
              ip = 77;
      end

         77 :
      begin                                                                     // jEq
              ip = localMem[0+29] == 0 ? 174 : 78;
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
              heapMem[localMem[0+30]*10 + 0] = 1;
              ip = 80;
      end

         80 :
      begin                                                                     // mov
              heapMem[localMem[0+30]*10 + 2] = 0;
              ip = 81;
      end

         81 :
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
              ip = 82;
      end

         82 :
      begin                                                                     // mov
              heapMem[localMem[0+30]*10 + 4] = localMem[0+31];
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
              heapMem[localMem[0+30]*10 + 5] = localMem[0+32];
              ip = 85;
      end

         85 :
      begin                                                                     // mov
              heapMem[localMem[0+30]*10 + 6] = 0;
              ip = 86;
      end

         86 :
      begin                                                                     // mov
              heapMem[localMem[0+30]*10 + 3] = localMem[0+28];
              ip = 87;
      end

         87 :
      begin                                                                     // add
              heapMem[localMem[0+28]*10 + 1] = heapMem[localMem[0+28]*10 + 1] + 1;
              ip = 88;
      end

         88 :
      begin                                                                     // mov
              heapMem[localMem[0+30]*10 + 1] = heapMem[localMem[0+28]*10 + 1];
              ip = 89;
      end

         89 :
      begin                                                                     // not
              localMem[0 + 33] = !heapMem[localMem[0+25]*10 + 6];
              ip = 90;
      end

         90 :
      begin                                                                     // jNe
              ip = localMem[0+33] != 0 ? 119 : 91;
      end

         91 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 34] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 34] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 34]] = 0;
              ip = 92;
      end

         92 :
      begin                                                                     // mov
              heapMem[localMem[0+30]*10 + 6] = localMem[0+34];
              ip = 93;
      end

         93 :
      begin                                                                     // mov
              localMem[0 + 35] = heapMem[localMem[0+25]*10 + 4];
              ip = 94;
      end

         94 :
      begin                                                                     // mov
              localMem[0 + 36] = heapMem[localMem[0+30]*10 + 4];
              ip = 95;
      end

         95 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+36] + 0 + i] = heapMem[NArea * localMem[0+35] + 2 + i];
                end
              end
              ip = 96;
      end

         96 :
      begin                                                                     // mov
              localMem[0 + 37] = heapMem[localMem[0+25]*10 + 5];
              ip = 97;
      end

         97 :
      begin                                                                     // mov
              localMem[0 + 38] = heapMem[localMem[0+30]*10 + 5];
              ip = 98;
      end

         98 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+38] + 0 + i] = heapMem[NArea * localMem[0+37] + 2 + i];
                end
              end
              ip = 99;
      end

         99 :
      begin                                                                     // mov
              localMem[0 + 39] = heapMem[localMem[0+25]*10 + 6];
              ip = 100;
      end

        100 :
      begin                                                                     // mov
              localMem[0 + 40] = heapMem[localMem[0+30]*10 + 6];
              ip = 101;
      end

        101 :
      begin                                                                     // add
              localMem[0 + 41] = 1 + 1;
              ip = 102;
      end

        102 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+41]) begin
                  heapMem[NArea * localMem[0+40] + 0 + i] = heapMem[NArea * localMem[0+39] + 2 + i];
                end
              end
              ip = 103;
      end

        103 :
      begin                                                                     // mov
              localMem[0 + 42] = heapMem[localMem[0+30]*10 + 0];
              ip = 104;
      end

        104 :
      begin                                                                     // add
              localMem[0 + 43] = localMem[0+42] + 1;
              ip = 105;
      end

        105 :
      begin                                                                     // mov
              localMem[0 + 44] = heapMem[localMem[0+30]*10 + 6];
              ip = 106;
      end

        106 :
      begin                                                                     // label
              ip = 107;
      end

        107 :
      begin                                                                     // mov
              localMem[0 + 45] = 0;
              ip = 108;
      end

        108 :
      begin                                                                     // label
              ip = 109;
      end

        109 :
      begin                                                                     // jGe
              ip = localMem[0+45] >= localMem[0+43] ? 115 : 110;
      end

        110 :
      begin                                                                     // mov
              localMem[0 + 46] = heapMem[localMem[0+44]*10 + localMem[0+45]];
              ip = 111;
      end

        111 :
      begin                                                                     // mov
              heapMem[localMem[0+46]*10 + 2] = localMem[0+30];
              ip = 112;
      end

        112 :
      begin                                                                     // label
              ip = 113;
      end

        113 :
      begin                                                                     // add
              localMem[0 + 45] = localMem[0+45] + 1;
              ip = 114;
      end

        114 :
      begin                                                                     // jmp
              ip = 108;
      end

        115 :
      begin                                                                     // label
              ip = 116;
      end

        116 :
      begin                                                                     // mov
              localMem[0 + 47] = heapMem[localMem[0+25]*10 + 6];
              ip = 117;
      end

        117 :
      begin                                                                     // resize
              arraySizes[localMem[0+47]] = 2;
              ip = 118;
      end

        118 :
      begin                                                                     // jmp
              ip = 126;
      end

        119 :
      begin                                                                     // label
              ip = 120;
      end

        120 :
      begin                                                                     // mov
              localMem[0 + 48] = heapMem[localMem[0+25]*10 + 4];
              ip = 121;
      end

        121 :
      begin                                                                     // mov
              localMem[0 + 49] = heapMem[localMem[0+30]*10 + 4];
              ip = 122;
      end

        122 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+49] + 0 + i] = heapMem[NArea * localMem[0+48] + 2 + i];
                end
              end
              ip = 123;
      end

        123 :
      begin                                                                     // mov
              localMem[0 + 50] = heapMem[localMem[0+25]*10 + 5];
              ip = 124;
      end

        124 :
      begin                                                                     // mov
              localMem[0 + 51] = heapMem[localMem[0+30]*10 + 5];
              ip = 125;
      end

        125 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+51] + 0 + i] = heapMem[NArea * localMem[0+50] + 2 + i];
                end
              end
              ip = 126;
      end

        126 :
      begin                                                                     // label
              ip = 127;
      end

        127 :
      begin                                                                     // mov
              heapMem[localMem[0+25]*10 + 0] = 1;
              ip = 128;
      end

        128 :
      begin                                                                     // mov
              heapMem[localMem[0+30]*10 + 2] = localMem[0+29];
              ip = 129;
      end

        129 :
      begin                                                                     // mov
              localMem[0 + 52] = heapMem[localMem[0+29]*10 + 0];
              ip = 130;
      end

        130 :
      begin                                                                     // mov
              localMem[0 + 53] = heapMem[localMem[0+29]*10 + 6];
              ip = 131;
      end

        131 :
      begin                                                                     // mov
              localMem[0 + 54] = heapMem[localMem[0+53]*10 + localMem[0+52]];
              ip = 132;
      end

        132 :
      begin                                                                     // jNe
              ip = localMem[0+54] != localMem[0+25] ? 151 : 133;
      end

        133 :
      begin                                                                     // mov
              localMem[0 + 55] = heapMem[localMem[0+25]*10 + 4];
              ip = 134;
      end

        134 :
      begin                                                                     // mov
              localMem[0 + 56] = heapMem[localMem[0+55]*10 + 1];
              ip = 135;
      end

        135 :
      begin                                                                     // mov
              localMem[0 + 57] = heapMem[localMem[0+29]*10 + 4];
              ip = 136;
      end

        136 :
      begin                                                                     // mov
              heapMem[localMem[0+57]*10 + localMem[0+52]] = localMem[0+56];
              ip = 137;
      end

        137 :
      begin                                                                     // mov
              localMem[0 + 58] = heapMem[localMem[0+25]*10 + 5];
              ip = 138;
      end

        138 :
      begin                                                                     // mov
              localMem[0 + 59] = heapMem[localMem[0+58]*10 + 1];
              ip = 139;
      end

        139 :
      begin                                                                     // mov
              localMem[0 + 60] = heapMem[localMem[0+29]*10 + 5];
              ip = 140;
      end

        140 :
      begin                                                                     // mov
              heapMem[localMem[0+60]*10 + localMem[0+52]] = localMem[0+59];
              ip = 141;
      end

        141 :
      begin                                                                     // mov
              localMem[0 + 61] = heapMem[localMem[0+25]*10 + 4];
              ip = 142;
      end

        142 :
      begin                                                                     // resize
              arraySizes[localMem[0+61]] = 1;
              ip = 143;
      end

        143 :
      begin                                                                     // mov
              localMem[0 + 62] = heapMem[localMem[0+25]*10 + 5];
              ip = 144;
      end

        144 :
      begin                                                                     // resize
              arraySizes[localMem[0+62]] = 1;
              ip = 145;
      end

        145 :
      begin                                                                     // add
              localMem[0 + 63] = localMem[0+52] + 1;
              ip = 146;
      end

        146 :
      begin                                                                     // mov
              heapMem[localMem[0+29]*10 + 0] = localMem[0+63];
              ip = 147;
      end

        147 :
      begin                                                                     // mov
              localMem[0 + 64] = heapMem[localMem[0+29]*10 + 6];
              ip = 148;
      end

        148 :
      begin                                                                     // mov
              heapMem[localMem[0+64]*10 + localMem[0+63]] = localMem[0+30];
              ip = 149;
      end

        149 :
      begin                                                                     // jmp
              ip = 289;
      end

        150 :
      begin                                                                     // jmp
              ip = 173;
      end

        151 :
      begin                                                                     // label
              ip = 152;
      end

        152 :
      begin                                                                     // assertNe
            ip = 153;
      end

        153 :
      begin                                                                     // mov
              localMem[0 + 65] = heapMem[localMem[0+29]*10 + 6];
              ip = 154;
      end

        154 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+65] * NArea + i] == localMem[0+25]) localMem[0 + 66] = i + 1;
              end
              ip = 155;
      end

        155 :
      begin                                                                     // subtract
              localMem[0 + 66] = localMem[0+66] - 1;
              ip = 156;
      end

        156 :
      begin                                                                     // mov
              localMem[0 + 67] = heapMem[localMem[0+25]*10 + 4];
              ip = 157;
      end

        157 :
      begin                                                                     // mov
              localMem[0 + 68] = heapMem[localMem[0+67]*10 + 1];
              ip = 158;
      end

        158 :
      begin                                                                     // mov
              localMem[0 + 69] = heapMem[localMem[0+25]*10 + 5];
              ip = 159;
      end

        159 :
      begin                                                                     // mov
              localMem[0 + 70] = heapMem[localMem[0+69]*10 + 1];
              ip = 160;
      end

        160 :
      begin                                                                     // mov
              localMem[0 + 71] = heapMem[localMem[0+25]*10 + 4];
              ip = 161;
      end

        161 :
      begin                                                                     // resize
              arraySizes[localMem[0+71]] = 1;
              ip = 162;
      end

        162 :
      begin                                                                     // mov
              localMem[0 + 72] = heapMem[localMem[0+25]*10 + 5];
              ip = 163;
      end

        163 :
      begin                                                                     // resize
              arraySizes[localMem[0+72]] = 1;
              ip = 164;
      end

        164 :
      begin                                                                     // mov
              localMem[0 + 73] = heapMem[localMem[0+29]*10 + 4];
              ip = 165;
      end

        165 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+73] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[66]) begin
                  heapMem[NArea * localMem[0+73] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+73] + localMem[66]] = localMem[0+68];                                    // Insert new value
              arraySizes[localMem[0+73]] = arraySizes[localMem[0+73]] + 1;                              // Increase array size
              ip = 166;
      end

        166 :
      begin                                                                     // mov
              localMem[0 + 74] = heapMem[localMem[0+29]*10 + 5];
              ip = 167;
      end

        167 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+74] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[66]) begin
                  heapMem[NArea * localMem[0+74] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+74] + localMem[66]] = localMem[0+70];                                    // Insert new value
              arraySizes[localMem[0+74]] = arraySizes[localMem[0+74]] + 1;                              // Increase array size
              ip = 168;
      end

        168 :
      begin                                                                     // mov
              localMem[0 + 75] = heapMem[localMem[0+29]*10 + 6];
              ip = 169;
      end

        169 :
      begin                                                                     // add
              localMem[0 + 76] = localMem[0+66] + 1;
              ip = 170;
      end

        170 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+75] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[76]) begin
                  heapMem[NArea * localMem[0+75] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+75] + localMem[76]] = localMem[0+30];                                    // Insert new value
              arraySizes[localMem[0+75]] = arraySizes[localMem[0+75]] + 1;                              // Increase array size
              ip = 171;
      end

        171 :
      begin                                                                     // add
              heapMem[localMem[0+29]*10 + 0] = heapMem[localMem[0+29]*10 + 0] + 1;
              ip = 172;
      end

        172 :
      begin                                                                     // jmp
              ip = 289;
      end

        173 :
      begin                                                                     // label
              ip = 174;
      end

        174 :
      begin                                                                     // label
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
              heapMem[localMem[0+77]*10 + 0] = 1;
              ip = 177;
      end

        177 :
      begin                                                                     // mov
              heapMem[localMem[0+77]*10 + 2] = 0;
              ip = 178;
      end

        178 :
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
              ip = 179;
      end

        179 :
      begin                                                                     // mov
              heapMem[localMem[0+77]*10 + 4] = localMem[0+78];
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
              heapMem[localMem[0+77]*10 + 5] = localMem[0+79];
              ip = 182;
      end

        182 :
      begin                                                                     // mov
              heapMem[localMem[0+77]*10 + 6] = 0;
              ip = 183;
      end

        183 :
      begin                                                                     // mov
              heapMem[localMem[0+77]*10 + 3] = localMem[0+28];
              ip = 184;
      end

        184 :
      begin                                                                     // add
              heapMem[localMem[0+28]*10 + 1] = heapMem[localMem[0+28]*10 + 1] + 1;
              ip = 185;
      end

        185 :
      begin                                                                     // mov
              heapMem[localMem[0+77]*10 + 1] = heapMem[localMem[0+28]*10 + 1];
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
              heapMem[localMem[0+80]*10 + 0] = 1;
              ip = 188;
      end

        188 :
      begin                                                                     // mov
              heapMem[localMem[0+80]*10 + 2] = 0;
              ip = 189;
      end

        189 :
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
              ip = 190;
      end

        190 :
      begin                                                                     // mov
              heapMem[localMem[0+80]*10 + 4] = localMem[0+81];
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
              heapMem[localMem[0+80]*10 + 5] = localMem[0+82];
              ip = 193;
      end

        193 :
      begin                                                                     // mov
              heapMem[localMem[0+80]*10 + 6] = 0;
              ip = 194;
      end

        194 :
      begin                                                                     // mov
              heapMem[localMem[0+80]*10 + 3] = localMem[0+28];
              ip = 195;
      end

        195 :
      begin                                                                     // add
              heapMem[localMem[0+28]*10 + 1] = heapMem[localMem[0+28]*10 + 1] + 1;
              ip = 196;
      end

        196 :
      begin                                                                     // mov
              heapMem[localMem[0+80]*10 + 1] = heapMem[localMem[0+28]*10 + 1];
              ip = 197;
      end

        197 :
      begin                                                                     // not
              localMem[0 + 83] = !heapMem[localMem[0+25]*10 + 6];
              ip = 198;
      end

        198 :
      begin                                                                     // jNe
              ip = localMem[0+83] != 0 ? 250 : 199;
      end

        199 :
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
              ip = 200;
      end

        200 :
      begin                                                                     // mov
              heapMem[localMem[0+77]*10 + 6] = localMem[0+84];
              ip = 201;
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
              heapMem[localMem[0+80]*10 + 6] = localMem[0+85];
              ip = 203;
      end

        203 :
      begin                                                                     // mov
              localMem[0 + 86] = heapMem[localMem[0+25]*10 + 4];
              ip = 204;
      end

        204 :
      begin                                                                     // mov
              localMem[0 + 87] = heapMem[localMem[0+77]*10 + 4];
              ip = 205;
      end

        205 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+87] + 0 + i] = heapMem[NArea * localMem[0+86] + 0 + i];
                end
              end
              ip = 206;
      end

        206 :
      begin                                                                     // mov
              localMem[0 + 88] = heapMem[localMem[0+25]*10 + 5];
              ip = 207;
      end

        207 :
      begin                                                                     // mov
              localMem[0 + 89] = heapMem[localMem[0+77]*10 + 5];
              ip = 208;
      end

        208 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+89] + 0 + i] = heapMem[NArea * localMem[0+88] + 0 + i];
                end
              end
              ip = 209;
      end

        209 :
      begin                                                                     // mov
              localMem[0 + 90] = heapMem[localMem[0+25]*10 + 6];
              ip = 210;
      end

        210 :
      begin                                                                     // mov
              localMem[0 + 91] = heapMem[localMem[0+77]*10 + 6];
              ip = 211;
      end

        211 :
      begin                                                                     // add
              localMem[0 + 92] = 1 + 1;
              ip = 212;
      end

        212 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+92]) begin
                  heapMem[NArea * localMem[0+91] + 0 + i] = heapMem[NArea * localMem[0+90] + 0 + i];
                end
              end
              ip = 213;
      end

        213 :
      begin                                                                     // mov
              localMem[0 + 93] = heapMem[localMem[0+25]*10 + 4];
              ip = 214;
      end

        214 :
      begin                                                                     // mov
              localMem[0 + 94] = heapMem[localMem[0+80]*10 + 4];
              ip = 215;
      end

        215 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+94] + 0 + i] = heapMem[NArea * localMem[0+93] + 2 + i];
                end
              end
              ip = 216;
      end

        216 :
      begin                                                                     // mov
              localMem[0 + 95] = heapMem[localMem[0+25]*10 + 5];
              ip = 217;
      end

        217 :
      begin                                                                     // mov
              localMem[0 + 96] = heapMem[localMem[0+80]*10 + 5];
              ip = 218;
      end

        218 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+96] + 0 + i] = heapMem[NArea * localMem[0+95] + 2 + i];
                end
              end
              ip = 219;
      end

        219 :
      begin                                                                     // mov
              localMem[0 + 97] = heapMem[localMem[0+25]*10 + 6];
              ip = 220;
      end

        220 :
      begin                                                                     // mov
              localMem[0 + 98] = heapMem[localMem[0+80]*10 + 6];
              ip = 221;
      end

        221 :
      begin                                                                     // add
              localMem[0 + 99] = 1 + 1;
              ip = 222;
      end

        222 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+99]) begin
                  heapMem[NArea * localMem[0+98] + 0 + i] = heapMem[NArea * localMem[0+97] + 2 + i];
                end
              end
              ip = 223;
      end

        223 :
      begin                                                                     // mov
              localMem[0 + 100] = heapMem[localMem[0+77]*10 + 0];
              ip = 224;
      end

        224 :
      begin                                                                     // add
              localMem[0 + 101] = localMem[0+100] + 1;
              ip = 225;
      end

        225 :
      begin                                                                     // mov
              localMem[0 + 102] = heapMem[localMem[0+77]*10 + 6];
              ip = 226;
      end

        226 :
      begin                                                                     // label
              ip = 227;
      end

        227 :
      begin                                                                     // mov
              localMem[0 + 103] = 0;
              ip = 228;
      end

        228 :
      begin                                                                     // label
              ip = 229;
      end

        229 :
      begin                                                                     // jGe
              ip = localMem[0+103] >= localMem[0+101] ? 235 : 230;
      end

        230 :
      begin                                                                     // mov
              localMem[0 + 104] = heapMem[localMem[0+102]*10 + localMem[0+103]];
              ip = 231;
      end

        231 :
      begin                                                                     // mov
              heapMem[localMem[0+104]*10 + 2] = localMem[0+77];
              ip = 232;
      end

        232 :
      begin                                                                     // label
              ip = 233;
      end

        233 :
      begin                                                                     // add
              localMem[0 + 103] = localMem[0+103] + 1;
              ip = 234;
      end

        234 :
      begin                                                                     // jmp
              ip = 228;
      end

        235 :
      begin                                                                     // label
              ip = 236;
      end

        236 :
      begin                                                                     // mov
              localMem[0 + 105] = heapMem[localMem[0+80]*10 + 0];
              ip = 237;
      end

        237 :
      begin                                                                     // add
              localMem[0 + 106] = localMem[0+105] + 1;
              ip = 238;
      end

        238 :
      begin                                                                     // mov
              localMem[0 + 107] = heapMem[localMem[0+80]*10 + 6];
              ip = 239;
      end

        239 :
      begin                                                                     // label
              ip = 240;
      end

        240 :
      begin                                                                     // mov
              localMem[0 + 108] = 0;
              ip = 241;
      end

        241 :
      begin                                                                     // label
              ip = 242;
      end

        242 :
      begin                                                                     // jGe
              ip = localMem[0+108] >= localMem[0+106] ? 248 : 243;
      end

        243 :
      begin                                                                     // mov
              localMem[0 + 109] = heapMem[localMem[0+107]*10 + localMem[0+108]];
              ip = 244;
      end

        244 :
      begin                                                                     // mov
              heapMem[localMem[0+109]*10 + 2] = localMem[0+80];
              ip = 245;
      end

        245 :
      begin                                                                     // label
              ip = 246;
      end

        246 :
      begin                                                                     // add
              localMem[0 + 108] = localMem[0+108] + 1;
              ip = 247;
      end

        247 :
      begin                                                                     // jmp
              ip = 241;
      end

        248 :
      begin                                                                     // label
              ip = 249;
      end

        249 :
      begin                                                                     // jmp
              ip = 265;
      end

        250 :
      begin                                                                     // label
              ip = 251;
      end

        251 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 110] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 110] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 110]] = 0;
              ip = 252;
      end

        252 :
      begin                                                                     // mov
              heapMem[localMem[0+25]*10 + 6] = localMem[0+110];
              ip = 253;
      end

        253 :
      begin                                                                     // mov
              localMem[0 + 111] = heapMem[localMem[0+25]*10 + 4];
              ip = 254;
      end

        254 :
      begin                                                                     // mov
              localMem[0 + 112] = heapMem[localMem[0+77]*10 + 4];
              ip = 255;
      end

        255 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+112] + 0 + i] = heapMem[NArea * localMem[0+111] + 0 + i];
                end
              end
              ip = 256;
      end

        256 :
      begin                                                                     // mov
              localMem[0 + 113] = heapMem[localMem[0+25]*10 + 5];
              ip = 257;
      end

        257 :
      begin                                                                     // mov
              localMem[0 + 114] = heapMem[localMem[0+77]*10 + 5];
              ip = 258;
      end

        258 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+114] + 0 + i] = heapMem[NArea * localMem[0+113] + 0 + i];
                end
              end
              ip = 259;
      end

        259 :
      begin                                                                     // mov
              localMem[0 + 115] = heapMem[localMem[0+25]*10 + 4];
              ip = 260;
      end

        260 :
      begin                                                                     // mov
              localMem[0 + 116] = heapMem[localMem[0+80]*10 + 4];
              ip = 261;
      end

        261 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+116] + 0 + i] = heapMem[NArea * localMem[0+115] + 2 + i];
                end
              end
              ip = 262;
      end

        262 :
      begin                                                                     // mov
              localMem[0 + 117] = heapMem[localMem[0+25]*10 + 5];
              ip = 263;
      end

        263 :
      begin                                                                     // mov
              localMem[0 + 118] = heapMem[localMem[0+80]*10 + 5];
              ip = 264;
      end

        264 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+118] + 0 + i] = heapMem[NArea * localMem[0+117] + 2 + i];
                end
              end
              ip = 265;
      end

        265 :
      begin                                                                     // label
              ip = 266;
      end

        266 :
      begin                                                                     // mov
              heapMem[localMem[0+77]*10 + 2] = localMem[0+25];
              ip = 267;
      end

        267 :
      begin                                                                     // mov
              heapMem[localMem[0+80]*10 + 2] = localMem[0+25];
              ip = 268;
      end

        268 :
      begin                                                                     // mov
              localMem[0 + 119] = heapMem[localMem[0+25]*10 + 4];
              ip = 269;
      end

        269 :
      begin                                                                     // mov
              localMem[0 + 120] = heapMem[localMem[0+119]*10 + 1];
              ip = 270;
      end

        270 :
      begin                                                                     // mov
              localMem[0 + 121] = heapMem[localMem[0+25]*10 + 5];
              ip = 271;
      end

        271 :
      begin                                                                     // mov
              localMem[0 + 122] = heapMem[localMem[0+121]*10 + 1];
              ip = 272;
      end

        272 :
      begin                                                                     // mov
              localMem[0 + 123] = heapMem[localMem[0+25]*10 + 4];
              ip = 273;
      end

        273 :
      begin                                                                     // mov
              heapMem[localMem[0+123]*10 + 0] = localMem[0+120];
              ip = 274;
      end

        274 :
      begin                                                                     // mov
              localMem[0 + 124] = heapMem[localMem[0+25]*10 + 5];
              ip = 275;
      end

        275 :
      begin                                                                     // mov
              heapMem[localMem[0+124]*10 + 0] = localMem[0+122];
              ip = 276;
      end

        276 :
      begin                                                                     // mov
              localMem[0 + 125] = heapMem[localMem[0+25]*10 + 6];
              ip = 277;
      end

        277 :
      begin                                                                     // mov
              heapMem[localMem[0+125]*10 + 0] = localMem[0+77];
              ip = 278;
      end

        278 :
      begin                                                                     // mov
              localMem[0 + 126] = heapMem[localMem[0+25]*10 + 6];
              ip = 279;
      end

        279 :
      begin                                                                     // mov
              heapMem[localMem[0+126]*10 + 1] = localMem[0+80];
              ip = 280;
      end

        280 :
      begin                                                                     // mov
              heapMem[localMem[0+25]*10 + 0] = 1;
              ip = 281;
      end

        281 :
      begin                                                                     // mov
              localMem[0 + 127] = heapMem[localMem[0+25]*10 + 4];
              ip = 282;
      end

        282 :
      begin                                                                     // resize
              arraySizes[localMem[0+127]] = 1;
              ip = 283;
      end

        283 :
      begin                                                                     // mov
              localMem[0 + 128] = heapMem[localMem[0+25]*10 + 5];
              ip = 284;
      end

        284 :
      begin                                                                     // resize
              arraySizes[localMem[0+128]] = 1;
              ip = 285;
      end

        285 :
      begin                                                                     // mov
              localMem[0 + 129] = heapMem[localMem[0+25]*10 + 6];
              ip = 286;
      end

        286 :
      begin                                                                     // resize
              arraySizes[localMem[0+129]] = 2;
              ip = 287;
      end

        287 :
      begin                                                                     // jmp
              ip = 289;
      end

        288 :
      begin                                                                     // jmp
              ip = 294;
      end

        289 :
      begin                                                                     // label
              ip = 290;
      end

        290 :
      begin                                                                     // mov
              localMem[0 + 26] = 1;
              ip = 291;
      end

        291 :
      begin                                                                     // jmp
              ip = 294;
      end

        292 :
      begin                                                                     // label
              ip = 293;
      end

        293 :
      begin                                                                     // mov
              localMem[0 + 26] = 0;
              ip = 294;
      end

        294 :
      begin                                                                     // label
              ip = 295;
      end

        295 :
      begin                                                                     // label
              ip = 296;
      end

        296 :
      begin                                                                     // label
              ip = 297;
      end

        297 :
      begin                                                                     // mov
              localMem[0 + 130] = 0;
              ip = 298;
      end

        298 :
      begin                                                                     // label
              ip = 299;
      end

        299 :
      begin                                                                     // jGe
              ip = localMem[0+130] >= 99 ? 789 : 300;
      end

        300 :
      begin                                                                     // mov
              localMem[0 + 131] = heapMem[localMem[0+25]*10 + 0];
              ip = 301;
      end

        301 :
      begin                                                                     // subtract
              localMem[0 + 132] = localMem[0+131] - 1;
              ip = 302;
      end

        302 :
      begin                                                                     // mov
              localMem[0 + 133] = heapMem[localMem[0+25]*10 + 4];
              ip = 303;
      end

        303 :
      begin                                                                     // mov
              localMem[0 + 134] = heapMem[localMem[0+133]*10 + localMem[0+132]];
              ip = 304;
      end

        304 :
      begin                                                                     // jLe
              ip = localMem[0+3] <= localMem[0+134] ? 541 : 305;
      end

        305 :
      begin                                                                     // not
              localMem[0 + 135] = !heapMem[localMem[0+25]*10 + 6];
              ip = 306;
      end

        306 :
      begin                                                                     // jEq
              ip = localMem[0+135] == 0 ? 311 : 307;
      end

        307 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 0] = localMem[0+25];
              ip = 308;
      end

        308 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 1] = 2;
              ip = 309;
      end

        309 :
      begin                                                                     // subtract
              heapMem[localMem[0+1]*10 + 2] = localMem[0+131] - 1;
              ip = 310;
      end

        310 :
      begin                                                                     // jmp
              ip = 793;
      end

        311 :
      begin                                                                     // label
              ip = 312;
      end

        312 :
      begin                                                                     // mov
              localMem[0 + 136] = heapMem[localMem[0+25]*10 + 6];
              ip = 313;
      end

        313 :
      begin                                                                     // mov
              localMem[0 + 137] = heapMem[localMem[0+136]*10 + localMem[0+131]];
              ip = 314;
      end

        314 :
      begin                                                                     // label
              ip = 315;
      end

        315 :
      begin                                                                     // mov
              localMem[0 + 139] = heapMem[localMem[0+137]*10 + 0];
              ip = 316;
      end

        316 :
      begin                                                                     // jLt
              ip = localMem[0+139] <  3 ? 534 : 317;
      end

        317 :
      begin                                                                     // mov
              localMem[0 + 140] = heapMem[localMem[0+137]*10 + 3];
              ip = 318;
      end

        318 :
      begin                                                                     // mov
              localMem[0 + 141] = heapMem[localMem[0+137]*10 + 2];
              ip = 319;
      end

        319 :
      begin                                                                     // jEq
              ip = localMem[0+141] == 0 ? 416 : 320;
      end

        320 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 142] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 142] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 142]] = 0;
              ip = 321;
      end

        321 :
      begin                                                                     // mov
              heapMem[localMem[0+142]*10 + 0] = 1;
              ip = 322;
      end

        322 :
      begin                                                                     // mov
              heapMem[localMem[0+142]*10 + 2] = 0;
              ip = 323;
      end

        323 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 143] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 143] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 143]] = 0;
              ip = 324;
      end

        324 :
      begin                                                                     // mov
              heapMem[localMem[0+142]*10 + 4] = localMem[0+143];
              ip = 325;
      end

        325 :
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
              ip = 326;
      end

        326 :
      begin                                                                     // mov
              heapMem[localMem[0+142]*10 + 5] = localMem[0+144];
              ip = 327;
      end

        327 :
      begin                                                                     // mov
              heapMem[localMem[0+142]*10 + 6] = 0;
              ip = 328;
      end

        328 :
      begin                                                                     // mov
              heapMem[localMem[0+142]*10 + 3] = localMem[0+140];
              ip = 329;
      end

        329 :
      begin                                                                     // add
              heapMem[localMem[0+140]*10 + 1] = heapMem[localMem[0+140]*10 + 1] + 1;
              ip = 330;
      end

        330 :
      begin                                                                     // mov
              heapMem[localMem[0+142]*10 + 1] = heapMem[localMem[0+140]*10 + 1];
              ip = 331;
      end

        331 :
      begin                                                                     // not
              localMem[0 + 145] = !heapMem[localMem[0+137]*10 + 6];
              ip = 332;
      end

        332 :
      begin                                                                     // jNe
              ip = localMem[0+145] != 0 ? 361 : 333;
      end

        333 :
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
              ip = 334;
      end

        334 :
      begin                                                                     // mov
              heapMem[localMem[0+142]*10 + 6] = localMem[0+146];
              ip = 335;
      end

        335 :
      begin                                                                     // mov
              localMem[0 + 147] = heapMem[localMem[0+137]*10 + 4];
              ip = 336;
      end

        336 :
      begin                                                                     // mov
              localMem[0 + 148] = heapMem[localMem[0+142]*10 + 4];
              ip = 337;
      end

        337 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+148] + 0 + i] = heapMem[NArea * localMem[0+147] + 2 + i];
                end
              end
              ip = 338;
      end

        338 :
      begin                                                                     // mov
              localMem[0 + 149] = heapMem[localMem[0+137]*10 + 5];
              ip = 339;
      end

        339 :
      begin                                                                     // mov
              localMem[0 + 150] = heapMem[localMem[0+142]*10 + 5];
              ip = 340;
      end

        340 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+150] + 0 + i] = heapMem[NArea * localMem[0+149] + 2 + i];
                end
              end
              ip = 341;
      end

        341 :
      begin                                                                     // mov
              localMem[0 + 151] = heapMem[localMem[0+137]*10 + 6];
              ip = 342;
      end

        342 :
      begin                                                                     // mov
              localMem[0 + 152] = heapMem[localMem[0+142]*10 + 6];
              ip = 343;
      end

        343 :
      begin                                                                     // add
              localMem[0 + 153] = 1 + 1;
              ip = 344;
      end

        344 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+153]) begin
                  heapMem[NArea * localMem[0+152] + 0 + i] = heapMem[NArea * localMem[0+151] + 2 + i];
                end
              end
              ip = 345;
      end

        345 :
      begin                                                                     // mov
              localMem[0 + 154] = heapMem[localMem[0+142]*10 + 0];
              ip = 346;
      end

        346 :
      begin                                                                     // add
              localMem[0 + 155] = localMem[0+154] + 1;
              ip = 347;
      end

        347 :
      begin                                                                     // mov
              localMem[0 + 156] = heapMem[localMem[0+142]*10 + 6];
              ip = 348;
      end

        348 :
      begin                                                                     // label
              ip = 349;
      end

        349 :
      begin                                                                     // mov
              localMem[0 + 157] = 0;
              ip = 350;
      end

        350 :
      begin                                                                     // label
              ip = 351;
      end

        351 :
      begin                                                                     // jGe
              ip = localMem[0+157] >= localMem[0+155] ? 357 : 352;
      end

        352 :
      begin                                                                     // mov
              localMem[0 + 158] = heapMem[localMem[0+156]*10 + localMem[0+157]];
              ip = 353;
      end

        353 :
      begin                                                                     // mov
              heapMem[localMem[0+158]*10 + 2] = localMem[0+142];
              ip = 354;
      end

        354 :
      begin                                                                     // label
              ip = 355;
      end

        355 :
      begin                                                                     // add
              localMem[0 + 157] = localMem[0+157] + 1;
              ip = 356;
      end

        356 :
      begin                                                                     // jmp
              ip = 350;
      end

        357 :
      begin                                                                     // label
              ip = 358;
      end

        358 :
      begin                                                                     // mov
              localMem[0 + 159] = heapMem[localMem[0+137]*10 + 6];
              ip = 359;
      end

        359 :
      begin                                                                     // resize
              arraySizes[localMem[0+159]] = 2;
              ip = 360;
      end

        360 :
      begin                                                                     // jmp
              ip = 368;
      end

        361 :
      begin                                                                     // label
              ip = 362;
      end

        362 :
      begin                                                                     // mov
              localMem[0 + 160] = heapMem[localMem[0+137]*10 + 4];
              ip = 363;
      end

        363 :
      begin                                                                     // mov
              localMem[0 + 161] = heapMem[localMem[0+142]*10 + 4];
              ip = 364;
      end

        364 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+161] + 0 + i] = heapMem[NArea * localMem[0+160] + 2 + i];
                end
              end
              ip = 365;
      end

        365 :
      begin                                                                     // mov
              localMem[0 + 162] = heapMem[localMem[0+137]*10 + 5];
              ip = 366;
      end

        366 :
      begin                                                                     // mov
              localMem[0 + 163] = heapMem[localMem[0+142]*10 + 5];
              ip = 367;
      end

        367 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+163] + 0 + i] = heapMem[NArea * localMem[0+162] + 2 + i];
                end
              end
              ip = 368;
      end

        368 :
      begin                                                                     // label
              ip = 369;
      end

        369 :
      begin                                                                     // mov
              heapMem[localMem[0+137]*10 + 0] = 1;
              ip = 370;
      end

        370 :
      begin                                                                     // mov
              heapMem[localMem[0+142]*10 + 2] = localMem[0+141];
              ip = 371;
      end

        371 :
      begin                                                                     // mov
              localMem[0 + 164] = heapMem[localMem[0+141]*10 + 0];
              ip = 372;
      end

        372 :
      begin                                                                     // mov
              localMem[0 + 165] = heapMem[localMem[0+141]*10 + 6];
              ip = 373;
      end

        373 :
      begin                                                                     // mov
              localMem[0 + 166] = heapMem[localMem[0+165]*10 + localMem[0+164]];
              ip = 374;
      end

        374 :
      begin                                                                     // jNe
              ip = localMem[0+166] != localMem[0+137] ? 393 : 375;
      end

        375 :
      begin                                                                     // mov
              localMem[0 + 167] = heapMem[localMem[0+137]*10 + 4];
              ip = 376;
      end

        376 :
      begin                                                                     // mov
              localMem[0 + 168] = heapMem[localMem[0+167]*10 + 1];
              ip = 377;
      end

        377 :
      begin                                                                     // mov
              localMem[0 + 169] = heapMem[localMem[0+141]*10 + 4];
              ip = 378;
      end

        378 :
      begin                                                                     // mov
              heapMem[localMem[0+169]*10 + localMem[0+164]] = localMem[0+168];
              ip = 379;
      end

        379 :
      begin                                                                     // mov
              localMem[0 + 170] = heapMem[localMem[0+137]*10 + 5];
              ip = 380;
      end

        380 :
      begin                                                                     // mov
              localMem[0 + 171] = heapMem[localMem[0+170]*10 + 1];
              ip = 381;
      end

        381 :
      begin                                                                     // mov
              localMem[0 + 172] = heapMem[localMem[0+141]*10 + 5];
              ip = 382;
      end

        382 :
      begin                                                                     // mov
              heapMem[localMem[0+172]*10 + localMem[0+164]] = localMem[0+171];
              ip = 383;
      end

        383 :
      begin                                                                     // mov
              localMem[0 + 173] = heapMem[localMem[0+137]*10 + 4];
              ip = 384;
      end

        384 :
      begin                                                                     // resize
              arraySizes[localMem[0+173]] = 1;
              ip = 385;
      end

        385 :
      begin                                                                     // mov
              localMem[0 + 174] = heapMem[localMem[0+137]*10 + 5];
              ip = 386;
      end

        386 :
      begin                                                                     // resize
              arraySizes[localMem[0+174]] = 1;
              ip = 387;
      end

        387 :
      begin                                                                     // add
              localMem[0 + 175] = localMem[0+164] + 1;
              ip = 388;
      end

        388 :
      begin                                                                     // mov
              heapMem[localMem[0+141]*10 + 0] = localMem[0+175];
              ip = 389;
      end

        389 :
      begin                                                                     // mov
              localMem[0 + 176] = heapMem[localMem[0+141]*10 + 6];
              ip = 390;
      end

        390 :
      begin                                                                     // mov
              heapMem[localMem[0+176]*10 + localMem[0+175]] = localMem[0+142];
              ip = 391;
      end

        391 :
      begin                                                                     // jmp
              ip = 531;
      end

        392 :
      begin                                                                     // jmp
              ip = 415;
      end

        393 :
      begin                                                                     // label
              ip = 394;
      end

        394 :
      begin                                                                     // assertNe
            ip = 395;
      end

        395 :
      begin                                                                     // mov
              localMem[0 + 177] = heapMem[localMem[0+141]*10 + 6];
              ip = 396;
      end

        396 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+177] * NArea + i] == localMem[0+137]) localMem[0 + 178] = i + 1;
              end
              ip = 397;
      end

        397 :
      begin                                                                     // subtract
              localMem[0 + 178] = localMem[0+178] - 1;
              ip = 398;
      end

        398 :
      begin                                                                     // mov
              localMem[0 + 179] = heapMem[localMem[0+137]*10 + 4];
              ip = 399;
      end

        399 :
      begin                                                                     // mov
              localMem[0 + 180] = heapMem[localMem[0+179]*10 + 1];
              ip = 400;
      end

        400 :
      begin                                                                     // mov
              localMem[0 + 181] = heapMem[localMem[0+137]*10 + 5];
              ip = 401;
      end

        401 :
      begin                                                                     // mov
              localMem[0 + 182] = heapMem[localMem[0+181]*10 + 1];
              ip = 402;
      end

        402 :
      begin                                                                     // mov
              localMem[0 + 183] = heapMem[localMem[0+137]*10 + 4];
              ip = 403;
      end

        403 :
      begin                                                                     // resize
              arraySizes[localMem[0+183]] = 1;
              ip = 404;
      end

        404 :
      begin                                                                     // mov
              localMem[0 + 184] = heapMem[localMem[0+137]*10 + 5];
              ip = 405;
      end

        405 :
      begin                                                                     // resize
              arraySizes[localMem[0+184]] = 1;
              ip = 406;
      end

        406 :
      begin                                                                     // mov
              localMem[0 + 185] = heapMem[localMem[0+141]*10 + 4];
              ip = 407;
      end

        407 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+185] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[178]) begin
                  heapMem[NArea * localMem[0+185] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+185] + localMem[178]] = localMem[0+180];                                    // Insert new value
              arraySizes[localMem[0+185]] = arraySizes[localMem[0+185]] + 1;                              // Increase array size
              ip = 408;
      end

        408 :
      begin                                                                     // mov
              localMem[0 + 186] = heapMem[localMem[0+141]*10 + 5];
              ip = 409;
      end

        409 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+186] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[178]) begin
                  heapMem[NArea * localMem[0+186] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+186] + localMem[178]] = localMem[0+182];                                    // Insert new value
              arraySizes[localMem[0+186]] = arraySizes[localMem[0+186]] + 1;                              // Increase array size
              ip = 410;
      end

        410 :
      begin                                                                     // mov
              localMem[0 + 187] = heapMem[localMem[0+141]*10 + 6];
              ip = 411;
      end

        411 :
      begin                                                                     // add
              localMem[0 + 188] = localMem[0+178] + 1;
              ip = 412;
      end

        412 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+187] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[188]) begin
                  heapMem[NArea * localMem[0+187] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+187] + localMem[188]] = localMem[0+142];                                    // Insert new value
              arraySizes[localMem[0+187]] = arraySizes[localMem[0+187]] + 1;                              // Increase array size
              ip = 413;
      end

        413 :
      begin                                                                     // add
              heapMem[localMem[0+141]*10 + 0] = heapMem[localMem[0+141]*10 + 0] + 1;
              ip = 414;
      end

        414 :
      begin                                                                     // jmp
              ip = 531;
      end

        415 :
      begin                                                                     // label
              ip = 416;
      end

        416 :
      begin                                                                     // label
              ip = 417;
      end

        417 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 189] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 189] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 189]] = 0;
              ip = 418;
      end

        418 :
      begin                                                                     // mov
              heapMem[localMem[0+189]*10 + 0] = 1;
              ip = 419;
      end

        419 :
      begin                                                                     // mov
              heapMem[localMem[0+189]*10 + 2] = 0;
              ip = 420;
      end

        420 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 190] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 190] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 190]] = 0;
              ip = 421;
      end

        421 :
      begin                                                                     // mov
              heapMem[localMem[0+189]*10 + 4] = localMem[0+190];
              ip = 422;
      end

        422 :
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
              ip = 423;
      end

        423 :
      begin                                                                     // mov
              heapMem[localMem[0+189]*10 + 5] = localMem[0+191];
              ip = 424;
      end

        424 :
      begin                                                                     // mov
              heapMem[localMem[0+189]*10 + 6] = 0;
              ip = 425;
      end

        425 :
      begin                                                                     // mov
              heapMem[localMem[0+189]*10 + 3] = localMem[0+140];
              ip = 426;
      end

        426 :
      begin                                                                     // add
              heapMem[localMem[0+140]*10 + 1] = heapMem[localMem[0+140]*10 + 1] + 1;
              ip = 427;
      end

        427 :
      begin                                                                     // mov
              heapMem[localMem[0+189]*10 + 1] = heapMem[localMem[0+140]*10 + 1];
              ip = 428;
      end

        428 :
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
              ip = 429;
      end

        429 :
      begin                                                                     // mov
              heapMem[localMem[0+192]*10 + 0] = 1;
              ip = 430;
      end

        430 :
      begin                                                                     // mov
              heapMem[localMem[0+192]*10 + 2] = 0;
              ip = 431;
      end

        431 :
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
              ip = 432;
      end

        432 :
      begin                                                                     // mov
              heapMem[localMem[0+192]*10 + 4] = localMem[0+193];
              ip = 433;
      end

        433 :
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
              ip = 434;
      end

        434 :
      begin                                                                     // mov
              heapMem[localMem[0+192]*10 + 5] = localMem[0+194];
              ip = 435;
      end

        435 :
      begin                                                                     // mov
              heapMem[localMem[0+192]*10 + 6] = 0;
              ip = 436;
      end

        436 :
      begin                                                                     // mov
              heapMem[localMem[0+192]*10 + 3] = localMem[0+140];
              ip = 437;
      end

        437 :
      begin                                                                     // add
              heapMem[localMem[0+140]*10 + 1] = heapMem[localMem[0+140]*10 + 1] + 1;
              ip = 438;
      end

        438 :
      begin                                                                     // mov
              heapMem[localMem[0+192]*10 + 1] = heapMem[localMem[0+140]*10 + 1];
              ip = 439;
      end

        439 :
      begin                                                                     // not
              localMem[0 + 195] = !heapMem[localMem[0+137]*10 + 6];
              ip = 440;
      end

        440 :
      begin                                                                     // jNe
              ip = localMem[0+195] != 0 ? 492 : 441;
      end

        441 :
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
              ip = 442;
      end

        442 :
      begin                                                                     // mov
              heapMem[localMem[0+189]*10 + 6] = localMem[0+196];
              ip = 443;
      end

        443 :
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
              ip = 444;
      end

        444 :
      begin                                                                     // mov
              heapMem[localMem[0+192]*10 + 6] = localMem[0+197];
              ip = 445;
      end

        445 :
      begin                                                                     // mov
              localMem[0 + 198] = heapMem[localMem[0+137]*10 + 4];
              ip = 446;
      end

        446 :
      begin                                                                     // mov
              localMem[0 + 199] = heapMem[localMem[0+189]*10 + 4];
              ip = 447;
      end

        447 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+199] + 0 + i] = heapMem[NArea * localMem[0+198] + 0 + i];
                end
              end
              ip = 448;
      end

        448 :
      begin                                                                     // mov
              localMem[0 + 200] = heapMem[localMem[0+137]*10 + 5];
              ip = 449;
      end

        449 :
      begin                                                                     // mov
              localMem[0 + 201] = heapMem[localMem[0+189]*10 + 5];
              ip = 450;
      end

        450 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+201] + 0 + i] = heapMem[NArea * localMem[0+200] + 0 + i];
                end
              end
              ip = 451;
      end

        451 :
      begin                                                                     // mov
              localMem[0 + 202] = heapMem[localMem[0+137]*10 + 6];
              ip = 452;
      end

        452 :
      begin                                                                     // mov
              localMem[0 + 203] = heapMem[localMem[0+189]*10 + 6];
              ip = 453;
      end

        453 :
      begin                                                                     // add
              localMem[0 + 204] = 1 + 1;
              ip = 454;
      end

        454 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+204]) begin
                  heapMem[NArea * localMem[0+203] + 0 + i] = heapMem[NArea * localMem[0+202] + 0 + i];
                end
              end
              ip = 455;
      end

        455 :
      begin                                                                     // mov
              localMem[0 + 205] = heapMem[localMem[0+137]*10 + 4];
              ip = 456;
      end

        456 :
      begin                                                                     // mov
              localMem[0 + 206] = heapMem[localMem[0+192]*10 + 4];
              ip = 457;
      end

        457 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+206] + 0 + i] = heapMem[NArea * localMem[0+205] + 2 + i];
                end
              end
              ip = 458;
      end

        458 :
      begin                                                                     // mov
              localMem[0 + 207] = heapMem[localMem[0+137]*10 + 5];
              ip = 459;
      end

        459 :
      begin                                                                     // mov
              localMem[0 + 208] = heapMem[localMem[0+192]*10 + 5];
              ip = 460;
      end

        460 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+208] + 0 + i] = heapMem[NArea * localMem[0+207] + 2 + i];
                end
              end
              ip = 461;
      end

        461 :
      begin                                                                     // mov
              localMem[0 + 209] = heapMem[localMem[0+137]*10 + 6];
              ip = 462;
      end

        462 :
      begin                                                                     // mov
              localMem[0 + 210] = heapMem[localMem[0+192]*10 + 6];
              ip = 463;
      end

        463 :
      begin                                                                     // add
              localMem[0 + 211] = 1 + 1;
              ip = 464;
      end

        464 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+211]) begin
                  heapMem[NArea * localMem[0+210] + 0 + i] = heapMem[NArea * localMem[0+209] + 2 + i];
                end
              end
              ip = 465;
      end

        465 :
      begin                                                                     // mov
              localMem[0 + 212] = heapMem[localMem[0+189]*10 + 0];
              ip = 466;
      end

        466 :
      begin                                                                     // add
              localMem[0 + 213] = localMem[0+212] + 1;
              ip = 467;
      end

        467 :
      begin                                                                     // mov
              localMem[0 + 214] = heapMem[localMem[0+189]*10 + 6];
              ip = 468;
      end

        468 :
      begin                                                                     // label
              ip = 469;
      end

        469 :
      begin                                                                     // mov
              localMem[0 + 215] = 0;
              ip = 470;
      end

        470 :
      begin                                                                     // label
              ip = 471;
      end

        471 :
      begin                                                                     // jGe
              ip = localMem[0+215] >= localMem[0+213] ? 477 : 472;
      end

        472 :
      begin                                                                     // mov
              localMem[0 + 216] = heapMem[localMem[0+214]*10 + localMem[0+215]];
              ip = 473;
      end

        473 :
      begin                                                                     // mov
              heapMem[localMem[0+216]*10 + 2] = localMem[0+189];
              ip = 474;
      end

        474 :
      begin                                                                     // label
              ip = 475;
      end

        475 :
      begin                                                                     // add
              localMem[0 + 215] = localMem[0+215] + 1;
              ip = 476;
      end

        476 :
      begin                                                                     // jmp
              ip = 470;
      end

        477 :
      begin                                                                     // label
              ip = 478;
      end

        478 :
      begin                                                                     // mov
              localMem[0 + 217] = heapMem[localMem[0+192]*10 + 0];
              ip = 479;
      end

        479 :
      begin                                                                     // add
              localMem[0 + 218] = localMem[0+217] + 1;
              ip = 480;
      end

        480 :
      begin                                                                     // mov
              localMem[0 + 219] = heapMem[localMem[0+192]*10 + 6];
              ip = 481;
      end

        481 :
      begin                                                                     // label
              ip = 482;
      end

        482 :
      begin                                                                     // mov
              localMem[0 + 220] = 0;
              ip = 483;
      end

        483 :
      begin                                                                     // label
              ip = 484;
      end

        484 :
      begin                                                                     // jGe
              ip = localMem[0+220] >= localMem[0+218] ? 490 : 485;
      end

        485 :
      begin                                                                     // mov
              localMem[0 + 221] = heapMem[localMem[0+219]*10 + localMem[0+220]];
              ip = 486;
      end

        486 :
      begin                                                                     // mov
              heapMem[localMem[0+221]*10 + 2] = localMem[0+192];
              ip = 487;
      end

        487 :
      begin                                                                     // label
              ip = 488;
      end

        488 :
      begin                                                                     // add
              localMem[0 + 220] = localMem[0+220] + 1;
              ip = 489;
      end

        489 :
      begin                                                                     // jmp
              ip = 483;
      end

        490 :
      begin                                                                     // label
              ip = 491;
      end

        491 :
      begin                                                                     // jmp
              ip = 507;
      end

        492 :
      begin                                                                     // label
              ip = 493;
      end

        493 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 222] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 222] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 222]] = 0;
              ip = 494;
      end

        494 :
      begin                                                                     // mov
              heapMem[localMem[0+137]*10 + 6] = localMem[0+222];
              ip = 495;
      end

        495 :
      begin                                                                     // mov
              localMem[0 + 223] = heapMem[localMem[0+137]*10 + 4];
              ip = 496;
      end

        496 :
      begin                                                                     // mov
              localMem[0 + 224] = heapMem[localMem[0+189]*10 + 4];
              ip = 497;
      end

        497 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+224] + 0 + i] = heapMem[NArea * localMem[0+223] + 0 + i];
                end
              end
              ip = 498;
      end

        498 :
      begin                                                                     // mov
              localMem[0 + 225] = heapMem[localMem[0+137]*10 + 5];
              ip = 499;
      end

        499 :
      begin                                                                     // mov
              localMem[0 + 226] = heapMem[localMem[0+189]*10 + 5];
              ip = 500;
      end

        500 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+226] + 0 + i] = heapMem[NArea * localMem[0+225] + 0 + i];
                end
              end
              ip = 501;
      end

        501 :
      begin                                                                     // mov
              localMem[0 + 227] = heapMem[localMem[0+137]*10 + 4];
              ip = 502;
      end

        502 :
      begin                                                                     // mov
              localMem[0 + 228] = heapMem[localMem[0+192]*10 + 4];
              ip = 503;
      end

        503 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+228] + 0 + i] = heapMem[NArea * localMem[0+227] + 2 + i];
                end
              end
              ip = 504;
      end

        504 :
      begin                                                                     // mov
              localMem[0 + 229] = heapMem[localMem[0+137]*10 + 5];
              ip = 505;
      end

        505 :
      begin                                                                     // mov
              localMem[0 + 230] = heapMem[localMem[0+192]*10 + 5];
              ip = 506;
      end

        506 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+230] + 0 + i] = heapMem[NArea * localMem[0+229] + 2 + i];
                end
              end
              ip = 507;
      end

        507 :
      begin                                                                     // label
              ip = 508;
      end

        508 :
      begin                                                                     // mov
              heapMem[localMem[0+189]*10 + 2] = localMem[0+137];
              ip = 509;
      end

        509 :
      begin                                                                     // mov
              heapMem[localMem[0+192]*10 + 2] = localMem[0+137];
              ip = 510;
      end

        510 :
      begin                                                                     // mov
              localMem[0 + 231] = heapMem[localMem[0+137]*10 + 4];
              ip = 511;
      end

        511 :
      begin                                                                     // mov
              localMem[0 + 232] = heapMem[localMem[0+231]*10 + 1];
              ip = 512;
      end

        512 :
      begin                                                                     // mov
              localMem[0 + 233] = heapMem[localMem[0+137]*10 + 5];
              ip = 513;
      end

        513 :
      begin                                                                     // mov
              localMem[0 + 234] = heapMem[localMem[0+233]*10 + 1];
              ip = 514;
      end

        514 :
      begin                                                                     // mov
              localMem[0 + 235] = heapMem[localMem[0+137]*10 + 4];
              ip = 515;
      end

        515 :
      begin                                                                     // mov
              heapMem[localMem[0+235]*10 + 0] = localMem[0+232];
              ip = 516;
      end

        516 :
      begin                                                                     // mov
              localMem[0 + 236] = heapMem[localMem[0+137]*10 + 5];
              ip = 517;
      end

        517 :
      begin                                                                     // mov
              heapMem[localMem[0+236]*10 + 0] = localMem[0+234];
              ip = 518;
      end

        518 :
      begin                                                                     // mov
              localMem[0 + 237] = heapMem[localMem[0+137]*10 + 6];
              ip = 519;
      end

        519 :
      begin                                                                     // mov
              heapMem[localMem[0+237]*10 + 0] = localMem[0+189];
              ip = 520;
      end

        520 :
      begin                                                                     // mov
              localMem[0 + 238] = heapMem[localMem[0+137]*10 + 6];
              ip = 521;
      end

        521 :
      begin                                                                     // mov
              heapMem[localMem[0+238]*10 + 1] = localMem[0+192];
              ip = 522;
      end

        522 :
      begin                                                                     // mov
              heapMem[localMem[0+137]*10 + 0] = 1;
              ip = 523;
      end

        523 :
      begin                                                                     // mov
              localMem[0 + 239] = heapMem[localMem[0+137]*10 + 4];
              ip = 524;
      end

        524 :
      begin                                                                     // resize
              arraySizes[localMem[0+239]] = 1;
              ip = 525;
      end

        525 :
      begin                                                                     // mov
              localMem[0 + 240] = heapMem[localMem[0+137]*10 + 5];
              ip = 526;
      end

        526 :
      begin                                                                     // resize
              arraySizes[localMem[0+240]] = 1;
              ip = 527;
      end

        527 :
      begin                                                                     // mov
              localMem[0 + 241] = heapMem[localMem[0+137]*10 + 6];
              ip = 528;
      end

        528 :
      begin                                                                     // resize
              arraySizes[localMem[0+241]] = 2;
              ip = 529;
      end

        529 :
      begin                                                                     // jmp
              ip = 531;
      end

        530 :
      begin                                                                     // jmp
              ip = 536;
      end

        531 :
      begin                                                                     // label
              ip = 532;
      end

        532 :
      begin                                                                     // mov
              localMem[0 + 138] = 1;
              ip = 533;
      end

        533 :
      begin                                                                     // jmp
              ip = 536;
      end

        534 :
      begin                                                                     // label
              ip = 535;
      end

        535 :
      begin                                                                     // mov
              localMem[0 + 138] = 0;
              ip = 536;
      end

        536 :
      begin                                                                     // label
              ip = 537;
      end

        537 :
      begin                                                                     // jNe
              ip = localMem[0+138] != 0 ? 539 : 538;
      end

        538 :
      begin                                                                     // mov
              localMem[0 + 25] = localMem[0+137];
              ip = 539;
      end

        539 :
      begin                                                                     // label
              ip = 540;
      end

        540 :
      begin                                                                     // jmp
              ip = 786;
      end

        541 :
      begin                                                                     // label
              ip = 542;
      end

        542 :
      begin                                                                     // mov
              localMem[0 + 242] = heapMem[localMem[0+25]*10 + 4];
              ip = 543;
      end

        543 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+242] * NArea + i] == localMem[0+3]) localMem[0 + 243] = i + 1;
              end
              ip = 544;
      end

        544 :
      begin                                                                     // jEq
              ip = localMem[0+243] == 0 ? 549 : 545;
      end

        545 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 0] = localMem[0+25];
              ip = 546;
      end

        546 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 1] = 1;
              ip = 547;
      end

        547 :
      begin                                                                     // subtract
              heapMem[localMem[0+1]*10 + 2] = localMem[0+243] - 1;
              ip = 548;
      end

        548 :
      begin                                                                     // jmp
              ip = 793;
      end

        549 :
      begin                                                                     // label
              ip = 550;
      end

        550 :
      begin                                                                     // arrayCountLess
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+242] * NArea + i] < localMem[0+3]) j = j + 1;
              end
              localMem[0 + 244] = j;
              ip = 551;
      end

        551 :
      begin                                                                     // not
              localMem[0 + 245] = !heapMem[localMem[0+25]*10 + 6];
              ip = 552;
      end

        552 :
      begin                                                                     // jEq
              ip = localMem[0+245] == 0 ? 557 : 553;
      end

        553 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 0] = localMem[0+25];
              ip = 554;
      end

        554 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 1] = 0;
              ip = 555;
      end

        555 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 2] = localMem[0+244];
              ip = 556;
      end

        556 :
      begin                                                                     // jmp
              ip = 793;
      end

        557 :
      begin                                                                     // label
              ip = 558;
      end

        558 :
      begin                                                                     // mov
              localMem[0 + 246] = heapMem[localMem[0+25]*10 + 6];
              ip = 559;
      end

        559 :
      begin                                                                     // mov
              localMem[0 + 247] = heapMem[localMem[0+246]*10 + localMem[0+244]];
              ip = 560;
      end

        560 :
      begin                                                                     // label
              ip = 561;
      end

        561 :
      begin                                                                     // mov
              localMem[0 + 249] = heapMem[localMem[0+247]*10 + 0];
              ip = 562;
      end

        562 :
      begin                                                                     // jLt
              ip = localMem[0+249] <  3 ? 780 : 563;
      end

        563 :
      begin                                                                     // mov
              localMem[0 + 250] = heapMem[localMem[0+247]*10 + 3];
              ip = 564;
      end

        564 :
      begin                                                                     // mov
              localMem[0 + 251] = heapMem[localMem[0+247]*10 + 2];
              ip = 565;
      end

        565 :
      begin                                                                     // jEq
              ip = localMem[0+251] == 0 ? 662 : 566;
      end

        566 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 252] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 252] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 252]] = 0;
              ip = 567;
      end

        567 :
      begin                                                                     // mov
              heapMem[localMem[0+252]*10 + 0] = 1;
              ip = 568;
      end

        568 :
      begin                                                                     // mov
              heapMem[localMem[0+252]*10 + 2] = 0;
              ip = 569;
      end

        569 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 253] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 253] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 253]] = 0;
              ip = 570;
      end

        570 :
      begin                                                                     // mov
              heapMem[localMem[0+252]*10 + 4] = localMem[0+253];
              ip = 571;
      end

        571 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 254] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 254] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 254]] = 0;
              ip = 572;
      end

        572 :
      begin                                                                     // mov
              heapMem[localMem[0+252]*10 + 5] = localMem[0+254];
              ip = 573;
      end

        573 :
      begin                                                                     // mov
              heapMem[localMem[0+252]*10 + 6] = 0;
              ip = 574;
      end

        574 :
      begin                                                                     // mov
              heapMem[localMem[0+252]*10 + 3] = localMem[0+250];
              ip = 575;
      end

        575 :
      begin                                                                     // add
              heapMem[localMem[0+250]*10 + 1] = heapMem[localMem[0+250]*10 + 1] + 1;
              ip = 576;
      end

        576 :
      begin                                                                     // mov
              heapMem[localMem[0+252]*10 + 1] = heapMem[localMem[0+250]*10 + 1];
              ip = 577;
      end

        577 :
      begin                                                                     // not
              localMem[0 + 255] = !heapMem[localMem[0+247]*10 + 6];
              ip = 578;
      end

        578 :
      begin                                                                     // jNe
              ip = localMem[0+255] != 0 ? 607 : 579;
      end

        579 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 256] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 256] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 256]] = 0;
              ip = 580;
      end

        580 :
      begin                                                                     // mov
              heapMem[localMem[0+252]*10 + 6] = localMem[0+256];
              ip = 581;
      end

        581 :
      begin                                                                     // mov
              localMem[0 + 257] = heapMem[localMem[0+247]*10 + 4];
              ip = 582;
      end

        582 :
      begin                                                                     // mov
              localMem[0 + 258] = heapMem[localMem[0+252]*10 + 4];
              ip = 583;
      end

        583 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+258] + 0 + i] = heapMem[NArea * localMem[0+257] + 2 + i];
                end
              end
              ip = 584;
      end

        584 :
      begin                                                                     // mov
              localMem[0 + 259] = heapMem[localMem[0+247]*10 + 5];
              ip = 585;
      end

        585 :
      begin                                                                     // mov
              localMem[0 + 260] = heapMem[localMem[0+252]*10 + 5];
              ip = 586;
      end

        586 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+260] + 0 + i] = heapMem[NArea * localMem[0+259] + 2 + i];
                end
              end
              ip = 587;
      end

        587 :
      begin                                                                     // mov
              localMem[0 + 261] = heapMem[localMem[0+247]*10 + 6];
              ip = 588;
      end

        588 :
      begin                                                                     // mov
              localMem[0 + 262] = heapMem[localMem[0+252]*10 + 6];
              ip = 589;
      end

        589 :
      begin                                                                     // add
              localMem[0 + 263] = 1 + 1;
              ip = 590;
      end

        590 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+263]) begin
                  heapMem[NArea * localMem[0+262] + 0 + i] = heapMem[NArea * localMem[0+261] + 2 + i];
                end
              end
              ip = 591;
      end

        591 :
      begin                                                                     // mov
              localMem[0 + 264] = heapMem[localMem[0+252]*10 + 0];
              ip = 592;
      end

        592 :
      begin                                                                     // add
              localMem[0 + 265] = localMem[0+264] + 1;
              ip = 593;
      end

        593 :
      begin                                                                     // mov
              localMem[0 + 266] = heapMem[localMem[0+252]*10 + 6];
              ip = 594;
      end

        594 :
      begin                                                                     // label
              ip = 595;
      end

        595 :
      begin                                                                     // mov
              localMem[0 + 267] = 0;
              ip = 596;
      end

        596 :
      begin                                                                     // label
              ip = 597;
      end

        597 :
      begin                                                                     // jGe
              ip = localMem[0+267] >= localMem[0+265] ? 603 : 598;
      end

        598 :
      begin                                                                     // mov
              localMem[0 + 268] = heapMem[localMem[0+266]*10 + localMem[0+267]];
              ip = 599;
      end

        599 :
      begin                                                                     // mov
              heapMem[localMem[0+268]*10 + 2] = localMem[0+252];
              ip = 600;
      end

        600 :
      begin                                                                     // label
              ip = 601;
      end

        601 :
      begin                                                                     // add
              localMem[0 + 267] = localMem[0+267] + 1;
              ip = 602;
      end

        602 :
      begin                                                                     // jmp
              ip = 596;
      end

        603 :
      begin                                                                     // label
              ip = 604;
      end

        604 :
      begin                                                                     // mov
              localMem[0 + 269] = heapMem[localMem[0+247]*10 + 6];
              ip = 605;
      end

        605 :
      begin                                                                     // resize
              arraySizes[localMem[0+269]] = 2;
              ip = 606;
      end

        606 :
      begin                                                                     // jmp
              ip = 614;
      end

        607 :
      begin                                                                     // label
              ip = 608;
      end

        608 :
      begin                                                                     // mov
              localMem[0 + 270] = heapMem[localMem[0+247]*10 + 4];
              ip = 609;
      end

        609 :
      begin                                                                     // mov
              localMem[0 + 271] = heapMem[localMem[0+252]*10 + 4];
              ip = 610;
      end

        610 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+271] + 0 + i] = heapMem[NArea * localMem[0+270] + 2 + i];
                end
              end
              ip = 611;
      end

        611 :
      begin                                                                     // mov
              localMem[0 + 272] = heapMem[localMem[0+247]*10 + 5];
              ip = 612;
      end

        612 :
      begin                                                                     // mov
              localMem[0 + 273] = heapMem[localMem[0+252]*10 + 5];
              ip = 613;
      end

        613 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+273] + 0 + i] = heapMem[NArea * localMem[0+272] + 2 + i];
                end
              end
              ip = 614;
      end

        614 :
      begin                                                                     // label
              ip = 615;
      end

        615 :
      begin                                                                     // mov
              heapMem[localMem[0+247]*10 + 0] = 1;
              ip = 616;
      end

        616 :
      begin                                                                     // mov
              heapMem[localMem[0+252]*10 + 2] = localMem[0+251];
              ip = 617;
      end

        617 :
      begin                                                                     // mov
              localMem[0 + 274] = heapMem[localMem[0+251]*10 + 0];
              ip = 618;
      end

        618 :
      begin                                                                     // mov
              localMem[0 + 275] = heapMem[localMem[0+251]*10 + 6];
              ip = 619;
      end

        619 :
      begin                                                                     // mov
              localMem[0 + 276] = heapMem[localMem[0+275]*10 + localMem[0+274]];
              ip = 620;
      end

        620 :
      begin                                                                     // jNe
              ip = localMem[0+276] != localMem[0+247] ? 639 : 621;
      end

        621 :
      begin                                                                     // mov
              localMem[0 + 277] = heapMem[localMem[0+247]*10 + 4];
              ip = 622;
      end

        622 :
      begin                                                                     // mov
              localMem[0 + 278] = heapMem[localMem[0+277]*10 + 1];
              ip = 623;
      end

        623 :
      begin                                                                     // mov
              localMem[0 + 279] = heapMem[localMem[0+251]*10 + 4];
              ip = 624;
      end

        624 :
      begin                                                                     // mov
              heapMem[localMem[0+279]*10 + localMem[0+274]] = localMem[0+278];
              ip = 625;
      end

        625 :
      begin                                                                     // mov
              localMem[0 + 280] = heapMem[localMem[0+247]*10 + 5];
              ip = 626;
      end

        626 :
      begin                                                                     // mov
              localMem[0 + 281] = heapMem[localMem[0+280]*10 + 1];
              ip = 627;
      end

        627 :
      begin                                                                     // mov
              localMem[0 + 282] = heapMem[localMem[0+251]*10 + 5];
              ip = 628;
      end

        628 :
      begin                                                                     // mov
              heapMem[localMem[0+282]*10 + localMem[0+274]] = localMem[0+281];
              ip = 629;
      end

        629 :
      begin                                                                     // mov
              localMem[0 + 283] = heapMem[localMem[0+247]*10 + 4];
              ip = 630;
      end

        630 :
      begin                                                                     // resize
              arraySizes[localMem[0+283]] = 1;
              ip = 631;
      end

        631 :
      begin                                                                     // mov
              localMem[0 + 284] = heapMem[localMem[0+247]*10 + 5];
              ip = 632;
      end

        632 :
      begin                                                                     // resize
              arraySizes[localMem[0+284]] = 1;
              ip = 633;
      end

        633 :
      begin                                                                     // add
              localMem[0 + 285] = localMem[0+274] + 1;
              ip = 634;
      end

        634 :
      begin                                                                     // mov
              heapMem[localMem[0+251]*10 + 0] = localMem[0+285];
              ip = 635;
      end

        635 :
      begin                                                                     // mov
              localMem[0 + 286] = heapMem[localMem[0+251]*10 + 6];
              ip = 636;
      end

        636 :
      begin                                                                     // mov
              heapMem[localMem[0+286]*10 + localMem[0+285]] = localMem[0+252];
              ip = 637;
      end

        637 :
      begin                                                                     // jmp
              ip = 777;
      end

        638 :
      begin                                                                     // jmp
              ip = 661;
      end

        639 :
      begin                                                                     // label
              ip = 640;
      end

        640 :
      begin                                                                     // assertNe
            ip = 641;
      end

        641 :
      begin                                                                     // mov
              localMem[0 + 287] = heapMem[localMem[0+251]*10 + 6];
              ip = 642;
      end

        642 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+287] * NArea + i] == localMem[0+247]) localMem[0 + 288] = i + 1;
              end
              ip = 643;
      end

        643 :
      begin                                                                     // subtract
              localMem[0 + 288] = localMem[0+288] - 1;
              ip = 644;
      end

        644 :
      begin                                                                     // mov
              localMem[0 + 289] = heapMem[localMem[0+247]*10 + 4];
              ip = 645;
      end

        645 :
      begin                                                                     // mov
              localMem[0 + 290] = heapMem[localMem[0+289]*10 + 1];
              ip = 646;
      end

        646 :
      begin                                                                     // mov
              localMem[0 + 291] = heapMem[localMem[0+247]*10 + 5];
              ip = 647;
      end

        647 :
      begin                                                                     // mov
              localMem[0 + 292] = heapMem[localMem[0+291]*10 + 1];
              ip = 648;
      end

        648 :
      begin                                                                     // mov
              localMem[0 + 293] = heapMem[localMem[0+247]*10 + 4];
              ip = 649;
      end

        649 :
      begin                                                                     // resize
              arraySizes[localMem[0+293]] = 1;
              ip = 650;
      end

        650 :
      begin                                                                     // mov
              localMem[0 + 294] = heapMem[localMem[0+247]*10 + 5];
              ip = 651;
      end

        651 :
      begin                                                                     // resize
              arraySizes[localMem[0+294]] = 1;
              ip = 652;
      end

        652 :
      begin                                                                     // mov
              localMem[0 + 295] = heapMem[localMem[0+251]*10 + 4];
              ip = 653;
      end

        653 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+295] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[288]) begin
                  heapMem[NArea * localMem[0+295] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+295] + localMem[288]] = localMem[0+290];                                    // Insert new value
              arraySizes[localMem[0+295]] = arraySizes[localMem[0+295]] + 1;                              // Increase array size
              ip = 654;
      end

        654 :
      begin                                                                     // mov
              localMem[0 + 296] = heapMem[localMem[0+251]*10 + 5];
              ip = 655;
      end

        655 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+296] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[288]) begin
                  heapMem[NArea * localMem[0+296] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+296] + localMem[288]] = localMem[0+292];                                    // Insert new value
              arraySizes[localMem[0+296]] = arraySizes[localMem[0+296]] + 1;                              // Increase array size
              ip = 656;
      end

        656 :
      begin                                                                     // mov
              localMem[0 + 297] = heapMem[localMem[0+251]*10 + 6];
              ip = 657;
      end

        657 :
      begin                                                                     // add
              localMem[0 + 298] = localMem[0+288] + 1;
              ip = 658;
      end

        658 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+297] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[298]) begin
                  heapMem[NArea * localMem[0+297] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+297] + localMem[298]] = localMem[0+252];                                    // Insert new value
              arraySizes[localMem[0+297]] = arraySizes[localMem[0+297]] + 1;                              // Increase array size
              ip = 659;
      end

        659 :
      begin                                                                     // add
              heapMem[localMem[0+251]*10 + 0] = heapMem[localMem[0+251]*10 + 0] + 1;
              ip = 660;
      end

        660 :
      begin                                                                     // jmp
              ip = 777;
      end

        661 :
      begin                                                                     // label
              ip = 662;
      end

        662 :
      begin                                                                     // label
              ip = 663;
      end

        663 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 299] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 299] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 299]] = 0;
              ip = 664;
      end

        664 :
      begin                                                                     // mov
              heapMem[localMem[0+299]*10 + 0] = 1;
              ip = 665;
      end

        665 :
      begin                                                                     // mov
              heapMem[localMem[0+299]*10 + 2] = 0;
              ip = 666;
      end

        666 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 300] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 300] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 300]] = 0;
              ip = 667;
      end

        667 :
      begin                                                                     // mov
              heapMem[localMem[0+299]*10 + 4] = localMem[0+300];
              ip = 668;
      end

        668 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 301] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 301] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 301]] = 0;
              ip = 669;
      end

        669 :
      begin                                                                     // mov
              heapMem[localMem[0+299]*10 + 5] = localMem[0+301];
              ip = 670;
      end

        670 :
      begin                                                                     // mov
              heapMem[localMem[0+299]*10 + 6] = 0;
              ip = 671;
      end

        671 :
      begin                                                                     // mov
              heapMem[localMem[0+299]*10 + 3] = localMem[0+250];
              ip = 672;
      end

        672 :
      begin                                                                     // add
              heapMem[localMem[0+250]*10 + 1] = heapMem[localMem[0+250]*10 + 1] + 1;
              ip = 673;
      end

        673 :
      begin                                                                     // mov
              heapMem[localMem[0+299]*10 + 1] = heapMem[localMem[0+250]*10 + 1];
              ip = 674;
      end

        674 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 302] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 302] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 302]] = 0;
              ip = 675;
      end

        675 :
      begin                                                                     // mov
              heapMem[localMem[0+302]*10 + 0] = 1;
              ip = 676;
      end

        676 :
      begin                                                                     // mov
              heapMem[localMem[0+302]*10 + 2] = 0;
              ip = 677;
      end

        677 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 303] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 303] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 303]] = 0;
              ip = 678;
      end

        678 :
      begin                                                                     // mov
              heapMem[localMem[0+302]*10 + 4] = localMem[0+303];
              ip = 679;
      end

        679 :
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
              ip = 680;
      end

        680 :
      begin                                                                     // mov
              heapMem[localMem[0+302]*10 + 5] = localMem[0+304];
              ip = 681;
      end

        681 :
      begin                                                                     // mov
              heapMem[localMem[0+302]*10 + 6] = 0;
              ip = 682;
      end

        682 :
      begin                                                                     // mov
              heapMem[localMem[0+302]*10 + 3] = localMem[0+250];
              ip = 683;
      end

        683 :
      begin                                                                     // add
              heapMem[localMem[0+250]*10 + 1] = heapMem[localMem[0+250]*10 + 1] + 1;
              ip = 684;
      end

        684 :
      begin                                                                     // mov
              heapMem[localMem[0+302]*10 + 1] = heapMem[localMem[0+250]*10 + 1];
              ip = 685;
      end

        685 :
      begin                                                                     // not
              localMem[0 + 305] = !heapMem[localMem[0+247]*10 + 6];
              ip = 686;
      end

        686 :
      begin                                                                     // jNe
              ip = localMem[0+305] != 0 ? 738 : 687;
      end

        687 :
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
              ip = 688;
      end

        688 :
      begin                                                                     // mov
              heapMem[localMem[0+299]*10 + 6] = localMem[0+306];
              ip = 689;
      end

        689 :
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
              ip = 690;
      end

        690 :
      begin                                                                     // mov
              heapMem[localMem[0+302]*10 + 6] = localMem[0+307];
              ip = 691;
      end

        691 :
      begin                                                                     // mov
              localMem[0 + 308] = heapMem[localMem[0+247]*10 + 4];
              ip = 692;
      end

        692 :
      begin                                                                     // mov
              localMem[0 + 309] = heapMem[localMem[0+299]*10 + 4];
              ip = 693;
      end

        693 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+309] + 0 + i] = heapMem[NArea * localMem[0+308] + 0 + i];
                end
              end
              ip = 694;
      end

        694 :
      begin                                                                     // mov
              localMem[0 + 310] = heapMem[localMem[0+247]*10 + 5];
              ip = 695;
      end

        695 :
      begin                                                                     // mov
              localMem[0 + 311] = heapMem[localMem[0+299]*10 + 5];
              ip = 696;
      end

        696 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+311] + 0 + i] = heapMem[NArea * localMem[0+310] + 0 + i];
                end
              end
              ip = 697;
      end

        697 :
      begin                                                                     // mov
              localMem[0 + 312] = heapMem[localMem[0+247]*10 + 6];
              ip = 698;
      end

        698 :
      begin                                                                     // mov
              localMem[0 + 313] = heapMem[localMem[0+299]*10 + 6];
              ip = 699;
      end

        699 :
      begin                                                                     // add
              localMem[0 + 314] = 1 + 1;
              ip = 700;
      end

        700 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+314]) begin
                  heapMem[NArea * localMem[0+313] + 0 + i] = heapMem[NArea * localMem[0+312] + 0 + i];
                end
              end
              ip = 701;
      end

        701 :
      begin                                                                     // mov
              localMem[0 + 315] = heapMem[localMem[0+247]*10 + 4];
              ip = 702;
      end

        702 :
      begin                                                                     // mov
              localMem[0 + 316] = heapMem[localMem[0+302]*10 + 4];
              ip = 703;
      end

        703 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+316] + 0 + i] = heapMem[NArea * localMem[0+315] + 2 + i];
                end
              end
              ip = 704;
      end

        704 :
      begin                                                                     // mov
              localMem[0 + 317] = heapMem[localMem[0+247]*10 + 5];
              ip = 705;
      end

        705 :
      begin                                                                     // mov
              localMem[0 + 318] = heapMem[localMem[0+302]*10 + 5];
              ip = 706;
      end

        706 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+318] + 0 + i] = heapMem[NArea * localMem[0+317] + 2 + i];
                end
              end
              ip = 707;
      end

        707 :
      begin                                                                     // mov
              localMem[0 + 319] = heapMem[localMem[0+247]*10 + 6];
              ip = 708;
      end

        708 :
      begin                                                                     // mov
              localMem[0 + 320] = heapMem[localMem[0+302]*10 + 6];
              ip = 709;
      end

        709 :
      begin                                                                     // add
              localMem[0 + 321] = 1 + 1;
              ip = 710;
      end

        710 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+321]) begin
                  heapMem[NArea * localMem[0+320] + 0 + i] = heapMem[NArea * localMem[0+319] + 2 + i];
                end
              end
              ip = 711;
      end

        711 :
      begin                                                                     // mov
              localMem[0 + 322] = heapMem[localMem[0+299]*10 + 0];
              ip = 712;
      end

        712 :
      begin                                                                     // add
              localMem[0 + 323] = localMem[0+322] + 1;
              ip = 713;
      end

        713 :
      begin                                                                     // mov
              localMem[0 + 324] = heapMem[localMem[0+299]*10 + 6];
              ip = 714;
      end

        714 :
      begin                                                                     // label
              ip = 715;
      end

        715 :
      begin                                                                     // mov
              localMem[0 + 325] = 0;
              ip = 716;
      end

        716 :
      begin                                                                     // label
              ip = 717;
      end

        717 :
      begin                                                                     // jGe
              ip = localMem[0+325] >= localMem[0+323] ? 723 : 718;
      end

        718 :
      begin                                                                     // mov
              localMem[0 + 326] = heapMem[localMem[0+324]*10 + localMem[0+325]];
              ip = 719;
      end

        719 :
      begin                                                                     // mov
              heapMem[localMem[0+326]*10 + 2] = localMem[0+299];
              ip = 720;
      end

        720 :
      begin                                                                     // label
              ip = 721;
      end

        721 :
      begin                                                                     // add
              localMem[0 + 325] = localMem[0+325] + 1;
              ip = 722;
      end

        722 :
      begin                                                                     // jmp
              ip = 716;
      end

        723 :
      begin                                                                     // label
              ip = 724;
      end

        724 :
      begin                                                                     // mov
              localMem[0 + 327] = heapMem[localMem[0+302]*10 + 0];
              ip = 725;
      end

        725 :
      begin                                                                     // add
              localMem[0 + 328] = localMem[0+327] + 1;
              ip = 726;
      end

        726 :
      begin                                                                     // mov
              localMem[0 + 329] = heapMem[localMem[0+302]*10 + 6];
              ip = 727;
      end

        727 :
      begin                                                                     // label
              ip = 728;
      end

        728 :
      begin                                                                     // mov
              localMem[0 + 330] = 0;
              ip = 729;
      end

        729 :
      begin                                                                     // label
              ip = 730;
      end

        730 :
      begin                                                                     // jGe
              ip = localMem[0+330] >= localMem[0+328] ? 736 : 731;
      end

        731 :
      begin                                                                     // mov
              localMem[0 + 331] = heapMem[localMem[0+329]*10 + localMem[0+330]];
              ip = 732;
      end

        732 :
      begin                                                                     // mov
              heapMem[localMem[0+331]*10 + 2] = localMem[0+302];
              ip = 733;
      end

        733 :
      begin                                                                     // label
              ip = 734;
      end

        734 :
      begin                                                                     // add
              localMem[0 + 330] = localMem[0+330] + 1;
              ip = 735;
      end

        735 :
      begin                                                                     // jmp
              ip = 729;
      end

        736 :
      begin                                                                     // label
              ip = 737;
      end

        737 :
      begin                                                                     // jmp
              ip = 753;
      end

        738 :
      begin                                                                     // label
              ip = 739;
      end

        739 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 332] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 332] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 332]] = 0;
              ip = 740;
      end

        740 :
      begin                                                                     // mov
              heapMem[localMem[0+247]*10 + 6] = localMem[0+332];
              ip = 741;
      end

        741 :
      begin                                                                     // mov
              localMem[0 + 333] = heapMem[localMem[0+247]*10 + 4];
              ip = 742;
      end

        742 :
      begin                                                                     // mov
              localMem[0 + 334] = heapMem[localMem[0+299]*10 + 4];
              ip = 743;
      end

        743 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+334] + 0 + i] = heapMem[NArea * localMem[0+333] + 0 + i];
                end
              end
              ip = 744;
      end

        744 :
      begin                                                                     // mov
              localMem[0 + 335] = heapMem[localMem[0+247]*10 + 5];
              ip = 745;
      end

        745 :
      begin                                                                     // mov
              localMem[0 + 336] = heapMem[localMem[0+299]*10 + 5];
              ip = 746;
      end

        746 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+336] + 0 + i] = heapMem[NArea * localMem[0+335] + 0 + i];
                end
              end
              ip = 747;
      end

        747 :
      begin                                                                     // mov
              localMem[0 + 337] = heapMem[localMem[0+247]*10 + 4];
              ip = 748;
      end

        748 :
      begin                                                                     // mov
              localMem[0 + 338] = heapMem[localMem[0+302]*10 + 4];
              ip = 749;
      end

        749 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+338] + 0 + i] = heapMem[NArea * localMem[0+337] + 2 + i];
                end
              end
              ip = 750;
      end

        750 :
      begin                                                                     // mov
              localMem[0 + 339] = heapMem[localMem[0+247]*10 + 5];
              ip = 751;
      end

        751 :
      begin                                                                     // mov
              localMem[0 + 340] = heapMem[localMem[0+302]*10 + 5];
              ip = 752;
      end

        752 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+340] + 0 + i] = heapMem[NArea * localMem[0+339] + 2 + i];
                end
              end
              ip = 753;
      end

        753 :
      begin                                                                     // label
              ip = 754;
      end

        754 :
      begin                                                                     // mov
              heapMem[localMem[0+299]*10 + 2] = localMem[0+247];
              ip = 755;
      end

        755 :
      begin                                                                     // mov
              heapMem[localMem[0+302]*10 + 2] = localMem[0+247];
              ip = 756;
      end

        756 :
      begin                                                                     // mov
              localMem[0 + 341] = heapMem[localMem[0+247]*10 + 4];
              ip = 757;
      end

        757 :
      begin                                                                     // mov
              localMem[0 + 342] = heapMem[localMem[0+341]*10 + 1];
              ip = 758;
      end

        758 :
      begin                                                                     // mov
              localMem[0 + 343] = heapMem[localMem[0+247]*10 + 5];
              ip = 759;
      end

        759 :
      begin                                                                     // mov
              localMem[0 + 344] = heapMem[localMem[0+343]*10 + 1];
              ip = 760;
      end

        760 :
      begin                                                                     // mov
              localMem[0 + 345] = heapMem[localMem[0+247]*10 + 4];
              ip = 761;
      end

        761 :
      begin                                                                     // mov
              heapMem[localMem[0+345]*10 + 0] = localMem[0+342];
              ip = 762;
      end

        762 :
      begin                                                                     // mov
              localMem[0 + 346] = heapMem[localMem[0+247]*10 + 5];
              ip = 763;
      end

        763 :
      begin                                                                     // mov
              heapMem[localMem[0+346]*10 + 0] = localMem[0+344];
              ip = 764;
      end

        764 :
      begin                                                                     // mov
              localMem[0 + 347] = heapMem[localMem[0+247]*10 + 6];
              ip = 765;
      end

        765 :
      begin                                                                     // mov
              heapMem[localMem[0+347]*10 + 0] = localMem[0+299];
              ip = 766;
      end

        766 :
      begin                                                                     // mov
              localMem[0 + 348] = heapMem[localMem[0+247]*10 + 6];
              ip = 767;
      end

        767 :
      begin                                                                     // mov
              heapMem[localMem[0+348]*10 + 1] = localMem[0+302];
              ip = 768;
      end

        768 :
      begin                                                                     // mov
              heapMem[localMem[0+247]*10 + 0] = 1;
              ip = 769;
      end

        769 :
      begin                                                                     // mov
              localMem[0 + 349] = heapMem[localMem[0+247]*10 + 4];
              ip = 770;
      end

        770 :
      begin                                                                     // resize
              arraySizes[localMem[0+349]] = 1;
              ip = 771;
      end

        771 :
      begin                                                                     // mov
              localMem[0 + 350] = heapMem[localMem[0+247]*10 + 5];
              ip = 772;
      end

        772 :
      begin                                                                     // resize
              arraySizes[localMem[0+350]] = 1;
              ip = 773;
      end

        773 :
      begin                                                                     // mov
              localMem[0 + 351] = heapMem[localMem[0+247]*10 + 6];
              ip = 774;
      end

        774 :
      begin                                                                     // resize
              arraySizes[localMem[0+351]] = 2;
              ip = 775;
      end

        775 :
      begin                                                                     // jmp
              ip = 777;
      end

        776 :
      begin                                                                     // jmp
              ip = 782;
      end

        777 :
      begin                                                                     // label
              ip = 778;
      end

        778 :
      begin                                                                     // mov
              localMem[0 + 248] = 1;
              ip = 779;
      end

        779 :
      begin                                                                     // jmp
              ip = 782;
      end

        780 :
      begin                                                                     // label
              ip = 781;
      end

        781 :
      begin                                                                     // mov
              localMem[0 + 248] = 0;
              ip = 782;
      end

        782 :
      begin                                                                     // label
              ip = 783;
      end

        783 :
      begin                                                                     // jNe
              ip = localMem[0+248] != 0 ? 785 : 784;
      end

        784 :
      begin                                                                     // mov
              localMem[0 + 25] = localMem[0+247];
              ip = 785;
      end

        785 :
      begin                                                                     // label
              ip = 786;
      end

        786 :
      begin                                                                     // label
              ip = 787;
      end

        787 :
      begin                                                                     // add
              localMem[0 + 130] = localMem[0+130] + 1;
              ip = 788;
      end

        788 :
      begin                                                                     // jmp
              ip = 298;
      end

        789 :
      begin                                                                     // label
              ip = 790;
      end

        790 :
      begin                                                                     // assert
            ip = 791;
      end

        791 :
      begin                                                                     // label
              ip = 792;
      end

        792 :
      begin                                                                     // label
              ip = 793;
      end

        793 :
      begin                                                                     // label
              ip = 794;
      end

        794 :
      begin                                                                     // mov
              localMem[0 + 352] = heapMem[localMem[0+1]*10 + 0];
              ip = 795;
      end

        795 :
      begin                                                                     // mov
              localMem[0 + 353] = heapMem[localMem[0+1]*10 + 1];
              ip = 796;
      end

        796 :
      begin                                                                     // mov
              localMem[0 + 354] = heapMem[localMem[0+1]*10 + 2];
              ip = 797;
      end

        797 :
      begin                                                                     // jNe
              ip = localMem[0+353] != 1 ? 801 : 798;
      end

        798 :
      begin                                                                     // mov
              localMem[0 + 355] = heapMem[localMem[0+352]*10 + 5];
              ip = 799;
      end

        799 :
      begin                                                                     // mov
              heapMem[localMem[0+355]*10 + localMem[0+354]] = localMem[0+5];
              ip = 800;
      end

        800 :
      begin                                                                     // jmp
              ip = 1043;
      end

        801 :
      begin                                                                     // label
              ip = 802;
      end

        802 :
      begin                                                                     // jNe
              ip = localMem[0+353] != 2 ? 810 : 803;
      end

        803 :
      begin                                                                     // add
              localMem[0 + 356] = localMem[0+354] + 1;
              ip = 804;
      end

        804 :
      begin                                                                     // mov
              localMem[0 + 357] = heapMem[localMem[0+352]*10 + 4];
              ip = 805;
      end

        805 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+357] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[356]) begin
                  heapMem[NArea * localMem[0+357] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+357] + localMem[356]] = localMem[0+3];                                    // Insert new value
              arraySizes[localMem[0+357]] = arraySizes[localMem[0+357]] + 1;                              // Increase array size
              ip = 806;
      end

        806 :
      begin                                                                     // mov
              localMem[0 + 358] = heapMem[localMem[0+352]*10 + 5];
              ip = 807;
      end

        807 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+358] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[356]) begin
                  heapMem[NArea * localMem[0+358] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+358] + localMem[356]] = localMem[0+5];                                    // Insert new value
              arraySizes[localMem[0+358]] = arraySizes[localMem[0+358]] + 1;                              // Increase array size
              ip = 808;
      end

        808 :
      begin                                                                     // add
              heapMem[localMem[0+352]*10 + 0] = heapMem[localMem[0+352]*10 + 0] + 1;
              ip = 809;
      end

        809 :
      begin                                                                     // jmp
              ip = 816;
      end

        810 :
      begin                                                                     // label
              ip = 811;
      end

        811 :
      begin                                                                     // mov
              localMem[0 + 359] = heapMem[localMem[0+352]*10 + 4];
              ip = 812;
      end

        812 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+359] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[354]) begin
                  heapMem[NArea * localMem[0+359] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+359] + localMem[354]] = localMem[0+3];                                    // Insert new value
              arraySizes[localMem[0+359]] = arraySizes[localMem[0+359]] + 1;                              // Increase array size
              ip = 813;
      end

        813 :
      begin                                                                     // mov
              localMem[0 + 360] = heapMem[localMem[0+352]*10 + 5];
              ip = 814;
      end

        814 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+360] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[354]) begin
                  heapMem[NArea * localMem[0+360] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+360] + localMem[354]] = localMem[0+5];                                    // Insert new value
              arraySizes[localMem[0+360]] = arraySizes[localMem[0+360]] + 1;                              // Increase array size
              ip = 815;
      end

        815 :
      begin                                                                     // add
              heapMem[localMem[0+352]*10 + 0] = heapMem[localMem[0+352]*10 + 0] + 1;
              ip = 816;
      end

        816 :
      begin                                                                     // label
              ip = 817;
      end

        817 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 0] = heapMem[localMem[0+0]*10 + 0] + 1;
              ip = 818;
      end

        818 :
      begin                                                                     // label
              ip = 819;
      end

        819 :
      begin                                                                     // mov
              localMem[0 + 362] = heapMem[localMem[0+352]*10 + 0];
              ip = 820;
      end

        820 :
      begin                                                                     // jLt
              ip = localMem[0+362] <  3 ? 1038 : 821;
      end

        821 :
      begin                                                                     // mov
              localMem[0 + 363] = heapMem[localMem[0+352]*10 + 3];
              ip = 822;
      end

        822 :
      begin                                                                     // mov
              localMem[0 + 364] = heapMem[localMem[0+352]*10 + 2];
              ip = 823;
      end

        823 :
      begin                                                                     // jEq
              ip = localMem[0+364] == 0 ? 920 : 824;
      end

        824 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 365] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 365] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 365]] = 0;
              ip = 825;
      end

        825 :
      begin                                                                     // mov
              heapMem[localMem[0+365]*10 + 0] = 1;
              ip = 826;
      end

        826 :
      begin                                                                     // mov
              heapMem[localMem[0+365]*10 + 2] = 0;
              ip = 827;
      end

        827 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 366] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 366] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 366]] = 0;
              ip = 828;
      end

        828 :
      begin                                                                     // mov
              heapMem[localMem[0+365]*10 + 4] = localMem[0+366];
              ip = 829;
      end

        829 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 367] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 367] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 367]] = 0;
              ip = 830;
      end

        830 :
      begin                                                                     // mov
              heapMem[localMem[0+365]*10 + 5] = localMem[0+367];
              ip = 831;
      end

        831 :
      begin                                                                     // mov
              heapMem[localMem[0+365]*10 + 6] = 0;
              ip = 832;
      end

        832 :
      begin                                                                     // mov
              heapMem[localMem[0+365]*10 + 3] = localMem[0+363];
              ip = 833;
      end

        833 :
      begin                                                                     // add
              heapMem[localMem[0+363]*10 + 1] = heapMem[localMem[0+363]*10 + 1] + 1;
              ip = 834;
      end

        834 :
      begin                                                                     // mov
              heapMem[localMem[0+365]*10 + 1] = heapMem[localMem[0+363]*10 + 1];
              ip = 835;
      end

        835 :
      begin                                                                     // not
              localMem[0 + 368] = !heapMem[localMem[0+352]*10 + 6];
              ip = 836;
      end

        836 :
      begin                                                                     // jNe
              ip = localMem[0+368] != 0 ? 865 : 837;
      end

        837 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 369] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 369] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 369]] = 0;
              ip = 838;
      end

        838 :
      begin                                                                     // mov
              heapMem[localMem[0+365]*10 + 6] = localMem[0+369];
              ip = 839;
      end

        839 :
      begin                                                                     // mov
              localMem[0 + 370] = heapMem[localMem[0+352]*10 + 4];
              ip = 840;
      end

        840 :
      begin                                                                     // mov
              localMem[0 + 371] = heapMem[localMem[0+365]*10 + 4];
              ip = 841;
      end

        841 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+371] + 0 + i] = heapMem[NArea * localMem[0+370] + 2 + i];
                end
              end
              ip = 842;
      end

        842 :
      begin                                                                     // mov
              localMem[0 + 372] = heapMem[localMem[0+352]*10 + 5];
              ip = 843;
      end

        843 :
      begin                                                                     // mov
              localMem[0 + 373] = heapMem[localMem[0+365]*10 + 5];
              ip = 844;
      end

        844 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+373] + 0 + i] = heapMem[NArea * localMem[0+372] + 2 + i];
                end
              end
              ip = 845;
      end

        845 :
      begin                                                                     // mov
              localMem[0 + 374] = heapMem[localMem[0+352]*10 + 6];
              ip = 846;
      end

        846 :
      begin                                                                     // mov
              localMem[0 + 375] = heapMem[localMem[0+365]*10 + 6];
              ip = 847;
      end

        847 :
      begin                                                                     // add
              localMem[0 + 376] = 1 + 1;
              ip = 848;
      end

        848 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+376]) begin
                  heapMem[NArea * localMem[0+375] + 0 + i] = heapMem[NArea * localMem[0+374] + 2 + i];
                end
              end
              ip = 849;
      end

        849 :
      begin                                                                     // mov
              localMem[0 + 377] = heapMem[localMem[0+365]*10 + 0];
              ip = 850;
      end

        850 :
      begin                                                                     // add
              localMem[0 + 378] = localMem[0+377] + 1;
              ip = 851;
      end

        851 :
      begin                                                                     // mov
              localMem[0 + 379] = heapMem[localMem[0+365]*10 + 6];
              ip = 852;
      end

        852 :
      begin                                                                     // label
              ip = 853;
      end

        853 :
      begin                                                                     // mov
              localMem[0 + 380] = 0;
              ip = 854;
      end

        854 :
      begin                                                                     // label
              ip = 855;
      end

        855 :
      begin                                                                     // jGe
              ip = localMem[0+380] >= localMem[0+378] ? 861 : 856;
      end

        856 :
      begin                                                                     // mov
              localMem[0 + 381] = heapMem[localMem[0+379]*10 + localMem[0+380]];
              ip = 857;
      end

        857 :
      begin                                                                     // mov
              heapMem[localMem[0+381]*10 + 2] = localMem[0+365];
              ip = 858;
      end

        858 :
      begin                                                                     // label
              ip = 859;
      end

        859 :
      begin                                                                     // add
              localMem[0 + 380] = localMem[0+380] + 1;
              ip = 860;
      end

        860 :
      begin                                                                     // jmp
              ip = 854;
      end

        861 :
      begin                                                                     // label
              ip = 862;
      end

        862 :
      begin                                                                     // mov
              localMem[0 + 382] = heapMem[localMem[0+352]*10 + 6];
              ip = 863;
      end

        863 :
      begin                                                                     // resize
              arraySizes[localMem[0+382]] = 2;
              ip = 864;
      end

        864 :
      begin                                                                     // jmp
              ip = 872;
      end

        865 :
      begin                                                                     // label
              ip = 866;
      end

        866 :
      begin                                                                     // mov
              localMem[0 + 383] = heapMem[localMem[0+352]*10 + 4];
              ip = 867;
      end

        867 :
      begin                                                                     // mov
              localMem[0 + 384] = heapMem[localMem[0+365]*10 + 4];
              ip = 868;
      end

        868 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+384] + 0 + i] = heapMem[NArea * localMem[0+383] + 2 + i];
                end
              end
              ip = 869;
      end

        869 :
      begin                                                                     // mov
              localMem[0 + 385] = heapMem[localMem[0+352]*10 + 5];
              ip = 870;
      end

        870 :
      begin                                                                     // mov
              localMem[0 + 386] = heapMem[localMem[0+365]*10 + 5];
              ip = 871;
      end

        871 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+386] + 0 + i] = heapMem[NArea * localMem[0+385] + 2 + i];
                end
              end
              ip = 872;
      end

        872 :
      begin                                                                     // label
              ip = 873;
      end

        873 :
      begin                                                                     // mov
              heapMem[localMem[0+352]*10 + 0] = 1;
              ip = 874;
      end

        874 :
      begin                                                                     // mov
              heapMem[localMem[0+365]*10 + 2] = localMem[0+364];
              ip = 875;
      end

        875 :
      begin                                                                     // mov
              localMem[0 + 387] = heapMem[localMem[0+364]*10 + 0];
              ip = 876;
      end

        876 :
      begin                                                                     // mov
              localMem[0 + 388] = heapMem[localMem[0+364]*10 + 6];
              ip = 877;
      end

        877 :
      begin                                                                     // mov
              localMem[0 + 389] = heapMem[localMem[0+388]*10 + localMem[0+387]];
              ip = 878;
      end

        878 :
      begin                                                                     // jNe
              ip = localMem[0+389] != localMem[0+352] ? 897 : 879;
      end

        879 :
      begin                                                                     // mov
              localMem[0 + 390] = heapMem[localMem[0+352]*10 + 4];
              ip = 880;
      end

        880 :
      begin                                                                     // mov
              localMem[0 + 391] = heapMem[localMem[0+390]*10 + 1];
              ip = 881;
      end

        881 :
      begin                                                                     // mov
              localMem[0 + 392] = heapMem[localMem[0+364]*10 + 4];
              ip = 882;
      end

        882 :
      begin                                                                     // mov
              heapMem[localMem[0+392]*10 + localMem[0+387]] = localMem[0+391];
              ip = 883;
      end

        883 :
      begin                                                                     // mov
              localMem[0 + 393] = heapMem[localMem[0+352]*10 + 5];
              ip = 884;
      end

        884 :
      begin                                                                     // mov
              localMem[0 + 394] = heapMem[localMem[0+393]*10 + 1];
              ip = 885;
      end

        885 :
      begin                                                                     // mov
              localMem[0 + 395] = heapMem[localMem[0+364]*10 + 5];
              ip = 886;
      end

        886 :
      begin                                                                     // mov
              heapMem[localMem[0+395]*10 + localMem[0+387]] = localMem[0+394];
              ip = 887;
      end

        887 :
      begin                                                                     // mov
              localMem[0 + 396] = heapMem[localMem[0+352]*10 + 4];
              ip = 888;
      end

        888 :
      begin                                                                     // resize
              arraySizes[localMem[0+396]] = 1;
              ip = 889;
      end

        889 :
      begin                                                                     // mov
              localMem[0 + 397] = heapMem[localMem[0+352]*10 + 5];
              ip = 890;
      end

        890 :
      begin                                                                     // resize
              arraySizes[localMem[0+397]] = 1;
              ip = 891;
      end

        891 :
      begin                                                                     // add
              localMem[0 + 398] = localMem[0+387] + 1;
              ip = 892;
      end

        892 :
      begin                                                                     // mov
              heapMem[localMem[0+364]*10 + 0] = localMem[0+398];
              ip = 893;
      end

        893 :
      begin                                                                     // mov
              localMem[0 + 399] = heapMem[localMem[0+364]*10 + 6];
              ip = 894;
      end

        894 :
      begin                                                                     // mov
              heapMem[localMem[0+399]*10 + localMem[0+398]] = localMem[0+365];
              ip = 895;
      end

        895 :
      begin                                                                     // jmp
              ip = 1035;
      end

        896 :
      begin                                                                     // jmp
              ip = 919;
      end

        897 :
      begin                                                                     // label
              ip = 898;
      end

        898 :
      begin                                                                     // assertNe
            ip = 899;
      end

        899 :
      begin                                                                     // mov
              localMem[0 + 400] = heapMem[localMem[0+364]*10 + 6];
              ip = 900;
      end

        900 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+400] * NArea + i] == localMem[0+352]) localMem[0 + 401] = i + 1;
              end
              ip = 901;
      end

        901 :
      begin                                                                     // subtract
              localMem[0 + 401] = localMem[0+401] - 1;
              ip = 902;
      end

        902 :
      begin                                                                     // mov
              localMem[0 + 402] = heapMem[localMem[0+352]*10 + 4];
              ip = 903;
      end

        903 :
      begin                                                                     // mov
              localMem[0 + 403] = heapMem[localMem[0+402]*10 + 1];
              ip = 904;
      end

        904 :
      begin                                                                     // mov
              localMem[0 + 404] = heapMem[localMem[0+352]*10 + 5];
              ip = 905;
      end

        905 :
      begin                                                                     // mov
              localMem[0 + 405] = heapMem[localMem[0+404]*10 + 1];
              ip = 906;
      end

        906 :
      begin                                                                     // mov
              localMem[0 + 406] = heapMem[localMem[0+352]*10 + 4];
              ip = 907;
      end

        907 :
      begin                                                                     // resize
              arraySizes[localMem[0+406]] = 1;
              ip = 908;
      end

        908 :
      begin                                                                     // mov
              localMem[0 + 407] = heapMem[localMem[0+352]*10 + 5];
              ip = 909;
      end

        909 :
      begin                                                                     // resize
              arraySizes[localMem[0+407]] = 1;
              ip = 910;
      end

        910 :
      begin                                                                     // mov
              localMem[0 + 408] = heapMem[localMem[0+364]*10 + 4];
              ip = 911;
      end

        911 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+408] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[401]) begin
                  heapMem[NArea * localMem[0+408] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+408] + localMem[401]] = localMem[0+403];                                    // Insert new value
              arraySizes[localMem[0+408]] = arraySizes[localMem[0+408]] + 1;                              // Increase array size
              ip = 912;
      end

        912 :
      begin                                                                     // mov
              localMem[0 + 409] = heapMem[localMem[0+364]*10 + 5];
              ip = 913;
      end

        913 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+409] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[401]) begin
                  heapMem[NArea * localMem[0+409] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+409] + localMem[401]] = localMem[0+405];                                    // Insert new value
              arraySizes[localMem[0+409]] = arraySizes[localMem[0+409]] + 1;                              // Increase array size
              ip = 914;
      end

        914 :
      begin                                                                     // mov
              localMem[0 + 410] = heapMem[localMem[0+364]*10 + 6];
              ip = 915;
      end

        915 :
      begin                                                                     // add
              localMem[0 + 411] = localMem[0+401] + 1;
              ip = 916;
      end

        916 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+410] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[411]) begin
                  heapMem[NArea * localMem[0+410] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+410] + localMem[411]] = localMem[0+365];                                    // Insert new value
              arraySizes[localMem[0+410]] = arraySizes[localMem[0+410]] + 1;                              // Increase array size
              ip = 917;
      end

        917 :
      begin                                                                     // add
              heapMem[localMem[0+364]*10 + 0] = heapMem[localMem[0+364]*10 + 0] + 1;
              ip = 918;
      end

        918 :
      begin                                                                     // jmp
              ip = 1035;
      end

        919 :
      begin                                                                     // label
              ip = 920;
      end

        920 :
      begin                                                                     // label
              ip = 921;
      end

        921 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 412] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 412] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 412]] = 0;
              ip = 922;
      end

        922 :
      begin                                                                     // mov
              heapMem[localMem[0+412]*10 + 0] = 1;
              ip = 923;
      end

        923 :
      begin                                                                     // mov
              heapMem[localMem[0+412]*10 + 2] = 0;
              ip = 924;
      end

        924 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 413] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 413] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 413]] = 0;
              ip = 925;
      end

        925 :
      begin                                                                     // mov
              heapMem[localMem[0+412]*10 + 4] = localMem[0+413];
              ip = 926;
      end

        926 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 414] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 414] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 414]] = 0;
              ip = 927;
      end

        927 :
      begin                                                                     // mov
              heapMem[localMem[0+412]*10 + 5] = localMem[0+414];
              ip = 928;
      end

        928 :
      begin                                                                     // mov
              heapMem[localMem[0+412]*10 + 6] = 0;
              ip = 929;
      end

        929 :
      begin                                                                     // mov
              heapMem[localMem[0+412]*10 + 3] = localMem[0+363];
              ip = 930;
      end

        930 :
      begin                                                                     // add
              heapMem[localMem[0+363]*10 + 1] = heapMem[localMem[0+363]*10 + 1] + 1;
              ip = 931;
      end

        931 :
      begin                                                                     // mov
              heapMem[localMem[0+412]*10 + 1] = heapMem[localMem[0+363]*10 + 1];
              ip = 932;
      end

        932 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 415] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 415] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 415]] = 0;
              ip = 933;
      end

        933 :
      begin                                                                     // mov
              heapMem[localMem[0+415]*10 + 0] = 1;
              ip = 934;
      end

        934 :
      begin                                                                     // mov
              heapMem[localMem[0+415]*10 + 2] = 0;
              ip = 935;
      end

        935 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 416] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 416] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 416]] = 0;
              ip = 936;
      end

        936 :
      begin                                                                     // mov
              heapMem[localMem[0+415]*10 + 4] = localMem[0+416];
              ip = 937;
      end

        937 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 417] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 417] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 417]] = 0;
              ip = 938;
      end

        938 :
      begin                                                                     // mov
              heapMem[localMem[0+415]*10 + 5] = localMem[0+417];
              ip = 939;
      end

        939 :
      begin                                                                     // mov
              heapMem[localMem[0+415]*10 + 6] = 0;
              ip = 940;
      end

        940 :
      begin                                                                     // mov
              heapMem[localMem[0+415]*10 + 3] = localMem[0+363];
              ip = 941;
      end

        941 :
      begin                                                                     // add
              heapMem[localMem[0+363]*10 + 1] = heapMem[localMem[0+363]*10 + 1] + 1;
              ip = 942;
      end

        942 :
      begin                                                                     // mov
              heapMem[localMem[0+415]*10 + 1] = heapMem[localMem[0+363]*10 + 1];
              ip = 943;
      end

        943 :
      begin                                                                     // not
              localMem[0 + 418] = !heapMem[localMem[0+352]*10 + 6];
              ip = 944;
      end

        944 :
      begin                                                                     // jNe
              ip = localMem[0+418] != 0 ? 996 : 945;
      end

        945 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 419] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 419] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 419]] = 0;
              ip = 946;
      end

        946 :
      begin                                                                     // mov
              heapMem[localMem[0+412]*10 + 6] = localMem[0+419];
              ip = 947;
      end

        947 :
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
              ip = 948;
      end

        948 :
      begin                                                                     // mov
              heapMem[localMem[0+415]*10 + 6] = localMem[0+420];
              ip = 949;
      end

        949 :
      begin                                                                     // mov
              localMem[0 + 421] = heapMem[localMem[0+352]*10 + 4];
              ip = 950;
      end

        950 :
      begin                                                                     // mov
              localMem[0 + 422] = heapMem[localMem[0+412]*10 + 4];
              ip = 951;
      end

        951 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+422] + 0 + i] = heapMem[NArea * localMem[0+421] + 0 + i];
                end
              end
              ip = 952;
      end

        952 :
      begin                                                                     // mov
              localMem[0 + 423] = heapMem[localMem[0+352]*10 + 5];
              ip = 953;
      end

        953 :
      begin                                                                     // mov
              localMem[0 + 424] = heapMem[localMem[0+412]*10 + 5];
              ip = 954;
      end

        954 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+424] + 0 + i] = heapMem[NArea * localMem[0+423] + 0 + i];
                end
              end
              ip = 955;
      end

        955 :
      begin                                                                     // mov
              localMem[0 + 425] = heapMem[localMem[0+352]*10 + 6];
              ip = 956;
      end

        956 :
      begin                                                                     // mov
              localMem[0 + 426] = heapMem[localMem[0+412]*10 + 6];
              ip = 957;
      end

        957 :
      begin                                                                     // add
              localMem[0 + 427] = 1 + 1;
              ip = 958;
      end

        958 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+427]) begin
                  heapMem[NArea * localMem[0+426] + 0 + i] = heapMem[NArea * localMem[0+425] + 0 + i];
                end
              end
              ip = 959;
      end

        959 :
      begin                                                                     // mov
              localMem[0 + 428] = heapMem[localMem[0+352]*10 + 4];
              ip = 960;
      end

        960 :
      begin                                                                     // mov
              localMem[0 + 429] = heapMem[localMem[0+415]*10 + 4];
              ip = 961;
      end

        961 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+429] + 0 + i] = heapMem[NArea * localMem[0+428] + 2 + i];
                end
              end
              ip = 962;
      end

        962 :
      begin                                                                     // mov
              localMem[0 + 430] = heapMem[localMem[0+352]*10 + 5];
              ip = 963;
      end

        963 :
      begin                                                                     // mov
              localMem[0 + 431] = heapMem[localMem[0+415]*10 + 5];
              ip = 964;
      end

        964 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+431] + 0 + i] = heapMem[NArea * localMem[0+430] + 2 + i];
                end
              end
              ip = 965;
      end

        965 :
      begin                                                                     // mov
              localMem[0 + 432] = heapMem[localMem[0+352]*10 + 6];
              ip = 966;
      end

        966 :
      begin                                                                     // mov
              localMem[0 + 433] = heapMem[localMem[0+415]*10 + 6];
              ip = 967;
      end

        967 :
      begin                                                                     // add
              localMem[0 + 434] = 1 + 1;
              ip = 968;
      end

        968 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+434]) begin
                  heapMem[NArea * localMem[0+433] + 0 + i] = heapMem[NArea * localMem[0+432] + 2 + i];
                end
              end
              ip = 969;
      end

        969 :
      begin                                                                     // mov
              localMem[0 + 435] = heapMem[localMem[0+412]*10 + 0];
              ip = 970;
      end

        970 :
      begin                                                                     // add
              localMem[0 + 436] = localMem[0+435] + 1;
              ip = 971;
      end

        971 :
      begin                                                                     // mov
              localMem[0 + 437] = heapMem[localMem[0+412]*10 + 6];
              ip = 972;
      end

        972 :
      begin                                                                     // label
              ip = 973;
      end

        973 :
      begin                                                                     // mov
              localMem[0 + 438] = 0;
              ip = 974;
      end

        974 :
      begin                                                                     // label
              ip = 975;
      end

        975 :
      begin                                                                     // jGe
              ip = localMem[0+438] >= localMem[0+436] ? 981 : 976;
      end

        976 :
      begin                                                                     // mov
              localMem[0 + 439] = heapMem[localMem[0+437]*10 + localMem[0+438]];
              ip = 977;
      end

        977 :
      begin                                                                     // mov
              heapMem[localMem[0+439]*10 + 2] = localMem[0+412];
              ip = 978;
      end

        978 :
      begin                                                                     // label
              ip = 979;
      end

        979 :
      begin                                                                     // add
              localMem[0 + 438] = localMem[0+438] + 1;
              ip = 980;
      end

        980 :
      begin                                                                     // jmp
              ip = 974;
      end

        981 :
      begin                                                                     // label
              ip = 982;
      end

        982 :
      begin                                                                     // mov
              localMem[0 + 440] = heapMem[localMem[0+415]*10 + 0];
              ip = 983;
      end

        983 :
      begin                                                                     // add
              localMem[0 + 441] = localMem[0+440] + 1;
              ip = 984;
      end

        984 :
      begin                                                                     // mov
              localMem[0 + 442] = heapMem[localMem[0+415]*10 + 6];
              ip = 985;
      end

        985 :
      begin                                                                     // label
              ip = 986;
      end

        986 :
      begin                                                                     // mov
              localMem[0 + 443] = 0;
              ip = 987;
      end

        987 :
      begin                                                                     // label
              ip = 988;
      end

        988 :
      begin                                                                     // jGe
              ip = localMem[0+443] >= localMem[0+441] ? 994 : 989;
      end

        989 :
      begin                                                                     // mov
              localMem[0 + 444] = heapMem[localMem[0+442]*10 + localMem[0+443]];
              ip = 990;
      end

        990 :
      begin                                                                     // mov
              heapMem[localMem[0+444]*10 + 2] = localMem[0+415];
              ip = 991;
      end

        991 :
      begin                                                                     // label
              ip = 992;
      end

        992 :
      begin                                                                     // add
              localMem[0 + 443] = localMem[0+443] + 1;
              ip = 993;
      end

        993 :
      begin                                                                     // jmp
              ip = 987;
      end

        994 :
      begin                                                                     // label
              ip = 995;
      end

        995 :
      begin                                                                     // jmp
              ip = 1011;
      end

        996 :
      begin                                                                     // label
              ip = 997;
      end

        997 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 445] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 445] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 445]] = 0;
              ip = 998;
      end

        998 :
      begin                                                                     // mov
              heapMem[localMem[0+352]*10 + 6] = localMem[0+445];
              ip = 999;
      end

        999 :
      begin                                                                     // mov
              localMem[0 + 446] = heapMem[localMem[0+352]*10 + 4];
              ip = 1000;
      end

       1000 :
      begin                                                                     // mov
              localMem[0 + 447] = heapMem[localMem[0+412]*10 + 4];
              ip = 1001;
      end

       1001 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+447] + 0 + i] = heapMem[NArea * localMem[0+446] + 0 + i];
                end
              end
              ip = 1002;
      end

       1002 :
      begin                                                                     // mov
              localMem[0 + 448] = heapMem[localMem[0+352]*10 + 5];
              ip = 1003;
      end

       1003 :
      begin                                                                     // mov
              localMem[0 + 449] = heapMem[localMem[0+412]*10 + 5];
              ip = 1004;
      end

       1004 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+449] + 0 + i] = heapMem[NArea * localMem[0+448] + 0 + i];
                end
              end
              ip = 1005;
      end

       1005 :
      begin                                                                     // mov
              localMem[0 + 450] = heapMem[localMem[0+352]*10 + 4];
              ip = 1006;
      end

       1006 :
      begin                                                                     // mov
              localMem[0 + 451] = heapMem[localMem[0+415]*10 + 4];
              ip = 1007;
      end

       1007 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+451] + 0 + i] = heapMem[NArea * localMem[0+450] + 2 + i];
                end
              end
              ip = 1008;
      end

       1008 :
      begin                                                                     // mov
              localMem[0 + 452] = heapMem[localMem[0+352]*10 + 5];
              ip = 1009;
      end

       1009 :
      begin                                                                     // mov
              localMem[0 + 453] = heapMem[localMem[0+415]*10 + 5];
              ip = 1010;
      end

       1010 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[0+453] + 0 + i] = heapMem[NArea * localMem[0+452] + 2 + i];
                end
              end
              ip = 1011;
      end

       1011 :
      begin                                                                     // label
              ip = 1012;
      end

       1012 :
      begin                                                                     // mov
              heapMem[localMem[0+412]*10 + 2] = localMem[0+352];
              ip = 1013;
      end

       1013 :
      begin                                                                     // mov
              heapMem[localMem[0+415]*10 + 2] = localMem[0+352];
              ip = 1014;
      end

       1014 :
      begin                                                                     // mov
              localMem[0 + 454] = heapMem[localMem[0+352]*10 + 4];
              ip = 1015;
      end

       1015 :
      begin                                                                     // mov
              localMem[0 + 455] = heapMem[localMem[0+454]*10 + 1];
              ip = 1016;
      end

       1016 :
      begin                                                                     // mov
              localMem[0 + 456] = heapMem[localMem[0+352]*10 + 5];
              ip = 1017;
      end

       1017 :
      begin                                                                     // mov
              localMem[0 + 457] = heapMem[localMem[0+456]*10 + 1];
              ip = 1018;
      end

       1018 :
      begin                                                                     // mov
              localMem[0 + 458] = heapMem[localMem[0+352]*10 + 4];
              ip = 1019;
      end

       1019 :
      begin                                                                     // mov
              heapMem[localMem[0+458]*10 + 0] = localMem[0+455];
              ip = 1020;
      end

       1020 :
      begin                                                                     // mov
              localMem[0 + 459] = heapMem[localMem[0+352]*10 + 5];
              ip = 1021;
      end

       1021 :
      begin                                                                     // mov
              heapMem[localMem[0+459]*10 + 0] = localMem[0+457];
              ip = 1022;
      end

       1022 :
      begin                                                                     // mov
              localMem[0 + 460] = heapMem[localMem[0+352]*10 + 6];
              ip = 1023;
      end

       1023 :
      begin                                                                     // mov
              heapMem[localMem[0+460]*10 + 0] = localMem[0+412];
              ip = 1024;
      end

       1024 :
      begin                                                                     // mov
              localMem[0 + 461] = heapMem[localMem[0+352]*10 + 6];
              ip = 1025;
      end

       1025 :
      begin                                                                     // mov
              heapMem[localMem[0+461]*10 + 1] = localMem[0+415];
              ip = 1026;
      end

       1026 :
      begin                                                                     // mov
              heapMem[localMem[0+352]*10 + 0] = 1;
              ip = 1027;
      end

       1027 :
      begin                                                                     // mov
              localMem[0 + 462] = heapMem[localMem[0+352]*10 + 4];
              ip = 1028;
      end

       1028 :
      begin                                                                     // resize
              arraySizes[localMem[0+462]] = 1;
              ip = 1029;
      end

       1029 :
      begin                                                                     // mov
              localMem[0 + 463] = heapMem[localMem[0+352]*10 + 5];
              ip = 1030;
      end

       1030 :
      begin                                                                     // resize
              arraySizes[localMem[0+463]] = 1;
              ip = 1031;
      end

       1031 :
      begin                                                                     // mov
              localMem[0 + 464] = heapMem[localMem[0+352]*10 + 6];
              ip = 1032;
      end

       1032 :
      begin                                                                     // resize
              arraySizes[localMem[0+464]] = 2;
              ip = 1033;
      end

       1033 :
      begin                                                                     // jmp
              ip = 1035;
      end

       1034 :
      begin                                                                     // jmp
              ip = 1040;
      end

       1035 :
      begin                                                                     // label
              ip = 1036;
      end

       1036 :
      begin                                                                     // mov
              localMem[0 + 361] = 1;
              ip = 1037;
      end

       1037 :
      begin                                                                     // jmp
              ip = 1040;
      end

       1038 :
      begin                                                                     // label
              ip = 1039;
      end

       1039 :
      begin                                                                     // mov
              localMem[0 + 361] = 0;
              ip = 1040;
      end

       1040 :
      begin                                                                     // label
              ip = 1041;
      end

       1041 :
      begin                                                                     // label
              ip = 1042;
      end

       1042 :
      begin                                                                     // label
              ip = 1043;
      end

       1043 :
      begin                                                                     // label
              ip = 1044;
      end

       1044 :
      begin                                                                     // tally
            ip = 1045;
      end

       1045 :
      begin                                                                     // label
              ip = 1046;
      end

       1046 :
      begin                                                                     // jmp
              ip = 6;
      end

       1047 :
      begin                                                                     // label
              ip = 1048;
      end

       1048 :
      begin                                                                     // mov
              localMem[0 + 465] = 1;
              ip = 1049;
      end

       1049 :
      begin                                                                     // shiftLeft
              localMem[0 + 465] = localMem[0+465] << 31;
              ip = 1050;
      end

       1050 :
      begin                                                                     // mov
              localMem[0 + 466] = heapMem[localMem[0+0]*10 + 3];
              ip = 1051;
      end

       1051 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 467] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 467] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 467]] = 0;
              ip = 1052;
      end

       1052 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 468] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 468] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 468]] = 0;
              ip = 1053;
      end

       1053 :
      begin                                                                     // jNe
              ip = localMem[0+466] != 0 ? 1058 : 1054;
      end

       1054 :
      begin                                                                     // mov
              heapMem[localMem[0+467]*10 + 0] = localMem[0+466];
              ip = 1055;
      end

       1055 :
      begin                                                                     // mov
              heapMem[localMem[0+467]*10 + 1] = 3;
              ip = 1056;
      end

       1056 :
      begin                                                                     // mov
              heapMem[localMem[0+467]*10 + 2] = 0;
              ip = 1057;
      end

       1057 :
      begin                                                                     // jmp
              ip = 1075;
      end

       1058 :
      begin                                                                     // label
              ip = 1059;
      end

       1059 :
      begin                                                                     // label
              ip = 1060;
      end

       1060 :
      begin                                                                     // mov
              localMem[0 + 469] = 0;
              ip = 1061;
      end

       1061 :
      begin                                                                     // label
              ip = 1062;
      end

       1062 :
      begin                                                                     // jGe
              ip = localMem[0+469] >= 99 ? 1071 : 1063;
      end

       1063 :
      begin                                                                     // not
              localMem[0 + 470] = !heapMem[localMem[0+466]*10 + 6];
              ip = 1064;
      end

       1064 :
      begin                                                                     // jTrue
              ip = localMem[0+470] != 0 ? 1071 : 1065;
      end

       1065 :
      begin                                                                     // mov
              localMem[0 + 471] = heapMem[localMem[0+466]*10 + 6];
              ip = 1066;
      end

       1066 :
      begin                                                                     // mov
              localMem[0 + 472] = heapMem[localMem[0+471]*10 + 0];
              ip = 1067;
      end

       1067 :
      begin                                                                     // mov
              localMem[0 + 466] = localMem[0+472];
              ip = 1068;
      end

       1068 :
      begin                                                                     // label
              ip = 1069;
      end

       1069 :
      begin                                                                     // add
              localMem[0 + 469] = localMem[0+469] + 1;
              ip = 1070;
      end

       1070 :
      begin                                                                     // jmp
              ip = 1061;
      end

       1071 :
      begin                                                                     // label
              ip = 1072;
      end

       1072 :
      begin                                                                     // mov
              heapMem[localMem[0+467]*10 + 0] = localMem[0+466];
              ip = 1073;
      end

       1073 :
      begin                                                                     // mov
              heapMem[localMem[0+467]*10 + 1] = 1;
              ip = 1074;
      end

       1074 :
      begin                                                                     // mov
              heapMem[localMem[0+467]*10 + 2] = 0;
              ip = 1075;
      end

       1075 :
      begin                                                                     // label
              ip = 1076;
      end

       1076 :
      begin                                                                     // label
              ip = 1077;
      end

       1077 :
      begin                                                                     // mov
              localMem[0 + 473] = heapMem[localMem[0+467]*10 + 1];
              ip = 1078;
      end

       1078 :
      begin                                                                     // jEq
              ip = localMem[0+473] == 3 ? 1223 : 1079;
      end

       1079 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 3) begin
                  heapMem[NArea * localMem[0+468] + 0 + i] = heapMem[NArea * localMem[0+467] + 0 + i];
                end
              end
              ip = 1080;
      end

       1080 :
      begin                                                                     // mov
              localMem[0 + 474] = heapMem[localMem[0+468]*10 + 0];
              ip = 1081;
      end

       1081 :
      begin                                                                     // mov
              localMem[0 + 475] = heapMem[localMem[0+468]*10 + 2];
              ip = 1082;
      end

       1082 :
      begin                                                                     // mov
              localMem[0 + 476] = heapMem[localMem[0+474]*10 + 4];
              ip = 1083;
      end

       1083 :
      begin                                                                     // mov
              localMem[0 + 477] = heapMem[localMem[0+476]*10 + localMem[0+475]];
              ip = 1084;
      end

       1084 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+477];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 1085;
      end

       1085 :
      begin                                                                     // tally
            ip = 1086;
      end

       1086 :
      begin                                                                     // label
              ip = 1087;
      end

       1087 :
      begin                                                                     // mov
              localMem[0 + 478] = heapMem[localMem[0+0]*10 + 3];
              ip = 1088;
      end

       1088 :
      begin                                                                     // jNe
              ip = localMem[0+478] != 0 ? 1093 : 1089;
      end

       1089 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 0] = localMem[0+478];
              ip = 1090;
      end

       1090 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 1] = 3;
              ip = 1091;
      end

       1091 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 2] = 0;
              ip = 1092;
      end

       1092 :
      begin                                                                     // jmp
              ip = 1139;
      end

       1093 :
      begin                                                                     // label
              ip = 1094;
      end

       1094 :
      begin                                                                     // label
              ip = 1095;
      end

       1095 :
      begin                                                                     // mov
              localMem[0 + 479] = 0;
              ip = 1096;
      end

       1096 :
      begin                                                                     // label
              ip = 1097;
      end

       1097 :
      begin                                                                     // jGe
              ip = localMem[0+479] >= 99 ? 1135 : 1098;
      end

       1098 :
      begin                                                                     // subtract
              localMem[0 + 480] = heapMem[localMem[0+478]*10 + 0] - 1;
              ip = 1099;
      end

       1099 :
      begin                                                                     // mov
              localMem[0 + 481] = heapMem[localMem[0+478]*10 + 4];
              ip = 1100;
      end

       1100 :
      begin                                                                     // jLe
              ip = localMem[0+477] <= heapMem[localMem[0+481]*10 + localMem[0+480]] ? 1113 : 1101;
      end

       1101 :
      begin                                                                     // add
              localMem[0 + 482] = localMem[0+480] + 1;
              ip = 1102;
      end

       1102 :
      begin                                                                     // not
              localMem[0 + 483] = !heapMem[localMem[0+478]*10 + 6];
              ip = 1103;
      end

       1103 :
      begin                                                                     // jEq
              ip = localMem[0+483] == 0 ? 1108 : 1104;
      end

       1104 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 0] = localMem[0+478];
              ip = 1105;
      end

       1105 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 1] = 2;
              ip = 1106;
      end

       1106 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 2] = localMem[0+482];
              ip = 1107;
      end

       1107 :
      begin                                                                     // jmp
              ip = 1139;
      end

       1108 :
      begin                                                                     // label
              ip = 1109;
      end

       1109 :
      begin                                                                     // mov
              localMem[0 + 484] = heapMem[localMem[0+478]*10 + 6];
              ip = 1110;
      end

       1110 :
      begin                                                                     // mov
              localMem[0 + 485] = heapMem[localMem[0+484]*10 + localMem[0+482]];
              ip = 1111;
      end

       1111 :
      begin                                                                     // mov
              localMem[0 + 478] = localMem[0+485];
              ip = 1112;
      end

       1112 :
      begin                                                                     // jmp
              ip = 1132;
      end

       1113 :
      begin                                                                     // label
              ip = 1114;
      end

       1114 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+481] * NArea + i] == localMem[0+477]) localMem[0 + 486] = i + 1;
              end
              ip = 1115;
      end

       1115 :
      begin                                                                     // jEq
              ip = localMem[0+486] == 0 ? 1120 : 1116;
      end

       1116 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 0] = localMem[0+478];
              ip = 1117;
      end

       1117 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 1] = 1;
              ip = 1118;
      end

       1118 :
      begin                                                                     // subtract
              heapMem[localMem[0+1]*10 + 2] = localMem[0+486] - 1;
              ip = 1119;
      end

       1119 :
      begin                                                                     // jmp
              ip = 1139;
      end

       1120 :
      begin                                                                     // label
              ip = 1121;
      end

       1121 :
      begin                                                                     // arrayCountLess
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+481] * NArea + i] < localMem[0+477]) j = j + 1;
              end
              localMem[0 + 487] = j;
              ip = 1122;
      end

       1122 :
      begin                                                                     // not
              localMem[0 + 488] = !heapMem[localMem[0+478]*10 + 6];
              ip = 1123;
      end

       1123 :
      begin                                                                     // jEq
              ip = localMem[0+488] == 0 ? 1128 : 1124;
      end

       1124 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 0] = localMem[0+478];
              ip = 1125;
      end

       1125 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 1] = 0;
              ip = 1126;
      end

       1126 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 2] = localMem[0+487];
              ip = 1127;
      end

       1127 :
      begin                                                                     // jmp
              ip = 1139;
      end

       1128 :
      begin                                                                     // label
              ip = 1129;
      end

       1129 :
      begin                                                                     // mov
              localMem[0 + 489] = heapMem[localMem[0+478]*10 + 6];
              ip = 1130;
      end

       1130 :
      begin                                                                     // mov
              localMem[0 + 490] = heapMem[localMem[0+489]*10 + localMem[0+487]];
              ip = 1131;
      end

       1131 :
      begin                                                                     // mov
              localMem[0 + 478] = localMem[0+490];
              ip = 1132;
      end

       1132 :
      begin                                                                     // label
              ip = 1133;
      end

       1133 :
      begin                                                                     // add
              localMem[0 + 479] = localMem[0+479] + 1;
              ip = 1134;
      end

       1134 :
      begin                                                                     // jmp
              ip = 1096;
      end

       1135 :
      begin                                                                     // label
              ip = 1136;
      end

       1136 :
      begin                                                                     // assert
            ip = 1137;
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
      begin                                                                     // label
              ip = 1140;
      end

       1140 :
      begin                                                                     // tally
            ip = 1141;
      end

       1141 :
      begin                                                                     // mov
              localMem[0 + 491] = heapMem[localMem[0+1]*10 + 0];
              ip = 1142;
      end

       1142 :
      begin                                                                     // mov
              localMem[0 + 492] = heapMem[localMem[0+1]*10 + 2];
              ip = 1143;
      end

       1143 :
      begin                                                                     // mov
              localMem[0 + 493] = heapMem[localMem[0+491]*10 + 5];
              ip = 1144;
      end

       1144 :
      begin                                                                     // mov
              localMem[0 + 494] = heapMem[localMem[0+493]*10 + localMem[0+492]];
              ip = 1145;
      end

       1145 :
      begin                                                                     // add
              localMem[0 + 495] = localMem[0+477] + localMem[0+477];
              ip = 1146;
      end

       1146 :
      begin                                                                     // assertEq
            ip = 1147;
      end

       1147 :
      begin                                                                     // label
              ip = 1148;
      end

       1148 :
      begin                                                                     // mov
              localMem[0 + 496] = heapMem[localMem[0+467]*10 + 0];
              ip = 1149;
      end

       1149 :
      begin                                                                     // not
              localMem[0 + 497] = !heapMem[localMem[0+496]*10 + 6];
              ip = 1150;
      end

       1150 :
      begin                                                                     // jEq
              ip = localMem[0+497] == 0 ? 1190 : 1151;
      end

       1151 :
      begin                                                                     // add
              localMem[0 + 498] = heapMem[localMem[0+467]*10 + 2] + 1;
              ip = 1152;
      end

       1152 :
      begin                                                                     // mov
              localMem[0 + 499] = heapMem[localMem[0+496]*10 + 0];
              ip = 1153;
      end

       1153 :
      begin                                                                     // jGe
              ip = localMem[0+498] >= localMem[0+499] ? 1158 : 1154;
      end

       1154 :
      begin                                                                     // mov
              heapMem[localMem[0+467]*10 + 0] = localMem[0+496];
              ip = 1155;
      end

       1155 :
      begin                                                                     // mov
              heapMem[localMem[0+467]*10 + 1] = 1;
              ip = 1156;
      end

       1156 :
      begin                                                                     // mov
              heapMem[localMem[0+467]*10 + 2] = localMem[0+498];
              ip = 1157;
      end

       1157 :
      begin                                                                     // jmp
              ip = 1219;
      end

       1158 :
      begin                                                                     // label
              ip = 1159;
      end

       1159 :
      begin                                                                     // mov
              localMem[0 + 500] = heapMem[localMem[0+496]*10 + 2];
              ip = 1160;
      end

       1160 :
      begin                                                                     // jEq
              ip = localMem[0+500] == 0 ? 1185 : 1161;
      end

       1161 :
      begin                                                                     // label
              ip = 1162;
      end

       1162 :
      begin                                                                     // mov
              localMem[0 + 501] = 0;
              ip = 1163;
      end

       1163 :
      begin                                                                     // label
              ip = 1164;
      end

       1164 :
      begin                                                                     // jGe
              ip = localMem[0+501] >= 99 ? 1184 : 1165;
      end

       1165 :
      begin                                                                     // mov
              localMem[0 + 502] = heapMem[localMem[0+500]*10 + 0];
              ip = 1166;
      end

       1166 :
      begin                                                                     // assertNe
            ip = 1167;
      end

       1167 :
      begin                                                                     // mov
              localMem[0 + 503] = heapMem[localMem[0+500]*10 + 6];
              ip = 1168;
      end

       1168 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+503] * NArea + i] == localMem[0+496]) localMem[0 + 504] = i + 1;
              end
              ip = 1169;
      end

       1169 :
      begin                                                                     // subtract
              localMem[0 + 504] = localMem[0+504] - 1;
              ip = 1170;
      end

       1170 :
      begin                                                                     // jNe
              ip = localMem[0+504] != localMem[0+502] ? 1175 : 1171;
      end

       1171 :
      begin                                                                     // mov
              localMem[0 + 496] = localMem[0+500];
              ip = 1172;
      end

       1172 :
      begin                                                                     // mov
              localMem[0 + 500] = heapMem[localMem[0+496]*10 + 2];
              ip = 1173;
      end

       1173 :
      begin                                                                     // jFalse
              ip = localMem[0+500] == 0 ? 1184 : 1174;
      end

       1174 :
      begin                                                                     // jmp
              ip = 1180;
      end

       1175 :
      begin                                                                     // label
              ip = 1176;
      end

       1176 :
      begin                                                                     // mov
              heapMem[localMem[0+467]*10 + 0] = localMem[0+500];
              ip = 1177;
      end

       1177 :
      begin                                                                     // mov
              heapMem[localMem[0+467]*10 + 1] = 1;
              ip = 1178;
      end

       1178 :
      begin                                                                     // mov
              heapMem[localMem[0+467]*10 + 2] = localMem[0+504];
              ip = 1179;
      end

       1179 :
      begin                                                                     // jmp
              ip = 1219;
      end

       1180 :
      begin                                                                     // label
              ip = 1181;
      end

       1181 :
      begin                                                                     // label
              ip = 1182;
      end

       1182 :
      begin                                                                     // add
              localMem[0 + 501] = localMem[0+501] + 1;
              ip = 1183;
      end

       1183 :
      begin                                                                     // jmp
              ip = 1163;
      end

       1184 :
      begin                                                                     // label
              ip = 1185;
      end

       1185 :
      begin                                                                     // label
              ip = 1186;
      end

       1186 :
      begin                                                                     // mov
              heapMem[localMem[0+467]*10 + 0] = localMem[0+496];
              ip = 1187;
      end

       1187 :
      begin                                                                     // mov
              heapMem[localMem[0+467]*10 + 1] = 3;
              ip = 1188;
      end

       1188 :
      begin                                                                     // mov
              heapMem[localMem[0+467]*10 + 2] = 0;
              ip = 1189;
      end

       1189 :
      begin                                                                     // jmp
              ip = 1219;
      end

       1190 :
      begin                                                                     // label
              ip = 1191;
      end

       1191 :
      begin                                                                     // add
              localMem[0 + 505] = heapMem[localMem[0+467]*10 + 2] + 1;
              ip = 1192;
      end

       1192 :
      begin                                                                     // mov
              localMem[0 + 506] = heapMem[localMem[0+496]*10 + 6];
              ip = 1193;
      end

       1193 :
      begin                                                                     // mov
              localMem[0 + 507] = heapMem[localMem[0+506]*10 + localMem[0+505]];
              ip = 1194;
      end

       1194 :
      begin                                                                     // jNe
              ip = localMem[0+507] != 0 ? 1199 : 1195;
      end

       1195 :
      begin                                                                     // mov
              heapMem[localMem[0+467]*10 + 0] = localMem[0+507];
              ip = 1196;
      end

       1196 :
      begin                                                                     // mov
              heapMem[localMem[0+467]*10 + 1] = 3;
              ip = 1197;
      end

       1197 :
      begin                                                                     // mov
              heapMem[localMem[0+467]*10 + 2] = 0;
              ip = 1198;
      end

       1198 :
      begin                                                                     // jmp
              ip = 1216;
      end

       1199 :
      begin                                                                     // label
              ip = 1200;
      end

       1200 :
      begin                                                                     // label
              ip = 1201;
      end

       1201 :
      begin                                                                     // mov
              localMem[0 + 508] = 0;
              ip = 1202;
      end

       1202 :
      begin                                                                     // label
              ip = 1203;
      end

       1203 :
      begin                                                                     // jGe
              ip = localMem[0+508] >= 99 ? 1212 : 1204;
      end

       1204 :
      begin                                                                     // not
              localMem[0 + 509] = !heapMem[localMem[0+507]*10 + 6];
              ip = 1205;
      end

       1205 :
      begin                                                                     // jTrue
              ip = localMem[0+509] != 0 ? 1212 : 1206;
      end

       1206 :
      begin                                                                     // mov
              localMem[0 + 510] = heapMem[localMem[0+507]*10 + 6];
              ip = 1207;
      end

       1207 :
      begin                                                                     // mov
              localMem[0 + 511] = heapMem[localMem[0+510]*10 + 0];
              ip = 1208;
      end

       1208 :
      begin                                                                     // mov
              localMem[0 + 507] = localMem[0+511];
              ip = 1209;
      end

       1209 :
      begin                                                                     // label
              ip = 1210;
      end

       1210 :
      begin                                                                     // add
              localMem[0 + 508] = localMem[0+508] + 1;
              ip = 1211;
      end

       1211 :
      begin                                                                     // jmp
              ip = 1202;
      end

       1212 :
      begin                                                                     // label
              ip = 1213;
      end

       1213 :
      begin                                                                     // mov
              heapMem[localMem[0+467]*10 + 0] = localMem[0+507];
              ip = 1214;
      end

       1214 :
      begin                                                                     // mov
              heapMem[localMem[0+467]*10 + 1] = 1;
              ip = 1215;
      end

       1215 :
      begin                                                                     // mov
              heapMem[localMem[0+467]*10 + 2] = 0;
              ip = 1216;
      end

       1216 :
      begin                                                                     // label
              ip = 1217;
      end

       1217 :
      begin                                                                     // label
              ip = 1218;
      end

       1218 :
      begin                                                                     // label
              ip = 1219;
      end

       1219 :
      begin                                                                     // label
              ip = 1220;
      end

       1220 :
      begin                                                                     // jmp
              ip = 1076;
      end

       1221 :
      begin                                                                     // label
              ip = 1222;
      end

       1222 :
      begin                                                                     // label
              ip = 1223;
      end

       1223 :
      begin                                                                     // label
              ip = 1224;
      end

       1224 :
      begin                                                                     // free
              freedArrays[freedArraysTop] = localMem[0+467];
              freedArraysTop = freedArraysTop + 1;
              ip = 1225;
      end

       1225 :
      begin                                                                     // free
              freedArrays[freedArraysTop] = localMem[0+468];
              freedArraysTop = freedArraysTop + 1;
              ip = 1226;
      end

       1226 :
      begin                                                                     // tally
            ip = 1227;
      end

       1227 :
      begin                                                                     // mov
              localMem[0 + 512] = 1;
              ip = 1228;
      end

       1228 :
      begin                                                                     // shiftLeft
              localMem[0 + 512] = localMem[0+512] << 31;
              ip = 1229;
      end

       1229 :
      begin                                                                     // mov
              localMem[0 + 513] = heapMem[localMem[0+0]*10 + 3];
              ip = 1230;
      end

       1230 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 514] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 514] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 514]] = 0;
              ip = 1231;
      end

       1231 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 515] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 515] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 515]] = 0;
              ip = 1232;
      end

       1232 :
      begin                                                                     // jNe
              ip = localMem[0+513] != 0 ? 1237 : 1233;
      end

       1233 :
      begin                                                                     // mov
              heapMem[localMem[0+514]*10 + 0] = localMem[0+513];
              ip = 1234;
      end

       1234 :
      begin                                                                     // mov
              heapMem[localMem[0+514]*10 + 1] = 3;
              ip = 1235;
      end

       1235 :
      begin                                                                     // mov
              heapMem[localMem[0+514]*10 + 2] = 0;
              ip = 1236;
      end

       1236 :
      begin                                                                     // jmp
              ip = 1254;
      end

       1237 :
      begin                                                                     // label
              ip = 1238;
      end

       1238 :
      begin                                                                     // label
              ip = 1239;
      end

       1239 :
      begin                                                                     // mov
              localMem[0 + 516] = 0;
              ip = 1240;
      end

       1240 :
      begin                                                                     // label
              ip = 1241;
      end

       1241 :
      begin                                                                     // jGe
              ip = localMem[0+516] >= 99 ? 1250 : 1242;
      end

       1242 :
      begin                                                                     // not
              localMem[0 + 517] = !heapMem[localMem[0+513]*10 + 6];
              ip = 1243;
      end

       1243 :
      begin                                                                     // jTrue
              ip = localMem[0+517] != 0 ? 1250 : 1244;
      end

       1244 :
      begin                                                                     // mov
              localMem[0 + 518] = heapMem[localMem[0+513]*10 + 6];
              ip = 1245;
      end

       1245 :
      begin                                                                     // mov
              localMem[0 + 519] = heapMem[localMem[0+518]*10 + 0];
              ip = 1246;
      end

       1246 :
      begin                                                                     // mov
              localMem[0 + 513] = localMem[0+519];
              ip = 1247;
      end

       1247 :
      begin                                                                     // label
              ip = 1248;
      end

       1248 :
      begin                                                                     // add
              localMem[0 + 516] = localMem[0+516] + 1;
              ip = 1249;
      end

       1249 :
      begin                                                                     // jmp
              ip = 1240;
      end

       1250 :
      begin                                                                     // label
              ip = 1251;
      end

       1251 :
      begin                                                                     // mov
              heapMem[localMem[0+514]*10 + 0] = localMem[0+513];
              ip = 1252;
      end

       1252 :
      begin                                                                     // mov
              heapMem[localMem[0+514]*10 + 1] = 1;
              ip = 1253;
      end

       1253 :
      begin                                                                     // mov
              heapMem[localMem[0+514]*10 + 2] = 0;
              ip = 1254;
      end

       1254 :
      begin                                                                     // label
              ip = 1255;
      end

       1255 :
      begin                                                                     // label
              ip = 1256;
      end

       1256 :
      begin                                                                     // mov
              localMem[0 + 520] = heapMem[localMem[0+514]*10 + 1];
              ip = 1257;
      end

       1257 :
      begin                                                                     // jEq
              ip = localMem[0+520] == 3 ? 1335 : 1258;
      end

       1258 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 3) begin
                  heapMem[NArea * localMem[0+515] + 0 + i] = heapMem[NArea * localMem[0+514] + 0 + i];
                end
              end
              ip = 1259;
      end

       1259 :
      begin                                                                     // label
              ip = 1260;
      end

       1260 :
      begin                                                                     // mov
              localMem[0 + 521] = heapMem[localMem[0+514]*10 + 0];
              ip = 1261;
      end

       1261 :
      begin                                                                     // not
              localMem[0 + 522] = !heapMem[localMem[0+521]*10 + 6];
              ip = 1262;
      end

       1262 :
      begin                                                                     // jEq
              ip = localMem[0+522] == 0 ? 1302 : 1263;
      end

       1263 :
      begin                                                                     // add
              localMem[0 + 523] = heapMem[localMem[0+514]*10 + 2] + 1;
              ip = 1264;
      end

       1264 :
      begin                                                                     // mov
              localMem[0 + 524] = heapMem[localMem[0+521]*10 + 0];
              ip = 1265;
      end

       1265 :
      begin                                                                     // jGe
              ip = localMem[0+523] >= localMem[0+524] ? 1270 : 1266;
      end

       1266 :
      begin                                                                     // mov
              heapMem[localMem[0+514]*10 + 0] = localMem[0+521];
              ip = 1267;
      end

       1267 :
      begin                                                                     // mov
              heapMem[localMem[0+514]*10 + 1] = 1;
              ip = 1268;
      end

       1268 :
      begin                                                                     // mov
              heapMem[localMem[0+514]*10 + 2] = localMem[0+523];
              ip = 1269;
      end

       1269 :
      begin                                                                     // jmp
              ip = 1331;
      end

       1270 :
      begin                                                                     // label
              ip = 1271;
      end

       1271 :
      begin                                                                     // mov
              localMem[0 + 525] = heapMem[localMem[0+521]*10 + 2];
              ip = 1272;
      end

       1272 :
      begin                                                                     // jEq
              ip = localMem[0+525] == 0 ? 1297 : 1273;
      end

       1273 :
      begin                                                                     // label
              ip = 1274;
      end

       1274 :
      begin                                                                     // mov
              localMem[0 + 526] = 0;
              ip = 1275;
      end

       1275 :
      begin                                                                     // label
              ip = 1276;
      end

       1276 :
      begin                                                                     // jGe
              ip = localMem[0+526] >= 99 ? 1296 : 1277;
      end

       1277 :
      begin                                                                     // mov
              localMem[0 + 527] = heapMem[localMem[0+525]*10 + 0];
              ip = 1278;
      end

       1278 :
      begin                                                                     // assertNe
            ip = 1279;
      end

       1279 :
      begin                                                                     // mov
              localMem[0 + 528] = heapMem[localMem[0+525]*10 + 6];
              ip = 1280;
      end

       1280 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+528] * NArea + i] == localMem[0+521]) localMem[0 + 529] = i + 1;
              end
              ip = 1281;
      end

       1281 :
      begin                                                                     // subtract
              localMem[0 + 529] = localMem[0+529] - 1;
              ip = 1282;
      end

       1282 :
      begin                                                                     // jNe
              ip = localMem[0+529] != localMem[0+527] ? 1287 : 1283;
      end

       1283 :
      begin                                                                     // mov
              localMem[0 + 521] = localMem[0+525];
              ip = 1284;
      end

       1284 :
      begin                                                                     // mov
              localMem[0 + 525] = heapMem[localMem[0+521]*10 + 2];
              ip = 1285;
      end

       1285 :
      begin                                                                     // jFalse
              ip = localMem[0+525] == 0 ? 1296 : 1286;
      end

       1286 :
      begin                                                                     // jmp
              ip = 1292;
      end

       1287 :
      begin                                                                     // label
              ip = 1288;
      end

       1288 :
      begin                                                                     // mov
              heapMem[localMem[0+514]*10 + 0] = localMem[0+525];
              ip = 1289;
      end

       1289 :
      begin                                                                     // mov
              heapMem[localMem[0+514]*10 + 1] = 1;
              ip = 1290;
      end

       1290 :
      begin                                                                     // mov
              heapMem[localMem[0+514]*10 + 2] = localMem[0+529];
              ip = 1291;
      end

       1291 :
      begin                                                                     // jmp
              ip = 1331;
      end

       1292 :
      begin                                                                     // label
              ip = 1293;
      end

       1293 :
      begin                                                                     // label
              ip = 1294;
      end

       1294 :
      begin                                                                     // add
              localMem[0 + 526] = localMem[0+526] + 1;
              ip = 1295;
      end

       1295 :
      begin                                                                     // jmp
              ip = 1275;
      end

       1296 :
      begin                                                                     // label
              ip = 1297;
      end

       1297 :
      begin                                                                     // label
              ip = 1298;
      end

       1298 :
      begin                                                                     // mov
              heapMem[localMem[0+514]*10 + 0] = localMem[0+521];
              ip = 1299;
      end

       1299 :
      begin                                                                     // mov
              heapMem[localMem[0+514]*10 + 1] = 3;
              ip = 1300;
      end

       1300 :
      begin                                                                     // mov
              heapMem[localMem[0+514]*10 + 2] = 0;
              ip = 1301;
      end

       1301 :
      begin                                                                     // jmp
              ip = 1331;
      end

       1302 :
      begin                                                                     // label
              ip = 1303;
      end

       1303 :
      begin                                                                     // add
              localMem[0 + 530] = heapMem[localMem[0+514]*10 + 2] + 1;
              ip = 1304;
      end

       1304 :
      begin                                                                     // mov
              localMem[0 + 531] = heapMem[localMem[0+521]*10 + 6];
              ip = 1305;
      end

       1305 :
      begin                                                                     // mov
              localMem[0 + 532] = heapMem[localMem[0+531]*10 + localMem[0+530]];
              ip = 1306;
      end

       1306 :
      begin                                                                     // jNe
              ip = localMem[0+532] != 0 ? 1311 : 1307;
      end

       1307 :
      begin                                                                     // mov
              heapMem[localMem[0+514]*10 + 0] = localMem[0+532];
              ip = 1308;
      end

       1308 :
      begin                                                                     // mov
              heapMem[localMem[0+514]*10 + 1] = 3;
              ip = 1309;
      end

       1309 :
      begin                                                                     // mov
              heapMem[localMem[0+514]*10 + 2] = 0;
              ip = 1310;
      end

       1310 :
      begin                                                                     // jmp
              ip = 1328;
      end

       1311 :
      begin                                                                     // label
              ip = 1312;
      end

       1312 :
      begin                                                                     // label
              ip = 1313;
      end

       1313 :
      begin                                                                     // mov
              localMem[0 + 533] = 0;
              ip = 1314;
      end

       1314 :
      begin                                                                     // label
              ip = 1315;
      end

       1315 :
      begin                                                                     // jGe
              ip = localMem[0+533] >= 99 ? 1324 : 1316;
      end

       1316 :
      begin                                                                     // not
              localMem[0 + 534] = !heapMem[localMem[0+532]*10 + 6];
              ip = 1317;
      end

       1317 :
      begin                                                                     // jTrue
              ip = localMem[0+534] != 0 ? 1324 : 1318;
      end

       1318 :
      begin                                                                     // mov
              localMem[0 + 535] = heapMem[localMem[0+532]*10 + 6];
              ip = 1319;
      end

       1319 :
      begin                                                                     // mov
              localMem[0 + 536] = heapMem[localMem[0+535]*10 + 0];
              ip = 1320;
      end

       1320 :
      begin                                                                     // mov
              localMem[0 + 532] = localMem[0+536];
              ip = 1321;
      end

       1321 :
      begin                                                                     // label
              ip = 1322;
      end

       1322 :
      begin                                                                     // add
              localMem[0 + 533] = localMem[0+533] + 1;
              ip = 1323;
      end

       1323 :
      begin                                                                     // jmp
              ip = 1314;
      end

       1324 :
      begin                                                                     // label
              ip = 1325;
      end

       1325 :
      begin                                                                     // mov
              heapMem[localMem[0+514]*10 + 0] = localMem[0+532];
              ip = 1326;
      end

       1326 :
      begin                                                                     // mov
              heapMem[localMem[0+514]*10 + 1] = 1;
              ip = 1327;
      end

       1327 :
      begin                                                                     // mov
              heapMem[localMem[0+514]*10 + 2] = 0;
              ip = 1328;
      end

       1328 :
      begin                                                                     // label
              ip = 1329;
      end

       1329 :
      begin                                                                     // label
              ip = 1330;
      end

       1330 :
      begin                                                                     // label
              ip = 1331;
      end

       1331 :
      begin                                                                     // label
              ip = 1332;
      end

       1332 :
      begin                                                                     // jmp
              ip = 1255;
      end

       1333 :
      begin                                                                     // label
              ip = 1334;
      end

       1334 :
      begin                                                                     // label
              ip = 1335;
      end

       1335 :
      begin                                                                     // label
              ip = 1336;
      end

       1336 :
      begin                                                                     // free
              freedArrays[freedArraysTop] = localMem[0+514];
              freedArraysTop = freedArraysTop + 1;
              ip = 1337;
      end

       1337 :
      begin                                                                     // free
              freedArrays[freedArraysTop] = localMem[0+515];
              freedArraysTop = freedArraysTop + 1;
              ip = 1338;
      end

       1338 :
      begin                                                                     // tally
            ip = 1339;
      end
      default: begin
        success  = 1;
        success  = success && outMem[0] == 1;
        success  = success && outMem[1] == 2;
        success  = success && outMem[2] == 3;
        success  = success && outMem[3] == 4;
        success  = success && outMem[4] == 5;
        success  = success && outMem[5] == 6;
        success  = success && outMem[6] == 7;
        success  = success && outMem[7] == 8;
        success  = success && outMem[8] == 9;
        success  = success && outMem[9] == 10;
        success  = success && outMem[10] == 11;
        success  = success && outMem[11] == 12;
        success  = success && outMem[12] == 13;
        success  = success && outMem[13] == 14;
        success  = success && outMem[14] == 15;
        success  = success && outMem[15] == 16;
        success  = success && outMem[16] == 17;
        success  = success && outMem[17] == 18;
        success  = success && outMem[18] == 19;
        success  = success && outMem[19] == 20;
        success  = success && outMem[20] == 21;
        success  = success && outMem[21] == 22;
        success  = success && outMem[22] == 23;
        success  = success && outMem[23] == 24;
        success  = success && outMem[24] == 25;
        success  = success && outMem[25] == 26;
        success  = success && outMem[26] == 27;
        success  = success && outMem[27] == 28;
        success  = success && outMem[28] == 29;
        success  = success && outMem[29] == 30;
        success  = success && outMem[30] == 31;
        success  = success && outMem[31] == 32;
        success  = success && outMem[32] == 33;
        success  = success && outMem[33] == 34;
        success  = success && outMem[34] == 35;
        success  = success && outMem[35] == 36;
        success  = success && outMem[36] == 37;
        success  = success && outMem[37] == 38;
        success  = success && outMem[38] == 39;
        success  = success && outMem[39] == 40;
        success  = success && outMem[40] == 41;
        success  = success && outMem[41] == 42;
        success  = success && outMem[42] == 43;
        success  = success && outMem[43] == 44;
        success  = success && outMem[44] == 45;
        success  = success && outMem[45] == 46;
        success  = success && outMem[46] == 47;
        success  = success && outMem[47] == 48;
        success  = success && outMem[48] == 49;
        success  = success && outMem[49] == 50;
        success  = success && outMem[50] == 51;
        success  = success && outMem[51] == 52;
        success  = success && outMem[52] == 53;
        success  = success && outMem[53] == 54;
        success  = success && outMem[54] == 55;
        success  = success && outMem[55] == 56;
        success  = success && outMem[56] == 57;
        success  = success && outMem[57] == 58;
        success  = success && outMem[58] == 59;
        success  = success && outMem[59] == 60;
        success  = success && outMem[60] == 61;
        success  = success && outMem[61] == 62;
        success  = success && outMem[62] == 63;
        success  = success && outMem[63] == 64;
        success  = success && outMem[64] == 65;
        success  = success && outMem[65] == 66;
        success  = success && outMem[66] == 67;
        success  = success && outMem[67] == 68;
        success  = success && outMem[68] == 69;
        success  = success && outMem[69] == 70;
        success  = success && outMem[70] == 71;
        success  = success && outMem[71] == 72;
        success  = success && outMem[72] == 73;
        success  = success && outMem[73] == 74;
        success  = success && outMem[74] == 75;
        success  = success && outMem[75] == 76;
        success  = success && outMem[76] == 77;
        success  = success && outMem[77] == 78;
        success  = success && outMem[78] == 79;
        success  = success && outMem[79] == 80;
        success  = success && outMem[80] == 81;
        success  = success && outMem[81] == 82;
        success  = success && outMem[82] == 83;
        success  = success && outMem[83] == 84;
        success  = success && outMem[84] == 85;
        success  = success && outMem[85] == 86;
        success  = success && outMem[86] == 87;
        success  = success && outMem[87] == 88;
        success  = success && outMem[88] == 89;
        success  = success && outMem[89] == 90;
        success  = success && outMem[90] == 91;
        success  = success && outMem[91] == 92;
        success  = success && outMem[92] == 93;
        success  = success && outMem[93] == 94;
        success  = success && outMem[94] == 95;
        success  = success && outMem[95] == 96;
        success  = success && outMem[96] == 97;
        success  = success && outMem[97] == 98;
        success  = success && outMem[98] == 99;
        success  = success && outMem[99] == 100;
        success  = success && outMem[100] == 101;
        success  = success && outMem[101] == 102;
        success  = success && outMem[102] == 103;
        success  = success && outMem[103] == 104;
        success  = success && outMem[104] == 105;
        success  = success && outMem[105] == 106;
        success  = success && outMem[106] == 107;
        finished = 1;
      end
    endcase
    if (steps <=  39359) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
  end
endmodule
