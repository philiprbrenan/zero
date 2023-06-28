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
  parameter integer NIn            =    21;                                     // Size of input area
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
    inMem[0] = 0;
    inMem[1] = 1;
    inMem[2] = 3;
    inMem[3] = 33;
    inMem[4] = 1;
    inMem[5] = 1;
    inMem[6] = 11;
    inMem[7] = 1;
    inMem[8] = 2;
    inMem[9] = 22;
    inMem[10] = 1;
    inMem[11] = 4;
    inMem[12] = 44;
    inMem[13] = 2;
    inMem[14] = 5;
    inMem[15] = 2;
    inMem[16] = 2;
    inMem[17] = 2;
    inMem[18] = 6;
    inMem[19] = 2;
    inMem[20] = 3;
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
      begin                                                                     // label
              ip = 2;
      end

          2 :
      begin                                                                     // inSize
              localMem[0 + 1] = NIn - inMemPos;
              ip = 3;
      end

          3 :
      begin                                                                     // jFalse
              ip = localMem[0+1] == 0 ? 1140 : 4;
      end

          4 :
      begin                                                                     // in
              if (inMemPos < NIn) begin
                localMem[0 + 2] = inMem[inMemPos];
                inMemPos = inMemPos + 1;
              end
              ip = 5;
      end

          5 :
      begin                                                                     // jNe
              ip = localMem[0+2] != 0 ? 12 : 6;
      end

          6 :
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
              ip = 7;
      end

          7 :
      begin                                                                     // mov
              heapMem[localMem[0+3]*10 + 2] = 3;
              ip = 8;
      end

          8 :
      begin                                                                     // mov
              heapMem[localMem[0+3]*10 + 3] = 0;
              ip = 9;
      end

          9 :
      begin                                                                     // mov
              heapMem[localMem[0+3]*10 + 0] = 0;
              ip = 10;
      end

         10 :
      begin                                                                     // mov
              heapMem[localMem[0+3]*10 + 1] = 0;
              ip = 11;
      end

         11 :
      begin                                                                     // jmp
              ip = 1138;
      end

         12 :
      begin                                                                     // label
              ip = 13;
      end

         13 :
      begin                                                                     // jNe
              ip = localMem[0+2] != 1 ? 1066 : 14;
      end

         14 :
      begin                                                                     // in
              if (inMemPos < NIn) begin
                localMem[0 + 4] = inMem[inMemPos];
                inMemPos = inMemPos + 1;
              end
              ip = 15;
      end

         15 :
      begin                                                                     // in
              if (inMemPos < NIn) begin
                localMem[0 + 5] = inMem[inMemPos];
                inMemPos = inMemPos + 1;
              end
              ip = 16;
      end

         16 :
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
              ip = 17;
      end

         17 :
      begin                                                                     // label
              ip = 18;
      end

         18 :
      begin                                                                     // mov
              localMem[0 + 7] = heapMem[localMem[0+3]*10 + 3];
              ip = 19;
      end

         19 :
      begin                                                                     // jNe
              ip = localMem[0+7] != 0 ? 38 : 20;
      end

         20 :
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
              ip = 21;
      end

         21 :
      begin                                                                     // mov
              heapMem[localMem[0+8]*10 + 0] = 1;
              ip = 22;
      end

         22 :
      begin                                                                     // mov
              heapMem[localMem[0+8]*10 + 2] = 0;
              ip = 23;
      end

         23 :
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
              ip = 24;
      end

         24 :
      begin                                                                     // mov
              heapMem[localMem[0+8]*10 + 4] = localMem[0+9];
              ip = 25;
      end

         25 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 10] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 10] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 10]] = 0;
              ip = 26;
      end

         26 :
      begin                                                                     // mov
              heapMem[localMem[0+8]*10 + 5] = localMem[0+10];
              ip = 27;
      end

         27 :
      begin                                                                     // mov
              heapMem[localMem[0+8]*10 + 6] = 0;
              ip = 28;
      end

         28 :
      begin                                                                     // mov
              heapMem[localMem[0+8]*10 + 3] = localMem[0+3];
              ip = 29;
      end

         29 :
      begin                                                                     // add
              heapMem[localMem[0+3]*10 + 1] = heapMem[localMem[0+3]*10 + 1] + 1;
              ip = 30;
      end

         30 :
      begin                                                                     // mov
              heapMem[localMem[0+8]*10 + 1] = heapMem[localMem[0+3]*10 + 1];
              ip = 31;
      end

         31 :
      begin                                                                     // mov
              localMem[0 + 11] = heapMem[localMem[0+8]*10 + 4];
              ip = 32;
      end

         32 :
      begin                                                                     // mov
              heapMem[localMem[0+11]*10 + 0] = localMem[0+4];
              ip = 33;
      end

         33 :
      begin                                                                     // mov
              localMem[0 + 12] = heapMem[localMem[0+8]*10 + 5];
              ip = 34;
      end

         34 :
      begin                                                                     // mov
              heapMem[localMem[0+12]*10 + 0] = localMem[0+5];
              ip = 35;
      end

         35 :
      begin                                                                     // add
              heapMem[localMem[0+3]*10 + 0] = heapMem[localMem[0+3]*10 + 0] + 1;
              ip = 36;
      end

         36 :
      begin                                                                     // mov
              heapMem[localMem[0+3]*10 + 3] = localMem[0+8];
              ip = 37;
      end

         37 :
      begin                                                                     // jmp
              ip = 1063;
      end

         38 :
      begin                                                                     // label
              ip = 39;
      end

         39 :
      begin                                                                     // mov
              localMem[0 + 13] = heapMem[localMem[0+7]*10 + 0];
              ip = 40;
      end

         40 :
      begin                                                                     // mov
              localMem[0 + 14] = heapMem[localMem[0+3]*10 + 2];
              ip = 41;
      end

         41 :
      begin                                                                     // jGe
              ip = localMem[0+13] >= localMem[0+14] ? 74 : 42;
      end

         42 :
      begin                                                                     // mov
              localMem[0 + 15] = heapMem[localMem[0+7]*10 + 2];
              ip = 43;
      end

         43 :
      begin                                                                     // jNe
              ip = localMem[0+15] != 0 ? 73 : 44;
      end

         44 :
      begin                                                                     // not
              localMem[0 + 16] = !heapMem[localMem[0+7]*10 + 6];
              ip = 45;
      end

         45 :
      begin                                                                     // jEq
              ip = localMem[0+16] == 0 ? 72 : 46;
      end

         46 :
      begin                                                                     // mov
              localMem[0 + 17] = heapMem[localMem[0+7]*10 + 4];
              ip = 47;
      end

         47 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+17] * NArea + i] == localMem[0+4]) localMem[0 + 18] = i + 1;
              end
              ip = 48;
      end

         48 :
      begin                                                                     // jEq
              ip = localMem[0+18] == 0 ? 53 : 49;
      end

         49 :
      begin                                                                     // subtract
              localMem[0 + 18] = localMem[0+18] - 1;
              ip = 50;
      end

         50 :
      begin                                                                     // mov
              localMem[0 + 19] = heapMem[localMem[0+7]*10 + 5];
              ip = 51;
      end

         51 :
      begin                                                                     // mov
              heapMem[localMem[0+19]*10 + localMem[0+18]] = localMem[0+5];
              ip = 52;
      end

         52 :
      begin                                                                     // jmp
              ip = 1063;
      end

         53 :
      begin                                                                     // label
              ip = 54;
      end

         54 :
      begin                                                                     // arrayCountGreater
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+17] * NArea + i] > localMem[0+4]) j = j + 1;
              end
              localMem[0 + 20] = j;
              ip = 55;
      end

         55 :
      begin                                                                     // jNe
              ip = localMem[0+20] != 0 ? 63 : 56;
      end

         56 :
      begin                                                                     // mov
              localMem[0 + 21] = heapMem[localMem[0+7]*10 + 4];
              ip = 57;
      end

         57 :
      begin                                                                     // mov
              heapMem[localMem[0+21]*10 + localMem[0+13]] = localMem[0+4];
              ip = 58;
      end

         58 :
      begin                                                                     // mov
              localMem[0 + 22] = heapMem[localMem[0+7]*10 + 5];
              ip = 59;
      end

         59 :
      begin                                                                     // mov
              heapMem[localMem[0+22]*10 + localMem[0+13]] = localMem[0+5];
              ip = 60;
      end

         60 :
      begin                                                                     // add
              heapMem[localMem[0+7]*10 + 0] = localMem[0+13] + 1;
              ip = 61;
      end

         61 :
      begin                                                                     // add
              heapMem[localMem[0+3]*10 + 0] = heapMem[localMem[0+3]*10 + 0] + 1;
              ip = 62;
      end

         62 :
      begin                                                                     // jmp
              ip = 1063;
      end

         63 :
      begin                                                                     // label
              ip = 64;
      end

         64 :
      begin                                                                     // arrayCountLess
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+17] * NArea + i] < localMem[0+4]) j = j + 1;
              end
              localMem[0 + 23] = j;
              ip = 65;
      end

         65 :
      begin                                                                     // mov
              localMem[0 + 24] = heapMem[localMem[0+7]*10 + 4];
              ip = 66;
      end

         66 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+24] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[23]) begin
                  heapMem[NArea * localMem[0+24] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+24] + localMem[23]] = localMem[0+4];                                    // Insert new value
              arraySizes[localMem[0+24]] = arraySizes[localMem[0+24]] + 1;                              // Increase array size
              ip = 67;
      end

         67 :
      begin                                                                     // mov
              localMem[0 + 25] = heapMem[localMem[0+7]*10 + 5];
              ip = 68;
      end

         68 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+25] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[23]) begin
                  heapMem[NArea * localMem[0+25] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+25] + localMem[23]] = localMem[0+5];                                    // Insert new value
              arraySizes[localMem[0+25]] = arraySizes[localMem[0+25]] + 1;                              // Increase array size
              ip = 69;
      end

         69 :
      begin                                                                     // add
              heapMem[localMem[0+7]*10 + 0] = heapMem[localMem[0+7]*10 + 0] + 1;
              ip = 70;
      end

         70 :
      begin                                                                     // add
              heapMem[localMem[0+3]*10 + 0] = heapMem[localMem[0+3]*10 + 0] + 1;
              ip = 71;
      end

         71 :
      begin                                                                     // jmp
              ip = 1063;
      end

         72 :
      begin                                                                     // label
              ip = 73;
      end

         73 :
      begin                                                                     // label
              ip = 74;
      end

         74 :
      begin                                                                     // label
              ip = 75;
      end

         75 :
      begin                                                                     // mov
              localMem[0 + 26] = heapMem[localMem[0+3]*10 + 3];
              ip = 76;
      end

         76 :
      begin                                                                     // label
              ip = 77;
      end

         77 :
      begin                                                                     // mov
              localMem[0 + 28] = heapMem[localMem[0+26]*10 + 0];
              ip = 78;
      end

         78 :
      begin                                                                     // mov
              localMem[0 + 29] = heapMem[localMem[0+26]*10 + 3];
              ip = 79;
      end

         79 :
      begin                                                                     // mov
              localMem[0 + 30] = heapMem[localMem[0+29]*10 + 2];
              ip = 80;
      end

         80 :
      begin                                                                     // jLt
              ip = localMem[0+28] <  localMem[0+30] ? 300 : 81;
      end

         81 :
      begin                                                                     // mov
              localMem[0 + 31] = localMem[0+30];
              ip = 82;
      end

         82 :
      begin                                                                     // shiftRight
              localMem[0 + 31] = localMem[0+31] >> 1;
              ip = 83;
      end

         83 :
      begin                                                                     // add
              localMem[0 + 32] = localMem[0+31] + 1;
              ip = 84;
      end

         84 :
      begin                                                                     // mov
              localMem[0 + 33] = heapMem[localMem[0+26]*10 + 2];
              ip = 85;
      end

         85 :
      begin                                                                     // jEq
              ip = localMem[0+33] == 0 ? 182 : 86;
      end

         86 :
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
              ip = 87;
      end

         87 :
      begin                                                                     // mov
              heapMem[localMem[0+34]*10 + 0] = localMem[0+31];
              ip = 88;
      end

         88 :
      begin                                                                     // mov
              heapMem[localMem[0+34]*10 + 2] = 0;
              ip = 89;
      end

         89 :
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
              ip = 90;
      end

         90 :
      begin                                                                     // mov
              heapMem[localMem[0+34]*10 + 4] = localMem[0+35];
              ip = 91;
      end

         91 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 36] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 36] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 36]] = 0;
              ip = 92;
      end

         92 :
      begin                                                                     // mov
              heapMem[localMem[0+34]*10 + 5] = localMem[0+36];
              ip = 93;
      end

         93 :
      begin                                                                     // mov
              heapMem[localMem[0+34]*10 + 6] = 0;
              ip = 94;
      end

         94 :
      begin                                                                     // mov
              heapMem[localMem[0+34]*10 + 3] = localMem[0+29];
              ip = 95;
      end

         95 :
      begin                                                                     // add
              heapMem[localMem[0+29]*10 + 1] = heapMem[localMem[0+29]*10 + 1] + 1;
              ip = 96;
      end

         96 :
      begin                                                                     // mov
              heapMem[localMem[0+34]*10 + 1] = heapMem[localMem[0+29]*10 + 1];
              ip = 97;
      end

         97 :
      begin                                                                     // not
              localMem[0 + 37] = !heapMem[localMem[0+26]*10 + 6];
              ip = 98;
      end

         98 :
      begin                                                                     // jNe
              ip = localMem[0+37] != 0 ? 127 : 99;
      end

         99 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 38] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 38] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 38]] = 0;
              ip = 100;
      end

        100 :
      begin                                                                     // mov
              heapMem[localMem[0+34]*10 + 6] = localMem[0+38];
              ip = 101;
      end

        101 :
      begin                                                                     // mov
              localMem[0 + 39] = heapMem[localMem[0+26]*10 + 4];
              ip = 102;
      end

        102 :
      begin                                                                     // mov
              localMem[0 + 40] = heapMem[localMem[0+34]*10 + 4];
              ip = 103;
      end

        103 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+31]) begin
                  heapMem[NArea * localMem[0+40] + 0 + i] = heapMem[NArea * localMem[0+39] + localMem[32] + i];
                end
              end
              ip = 104;
      end

        104 :
      begin                                                                     // mov
              localMem[0 + 41] = heapMem[localMem[0+26]*10 + 5];
              ip = 105;
      end

        105 :
      begin                                                                     // mov
              localMem[0 + 42] = heapMem[localMem[0+34]*10 + 5];
              ip = 106;
      end

        106 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+31]) begin
                  heapMem[NArea * localMem[0+42] + 0 + i] = heapMem[NArea * localMem[0+41] + localMem[32] + i];
                end
              end
              ip = 107;
      end

        107 :
      begin                                                                     // mov
              localMem[0 + 43] = heapMem[localMem[0+26]*10 + 6];
              ip = 108;
      end

        108 :
      begin                                                                     // mov
              localMem[0 + 44] = heapMem[localMem[0+34]*10 + 6];
              ip = 109;
      end

        109 :
      begin                                                                     // add
              localMem[0 + 45] = localMem[0+31] + 1;
              ip = 110;
      end

        110 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+45]) begin
                  heapMem[NArea * localMem[0+44] + 0 + i] = heapMem[NArea * localMem[0+43] + localMem[32] + i];
                end
              end
              ip = 111;
      end

        111 :
      begin                                                                     // mov
              localMem[0 + 46] = heapMem[localMem[0+34]*10 + 0];
              ip = 112;
      end

        112 :
      begin                                                                     // add
              localMem[0 + 47] = localMem[0+46] + 1;
              ip = 113;
      end

        113 :
      begin                                                                     // mov
              localMem[0 + 48] = heapMem[localMem[0+34]*10 + 6];
              ip = 114;
      end

        114 :
      begin                                                                     // label
              ip = 115;
      end

        115 :
      begin                                                                     // mov
              localMem[0 + 49] = 0;
              ip = 116;
      end

        116 :
      begin                                                                     // label
              ip = 117;
      end

        117 :
      begin                                                                     // jGe
              ip = localMem[0+49] >= localMem[0+47] ? 123 : 118;
      end

        118 :
      begin                                                                     // mov
              localMem[0 + 50] = heapMem[localMem[0+48]*10 + localMem[0+49]];
              ip = 119;
      end

        119 :
      begin                                                                     // mov
              heapMem[localMem[0+50]*10 + 2] = localMem[0+34];
              ip = 120;
      end

        120 :
      begin                                                                     // label
              ip = 121;
      end

        121 :
      begin                                                                     // add
              localMem[0 + 49] = localMem[0+49] + 1;
              ip = 122;
      end

        122 :
      begin                                                                     // jmp
              ip = 116;
      end

        123 :
      begin                                                                     // label
              ip = 124;
      end

        124 :
      begin                                                                     // mov
              localMem[0 + 51] = heapMem[localMem[0+26]*10 + 6];
              ip = 125;
      end

        125 :
      begin                                                                     // resize
              arraySizes[localMem[0+51]] = localMem[0+32];
              ip = 126;
      end

        126 :
      begin                                                                     // jmp
              ip = 134;
      end

        127 :
      begin                                                                     // label
              ip = 128;
      end

        128 :
      begin                                                                     // mov
              localMem[0 + 52] = heapMem[localMem[0+26]*10 + 4];
              ip = 129;
      end

        129 :
      begin                                                                     // mov
              localMem[0 + 53] = heapMem[localMem[0+34]*10 + 4];
              ip = 130;
      end

        130 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+31]) begin
                  heapMem[NArea * localMem[0+53] + 0 + i] = heapMem[NArea * localMem[0+52] + localMem[32] + i];
                end
              end
              ip = 131;
      end

        131 :
      begin                                                                     // mov
              localMem[0 + 54] = heapMem[localMem[0+26]*10 + 5];
              ip = 132;
      end

        132 :
      begin                                                                     // mov
              localMem[0 + 55] = heapMem[localMem[0+34]*10 + 5];
              ip = 133;
      end

        133 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+31]) begin
                  heapMem[NArea * localMem[0+55] + 0 + i] = heapMem[NArea * localMem[0+54] + localMem[32] + i];
                end
              end
              ip = 134;
      end

        134 :
      begin                                                                     // label
              ip = 135;
      end

        135 :
      begin                                                                     // mov
              heapMem[localMem[0+26]*10 + 0] = localMem[0+31];
              ip = 136;
      end

        136 :
      begin                                                                     // mov
              heapMem[localMem[0+34]*10 + 2] = localMem[0+33];
              ip = 137;
      end

        137 :
      begin                                                                     // mov
              localMem[0 + 56] = heapMem[localMem[0+33]*10 + 0];
              ip = 138;
      end

        138 :
      begin                                                                     // mov
              localMem[0 + 57] = heapMem[localMem[0+33]*10 + 6];
              ip = 139;
      end

        139 :
      begin                                                                     // mov
              localMem[0 + 58] = heapMem[localMem[0+57]*10 + localMem[0+56]];
              ip = 140;
      end

        140 :
      begin                                                                     // jNe
              ip = localMem[0+58] != localMem[0+26] ? 159 : 141;
      end

        141 :
      begin                                                                     // mov
              localMem[0 + 59] = heapMem[localMem[0+26]*10 + 4];
              ip = 142;
      end

        142 :
      begin                                                                     // mov
              localMem[0 + 60] = heapMem[localMem[0+59]*10 + localMem[0+31]];
              ip = 143;
      end

        143 :
      begin                                                                     // mov
              localMem[0 + 61] = heapMem[localMem[0+33]*10 + 4];
              ip = 144;
      end

        144 :
      begin                                                                     // mov
              heapMem[localMem[0+61]*10 + localMem[0+56]] = localMem[0+60];
              ip = 145;
      end

        145 :
      begin                                                                     // mov
              localMem[0 + 62] = heapMem[localMem[0+26]*10 + 5];
              ip = 146;
      end

        146 :
      begin                                                                     // mov
              localMem[0 + 63] = heapMem[localMem[0+62]*10 + localMem[0+31]];
              ip = 147;
      end

        147 :
      begin                                                                     // mov
              localMem[0 + 64] = heapMem[localMem[0+33]*10 + 5];
              ip = 148;
      end

        148 :
      begin                                                                     // mov
              heapMem[localMem[0+64]*10 + localMem[0+56]] = localMem[0+63];
              ip = 149;
      end

        149 :
      begin                                                                     // mov
              localMem[0 + 65] = heapMem[localMem[0+26]*10 + 4];
              ip = 150;
      end

        150 :
      begin                                                                     // resize
              arraySizes[localMem[0+65]] = localMem[0+31];
              ip = 151;
      end

        151 :
      begin                                                                     // mov
              localMem[0 + 66] = heapMem[localMem[0+26]*10 + 5];
              ip = 152;
      end

        152 :
      begin                                                                     // resize
              arraySizes[localMem[0+66]] = localMem[0+31];
              ip = 153;
      end

        153 :
      begin                                                                     // add
              localMem[0 + 67] = localMem[0+56] + 1;
              ip = 154;
      end

        154 :
      begin                                                                     // mov
              heapMem[localMem[0+33]*10 + 0] = localMem[0+67];
              ip = 155;
      end

        155 :
      begin                                                                     // mov
              localMem[0 + 68] = heapMem[localMem[0+33]*10 + 6];
              ip = 156;
      end

        156 :
      begin                                                                     // mov
              heapMem[localMem[0+68]*10 + localMem[0+67]] = localMem[0+34];
              ip = 157;
      end

        157 :
      begin                                                                     // jmp
              ip = 297;
      end

        158 :
      begin                                                                     // jmp
              ip = 181;
      end

        159 :
      begin                                                                     // label
              ip = 160;
      end

        160 :
      begin                                                                     // assertNe
            ip = 161;
      end

        161 :
      begin                                                                     // mov
              localMem[0 + 69] = heapMem[localMem[0+33]*10 + 6];
              ip = 162;
      end

        162 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+69] * NArea + i] == localMem[0+26]) localMem[0 + 70] = i + 1;
              end
              ip = 163;
      end

        163 :
      begin                                                                     // subtract
              localMem[0 + 70] = localMem[0+70] - 1;
              ip = 164;
      end

        164 :
      begin                                                                     // mov
              localMem[0 + 71] = heapMem[localMem[0+26]*10 + 4];
              ip = 165;
      end

        165 :
      begin                                                                     // mov
              localMem[0 + 72] = heapMem[localMem[0+71]*10 + localMem[0+31]];
              ip = 166;
      end

        166 :
      begin                                                                     // mov
              localMem[0 + 73] = heapMem[localMem[0+26]*10 + 5];
              ip = 167;
      end

        167 :
      begin                                                                     // mov
              localMem[0 + 74] = heapMem[localMem[0+73]*10 + localMem[0+31]];
              ip = 168;
      end

        168 :
      begin                                                                     // mov
              localMem[0 + 75] = heapMem[localMem[0+26]*10 + 4];
              ip = 169;
      end

        169 :
      begin                                                                     // resize
              arraySizes[localMem[0+75]] = localMem[0+31];
              ip = 170;
      end

        170 :
      begin                                                                     // mov
              localMem[0 + 76] = heapMem[localMem[0+26]*10 + 5];
              ip = 171;
      end

        171 :
      begin                                                                     // resize
              arraySizes[localMem[0+76]] = localMem[0+31];
              ip = 172;
      end

        172 :
      begin                                                                     // mov
              localMem[0 + 77] = heapMem[localMem[0+33]*10 + 4];
              ip = 173;
      end

        173 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+77] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[70]) begin
                  heapMem[NArea * localMem[0+77] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+77] + localMem[70]] = localMem[0+72];                                    // Insert new value
              arraySizes[localMem[0+77]] = arraySizes[localMem[0+77]] + 1;                              // Increase array size
              ip = 174;
      end

        174 :
      begin                                                                     // mov
              localMem[0 + 78] = heapMem[localMem[0+33]*10 + 5];
              ip = 175;
      end

        175 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+78] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[70]) begin
                  heapMem[NArea * localMem[0+78] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+78] + localMem[70]] = localMem[0+74];                                    // Insert new value
              arraySizes[localMem[0+78]] = arraySizes[localMem[0+78]] + 1;                              // Increase array size
              ip = 176;
      end

        176 :
      begin                                                                     // mov
              localMem[0 + 79] = heapMem[localMem[0+33]*10 + 6];
              ip = 177;
      end

        177 :
      begin                                                                     // add
              localMem[0 + 80] = localMem[0+70] + 1;
              ip = 178;
      end

        178 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+79] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[80]) begin
                  heapMem[NArea * localMem[0+79] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+79] + localMem[80]] = localMem[0+34];                                    // Insert new value
              arraySizes[localMem[0+79]] = arraySizes[localMem[0+79]] + 1;                              // Increase array size
              ip = 179;
      end

        179 :
      begin                                                                     // add
              heapMem[localMem[0+33]*10 + 0] = heapMem[localMem[0+33]*10 + 0] + 1;
              ip = 180;
      end

        180 :
      begin                                                                     // jmp
              ip = 297;
      end

        181 :
      begin                                                                     // label
              ip = 182;
      end

        182 :
      begin                                                                     // label
              ip = 183;
      end

        183 :
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
              ip = 184;
      end

        184 :
      begin                                                                     // mov
              heapMem[localMem[0+81]*10 + 0] = localMem[0+31];
              ip = 185;
      end

        185 :
      begin                                                                     // mov
              heapMem[localMem[0+81]*10 + 2] = 0;
              ip = 186;
      end

        186 :
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
              ip = 187;
      end

        187 :
      begin                                                                     // mov
              heapMem[localMem[0+81]*10 + 4] = localMem[0+82];
              ip = 188;
      end

        188 :
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
              ip = 189;
      end

        189 :
      begin                                                                     // mov
              heapMem[localMem[0+81]*10 + 5] = localMem[0+83];
              ip = 190;
      end

        190 :
      begin                                                                     // mov
              heapMem[localMem[0+81]*10 + 6] = 0;
              ip = 191;
      end

        191 :
      begin                                                                     // mov
              heapMem[localMem[0+81]*10 + 3] = localMem[0+29];
              ip = 192;
      end

        192 :
      begin                                                                     // add
              heapMem[localMem[0+29]*10 + 1] = heapMem[localMem[0+29]*10 + 1] + 1;
              ip = 193;
      end

        193 :
      begin                                                                     // mov
              heapMem[localMem[0+81]*10 + 1] = heapMem[localMem[0+29]*10 + 1];
              ip = 194;
      end

        194 :
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
              ip = 195;
      end

        195 :
      begin                                                                     // mov
              heapMem[localMem[0+84]*10 + 0] = localMem[0+31];
              ip = 196;
      end

        196 :
      begin                                                                     // mov
              heapMem[localMem[0+84]*10 + 2] = 0;
              ip = 197;
      end

        197 :
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
              ip = 198;
      end

        198 :
      begin                                                                     // mov
              heapMem[localMem[0+84]*10 + 4] = localMem[0+85];
              ip = 199;
      end

        199 :
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
              ip = 200;
      end

        200 :
      begin                                                                     // mov
              heapMem[localMem[0+84]*10 + 5] = localMem[0+86];
              ip = 201;
      end

        201 :
      begin                                                                     // mov
              heapMem[localMem[0+84]*10 + 6] = 0;
              ip = 202;
      end

        202 :
      begin                                                                     // mov
              heapMem[localMem[0+84]*10 + 3] = localMem[0+29];
              ip = 203;
      end

        203 :
      begin                                                                     // add
              heapMem[localMem[0+29]*10 + 1] = heapMem[localMem[0+29]*10 + 1] + 1;
              ip = 204;
      end

        204 :
      begin                                                                     // mov
              heapMem[localMem[0+84]*10 + 1] = heapMem[localMem[0+29]*10 + 1];
              ip = 205;
      end

        205 :
      begin                                                                     // not
              localMem[0 + 87] = !heapMem[localMem[0+26]*10 + 6];
              ip = 206;
      end

        206 :
      begin                                                                     // jNe
              ip = localMem[0+87] != 0 ? 258 : 207;
      end

        207 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 88] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 88] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 88]] = 0;
              ip = 208;
      end

        208 :
      begin                                                                     // mov
              heapMem[localMem[0+81]*10 + 6] = localMem[0+88];
              ip = 209;
      end

        209 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 89] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 89] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 89]] = 0;
              ip = 210;
      end

        210 :
      begin                                                                     // mov
              heapMem[localMem[0+84]*10 + 6] = localMem[0+89];
              ip = 211;
      end

        211 :
      begin                                                                     // mov
              localMem[0 + 90] = heapMem[localMem[0+26]*10 + 4];
              ip = 212;
      end

        212 :
      begin                                                                     // mov
              localMem[0 + 91] = heapMem[localMem[0+81]*10 + 4];
              ip = 213;
      end

        213 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+31]) begin
                  heapMem[NArea * localMem[0+91] + 0 + i] = heapMem[NArea * localMem[0+90] + 0 + i];
                end
              end
              ip = 214;
      end

        214 :
      begin                                                                     // mov
              localMem[0 + 92] = heapMem[localMem[0+26]*10 + 5];
              ip = 215;
      end

        215 :
      begin                                                                     // mov
              localMem[0 + 93] = heapMem[localMem[0+81]*10 + 5];
              ip = 216;
      end

        216 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+31]) begin
                  heapMem[NArea * localMem[0+93] + 0 + i] = heapMem[NArea * localMem[0+92] + 0 + i];
                end
              end
              ip = 217;
      end

        217 :
      begin                                                                     // mov
              localMem[0 + 94] = heapMem[localMem[0+26]*10 + 6];
              ip = 218;
      end

        218 :
      begin                                                                     // mov
              localMem[0 + 95] = heapMem[localMem[0+81]*10 + 6];
              ip = 219;
      end

        219 :
      begin                                                                     // add
              localMem[0 + 96] = localMem[0+31] + 1;
              ip = 220;
      end

        220 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+96]) begin
                  heapMem[NArea * localMem[0+95] + 0 + i] = heapMem[NArea * localMem[0+94] + 0 + i];
                end
              end
              ip = 221;
      end

        221 :
      begin                                                                     // mov
              localMem[0 + 97] = heapMem[localMem[0+26]*10 + 4];
              ip = 222;
      end

        222 :
      begin                                                                     // mov
              localMem[0 + 98] = heapMem[localMem[0+84]*10 + 4];
              ip = 223;
      end

        223 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+31]) begin
                  heapMem[NArea * localMem[0+98] + 0 + i] = heapMem[NArea * localMem[0+97] + localMem[32] + i];
                end
              end
              ip = 224;
      end

        224 :
      begin                                                                     // mov
              localMem[0 + 99] = heapMem[localMem[0+26]*10 + 5];
              ip = 225;
      end

        225 :
      begin                                                                     // mov
              localMem[0 + 100] = heapMem[localMem[0+84]*10 + 5];
              ip = 226;
      end

        226 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+31]) begin
                  heapMem[NArea * localMem[0+100] + 0 + i] = heapMem[NArea * localMem[0+99] + localMem[32] + i];
                end
              end
              ip = 227;
      end

        227 :
      begin                                                                     // mov
              localMem[0 + 101] = heapMem[localMem[0+26]*10 + 6];
              ip = 228;
      end

        228 :
      begin                                                                     // mov
              localMem[0 + 102] = heapMem[localMem[0+84]*10 + 6];
              ip = 229;
      end

        229 :
      begin                                                                     // add
              localMem[0 + 103] = localMem[0+31] + 1;
              ip = 230;
      end

        230 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+103]) begin
                  heapMem[NArea * localMem[0+102] + 0 + i] = heapMem[NArea * localMem[0+101] + localMem[32] + i];
                end
              end
              ip = 231;
      end

        231 :
      begin                                                                     // mov
              localMem[0 + 104] = heapMem[localMem[0+81]*10 + 0];
              ip = 232;
      end

        232 :
      begin                                                                     // add
              localMem[0 + 105] = localMem[0+104] + 1;
              ip = 233;
      end

        233 :
      begin                                                                     // mov
              localMem[0 + 106] = heapMem[localMem[0+81]*10 + 6];
              ip = 234;
      end

        234 :
      begin                                                                     // label
              ip = 235;
      end

        235 :
      begin                                                                     // mov
              localMem[0 + 107] = 0;
              ip = 236;
      end

        236 :
      begin                                                                     // label
              ip = 237;
      end

        237 :
      begin                                                                     // jGe
              ip = localMem[0+107] >= localMem[0+105] ? 243 : 238;
      end

        238 :
      begin                                                                     // mov
              localMem[0 + 108] = heapMem[localMem[0+106]*10 + localMem[0+107]];
              ip = 239;
      end

        239 :
      begin                                                                     // mov
              heapMem[localMem[0+108]*10 + 2] = localMem[0+81];
              ip = 240;
      end

        240 :
      begin                                                                     // label
              ip = 241;
      end

        241 :
      begin                                                                     // add
              localMem[0 + 107] = localMem[0+107] + 1;
              ip = 242;
      end

        242 :
      begin                                                                     // jmp
              ip = 236;
      end

        243 :
      begin                                                                     // label
              ip = 244;
      end

        244 :
      begin                                                                     // mov
              localMem[0 + 109] = heapMem[localMem[0+84]*10 + 0];
              ip = 245;
      end

        245 :
      begin                                                                     // add
              localMem[0 + 110] = localMem[0+109] + 1;
              ip = 246;
      end

        246 :
      begin                                                                     // mov
              localMem[0 + 111] = heapMem[localMem[0+84]*10 + 6];
              ip = 247;
      end

        247 :
      begin                                                                     // label
              ip = 248;
      end

        248 :
      begin                                                                     // mov
              localMem[0 + 112] = 0;
              ip = 249;
      end

        249 :
      begin                                                                     // label
              ip = 250;
      end

        250 :
      begin                                                                     // jGe
              ip = localMem[0+112] >= localMem[0+110] ? 256 : 251;
      end

        251 :
      begin                                                                     // mov
              localMem[0 + 113] = heapMem[localMem[0+111]*10 + localMem[0+112]];
              ip = 252;
      end

        252 :
      begin                                                                     // mov
              heapMem[localMem[0+113]*10 + 2] = localMem[0+84];
              ip = 253;
      end

        253 :
      begin                                                                     // label
              ip = 254;
      end

        254 :
      begin                                                                     // add
              localMem[0 + 112] = localMem[0+112] + 1;
              ip = 255;
      end

        255 :
      begin                                                                     // jmp
              ip = 249;
      end

        256 :
      begin                                                                     // label
              ip = 257;
      end

        257 :
      begin                                                                     // jmp
              ip = 273;
      end

        258 :
      begin                                                                     // label
              ip = 259;
      end

        259 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 114] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 114] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 114]] = 0;
              ip = 260;
      end

        260 :
      begin                                                                     // mov
              heapMem[localMem[0+26]*10 + 6] = localMem[0+114];
              ip = 261;
      end

        261 :
      begin                                                                     // mov
              localMem[0 + 115] = heapMem[localMem[0+26]*10 + 4];
              ip = 262;
      end

        262 :
      begin                                                                     // mov
              localMem[0 + 116] = heapMem[localMem[0+81]*10 + 4];
              ip = 263;
      end

        263 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+31]) begin
                  heapMem[NArea * localMem[0+116] + 0 + i] = heapMem[NArea * localMem[0+115] + 0 + i];
                end
              end
              ip = 264;
      end

        264 :
      begin                                                                     // mov
              localMem[0 + 117] = heapMem[localMem[0+26]*10 + 5];
              ip = 265;
      end

        265 :
      begin                                                                     // mov
              localMem[0 + 118] = heapMem[localMem[0+81]*10 + 5];
              ip = 266;
      end

        266 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+31]) begin
                  heapMem[NArea * localMem[0+118] + 0 + i] = heapMem[NArea * localMem[0+117] + 0 + i];
                end
              end
              ip = 267;
      end

        267 :
      begin                                                                     // mov
              localMem[0 + 119] = heapMem[localMem[0+26]*10 + 4];
              ip = 268;
      end

        268 :
      begin                                                                     // mov
              localMem[0 + 120] = heapMem[localMem[0+84]*10 + 4];
              ip = 269;
      end

        269 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+31]) begin
                  heapMem[NArea * localMem[0+120] + 0 + i] = heapMem[NArea * localMem[0+119] + localMem[32] + i];
                end
              end
              ip = 270;
      end

        270 :
      begin                                                                     // mov
              localMem[0 + 121] = heapMem[localMem[0+26]*10 + 5];
              ip = 271;
      end

        271 :
      begin                                                                     // mov
              localMem[0 + 122] = heapMem[localMem[0+84]*10 + 5];
              ip = 272;
      end

        272 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+31]) begin
                  heapMem[NArea * localMem[0+122] + 0 + i] = heapMem[NArea * localMem[0+121] + localMem[32] + i];
                end
              end
              ip = 273;
      end

        273 :
      begin                                                                     // label
              ip = 274;
      end

        274 :
      begin                                                                     // mov
              heapMem[localMem[0+81]*10 + 2] = localMem[0+26];
              ip = 275;
      end

        275 :
      begin                                                                     // mov
              heapMem[localMem[0+84]*10 + 2] = localMem[0+26];
              ip = 276;
      end

        276 :
      begin                                                                     // mov
              localMem[0 + 123] = heapMem[localMem[0+26]*10 + 4];
              ip = 277;
      end

        277 :
      begin                                                                     // mov
              localMem[0 + 124] = heapMem[localMem[0+123]*10 + localMem[0+31]];
              ip = 278;
      end

        278 :
      begin                                                                     // mov
              localMem[0 + 125] = heapMem[localMem[0+26]*10 + 5];
              ip = 279;
      end

        279 :
      begin                                                                     // mov
              localMem[0 + 126] = heapMem[localMem[0+125]*10 + localMem[0+31]];
              ip = 280;
      end

        280 :
      begin                                                                     // mov
              localMem[0 + 127] = heapMem[localMem[0+26]*10 + 4];
              ip = 281;
      end

        281 :
      begin                                                                     // mov
              heapMem[localMem[0+127]*10 + 0] = localMem[0+124];
              ip = 282;
      end

        282 :
      begin                                                                     // mov
              localMem[0 + 128] = heapMem[localMem[0+26]*10 + 5];
              ip = 283;
      end

        283 :
      begin                                                                     // mov
              heapMem[localMem[0+128]*10 + 0] = localMem[0+126];
              ip = 284;
      end

        284 :
      begin                                                                     // mov
              localMem[0 + 129] = heapMem[localMem[0+26]*10 + 6];
              ip = 285;
      end

        285 :
      begin                                                                     // mov
              heapMem[localMem[0+129]*10 + 0] = localMem[0+81];
              ip = 286;
      end

        286 :
      begin                                                                     // mov
              localMem[0 + 130] = heapMem[localMem[0+26]*10 + 6];
              ip = 287;
      end

        287 :
      begin                                                                     // mov
              heapMem[localMem[0+130]*10 + 1] = localMem[0+84];
              ip = 288;
      end

        288 :
      begin                                                                     // mov
              heapMem[localMem[0+26]*10 + 0] = 1;
              ip = 289;
      end

        289 :
      begin                                                                     // mov
              localMem[0 + 131] = heapMem[localMem[0+26]*10 + 4];
              ip = 290;
      end

        290 :
      begin                                                                     // resize
              arraySizes[localMem[0+131]] = 1;
              ip = 291;
      end

        291 :
      begin                                                                     // mov
              localMem[0 + 132] = heapMem[localMem[0+26]*10 + 5];
              ip = 292;
      end

        292 :
      begin                                                                     // resize
              arraySizes[localMem[0+132]] = 1;
              ip = 293;
      end

        293 :
      begin                                                                     // mov
              localMem[0 + 133] = heapMem[localMem[0+26]*10 + 6];
              ip = 294;
      end

        294 :
      begin                                                                     // resize
              arraySizes[localMem[0+133]] = 2;
              ip = 295;
      end

        295 :
      begin                                                                     // jmp
              ip = 297;
      end

        296 :
      begin                                                                     // jmp
              ip = 302;
      end

        297 :
      begin                                                                     // label
              ip = 298;
      end

        298 :
      begin                                                                     // mov
              localMem[0 + 27] = 1;
              ip = 299;
      end

        299 :
      begin                                                                     // jmp
              ip = 302;
      end

        300 :
      begin                                                                     // label
              ip = 301;
      end

        301 :
      begin                                                                     // mov
              localMem[0 + 27] = 0;
              ip = 302;
      end

        302 :
      begin                                                                     // label
              ip = 303;
      end

        303 :
      begin                                                                     // label
              ip = 304;
      end

        304 :
      begin                                                                     // label
              ip = 305;
      end

        305 :
      begin                                                                     // mov
              localMem[0 + 134] = 0;
              ip = 306;
      end

        306 :
      begin                                                                     // label
              ip = 307;
      end

        307 :
      begin                                                                     // jGe
              ip = localMem[0+134] >= 99 ? 805 : 308;
      end

        308 :
      begin                                                                     // mov
              localMem[0 + 135] = heapMem[localMem[0+26]*10 + 0];
              ip = 309;
      end

        309 :
      begin                                                                     // subtract
              localMem[0 + 136] = localMem[0+135] - 1;
              ip = 310;
      end

        310 :
      begin                                                                     // mov
              localMem[0 + 137] = heapMem[localMem[0+26]*10 + 4];
              ip = 311;
      end

        311 :
      begin                                                                     // mov
              localMem[0 + 138] = heapMem[localMem[0+137]*10 + localMem[0+136]];
              ip = 312;
      end

        312 :
      begin                                                                     // jLe
              ip = localMem[0+4] <= localMem[0+138] ? 553 : 313;
      end

        313 :
      begin                                                                     // not
              localMem[0 + 139] = !heapMem[localMem[0+26]*10 + 6];
              ip = 314;
      end

        314 :
      begin                                                                     // jEq
              ip = localMem[0+139] == 0 ? 319 : 315;
      end

        315 :
      begin                                                                     // mov
              heapMem[localMem[0+6]*10 + 0] = localMem[0+26];
              ip = 316;
      end

        316 :
      begin                                                                     // mov
              heapMem[localMem[0+6]*10 + 1] = 2;
              ip = 317;
      end

        317 :
      begin                                                                     // subtract
              heapMem[localMem[0+6]*10 + 2] = localMem[0+135] - 1;
              ip = 318;
      end

        318 :
      begin                                                                     // jmp
              ip = 809;
      end

        319 :
      begin                                                                     // label
              ip = 320;
      end

        320 :
      begin                                                                     // mov
              localMem[0 + 140] = heapMem[localMem[0+26]*10 + 6];
              ip = 321;
      end

        321 :
      begin                                                                     // mov
              localMem[0 + 141] = heapMem[localMem[0+140]*10 + localMem[0+135]];
              ip = 322;
      end

        322 :
      begin                                                                     // label
              ip = 323;
      end

        323 :
      begin                                                                     // mov
              localMem[0 + 143] = heapMem[localMem[0+141]*10 + 0];
              ip = 324;
      end

        324 :
      begin                                                                     // mov
              localMem[0 + 144] = heapMem[localMem[0+141]*10 + 3];
              ip = 325;
      end

        325 :
      begin                                                                     // mov
              localMem[0 + 145] = heapMem[localMem[0+144]*10 + 2];
              ip = 326;
      end

        326 :
      begin                                                                     // jLt
              ip = localMem[0+143] <  localMem[0+145] ? 546 : 327;
      end

        327 :
      begin                                                                     // mov
              localMem[0 + 146] = localMem[0+145];
              ip = 328;
      end

        328 :
      begin                                                                     // shiftRight
              localMem[0 + 146] = localMem[0+146] >> 1;
              ip = 329;
      end

        329 :
      begin                                                                     // add
              localMem[0 + 147] = localMem[0+146] + 1;
              ip = 330;
      end

        330 :
      begin                                                                     // mov
              localMem[0 + 148] = heapMem[localMem[0+141]*10 + 2];
              ip = 331;
      end

        331 :
      begin                                                                     // jEq
              ip = localMem[0+148] == 0 ? 428 : 332;
      end

        332 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 149] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 149] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 149]] = 0;
              ip = 333;
      end

        333 :
      begin                                                                     // mov
              heapMem[localMem[0+149]*10 + 0] = localMem[0+146];
              ip = 334;
      end

        334 :
      begin                                                                     // mov
              heapMem[localMem[0+149]*10 + 2] = 0;
              ip = 335;
      end

        335 :
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
              ip = 336;
      end

        336 :
      begin                                                                     // mov
              heapMem[localMem[0+149]*10 + 4] = localMem[0+150];
              ip = 337;
      end

        337 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 151] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 151] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 151]] = 0;
              ip = 338;
      end

        338 :
      begin                                                                     // mov
              heapMem[localMem[0+149]*10 + 5] = localMem[0+151];
              ip = 339;
      end

        339 :
      begin                                                                     // mov
              heapMem[localMem[0+149]*10 + 6] = 0;
              ip = 340;
      end

        340 :
      begin                                                                     // mov
              heapMem[localMem[0+149]*10 + 3] = localMem[0+144];
              ip = 341;
      end

        341 :
      begin                                                                     // add
              heapMem[localMem[0+144]*10 + 1] = heapMem[localMem[0+144]*10 + 1] + 1;
              ip = 342;
      end

        342 :
      begin                                                                     // mov
              heapMem[localMem[0+149]*10 + 1] = heapMem[localMem[0+144]*10 + 1];
              ip = 343;
      end

        343 :
      begin                                                                     // not
              localMem[0 + 152] = !heapMem[localMem[0+141]*10 + 6];
              ip = 344;
      end

        344 :
      begin                                                                     // jNe
              ip = localMem[0+152] != 0 ? 373 : 345;
      end

        345 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 153] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 153] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 153]] = 0;
              ip = 346;
      end

        346 :
      begin                                                                     // mov
              heapMem[localMem[0+149]*10 + 6] = localMem[0+153];
              ip = 347;
      end

        347 :
      begin                                                                     // mov
              localMem[0 + 154] = heapMem[localMem[0+141]*10 + 4];
              ip = 348;
      end

        348 :
      begin                                                                     // mov
              localMem[0 + 155] = heapMem[localMem[0+149]*10 + 4];
              ip = 349;
      end

        349 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+146]) begin
                  heapMem[NArea * localMem[0+155] + 0 + i] = heapMem[NArea * localMem[0+154] + localMem[147] + i];
                end
              end
              ip = 350;
      end

        350 :
      begin                                                                     // mov
              localMem[0 + 156] = heapMem[localMem[0+141]*10 + 5];
              ip = 351;
      end

        351 :
      begin                                                                     // mov
              localMem[0 + 157] = heapMem[localMem[0+149]*10 + 5];
              ip = 352;
      end

        352 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+146]) begin
                  heapMem[NArea * localMem[0+157] + 0 + i] = heapMem[NArea * localMem[0+156] + localMem[147] + i];
                end
              end
              ip = 353;
      end

        353 :
      begin                                                                     // mov
              localMem[0 + 158] = heapMem[localMem[0+141]*10 + 6];
              ip = 354;
      end

        354 :
      begin                                                                     // mov
              localMem[0 + 159] = heapMem[localMem[0+149]*10 + 6];
              ip = 355;
      end

        355 :
      begin                                                                     // add
              localMem[0 + 160] = localMem[0+146] + 1;
              ip = 356;
      end

        356 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+160]) begin
                  heapMem[NArea * localMem[0+159] + 0 + i] = heapMem[NArea * localMem[0+158] + localMem[147] + i];
                end
              end
              ip = 357;
      end

        357 :
      begin                                                                     // mov
              localMem[0 + 161] = heapMem[localMem[0+149]*10 + 0];
              ip = 358;
      end

        358 :
      begin                                                                     // add
              localMem[0 + 162] = localMem[0+161] + 1;
              ip = 359;
      end

        359 :
      begin                                                                     // mov
              localMem[0 + 163] = heapMem[localMem[0+149]*10 + 6];
              ip = 360;
      end

        360 :
      begin                                                                     // label
              ip = 361;
      end

        361 :
      begin                                                                     // mov
              localMem[0 + 164] = 0;
              ip = 362;
      end

        362 :
      begin                                                                     // label
              ip = 363;
      end

        363 :
      begin                                                                     // jGe
              ip = localMem[0+164] >= localMem[0+162] ? 369 : 364;
      end

        364 :
      begin                                                                     // mov
              localMem[0 + 165] = heapMem[localMem[0+163]*10 + localMem[0+164]];
              ip = 365;
      end

        365 :
      begin                                                                     // mov
              heapMem[localMem[0+165]*10 + 2] = localMem[0+149];
              ip = 366;
      end

        366 :
      begin                                                                     // label
              ip = 367;
      end

        367 :
      begin                                                                     // add
              localMem[0 + 164] = localMem[0+164] + 1;
              ip = 368;
      end

        368 :
      begin                                                                     // jmp
              ip = 362;
      end

        369 :
      begin                                                                     // label
              ip = 370;
      end

        370 :
      begin                                                                     // mov
              localMem[0 + 166] = heapMem[localMem[0+141]*10 + 6];
              ip = 371;
      end

        371 :
      begin                                                                     // resize
              arraySizes[localMem[0+166]] = localMem[0+147];
              ip = 372;
      end

        372 :
      begin                                                                     // jmp
              ip = 380;
      end

        373 :
      begin                                                                     // label
              ip = 374;
      end

        374 :
      begin                                                                     // mov
              localMem[0 + 167] = heapMem[localMem[0+141]*10 + 4];
              ip = 375;
      end

        375 :
      begin                                                                     // mov
              localMem[0 + 168] = heapMem[localMem[0+149]*10 + 4];
              ip = 376;
      end

        376 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+146]) begin
                  heapMem[NArea * localMem[0+168] + 0 + i] = heapMem[NArea * localMem[0+167] + localMem[147] + i];
                end
              end
              ip = 377;
      end

        377 :
      begin                                                                     // mov
              localMem[0 + 169] = heapMem[localMem[0+141]*10 + 5];
              ip = 378;
      end

        378 :
      begin                                                                     // mov
              localMem[0 + 170] = heapMem[localMem[0+149]*10 + 5];
              ip = 379;
      end

        379 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+146]) begin
                  heapMem[NArea * localMem[0+170] + 0 + i] = heapMem[NArea * localMem[0+169] + localMem[147] + i];
                end
              end
              ip = 380;
      end

        380 :
      begin                                                                     // label
              ip = 381;
      end

        381 :
      begin                                                                     // mov
              heapMem[localMem[0+141]*10 + 0] = localMem[0+146];
              ip = 382;
      end

        382 :
      begin                                                                     // mov
              heapMem[localMem[0+149]*10 + 2] = localMem[0+148];
              ip = 383;
      end

        383 :
      begin                                                                     // mov
              localMem[0 + 171] = heapMem[localMem[0+148]*10 + 0];
              ip = 384;
      end

        384 :
      begin                                                                     // mov
              localMem[0 + 172] = heapMem[localMem[0+148]*10 + 6];
              ip = 385;
      end

        385 :
      begin                                                                     // mov
              localMem[0 + 173] = heapMem[localMem[0+172]*10 + localMem[0+171]];
              ip = 386;
      end

        386 :
      begin                                                                     // jNe
              ip = localMem[0+173] != localMem[0+141] ? 405 : 387;
      end

        387 :
      begin                                                                     // mov
              localMem[0 + 174] = heapMem[localMem[0+141]*10 + 4];
              ip = 388;
      end

        388 :
      begin                                                                     // mov
              localMem[0 + 175] = heapMem[localMem[0+174]*10 + localMem[0+146]];
              ip = 389;
      end

        389 :
      begin                                                                     // mov
              localMem[0 + 176] = heapMem[localMem[0+148]*10 + 4];
              ip = 390;
      end

        390 :
      begin                                                                     // mov
              heapMem[localMem[0+176]*10 + localMem[0+171]] = localMem[0+175];
              ip = 391;
      end

        391 :
      begin                                                                     // mov
              localMem[0 + 177] = heapMem[localMem[0+141]*10 + 5];
              ip = 392;
      end

        392 :
      begin                                                                     // mov
              localMem[0 + 178] = heapMem[localMem[0+177]*10 + localMem[0+146]];
              ip = 393;
      end

        393 :
      begin                                                                     // mov
              localMem[0 + 179] = heapMem[localMem[0+148]*10 + 5];
              ip = 394;
      end

        394 :
      begin                                                                     // mov
              heapMem[localMem[0+179]*10 + localMem[0+171]] = localMem[0+178];
              ip = 395;
      end

        395 :
      begin                                                                     // mov
              localMem[0 + 180] = heapMem[localMem[0+141]*10 + 4];
              ip = 396;
      end

        396 :
      begin                                                                     // resize
              arraySizes[localMem[0+180]] = localMem[0+146];
              ip = 397;
      end

        397 :
      begin                                                                     // mov
              localMem[0 + 181] = heapMem[localMem[0+141]*10 + 5];
              ip = 398;
      end

        398 :
      begin                                                                     // resize
              arraySizes[localMem[0+181]] = localMem[0+146];
              ip = 399;
      end

        399 :
      begin                                                                     // add
              localMem[0 + 182] = localMem[0+171] + 1;
              ip = 400;
      end

        400 :
      begin                                                                     // mov
              heapMem[localMem[0+148]*10 + 0] = localMem[0+182];
              ip = 401;
      end

        401 :
      begin                                                                     // mov
              localMem[0 + 183] = heapMem[localMem[0+148]*10 + 6];
              ip = 402;
      end

        402 :
      begin                                                                     // mov
              heapMem[localMem[0+183]*10 + localMem[0+182]] = localMem[0+149];
              ip = 403;
      end

        403 :
      begin                                                                     // jmp
              ip = 543;
      end

        404 :
      begin                                                                     // jmp
              ip = 427;
      end

        405 :
      begin                                                                     // label
              ip = 406;
      end

        406 :
      begin                                                                     // assertNe
            ip = 407;
      end

        407 :
      begin                                                                     // mov
              localMem[0 + 184] = heapMem[localMem[0+148]*10 + 6];
              ip = 408;
      end

        408 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+184] * NArea + i] == localMem[0+141]) localMem[0 + 185] = i + 1;
              end
              ip = 409;
      end

        409 :
      begin                                                                     // subtract
              localMem[0 + 185] = localMem[0+185] - 1;
              ip = 410;
      end

        410 :
      begin                                                                     // mov
              localMem[0 + 186] = heapMem[localMem[0+141]*10 + 4];
              ip = 411;
      end

        411 :
      begin                                                                     // mov
              localMem[0 + 187] = heapMem[localMem[0+186]*10 + localMem[0+146]];
              ip = 412;
      end

        412 :
      begin                                                                     // mov
              localMem[0 + 188] = heapMem[localMem[0+141]*10 + 5];
              ip = 413;
      end

        413 :
      begin                                                                     // mov
              localMem[0 + 189] = heapMem[localMem[0+188]*10 + localMem[0+146]];
              ip = 414;
      end

        414 :
      begin                                                                     // mov
              localMem[0 + 190] = heapMem[localMem[0+141]*10 + 4];
              ip = 415;
      end

        415 :
      begin                                                                     // resize
              arraySizes[localMem[0+190]] = localMem[0+146];
              ip = 416;
      end

        416 :
      begin                                                                     // mov
              localMem[0 + 191] = heapMem[localMem[0+141]*10 + 5];
              ip = 417;
      end

        417 :
      begin                                                                     // resize
              arraySizes[localMem[0+191]] = localMem[0+146];
              ip = 418;
      end

        418 :
      begin                                                                     // mov
              localMem[0 + 192] = heapMem[localMem[0+148]*10 + 4];
              ip = 419;
      end

        419 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+192] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[185]) begin
                  heapMem[NArea * localMem[0+192] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+192] + localMem[185]] = localMem[0+187];                                    // Insert new value
              arraySizes[localMem[0+192]] = arraySizes[localMem[0+192]] + 1;                              // Increase array size
              ip = 420;
      end

        420 :
      begin                                                                     // mov
              localMem[0 + 193] = heapMem[localMem[0+148]*10 + 5];
              ip = 421;
      end

        421 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+193] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[185]) begin
                  heapMem[NArea * localMem[0+193] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+193] + localMem[185]] = localMem[0+189];                                    // Insert new value
              arraySizes[localMem[0+193]] = arraySizes[localMem[0+193]] + 1;                              // Increase array size
              ip = 422;
      end

        422 :
      begin                                                                     // mov
              localMem[0 + 194] = heapMem[localMem[0+148]*10 + 6];
              ip = 423;
      end

        423 :
      begin                                                                     // add
              localMem[0 + 195] = localMem[0+185] + 1;
              ip = 424;
      end

        424 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+194] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[195]) begin
                  heapMem[NArea * localMem[0+194] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+194] + localMem[195]] = localMem[0+149];                                    // Insert new value
              arraySizes[localMem[0+194]] = arraySizes[localMem[0+194]] + 1;                              // Increase array size
              ip = 425;
      end

        425 :
      begin                                                                     // add
              heapMem[localMem[0+148]*10 + 0] = heapMem[localMem[0+148]*10 + 0] + 1;
              ip = 426;
      end

        426 :
      begin                                                                     // jmp
              ip = 543;
      end

        427 :
      begin                                                                     // label
              ip = 428;
      end

        428 :
      begin                                                                     // label
              ip = 429;
      end

        429 :
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
              ip = 430;
      end

        430 :
      begin                                                                     // mov
              heapMem[localMem[0+196]*10 + 0] = localMem[0+146];
              ip = 431;
      end

        431 :
      begin                                                                     // mov
              heapMem[localMem[0+196]*10 + 2] = 0;
              ip = 432;
      end

        432 :
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
              ip = 433;
      end

        433 :
      begin                                                                     // mov
              heapMem[localMem[0+196]*10 + 4] = localMem[0+197];
              ip = 434;
      end

        434 :
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
              ip = 435;
      end

        435 :
      begin                                                                     // mov
              heapMem[localMem[0+196]*10 + 5] = localMem[0+198];
              ip = 436;
      end

        436 :
      begin                                                                     // mov
              heapMem[localMem[0+196]*10 + 6] = 0;
              ip = 437;
      end

        437 :
      begin                                                                     // mov
              heapMem[localMem[0+196]*10 + 3] = localMem[0+144];
              ip = 438;
      end

        438 :
      begin                                                                     // add
              heapMem[localMem[0+144]*10 + 1] = heapMem[localMem[0+144]*10 + 1] + 1;
              ip = 439;
      end

        439 :
      begin                                                                     // mov
              heapMem[localMem[0+196]*10 + 1] = heapMem[localMem[0+144]*10 + 1];
              ip = 440;
      end

        440 :
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
              ip = 441;
      end

        441 :
      begin                                                                     // mov
              heapMem[localMem[0+199]*10 + 0] = localMem[0+146];
              ip = 442;
      end

        442 :
      begin                                                                     // mov
              heapMem[localMem[0+199]*10 + 2] = 0;
              ip = 443;
      end

        443 :
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
              ip = 444;
      end

        444 :
      begin                                                                     // mov
              heapMem[localMem[0+199]*10 + 4] = localMem[0+200];
              ip = 445;
      end

        445 :
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
              ip = 446;
      end

        446 :
      begin                                                                     // mov
              heapMem[localMem[0+199]*10 + 5] = localMem[0+201];
              ip = 447;
      end

        447 :
      begin                                                                     // mov
              heapMem[localMem[0+199]*10 + 6] = 0;
              ip = 448;
      end

        448 :
      begin                                                                     // mov
              heapMem[localMem[0+199]*10 + 3] = localMem[0+144];
              ip = 449;
      end

        449 :
      begin                                                                     // add
              heapMem[localMem[0+144]*10 + 1] = heapMem[localMem[0+144]*10 + 1] + 1;
              ip = 450;
      end

        450 :
      begin                                                                     // mov
              heapMem[localMem[0+199]*10 + 1] = heapMem[localMem[0+144]*10 + 1];
              ip = 451;
      end

        451 :
      begin                                                                     // not
              localMem[0 + 202] = !heapMem[localMem[0+141]*10 + 6];
              ip = 452;
      end

        452 :
      begin                                                                     // jNe
              ip = localMem[0+202] != 0 ? 504 : 453;
      end

        453 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 203] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 203] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 203]] = 0;
              ip = 454;
      end

        454 :
      begin                                                                     // mov
              heapMem[localMem[0+196]*10 + 6] = localMem[0+203];
              ip = 455;
      end

        455 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 204] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 204] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 204]] = 0;
              ip = 456;
      end

        456 :
      begin                                                                     // mov
              heapMem[localMem[0+199]*10 + 6] = localMem[0+204];
              ip = 457;
      end

        457 :
      begin                                                                     // mov
              localMem[0 + 205] = heapMem[localMem[0+141]*10 + 4];
              ip = 458;
      end

        458 :
      begin                                                                     // mov
              localMem[0 + 206] = heapMem[localMem[0+196]*10 + 4];
              ip = 459;
      end

        459 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+146]) begin
                  heapMem[NArea * localMem[0+206] + 0 + i] = heapMem[NArea * localMem[0+205] + 0 + i];
                end
              end
              ip = 460;
      end

        460 :
      begin                                                                     // mov
              localMem[0 + 207] = heapMem[localMem[0+141]*10 + 5];
              ip = 461;
      end

        461 :
      begin                                                                     // mov
              localMem[0 + 208] = heapMem[localMem[0+196]*10 + 5];
              ip = 462;
      end

        462 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+146]) begin
                  heapMem[NArea * localMem[0+208] + 0 + i] = heapMem[NArea * localMem[0+207] + 0 + i];
                end
              end
              ip = 463;
      end

        463 :
      begin                                                                     // mov
              localMem[0 + 209] = heapMem[localMem[0+141]*10 + 6];
              ip = 464;
      end

        464 :
      begin                                                                     // mov
              localMem[0 + 210] = heapMem[localMem[0+196]*10 + 6];
              ip = 465;
      end

        465 :
      begin                                                                     // add
              localMem[0 + 211] = localMem[0+146] + 1;
              ip = 466;
      end

        466 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+211]) begin
                  heapMem[NArea * localMem[0+210] + 0 + i] = heapMem[NArea * localMem[0+209] + 0 + i];
                end
              end
              ip = 467;
      end

        467 :
      begin                                                                     // mov
              localMem[0 + 212] = heapMem[localMem[0+141]*10 + 4];
              ip = 468;
      end

        468 :
      begin                                                                     // mov
              localMem[0 + 213] = heapMem[localMem[0+199]*10 + 4];
              ip = 469;
      end

        469 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+146]) begin
                  heapMem[NArea * localMem[0+213] + 0 + i] = heapMem[NArea * localMem[0+212] + localMem[147] + i];
                end
              end
              ip = 470;
      end

        470 :
      begin                                                                     // mov
              localMem[0 + 214] = heapMem[localMem[0+141]*10 + 5];
              ip = 471;
      end

        471 :
      begin                                                                     // mov
              localMem[0 + 215] = heapMem[localMem[0+199]*10 + 5];
              ip = 472;
      end

        472 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+146]) begin
                  heapMem[NArea * localMem[0+215] + 0 + i] = heapMem[NArea * localMem[0+214] + localMem[147] + i];
                end
              end
              ip = 473;
      end

        473 :
      begin                                                                     // mov
              localMem[0 + 216] = heapMem[localMem[0+141]*10 + 6];
              ip = 474;
      end

        474 :
      begin                                                                     // mov
              localMem[0 + 217] = heapMem[localMem[0+199]*10 + 6];
              ip = 475;
      end

        475 :
      begin                                                                     // add
              localMem[0 + 218] = localMem[0+146] + 1;
              ip = 476;
      end

        476 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+218]) begin
                  heapMem[NArea * localMem[0+217] + 0 + i] = heapMem[NArea * localMem[0+216] + localMem[147] + i];
                end
              end
              ip = 477;
      end

        477 :
      begin                                                                     // mov
              localMem[0 + 219] = heapMem[localMem[0+196]*10 + 0];
              ip = 478;
      end

        478 :
      begin                                                                     // add
              localMem[0 + 220] = localMem[0+219] + 1;
              ip = 479;
      end

        479 :
      begin                                                                     // mov
              localMem[0 + 221] = heapMem[localMem[0+196]*10 + 6];
              ip = 480;
      end

        480 :
      begin                                                                     // label
              ip = 481;
      end

        481 :
      begin                                                                     // mov
              localMem[0 + 222] = 0;
              ip = 482;
      end

        482 :
      begin                                                                     // label
              ip = 483;
      end

        483 :
      begin                                                                     // jGe
              ip = localMem[0+222] >= localMem[0+220] ? 489 : 484;
      end

        484 :
      begin                                                                     // mov
              localMem[0 + 223] = heapMem[localMem[0+221]*10 + localMem[0+222]];
              ip = 485;
      end

        485 :
      begin                                                                     // mov
              heapMem[localMem[0+223]*10 + 2] = localMem[0+196];
              ip = 486;
      end

        486 :
      begin                                                                     // label
              ip = 487;
      end

        487 :
      begin                                                                     // add
              localMem[0 + 222] = localMem[0+222] + 1;
              ip = 488;
      end

        488 :
      begin                                                                     // jmp
              ip = 482;
      end

        489 :
      begin                                                                     // label
              ip = 490;
      end

        490 :
      begin                                                                     // mov
              localMem[0 + 224] = heapMem[localMem[0+199]*10 + 0];
              ip = 491;
      end

        491 :
      begin                                                                     // add
              localMem[0 + 225] = localMem[0+224] + 1;
              ip = 492;
      end

        492 :
      begin                                                                     // mov
              localMem[0 + 226] = heapMem[localMem[0+199]*10 + 6];
              ip = 493;
      end

        493 :
      begin                                                                     // label
              ip = 494;
      end

        494 :
      begin                                                                     // mov
              localMem[0 + 227] = 0;
              ip = 495;
      end

        495 :
      begin                                                                     // label
              ip = 496;
      end

        496 :
      begin                                                                     // jGe
              ip = localMem[0+227] >= localMem[0+225] ? 502 : 497;
      end

        497 :
      begin                                                                     // mov
              localMem[0 + 228] = heapMem[localMem[0+226]*10 + localMem[0+227]];
              ip = 498;
      end

        498 :
      begin                                                                     // mov
              heapMem[localMem[0+228]*10 + 2] = localMem[0+199];
              ip = 499;
      end

        499 :
      begin                                                                     // label
              ip = 500;
      end

        500 :
      begin                                                                     // add
              localMem[0 + 227] = localMem[0+227] + 1;
              ip = 501;
      end

        501 :
      begin                                                                     // jmp
              ip = 495;
      end

        502 :
      begin                                                                     // label
              ip = 503;
      end

        503 :
      begin                                                                     // jmp
              ip = 519;
      end

        504 :
      begin                                                                     // label
              ip = 505;
      end

        505 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 229] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 229] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 229]] = 0;
              ip = 506;
      end

        506 :
      begin                                                                     // mov
              heapMem[localMem[0+141]*10 + 6] = localMem[0+229];
              ip = 507;
      end

        507 :
      begin                                                                     // mov
              localMem[0 + 230] = heapMem[localMem[0+141]*10 + 4];
              ip = 508;
      end

        508 :
      begin                                                                     // mov
              localMem[0 + 231] = heapMem[localMem[0+196]*10 + 4];
              ip = 509;
      end

        509 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+146]) begin
                  heapMem[NArea * localMem[0+231] + 0 + i] = heapMem[NArea * localMem[0+230] + 0 + i];
                end
              end
              ip = 510;
      end

        510 :
      begin                                                                     // mov
              localMem[0 + 232] = heapMem[localMem[0+141]*10 + 5];
              ip = 511;
      end

        511 :
      begin                                                                     // mov
              localMem[0 + 233] = heapMem[localMem[0+196]*10 + 5];
              ip = 512;
      end

        512 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+146]) begin
                  heapMem[NArea * localMem[0+233] + 0 + i] = heapMem[NArea * localMem[0+232] + 0 + i];
                end
              end
              ip = 513;
      end

        513 :
      begin                                                                     // mov
              localMem[0 + 234] = heapMem[localMem[0+141]*10 + 4];
              ip = 514;
      end

        514 :
      begin                                                                     // mov
              localMem[0 + 235] = heapMem[localMem[0+199]*10 + 4];
              ip = 515;
      end

        515 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+146]) begin
                  heapMem[NArea * localMem[0+235] + 0 + i] = heapMem[NArea * localMem[0+234] + localMem[147] + i];
                end
              end
              ip = 516;
      end

        516 :
      begin                                                                     // mov
              localMem[0 + 236] = heapMem[localMem[0+141]*10 + 5];
              ip = 517;
      end

        517 :
      begin                                                                     // mov
              localMem[0 + 237] = heapMem[localMem[0+199]*10 + 5];
              ip = 518;
      end

        518 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+146]) begin
                  heapMem[NArea * localMem[0+237] + 0 + i] = heapMem[NArea * localMem[0+236] + localMem[147] + i];
                end
              end
              ip = 519;
      end

        519 :
      begin                                                                     // label
              ip = 520;
      end

        520 :
      begin                                                                     // mov
              heapMem[localMem[0+196]*10 + 2] = localMem[0+141];
              ip = 521;
      end

        521 :
      begin                                                                     // mov
              heapMem[localMem[0+199]*10 + 2] = localMem[0+141];
              ip = 522;
      end

        522 :
      begin                                                                     // mov
              localMem[0 + 238] = heapMem[localMem[0+141]*10 + 4];
              ip = 523;
      end

        523 :
      begin                                                                     // mov
              localMem[0 + 239] = heapMem[localMem[0+238]*10 + localMem[0+146]];
              ip = 524;
      end

        524 :
      begin                                                                     // mov
              localMem[0 + 240] = heapMem[localMem[0+141]*10 + 5];
              ip = 525;
      end

        525 :
      begin                                                                     // mov
              localMem[0 + 241] = heapMem[localMem[0+240]*10 + localMem[0+146]];
              ip = 526;
      end

        526 :
      begin                                                                     // mov
              localMem[0 + 242] = heapMem[localMem[0+141]*10 + 4];
              ip = 527;
      end

        527 :
      begin                                                                     // mov
              heapMem[localMem[0+242]*10 + 0] = localMem[0+239];
              ip = 528;
      end

        528 :
      begin                                                                     // mov
              localMem[0 + 243] = heapMem[localMem[0+141]*10 + 5];
              ip = 529;
      end

        529 :
      begin                                                                     // mov
              heapMem[localMem[0+243]*10 + 0] = localMem[0+241];
              ip = 530;
      end

        530 :
      begin                                                                     // mov
              localMem[0 + 244] = heapMem[localMem[0+141]*10 + 6];
              ip = 531;
      end

        531 :
      begin                                                                     // mov
              heapMem[localMem[0+244]*10 + 0] = localMem[0+196];
              ip = 532;
      end

        532 :
      begin                                                                     // mov
              localMem[0 + 245] = heapMem[localMem[0+141]*10 + 6];
              ip = 533;
      end

        533 :
      begin                                                                     // mov
              heapMem[localMem[0+245]*10 + 1] = localMem[0+199];
              ip = 534;
      end

        534 :
      begin                                                                     // mov
              heapMem[localMem[0+141]*10 + 0] = 1;
              ip = 535;
      end

        535 :
      begin                                                                     // mov
              localMem[0 + 246] = heapMem[localMem[0+141]*10 + 4];
              ip = 536;
      end

        536 :
      begin                                                                     // resize
              arraySizes[localMem[0+246]] = 1;
              ip = 537;
      end

        537 :
      begin                                                                     // mov
              localMem[0 + 247] = heapMem[localMem[0+141]*10 + 5];
              ip = 538;
      end

        538 :
      begin                                                                     // resize
              arraySizes[localMem[0+247]] = 1;
              ip = 539;
      end

        539 :
      begin                                                                     // mov
              localMem[0 + 248] = heapMem[localMem[0+141]*10 + 6];
              ip = 540;
      end

        540 :
      begin                                                                     // resize
              arraySizes[localMem[0+248]] = 2;
              ip = 541;
      end

        541 :
      begin                                                                     // jmp
              ip = 543;
      end

        542 :
      begin                                                                     // jmp
              ip = 548;
      end

        543 :
      begin                                                                     // label
              ip = 544;
      end

        544 :
      begin                                                                     // mov
              localMem[0 + 142] = 1;
              ip = 545;
      end

        545 :
      begin                                                                     // jmp
              ip = 548;
      end

        546 :
      begin                                                                     // label
              ip = 547;
      end

        547 :
      begin                                                                     // mov
              localMem[0 + 142] = 0;
              ip = 548;
      end

        548 :
      begin                                                                     // label
              ip = 549;
      end

        549 :
      begin                                                                     // jNe
              ip = localMem[0+142] != 0 ? 551 : 550;
      end

        550 :
      begin                                                                     // mov
              localMem[0 + 26] = localMem[0+141];
              ip = 551;
      end

        551 :
      begin                                                                     // label
              ip = 552;
      end

        552 :
      begin                                                                     // jmp
              ip = 802;
      end

        553 :
      begin                                                                     // label
              ip = 554;
      end

        554 :
      begin                                                                     // mov
              localMem[0 + 249] = heapMem[localMem[0+26]*10 + 4];
              ip = 555;
      end

        555 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+249] * NArea + i] == localMem[0+4]) localMem[0 + 250] = i + 1;
              end
              ip = 556;
      end

        556 :
      begin                                                                     // jEq
              ip = localMem[0+250] == 0 ? 561 : 557;
      end

        557 :
      begin                                                                     // mov
              heapMem[localMem[0+6]*10 + 0] = localMem[0+26];
              ip = 558;
      end

        558 :
      begin                                                                     // mov
              heapMem[localMem[0+6]*10 + 1] = 1;
              ip = 559;
      end

        559 :
      begin                                                                     // subtract
              heapMem[localMem[0+6]*10 + 2] = localMem[0+250] - 1;
              ip = 560;
      end

        560 :
      begin                                                                     // jmp
              ip = 809;
      end

        561 :
      begin                                                                     // label
              ip = 562;
      end

        562 :
      begin                                                                     // arrayCountLess
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+249] * NArea + i] < localMem[0+4]) j = j + 1;
              end
              localMem[0 + 251] = j;
              ip = 563;
      end

        563 :
      begin                                                                     // not
              localMem[0 + 252] = !heapMem[localMem[0+26]*10 + 6];
              ip = 564;
      end

        564 :
      begin                                                                     // jEq
              ip = localMem[0+252] == 0 ? 569 : 565;
      end

        565 :
      begin                                                                     // mov
              heapMem[localMem[0+6]*10 + 0] = localMem[0+26];
              ip = 566;
      end

        566 :
      begin                                                                     // mov
              heapMem[localMem[0+6]*10 + 1] = 0;
              ip = 567;
      end

        567 :
      begin                                                                     // mov
              heapMem[localMem[0+6]*10 + 2] = localMem[0+251];
              ip = 568;
      end

        568 :
      begin                                                                     // jmp
              ip = 809;
      end

        569 :
      begin                                                                     // label
              ip = 570;
      end

        570 :
      begin                                                                     // mov
              localMem[0 + 253] = heapMem[localMem[0+26]*10 + 6];
              ip = 571;
      end

        571 :
      begin                                                                     // mov
              localMem[0 + 254] = heapMem[localMem[0+253]*10 + localMem[0+251]];
              ip = 572;
      end

        572 :
      begin                                                                     // label
              ip = 573;
      end

        573 :
      begin                                                                     // mov
              localMem[0 + 256] = heapMem[localMem[0+254]*10 + 0];
              ip = 574;
      end

        574 :
      begin                                                                     // mov
              localMem[0 + 257] = heapMem[localMem[0+254]*10 + 3];
              ip = 575;
      end

        575 :
      begin                                                                     // mov
              localMem[0 + 258] = heapMem[localMem[0+257]*10 + 2];
              ip = 576;
      end

        576 :
      begin                                                                     // jLt
              ip = localMem[0+256] <  localMem[0+258] ? 796 : 577;
      end

        577 :
      begin                                                                     // mov
              localMem[0 + 259] = localMem[0+258];
              ip = 578;
      end

        578 :
      begin                                                                     // shiftRight
              localMem[0 + 259] = localMem[0+259] >> 1;
              ip = 579;
      end

        579 :
      begin                                                                     // add
              localMem[0 + 260] = localMem[0+259] + 1;
              ip = 580;
      end

        580 :
      begin                                                                     // mov
              localMem[0 + 261] = heapMem[localMem[0+254]*10 + 2];
              ip = 581;
      end

        581 :
      begin                                                                     // jEq
              ip = localMem[0+261] == 0 ? 678 : 582;
      end

        582 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 262] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 262] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 262]] = 0;
              ip = 583;
      end

        583 :
      begin                                                                     // mov
              heapMem[localMem[0+262]*10 + 0] = localMem[0+259];
              ip = 584;
      end

        584 :
      begin                                                                     // mov
              heapMem[localMem[0+262]*10 + 2] = 0;
              ip = 585;
      end

        585 :
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
              ip = 586;
      end

        586 :
      begin                                                                     // mov
              heapMem[localMem[0+262]*10 + 4] = localMem[0+263];
              ip = 587;
      end

        587 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 264] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 264] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 264]] = 0;
              ip = 588;
      end

        588 :
      begin                                                                     // mov
              heapMem[localMem[0+262]*10 + 5] = localMem[0+264];
              ip = 589;
      end

        589 :
      begin                                                                     // mov
              heapMem[localMem[0+262]*10 + 6] = 0;
              ip = 590;
      end

        590 :
      begin                                                                     // mov
              heapMem[localMem[0+262]*10 + 3] = localMem[0+257];
              ip = 591;
      end

        591 :
      begin                                                                     // add
              heapMem[localMem[0+257]*10 + 1] = heapMem[localMem[0+257]*10 + 1] + 1;
              ip = 592;
      end

        592 :
      begin                                                                     // mov
              heapMem[localMem[0+262]*10 + 1] = heapMem[localMem[0+257]*10 + 1];
              ip = 593;
      end

        593 :
      begin                                                                     // not
              localMem[0 + 265] = !heapMem[localMem[0+254]*10 + 6];
              ip = 594;
      end

        594 :
      begin                                                                     // jNe
              ip = localMem[0+265] != 0 ? 623 : 595;
      end

        595 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 266] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 266] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 266]] = 0;
              ip = 596;
      end

        596 :
      begin                                                                     // mov
              heapMem[localMem[0+262]*10 + 6] = localMem[0+266];
              ip = 597;
      end

        597 :
      begin                                                                     // mov
              localMem[0 + 267] = heapMem[localMem[0+254]*10 + 4];
              ip = 598;
      end

        598 :
      begin                                                                     // mov
              localMem[0 + 268] = heapMem[localMem[0+262]*10 + 4];
              ip = 599;
      end

        599 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+259]) begin
                  heapMem[NArea * localMem[0+268] + 0 + i] = heapMem[NArea * localMem[0+267] + localMem[260] + i];
                end
              end
              ip = 600;
      end

        600 :
      begin                                                                     // mov
              localMem[0 + 269] = heapMem[localMem[0+254]*10 + 5];
              ip = 601;
      end

        601 :
      begin                                                                     // mov
              localMem[0 + 270] = heapMem[localMem[0+262]*10 + 5];
              ip = 602;
      end

        602 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+259]) begin
                  heapMem[NArea * localMem[0+270] + 0 + i] = heapMem[NArea * localMem[0+269] + localMem[260] + i];
                end
              end
              ip = 603;
      end

        603 :
      begin                                                                     // mov
              localMem[0 + 271] = heapMem[localMem[0+254]*10 + 6];
              ip = 604;
      end

        604 :
      begin                                                                     // mov
              localMem[0 + 272] = heapMem[localMem[0+262]*10 + 6];
              ip = 605;
      end

        605 :
      begin                                                                     // add
              localMem[0 + 273] = localMem[0+259] + 1;
              ip = 606;
      end

        606 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+273]) begin
                  heapMem[NArea * localMem[0+272] + 0 + i] = heapMem[NArea * localMem[0+271] + localMem[260] + i];
                end
              end
              ip = 607;
      end

        607 :
      begin                                                                     // mov
              localMem[0 + 274] = heapMem[localMem[0+262]*10 + 0];
              ip = 608;
      end

        608 :
      begin                                                                     // add
              localMem[0 + 275] = localMem[0+274] + 1;
              ip = 609;
      end

        609 :
      begin                                                                     // mov
              localMem[0 + 276] = heapMem[localMem[0+262]*10 + 6];
              ip = 610;
      end

        610 :
      begin                                                                     // label
              ip = 611;
      end

        611 :
      begin                                                                     // mov
              localMem[0 + 277] = 0;
              ip = 612;
      end

        612 :
      begin                                                                     // label
              ip = 613;
      end

        613 :
      begin                                                                     // jGe
              ip = localMem[0+277] >= localMem[0+275] ? 619 : 614;
      end

        614 :
      begin                                                                     // mov
              localMem[0 + 278] = heapMem[localMem[0+276]*10 + localMem[0+277]];
              ip = 615;
      end

        615 :
      begin                                                                     // mov
              heapMem[localMem[0+278]*10 + 2] = localMem[0+262];
              ip = 616;
      end

        616 :
      begin                                                                     // label
              ip = 617;
      end

        617 :
      begin                                                                     // add
              localMem[0 + 277] = localMem[0+277] + 1;
              ip = 618;
      end

        618 :
      begin                                                                     // jmp
              ip = 612;
      end

        619 :
      begin                                                                     // label
              ip = 620;
      end

        620 :
      begin                                                                     // mov
              localMem[0 + 279] = heapMem[localMem[0+254]*10 + 6];
              ip = 621;
      end

        621 :
      begin                                                                     // resize
              arraySizes[localMem[0+279]] = localMem[0+260];
              ip = 622;
      end

        622 :
      begin                                                                     // jmp
              ip = 630;
      end

        623 :
      begin                                                                     // label
              ip = 624;
      end

        624 :
      begin                                                                     // mov
              localMem[0 + 280] = heapMem[localMem[0+254]*10 + 4];
              ip = 625;
      end

        625 :
      begin                                                                     // mov
              localMem[0 + 281] = heapMem[localMem[0+262]*10 + 4];
              ip = 626;
      end

        626 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+259]) begin
                  heapMem[NArea * localMem[0+281] + 0 + i] = heapMem[NArea * localMem[0+280] + localMem[260] + i];
                end
              end
              ip = 627;
      end

        627 :
      begin                                                                     // mov
              localMem[0 + 282] = heapMem[localMem[0+254]*10 + 5];
              ip = 628;
      end

        628 :
      begin                                                                     // mov
              localMem[0 + 283] = heapMem[localMem[0+262]*10 + 5];
              ip = 629;
      end

        629 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+259]) begin
                  heapMem[NArea * localMem[0+283] + 0 + i] = heapMem[NArea * localMem[0+282] + localMem[260] + i];
                end
              end
              ip = 630;
      end

        630 :
      begin                                                                     // label
              ip = 631;
      end

        631 :
      begin                                                                     // mov
              heapMem[localMem[0+254]*10 + 0] = localMem[0+259];
              ip = 632;
      end

        632 :
      begin                                                                     // mov
              heapMem[localMem[0+262]*10 + 2] = localMem[0+261];
              ip = 633;
      end

        633 :
      begin                                                                     // mov
              localMem[0 + 284] = heapMem[localMem[0+261]*10 + 0];
              ip = 634;
      end

        634 :
      begin                                                                     // mov
              localMem[0 + 285] = heapMem[localMem[0+261]*10 + 6];
              ip = 635;
      end

        635 :
      begin                                                                     // mov
              localMem[0 + 286] = heapMem[localMem[0+285]*10 + localMem[0+284]];
              ip = 636;
      end

        636 :
      begin                                                                     // jNe
              ip = localMem[0+286] != localMem[0+254] ? 655 : 637;
      end

        637 :
      begin                                                                     // mov
              localMem[0 + 287] = heapMem[localMem[0+254]*10 + 4];
              ip = 638;
      end

        638 :
      begin                                                                     // mov
              localMem[0 + 288] = heapMem[localMem[0+287]*10 + localMem[0+259]];
              ip = 639;
      end

        639 :
      begin                                                                     // mov
              localMem[0 + 289] = heapMem[localMem[0+261]*10 + 4];
              ip = 640;
      end

        640 :
      begin                                                                     // mov
              heapMem[localMem[0+289]*10 + localMem[0+284]] = localMem[0+288];
              ip = 641;
      end

        641 :
      begin                                                                     // mov
              localMem[0 + 290] = heapMem[localMem[0+254]*10 + 5];
              ip = 642;
      end

        642 :
      begin                                                                     // mov
              localMem[0 + 291] = heapMem[localMem[0+290]*10 + localMem[0+259]];
              ip = 643;
      end

        643 :
      begin                                                                     // mov
              localMem[0 + 292] = heapMem[localMem[0+261]*10 + 5];
              ip = 644;
      end

        644 :
      begin                                                                     // mov
              heapMem[localMem[0+292]*10 + localMem[0+284]] = localMem[0+291];
              ip = 645;
      end

        645 :
      begin                                                                     // mov
              localMem[0 + 293] = heapMem[localMem[0+254]*10 + 4];
              ip = 646;
      end

        646 :
      begin                                                                     // resize
              arraySizes[localMem[0+293]] = localMem[0+259];
              ip = 647;
      end

        647 :
      begin                                                                     // mov
              localMem[0 + 294] = heapMem[localMem[0+254]*10 + 5];
              ip = 648;
      end

        648 :
      begin                                                                     // resize
              arraySizes[localMem[0+294]] = localMem[0+259];
              ip = 649;
      end

        649 :
      begin                                                                     // add
              localMem[0 + 295] = localMem[0+284] + 1;
              ip = 650;
      end

        650 :
      begin                                                                     // mov
              heapMem[localMem[0+261]*10 + 0] = localMem[0+295];
              ip = 651;
      end

        651 :
      begin                                                                     // mov
              localMem[0 + 296] = heapMem[localMem[0+261]*10 + 6];
              ip = 652;
      end

        652 :
      begin                                                                     // mov
              heapMem[localMem[0+296]*10 + localMem[0+295]] = localMem[0+262];
              ip = 653;
      end

        653 :
      begin                                                                     // jmp
              ip = 793;
      end

        654 :
      begin                                                                     // jmp
              ip = 677;
      end

        655 :
      begin                                                                     // label
              ip = 656;
      end

        656 :
      begin                                                                     // assertNe
            ip = 657;
      end

        657 :
      begin                                                                     // mov
              localMem[0 + 297] = heapMem[localMem[0+261]*10 + 6];
              ip = 658;
      end

        658 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+297] * NArea + i] == localMem[0+254]) localMem[0 + 298] = i + 1;
              end
              ip = 659;
      end

        659 :
      begin                                                                     // subtract
              localMem[0 + 298] = localMem[0+298] - 1;
              ip = 660;
      end

        660 :
      begin                                                                     // mov
              localMem[0 + 299] = heapMem[localMem[0+254]*10 + 4];
              ip = 661;
      end

        661 :
      begin                                                                     // mov
              localMem[0 + 300] = heapMem[localMem[0+299]*10 + localMem[0+259]];
              ip = 662;
      end

        662 :
      begin                                                                     // mov
              localMem[0 + 301] = heapMem[localMem[0+254]*10 + 5];
              ip = 663;
      end

        663 :
      begin                                                                     // mov
              localMem[0 + 302] = heapMem[localMem[0+301]*10 + localMem[0+259]];
              ip = 664;
      end

        664 :
      begin                                                                     // mov
              localMem[0 + 303] = heapMem[localMem[0+254]*10 + 4];
              ip = 665;
      end

        665 :
      begin                                                                     // resize
              arraySizes[localMem[0+303]] = localMem[0+259];
              ip = 666;
      end

        666 :
      begin                                                                     // mov
              localMem[0 + 304] = heapMem[localMem[0+254]*10 + 5];
              ip = 667;
      end

        667 :
      begin                                                                     // resize
              arraySizes[localMem[0+304]] = localMem[0+259];
              ip = 668;
      end

        668 :
      begin                                                                     // mov
              localMem[0 + 305] = heapMem[localMem[0+261]*10 + 4];
              ip = 669;
      end

        669 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+305] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[298]) begin
                  heapMem[NArea * localMem[0+305] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+305] + localMem[298]] = localMem[0+300];                                    // Insert new value
              arraySizes[localMem[0+305]] = arraySizes[localMem[0+305]] + 1;                              // Increase array size
              ip = 670;
      end

        670 :
      begin                                                                     // mov
              localMem[0 + 306] = heapMem[localMem[0+261]*10 + 5];
              ip = 671;
      end

        671 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+306] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[298]) begin
                  heapMem[NArea * localMem[0+306] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+306] + localMem[298]] = localMem[0+302];                                    // Insert new value
              arraySizes[localMem[0+306]] = arraySizes[localMem[0+306]] + 1;                              // Increase array size
              ip = 672;
      end

        672 :
      begin                                                                     // mov
              localMem[0 + 307] = heapMem[localMem[0+261]*10 + 6];
              ip = 673;
      end

        673 :
      begin                                                                     // add
              localMem[0 + 308] = localMem[0+298] + 1;
              ip = 674;
      end

        674 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+307] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[308]) begin
                  heapMem[NArea * localMem[0+307] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+307] + localMem[308]] = localMem[0+262];                                    // Insert new value
              arraySizes[localMem[0+307]] = arraySizes[localMem[0+307]] + 1;                              // Increase array size
              ip = 675;
      end

        675 :
      begin                                                                     // add
              heapMem[localMem[0+261]*10 + 0] = heapMem[localMem[0+261]*10 + 0] + 1;
              ip = 676;
      end

        676 :
      begin                                                                     // jmp
              ip = 793;
      end

        677 :
      begin                                                                     // label
              ip = 678;
      end

        678 :
      begin                                                                     // label
              ip = 679;
      end

        679 :
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
              ip = 680;
      end

        680 :
      begin                                                                     // mov
              heapMem[localMem[0+309]*10 + 0] = localMem[0+259];
              ip = 681;
      end

        681 :
      begin                                                                     // mov
              heapMem[localMem[0+309]*10 + 2] = 0;
              ip = 682;
      end

        682 :
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
              ip = 683;
      end

        683 :
      begin                                                                     // mov
              heapMem[localMem[0+309]*10 + 4] = localMem[0+310];
              ip = 684;
      end

        684 :
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
              ip = 685;
      end

        685 :
      begin                                                                     // mov
              heapMem[localMem[0+309]*10 + 5] = localMem[0+311];
              ip = 686;
      end

        686 :
      begin                                                                     // mov
              heapMem[localMem[0+309]*10 + 6] = 0;
              ip = 687;
      end

        687 :
      begin                                                                     // mov
              heapMem[localMem[0+309]*10 + 3] = localMem[0+257];
              ip = 688;
      end

        688 :
      begin                                                                     // add
              heapMem[localMem[0+257]*10 + 1] = heapMem[localMem[0+257]*10 + 1] + 1;
              ip = 689;
      end

        689 :
      begin                                                                     // mov
              heapMem[localMem[0+309]*10 + 1] = heapMem[localMem[0+257]*10 + 1];
              ip = 690;
      end

        690 :
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
              ip = 691;
      end

        691 :
      begin                                                                     // mov
              heapMem[localMem[0+312]*10 + 0] = localMem[0+259];
              ip = 692;
      end

        692 :
      begin                                                                     // mov
              heapMem[localMem[0+312]*10 + 2] = 0;
              ip = 693;
      end

        693 :
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
              ip = 694;
      end

        694 :
      begin                                                                     // mov
              heapMem[localMem[0+312]*10 + 4] = localMem[0+313];
              ip = 695;
      end

        695 :
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
              ip = 696;
      end

        696 :
      begin                                                                     // mov
              heapMem[localMem[0+312]*10 + 5] = localMem[0+314];
              ip = 697;
      end

        697 :
      begin                                                                     // mov
              heapMem[localMem[0+312]*10 + 6] = 0;
              ip = 698;
      end

        698 :
      begin                                                                     // mov
              heapMem[localMem[0+312]*10 + 3] = localMem[0+257];
              ip = 699;
      end

        699 :
      begin                                                                     // add
              heapMem[localMem[0+257]*10 + 1] = heapMem[localMem[0+257]*10 + 1] + 1;
              ip = 700;
      end

        700 :
      begin                                                                     // mov
              heapMem[localMem[0+312]*10 + 1] = heapMem[localMem[0+257]*10 + 1];
              ip = 701;
      end

        701 :
      begin                                                                     // not
              localMem[0 + 315] = !heapMem[localMem[0+254]*10 + 6];
              ip = 702;
      end

        702 :
      begin                                                                     // jNe
              ip = localMem[0+315] != 0 ? 754 : 703;
      end

        703 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 316] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 316] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 316]] = 0;
              ip = 704;
      end

        704 :
      begin                                                                     // mov
              heapMem[localMem[0+309]*10 + 6] = localMem[0+316];
              ip = 705;
      end

        705 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 317] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 317] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 317]] = 0;
              ip = 706;
      end

        706 :
      begin                                                                     // mov
              heapMem[localMem[0+312]*10 + 6] = localMem[0+317];
              ip = 707;
      end

        707 :
      begin                                                                     // mov
              localMem[0 + 318] = heapMem[localMem[0+254]*10 + 4];
              ip = 708;
      end

        708 :
      begin                                                                     // mov
              localMem[0 + 319] = heapMem[localMem[0+309]*10 + 4];
              ip = 709;
      end

        709 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+259]) begin
                  heapMem[NArea * localMem[0+319] + 0 + i] = heapMem[NArea * localMem[0+318] + 0 + i];
                end
              end
              ip = 710;
      end

        710 :
      begin                                                                     // mov
              localMem[0 + 320] = heapMem[localMem[0+254]*10 + 5];
              ip = 711;
      end

        711 :
      begin                                                                     // mov
              localMem[0 + 321] = heapMem[localMem[0+309]*10 + 5];
              ip = 712;
      end

        712 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+259]) begin
                  heapMem[NArea * localMem[0+321] + 0 + i] = heapMem[NArea * localMem[0+320] + 0 + i];
                end
              end
              ip = 713;
      end

        713 :
      begin                                                                     // mov
              localMem[0 + 322] = heapMem[localMem[0+254]*10 + 6];
              ip = 714;
      end

        714 :
      begin                                                                     // mov
              localMem[0 + 323] = heapMem[localMem[0+309]*10 + 6];
              ip = 715;
      end

        715 :
      begin                                                                     // add
              localMem[0 + 324] = localMem[0+259] + 1;
              ip = 716;
      end

        716 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+324]) begin
                  heapMem[NArea * localMem[0+323] + 0 + i] = heapMem[NArea * localMem[0+322] + 0 + i];
                end
              end
              ip = 717;
      end

        717 :
      begin                                                                     // mov
              localMem[0 + 325] = heapMem[localMem[0+254]*10 + 4];
              ip = 718;
      end

        718 :
      begin                                                                     // mov
              localMem[0 + 326] = heapMem[localMem[0+312]*10 + 4];
              ip = 719;
      end

        719 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+259]) begin
                  heapMem[NArea * localMem[0+326] + 0 + i] = heapMem[NArea * localMem[0+325] + localMem[260] + i];
                end
              end
              ip = 720;
      end

        720 :
      begin                                                                     // mov
              localMem[0 + 327] = heapMem[localMem[0+254]*10 + 5];
              ip = 721;
      end

        721 :
      begin                                                                     // mov
              localMem[0 + 328] = heapMem[localMem[0+312]*10 + 5];
              ip = 722;
      end

        722 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+259]) begin
                  heapMem[NArea * localMem[0+328] + 0 + i] = heapMem[NArea * localMem[0+327] + localMem[260] + i];
                end
              end
              ip = 723;
      end

        723 :
      begin                                                                     // mov
              localMem[0 + 329] = heapMem[localMem[0+254]*10 + 6];
              ip = 724;
      end

        724 :
      begin                                                                     // mov
              localMem[0 + 330] = heapMem[localMem[0+312]*10 + 6];
              ip = 725;
      end

        725 :
      begin                                                                     // add
              localMem[0 + 331] = localMem[0+259] + 1;
              ip = 726;
      end

        726 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+331]) begin
                  heapMem[NArea * localMem[0+330] + 0 + i] = heapMem[NArea * localMem[0+329] + localMem[260] + i];
                end
              end
              ip = 727;
      end

        727 :
      begin                                                                     // mov
              localMem[0 + 332] = heapMem[localMem[0+309]*10 + 0];
              ip = 728;
      end

        728 :
      begin                                                                     // add
              localMem[0 + 333] = localMem[0+332] + 1;
              ip = 729;
      end

        729 :
      begin                                                                     // mov
              localMem[0 + 334] = heapMem[localMem[0+309]*10 + 6];
              ip = 730;
      end

        730 :
      begin                                                                     // label
              ip = 731;
      end

        731 :
      begin                                                                     // mov
              localMem[0 + 335] = 0;
              ip = 732;
      end

        732 :
      begin                                                                     // label
              ip = 733;
      end

        733 :
      begin                                                                     // jGe
              ip = localMem[0+335] >= localMem[0+333] ? 739 : 734;
      end

        734 :
      begin                                                                     // mov
              localMem[0 + 336] = heapMem[localMem[0+334]*10 + localMem[0+335]];
              ip = 735;
      end

        735 :
      begin                                                                     // mov
              heapMem[localMem[0+336]*10 + 2] = localMem[0+309];
              ip = 736;
      end

        736 :
      begin                                                                     // label
              ip = 737;
      end

        737 :
      begin                                                                     // add
              localMem[0 + 335] = localMem[0+335] + 1;
              ip = 738;
      end

        738 :
      begin                                                                     // jmp
              ip = 732;
      end

        739 :
      begin                                                                     // label
              ip = 740;
      end

        740 :
      begin                                                                     // mov
              localMem[0 + 337] = heapMem[localMem[0+312]*10 + 0];
              ip = 741;
      end

        741 :
      begin                                                                     // add
              localMem[0 + 338] = localMem[0+337] + 1;
              ip = 742;
      end

        742 :
      begin                                                                     // mov
              localMem[0 + 339] = heapMem[localMem[0+312]*10 + 6];
              ip = 743;
      end

        743 :
      begin                                                                     // label
              ip = 744;
      end

        744 :
      begin                                                                     // mov
              localMem[0 + 340] = 0;
              ip = 745;
      end

        745 :
      begin                                                                     // label
              ip = 746;
      end

        746 :
      begin                                                                     // jGe
              ip = localMem[0+340] >= localMem[0+338] ? 752 : 747;
      end

        747 :
      begin                                                                     // mov
              localMem[0 + 341] = heapMem[localMem[0+339]*10 + localMem[0+340]];
              ip = 748;
      end

        748 :
      begin                                                                     // mov
              heapMem[localMem[0+341]*10 + 2] = localMem[0+312];
              ip = 749;
      end

        749 :
      begin                                                                     // label
              ip = 750;
      end

        750 :
      begin                                                                     // add
              localMem[0 + 340] = localMem[0+340] + 1;
              ip = 751;
      end

        751 :
      begin                                                                     // jmp
              ip = 745;
      end

        752 :
      begin                                                                     // label
              ip = 753;
      end

        753 :
      begin                                                                     // jmp
              ip = 769;
      end

        754 :
      begin                                                                     // label
              ip = 755;
      end

        755 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 342] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 342] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 342]] = 0;
              ip = 756;
      end

        756 :
      begin                                                                     // mov
              heapMem[localMem[0+254]*10 + 6] = localMem[0+342];
              ip = 757;
      end

        757 :
      begin                                                                     // mov
              localMem[0 + 343] = heapMem[localMem[0+254]*10 + 4];
              ip = 758;
      end

        758 :
      begin                                                                     // mov
              localMem[0 + 344] = heapMem[localMem[0+309]*10 + 4];
              ip = 759;
      end

        759 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+259]) begin
                  heapMem[NArea * localMem[0+344] + 0 + i] = heapMem[NArea * localMem[0+343] + 0 + i];
                end
              end
              ip = 760;
      end

        760 :
      begin                                                                     // mov
              localMem[0 + 345] = heapMem[localMem[0+254]*10 + 5];
              ip = 761;
      end

        761 :
      begin                                                                     // mov
              localMem[0 + 346] = heapMem[localMem[0+309]*10 + 5];
              ip = 762;
      end

        762 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+259]) begin
                  heapMem[NArea * localMem[0+346] + 0 + i] = heapMem[NArea * localMem[0+345] + 0 + i];
                end
              end
              ip = 763;
      end

        763 :
      begin                                                                     // mov
              localMem[0 + 347] = heapMem[localMem[0+254]*10 + 4];
              ip = 764;
      end

        764 :
      begin                                                                     // mov
              localMem[0 + 348] = heapMem[localMem[0+312]*10 + 4];
              ip = 765;
      end

        765 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+259]) begin
                  heapMem[NArea * localMem[0+348] + 0 + i] = heapMem[NArea * localMem[0+347] + localMem[260] + i];
                end
              end
              ip = 766;
      end

        766 :
      begin                                                                     // mov
              localMem[0 + 349] = heapMem[localMem[0+254]*10 + 5];
              ip = 767;
      end

        767 :
      begin                                                                     // mov
              localMem[0 + 350] = heapMem[localMem[0+312]*10 + 5];
              ip = 768;
      end

        768 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+259]) begin
                  heapMem[NArea * localMem[0+350] + 0 + i] = heapMem[NArea * localMem[0+349] + localMem[260] + i];
                end
              end
              ip = 769;
      end

        769 :
      begin                                                                     // label
              ip = 770;
      end

        770 :
      begin                                                                     // mov
              heapMem[localMem[0+309]*10 + 2] = localMem[0+254];
              ip = 771;
      end

        771 :
      begin                                                                     // mov
              heapMem[localMem[0+312]*10 + 2] = localMem[0+254];
              ip = 772;
      end

        772 :
      begin                                                                     // mov
              localMem[0 + 351] = heapMem[localMem[0+254]*10 + 4];
              ip = 773;
      end

        773 :
      begin                                                                     // mov
              localMem[0 + 352] = heapMem[localMem[0+351]*10 + localMem[0+259]];
              ip = 774;
      end

        774 :
      begin                                                                     // mov
              localMem[0 + 353] = heapMem[localMem[0+254]*10 + 5];
              ip = 775;
      end

        775 :
      begin                                                                     // mov
              localMem[0 + 354] = heapMem[localMem[0+353]*10 + localMem[0+259]];
              ip = 776;
      end

        776 :
      begin                                                                     // mov
              localMem[0 + 355] = heapMem[localMem[0+254]*10 + 4];
              ip = 777;
      end

        777 :
      begin                                                                     // mov
              heapMem[localMem[0+355]*10 + 0] = localMem[0+352];
              ip = 778;
      end

        778 :
      begin                                                                     // mov
              localMem[0 + 356] = heapMem[localMem[0+254]*10 + 5];
              ip = 779;
      end

        779 :
      begin                                                                     // mov
              heapMem[localMem[0+356]*10 + 0] = localMem[0+354];
              ip = 780;
      end

        780 :
      begin                                                                     // mov
              localMem[0 + 357] = heapMem[localMem[0+254]*10 + 6];
              ip = 781;
      end

        781 :
      begin                                                                     // mov
              heapMem[localMem[0+357]*10 + 0] = localMem[0+309];
              ip = 782;
      end

        782 :
      begin                                                                     // mov
              localMem[0 + 358] = heapMem[localMem[0+254]*10 + 6];
              ip = 783;
      end

        783 :
      begin                                                                     // mov
              heapMem[localMem[0+358]*10 + 1] = localMem[0+312];
              ip = 784;
      end

        784 :
      begin                                                                     // mov
              heapMem[localMem[0+254]*10 + 0] = 1;
              ip = 785;
      end

        785 :
      begin                                                                     // mov
              localMem[0 + 359] = heapMem[localMem[0+254]*10 + 4];
              ip = 786;
      end

        786 :
      begin                                                                     // resize
              arraySizes[localMem[0+359]] = 1;
              ip = 787;
      end

        787 :
      begin                                                                     // mov
              localMem[0 + 360] = heapMem[localMem[0+254]*10 + 5];
              ip = 788;
      end

        788 :
      begin                                                                     // resize
              arraySizes[localMem[0+360]] = 1;
              ip = 789;
      end

        789 :
      begin                                                                     // mov
              localMem[0 + 361] = heapMem[localMem[0+254]*10 + 6];
              ip = 790;
      end

        790 :
      begin                                                                     // resize
              arraySizes[localMem[0+361]] = 2;
              ip = 791;
      end

        791 :
      begin                                                                     // jmp
              ip = 793;
      end

        792 :
      begin                                                                     // jmp
              ip = 798;
      end

        793 :
      begin                                                                     // label
              ip = 794;
      end

        794 :
      begin                                                                     // mov
              localMem[0 + 255] = 1;
              ip = 795;
      end

        795 :
      begin                                                                     // jmp
              ip = 798;
      end

        796 :
      begin                                                                     // label
              ip = 797;
      end

        797 :
      begin                                                                     // mov
              localMem[0 + 255] = 0;
              ip = 798;
      end

        798 :
      begin                                                                     // label
              ip = 799;
      end

        799 :
      begin                                                                     // jNe
              ip = localMem[0+255] != 0 ? 801 : 800;
      end

        800 :
      begin                                                                     // mov
              localMem[0 + 26] = localMem[0+254];
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
      begin                                                                     // add
              localMem[0 + 134] = localMem[0+134] + 1;
              ip = 804;
      end

        804 :
      begin                                                                     // jmp
              ip = 306;
      end

        805 :
      begin                                                                     // label
              ip = 806;
      end

        806 :
      begin                                                                     // assert
            ip = 807;
      end

        807 :
      begin                                                                     // label
              ip = 808;
      end

        808 :
      begin                                                                     // label
              ip = 809;
      end

        809 :
      begin                                                                     // label
              ip = 810;
      end

        810 :
      begin                                                                     // mov
              localMem[0 + 362] = heapMem[localMem[0+6]*10 + 0];
              ip = 811;
      end

        811 :
      begin                                                                     // mov
              localMem[0 + 363] = heapMem[localMem[0+6]*10 + 1];
              ip = 812;
      end

        812 :
      begin                                                                     // mov
              localMem[0 + 364] = heapMem[localMem[0+6]*10 + 2];
              ip = 813;
      end

        813 :
      begin                                                                     // jNe
              ip = localMem[0+363] != 1 ? 817 : 814;
      end

        814 :
      begin                                                                     // mov
              localMem[0 + 365] = heapMem[localMem[0+362]*10 + 5];
              ip = 815;
      end

        815 :
      begin                                                                     // mov
              heapMem[localMem[0+365]*10 + localMem[0+364]] = localMem[0+5];
              ip = 816;
      end

        816 :
      begin                                                                     // jmp
              ip = 1063;
      end

        817 :
      begin                                                                     // label
              ip = 818;
      end

        818 :
      begin                                                                     // jNe
              ip = localMem[0+363] != 2 ? 826 : 819;
      end

        819 :
      begin                                                                     // add
              localMem[0 + 366] = localMem[0+364] + 1;
              ip = 820;
      end

        820 :
      begin                                                                     // mov
              localMem[0 + 367] = heapMem[localMem[0+362]*10 + 4];
              ip = 821;
      end

        821 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+367] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[366]) begin
                  heapMem[NArea * localMem[0+367] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+367] + localMem[366]] = localMem[0+4];                                    // Insert new value
              arraySizes[localMem[0+367]] = arraySizes[localMem[0+367]] + 1;                              // Increase array size
              ip = 822;
      end

        822 :
      begin                                                                     // mov
              localMem[0 + 368] = heapMem[localMem[0+362]*10 + 5];
              ip = 823;
      end

        823 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+368] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[366]) begin
                  heapMem[NArea * localMem[0+368] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+368] + localMem[366]] = localMem[0+5];                                    // Insert new value
              arraySizes[localMem[0+368]] = arraySizes[localMem[0+368]] + 1;                              // Increase array size
              ip = 824;
      end

        824 :
      begin                                                                     // add
              heapMem[localMem[0+362]*10 + 0] = heapMem[localMem[0+362]*10 + 0] + 1;
              ip = 825;
      end

        825 :
      begin                                                                     // jmp
              ip = 832;
      end

        826 :
      begin                                                                     // label
              ip = 827;
      end

        827 :
      begin                                                                     // mov
              localMem[0 + 369] = heapMem[localMem[0+362]*10 + 4];
              ip = 828;
      end

        828 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+369] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[364]) begin
                  heapMem[NArea * localMem[0+369] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+369] + localMem[364]] = localMem[0+4];                                    // Insert new value
              arraySizes[localMem[0+369]] = arraySizes[localMem[0+369]] + 1;                              // Increase array size
              ip = 829;
      end

        829 :
      begin                                                                     // mov
              localMem[0 + 370] = heapMem[localMem[0+362]*10 + 5];
              ip = 830;
      end

        830 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+370] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[364]) begin
                  heapMem[NArea * localMem[0+370] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+370] + localMem[364]] = localMem[0+5];                                    // Insert new value
              arraySizes[localMem[0+370]] = arraySizes[localMem[0+370]] + 1;                              // Increase array size
              ip = 831;
      end

        831 :
      begin                                                                     // add
              heapMem[localMem[0+362]*10 + 0] = heapMem[localMem[0+362]*10 + 0] + 1;
              ip = 832;
      end

        832 :
      begin                                                                     // label
              ip = 833;
      end

        833 :
      begin                                                                     // add
              heapMem[localMem[0+3]*10 + 0] = heapMem[localMem[0+3]*10 + 0] + 1;
              ip = 834;
      end

        834 :
      begin                                                                     // label
              ip = 835;
      end

        835 :
      begin                                                                     // mov
              localMem[0 + 372] = heapMem[localMem[0+362]*10 + 0];
              ip = 836;
      end

        836 :
      begin                                                                     // mov
              localMem[0 + 373] = heapMem[localMem[0+362]*10 + 3];
              ip = 837;
      end

        837 :
      begin                                                                     // mov
              localMem[0 + 374] = heapMem[localMem[0+373]*10 + 2];
              ip = 838;
      end

        838 :
      begin                                                                     // jLt
              ip = localMem[0+372] <  localMem[0+374] ? 1058 : 839;
      end

        839 :
      begin                                                                     // mov
              localMem[0 + 375] = localMem[0+374];
              ip = 840;
      end

        840 :
      begin                                                                     // shiftRight
              localMem[0 + 375] = localMem[0+375] >> 1;
              ip = 841;
      end

        841 :
      begin                                                                     // add
              localMem[0 + 376] = localMem[0+375] + 1;
              ip = 842;
      end

        842 :
      begin                                                                     // mov
              localMem[0 + 377] = heapMem[localMem[0+362]*10 + 2];
              ip = 843;
      end

        843 :
      begin                                                                     // jEq
              ip = localMem[0+377] == 0 ? 940 : 844;
      end

        844 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 378] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 378] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 378]] = 0;
              ip = 845;
      end

        845 :
      begin                                                                     // mov
              heapMem[localMem[0+378]*10 + 0] = localMem[0+375];
              ip = 846;
      end

        846 :
      begin                                                                     // mov
              heapMem[localMem[0+378]*10 + 2] = 0;
              ip = 847;
      end

        847 :
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
              ip = 848;
      end

        848 :
      begin                                                                     // mov
              heapMem[localMem[0+378]*10 + 4] = localMem[0+379];
              ip = 849;
      end

        849 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 380] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 380] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 380]] = 0;
              ip = 850;
      end

        850 :
      begin                                                                     // mov
              heapMem[localMem[0+378]*10 + 5] = localMem[0+380];
              ip = 851;
      end

        851 :
      begin                                                                     // mov
              heapMem[localMem[0+378]*10 + 6] = 0;
              ip = 852;
      end

        852 :
      begin                                                                     // mov
              heapMem[localMem[0+378]*10 + 3] = localMem[0+373];
              ip = 853;
      end

        853 :
      begin                                                                     // add
              heapMem[localMem[0+373]*10 + 1] = heapMem[localMem[0+373]*10 + 1] + 1;
              ip = 854;
      end

        854 :
      begin                                                                     // mov
              heapMem[localMem[0+378]*10 + 1] = heapMem[localMem[0+373]*10 + 1];
              ip = 855;
      end

        855 :
      begin                                                                     // not
              localMem[0 + 381] = !heapMem[localMem[0+362]*10 + 6];
              ip = 856;
      end

        856 :
      begin                                                                     // jNe
              ip = localMem[0+381] != 0 ? 885 : 857;
      end

        857 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 382] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 382] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 382]] = 0;
              ip = 858;
      end

        858 :
      begin                                                                     // mov
              heapMem[localMem[0+378]*10 + 6] = localMem[0+382];
              ip = 859;
      end

        859 :
      begin                                                                     // mov
              localMem[0 + 383] = heapMem[localMem[0+362]*10 + 4];
              ip = 860;
      end

        860 :
      begin                                                                     // mov
              localMem[0 + 384] = heapMem[localMem[0+378]*10 + 4];
              ip = 861;
      end

        861 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+375]) begin
                  heapMem[NArea * localMem[0+384] + 0 + i] = heapMem[NArea * localMem[0+383] + localMem[376] + i];
                end
              end
              ip = 862;
      end

        862 :
      begin                                                                     // mov
              localMem[0 + 385] = heapMem[localMem[0+362]*10 + 5];
              ip = 863;
      end

        863 :
      begin                                                                     // mov
              localMem[0 + 386] = heapMem[localMem[0+378]*10 + 5];
              ip = 864;
      end

        864 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+375]) begin
                  heapMem[NArea * localMem[0+386] + 0 + i] = heapMem[NArea * localMem[0+385] + localMem[376] + i];
                end
              end
              ip = 865;
      end

        865 :
      begin                                                                     // mov
              localMem[0 + 387] = heapMem[localMem[0+362]*10 + 6];
              ip = 866;
      end

        866 :
      begin                                                                     // mov
              localMem[0 + 388] = heapMem[localMem[0+378]*10 + 6];
              ip = 867;
      end

        867 :
      begin                                                                     // add
              localMem[0 + 389] = localMem[0+375] + 1;
              ip = 868;
      end

        868 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+389]) begin
                  heapMem[NArea * localMem[0+388] + 0 + i] = heapMem[NArea * localMem[0+387] + localMem[376] + i];
                end
              end
              ip = 869;
      end

        869 :
      begin                                                                     // mov
              localMem[0 + 390] = heapMem[localMem[0+378]*10 + 0];
              ip = 870;
      end

        870 :
      begin                                                                     // add
              localMem[0 + 391] = localMem[0+390] + 1;
              ip = 871;
      end

        871 :
      begin                                                                     // mov
              localMem[0 + 392] = heapMem[localMem[0+378]*10 + 6];
              ip = 872;
      end

        872 :
      begin                                                                     // label
              ip = 873;
      end

        873 :
      begin                                                                     // mov
              localMem[0 + 393] = 0;
              ip = 874;
      end

        874 :
      begin                                                                     // label
              ip = 875;
      end

        875 :
      begin                                                                     // jGe
              ip = localMem[0+393] >= localMem[0+391] ? 881 : 876;
      end

        876 :
      begin                                                                     // mov
              localMem[0 + 394] = heapMem[localMem[0+392]*10 + localMem[0+393]];
              ip = 877;
      end

        877 :
      begin                                                                     // mov
              heapMem[localMem[0+394]*10 + 2] = localMem[0+378];
              ip = 878;
      end

        878 :
      begin                                                                     // label
              ip = 879;
      end

        879 :
      begin                                                                     // add
              localMem[0 + 393] = localMem[0+393] + 1;
              ip = 880;
      end

        880 :
      begin                                                                     // jmp
              ip = 874;
      end

        881 :
      begin                                                                     // label
              ip = 882;
      end

        882 :
      begin                                                                     // mov
              localMem[0 + 395] = heapMem[localMem[0+362]*10 + 6];
              ip = 883;
      end

        883 :
      begin                                                                     // resize
              arraySizes[localMem[0+395]] = localMem[0+376];
              ip = 884;
      end

        884 :
      begin                                                                     // jmp
              ip = 892;
      end

        885 :
      begin                                                                     // label
              ip = 886;
      end

        886 :
      begin                                                                     // mov
              localMem[0 + 396] = heapMem[localMem[0+362]*10 + 4];
              ip = 887;
      end

        887 :
      begin                                                                     // mov
              localMem[0 + 397] = heapMem[localMem[0+378]*10 + 4];
              ip = 888;
      end

        888 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+375]) begin
                  heapMem[NArea * localMem[0+397] + 0 + i] = heapMem[NArea * localMem[0+396] + localMem[376] + i];
                end
              end
              ip = 889;
      end

        889 :
      begin                                                                     // mov
              localMem[0 + 398] = heapMem[localMem[0+362]*10 + 5];
              ip = 890;
      end

        890 :
      begin                                                                     // mov
              localMem[0 + 399] = heapMem[localMem[0+378]*10 + 5];
              ip = 891;
      end

        891 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+375]) begin
                  heapMem[NArea * localMem[0+399] + 0 + i] = heapMem[NArea * localMem[0+398] + localMem[376] + i];
                end
              end
              ip = 892;
      end

        892 :
      begin                                                                     // label
              ip = 893;
      end

        893 :
      begin                                                                     // mov
              heapMem[localMem[0+362]*10 + 0] = localMem[0+375];
              ip = 894;
      end

        894 :
      begin                                                                     // mov
              heapMem[localMem[0+378]*10 + 2] = localMem[0+377];
              ip = 895;
      end

        895 :
      begin                                                                     // mov
              localMem[0 + 400] = heapMem[localMem[0+377]*10 + 0];
              ip = 896;
      end

        896 :
      begin                                                                     // mov
              localMem[0 + 401] = heapMem[localMem[0+377]*10 + 6];
              ip = 897;
      end

        897 :
      begin                                                                     // mov
              localMem[0 + 402] = heapMem[localMem[0+401]*10 + localMem[0+400]];
              ip = 898;
      end

        898 :
      begin                                                                     // jNe
              ip = localMem[0+402] != localMem[0+362] ? 917 : 899;
      end

        899 :
      begin                                                                     // mov
              localMem[0 + 403] = heapMem[localMem[0+362]*10 + 4];
              ip = 900;
      end

        900 :
      begin                                                                     // mov
              localMem[0 + 404] = heapMem[localMem[0+403]*10 + localMem[0+375]];
              ip = 901;
      end

        901 :
      begin                                                                     // mov
              localMem[0 + 405] = heapMem[localMem[0+377]*10 + 4];
              ip = 902;
      end

        902 :
      begin                                                                     // mov
              heapMem[localMem[0+405]*10 + localMem[0+400]] = localMem[0+404];
              ip = 903;
      end

        903 :
      begin                                                                     // mov
              localMem[0 + 406] = heapMem[localMem[0+362]*10 + 5];
              ip = 904;
      end

        904 :
      begin                                                                     // mov
              localMem[0 + 407] = heapMem[localMem[0+406]*10 + localMem[0+375]];
              ip = 905;
      end

        905 :
      begin                                                                     // mov
              localMem[0 + 408] = heapMem[localMem[0+377]*10 + 5];
              ip = 906;
      end

        906 :
      begin                                                                     // mov
              heapMem[localMem[0+408]*10 + localMem[0+400]] = localMem[0+407];
              ip = 907;
      end

        907 :
      begin                                                                     // mov
              localMem[0 + 409] = heapMem[localMem[0+362]*10 + 4];
              ip = 908;
      end

        908 :
      begin                                                                     // resize
              arraySizes[localMem[0+409]] = localMem[0+375];
              ip = 909;
      end

        909 :
      begin                                                                     // mov
              localMem[0 + 410] = heapMem[localMem[0+362]*10 + 5];
              ip = 910;
      end

        910 :
      begin                                                                     // resize
              arraySizes[localMem[0+410]] = localMem[0+375];
              ip = 911;
      end

        911 :
      begin                                                                     // add
              localMem[0 + 411] = localMem[0+400] + 1;
              ip = 912;
      end

        912 :
      begin                                                                     // mov
              heapMem[localMem[0+377]*10 + 0] = localMem[0+411];
              ip = 913;
      end

        913 :
      begin                                                                     // mov
              localMem[0 + 412] = heapMem[localMem[0+377]*10 + 6];
              ip = 914;
      end

        914 :
      begin                                                                     // mov
              heapMem[localMem[0+412]*10 + localMem[0+411]] = localMem[0+378];
              ip = 915;
      end

        915 :
      begin                                                                     // jmp
              ip = 1055;
      end

        916 :
      begin                                                                     // jmp
              ip = 939;
      end

        917 :
      begin                                                                     // label
              ip = 918;
      end

        918 :
      begin                                                                     // assertNe
            ip = 919;
      end

        919 :
      begin                                                                     // mov
              localMem[0 + 413] = heapMem[localMem[0+377]*10 + 6];
              ip = 920;
      end

        920 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+413] * NArea + i] == localMem[0+362]) localMem[0 + 414] = i + 1;
              end
              ip = 921;
      end

        921 :
      begin                                                                     // subtract
              localMem[0 + 414] = localMem[0+414] - 1;
              ip = 922;
      end

        922 :
      begin                                                                     // mov
              localMem[0 + 415] = heapMem[localMem[0+362]*10 + 4];
              ip = 923;
      end

        923 :
      begin                                                                     // mov
              localMem[0 + 416] = heapMem[localMem[0+415]*10 + localMem[0+375]];
              ip = 924;
      end

        924 :
      begin                                                                     // mov
              localMem[0 + 417] = heapMem[localMem[0+362]*10 + 5];
              ip = 925;
      end

        925 :
      begin                                                                     // mov
              localMem[0 + 418] = heapMem[localMem[0+417]*10 + localMem[0+375]];
              ip = 926;
      end

        926 :
      begin                                                                     // mov
              localMem[0 + 419] = heapMem[localMem[0+362]*10 + 4];
              ip = 927;
      end

        927 :
      begin                                                                     // resize
              arraySizes[localMem[0+419]] = localMem[0+375];
              ip = 928;
      end

        928 :
      begin                                                                     // mov
              localMem[0 + 420] = heapMem[localMem[0+362]*10 + 5];
              ip = 929;
      end

        929 :
      begin                                                                     // resize
              arraySizes[localMem[0+420]] = localMem[0+375];
              ip = 930;
      end

        930 :
      begin                                                                     // mov
              localMem[0 + 421] = heapMem[localMem[0+377]*10 + 4];
              ip = 931;
      end

        931 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+421] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[414]) begin
                  heapMem[NArea * localMem[0+421] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+421] + localMem[414]] = localMem[0+416];                                    // Insert new value
              arraySizes[localMem[0+421]] = arraySizes[localMem[0+421]] + 1;                              // Increase array size
              ip = 932;
      end

        932 :
      begin                                                                     // mov
              localMem[0 + 422] = heapMem[localMem[0+377]*10 + 5];
              ip = 933;
      end

        933 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+422] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[414]) begin
                  heapMem[NArea * localMem[0+422] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+422] + localMem[414]] = localMem[0+418];                                    // Insert new value
              arraySizes[localMem[0+422]] = arraySizes[localMem[0+422]] + 1;                              // Increase array size
              ip = 934;
      end

        934 :
      begin                                                                     // mov
              localMem[0 + 423] = heapMem[localMem[0+377]*10 + 6];
              ip = 935;
      end

        935 :
      begin                                                                     // add
              localMem[0 + 424] = localMem[0+414] + 1;
              ip = 936;
      end

        936 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+423] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[424]) begin
                  heapMem[NArea * localMem[0+423] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+423] + localMem[424]] = localMem[0+378];                                    // Insert new value
              arraySizes[localMem[0+423]] = arraySizes[localMem[0+423]] + 1;                              // Increase array size
              ip = 937;
      end

        937 :
      begin                                                                     // add
              heapMem[localMem[0+377]*10 + 0] = heapMem[localMem[0+377]*10 + 0] + 1;
              ip = 938;
      end

        938 :
      begin                                                                     // jmp
              ip = 1055;
      end

        939 :
      begin                                                                     // label
              ip = 940;
      end

        940 :
      begin                                                                     // label
              ip = 941;
      end

        941 :
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
              ip = 942;
      end

        942 :
      begin                                                                     // mov
              heapMem[localMem[0+425]*10 + 0] = localMem[0+375];
              ip = 943;
      end

        943 :
      begin                                                                     // mov
              heapMem[localMem[0+425]*10 + 2] = 0;
              ip = 944;
      end

        944 :
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
              ip = 945;
      end

        945 :
      begin                                                                     // mov
              heapMem[localMem[0+425]*10 + 4] = localMem[0+426];
              ip = 946;
      end

        946 :
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
              ip = 947;
      end

        947 :
      begin                                                                     // mov
              heapMem[localMem[0+425]*10 + 5] = localMem[0+427];
              ip = 948;
      end

        948 :
      begin                                                                     // mov
              heapMem[localMem[0+425]*10 + 6] = 0;
              ip = 949;
      end

        949 :
      begin                                                                     // mov
              heapMem[localMem[0+425]*10 + 3] = localMem[0+373];
              ip = 950;
      end

        950 :
      begin                                                                     // add
              heapMem[localMem[0+373]*10 + 1] = heapMem[localMem[0+373]*10 + 1] + 1;
              ip = 951;
      end

        951 :
      begin                                                                     // mov
              heapMem[localMem[0+425]*10 + 1] = heapMem[localMem[0+373]*10 + 1];
              ip = 952;
      end

        952 :
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
              ip = 953;
      end

        953 :
      begin                                                                     // mov
              heapMem[localMem[0+428]*10 + 0] = localMem[0+375];
              ip = 954;
      end

        954 :
      begin                                                                     // mov
              heapMem[localMem[0+428]*10 + 2] = 0;
              ip = 955;
      end

        955 :
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
              ip = 956;
      end

        956 :
      begin                                                                     // mov
              heapMem[localMem[0+428]*10 + 4] = localMem[0+429];
              ip = 957;
      end

        957 :
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
              ip = 958;
      end

        958 :
      begin                                                                     // mov
              heapMem[localMem[0+428]*10 + 5] = localMem[0+430];
              ip = 959;
      end

        959 :
      begin                                                                     // mov
              heapMem[localMem[0+428]*10 + 6] = 0;
              ip = 960;
      end

        960 :
      begin                                                                     // mov
              heapMem[localMem[0+428]*10 + 3] = localMem[0+373];
              ip = 961;
      end

        961 :
      begin                                                                     // add
              heapMem[localMem[0+373]*10 + 1] = heapMem[localMem[0+373]*10 + 1] + 1;
              ip = 962;
      end

        962 :
      begin                                                                     // mov
              heapMem[localMem[0+428]*10 + 1] = heapMem[localMem[0+373]*10 + 1];
              ip = 963;
      end

        963 :
      begin                                                                     // not
              localMem[0 + 431] = !heapMem[localMem[0+362]*10 + 6];
              ip = 964;
      end

        964 :
      begin                                                                     // jNe
              ip = localMem[0+431] != 0 ? 1016 : 965;
      end

        965 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 432] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 432] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 432]] = 0;
              ip = 966;
      end

        966 :
      begin                                                                     // mov
              heapMem[localMem[0+425]*10 + 6] = localMem[0+432];
              ip = 967;
      end

        967 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 433] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 433] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 433]] = 0;
              ip = 968;
      end

        968 :
      begin                                                                     // mov
              heapMem[localMem[0+428]*10 + 6] = localMem[0+433];
              ip = 969;
      end

        969 :
      begin                                                                     // mov
              localMem[0 + 434] = heapMem[localMem[0+362]*10 + 4];
              ip = 970;
      end

        970 :
      begin                                                                     // mov
              localMem[0 + 435] = heapMem[localMem[0+425]*10 + 4];
              ip = 971;
      end

        971 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+375]) begin
                  heapMem[NArea * localMem[0+435] + 0 + i] = heapMem[NArea * localMem[0+434] + 0 + i];
                end
              end
              ip = 972;
      end

        972 :
      begin                                                                     // mov
              localMem[0 + 436] = heapMem[localMem[0+362]*10 + 5];
              ip = 973;
      end

        973 :
      begin                                                                     // mov
              localMem[0 + 437] = heapMem[localMem[0+425]*10 + 5];
              ip = 974;
      end

        974 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+375]) begin
                  heapMem[NArea * localMem[0+437] + 0 + i] = heapMem[NArea * localMem[0+436] + 0 + i];
                end
              end
              ip = 975;
      end

        975 :
      begin                                                                     // mov
              localMem[0 + 438] = heapMem[localMem[0+362]*10 + 6];
              ip = 976;
      end

        976 :
      begin                                                                     // mov
              localMem[0 + 439] = heapMem[localMem[0+425]*10 + 6];
              ip = 977;
      end

        977 :
      begin                                                                     // add
              localMem[0 + 440] = localMem[0+375] + 1;
              ip = 978;
      end

        978 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+440]) begin
                  heapMem[NArea * localMem[0+439] + 0 + i] = heapMem[NArea * localMem[0+438] + 0 + i];
                end
              end
              ip = 979;
      end

        979 :
      begin                                                                     // mov
              localMem[0 + 441] = heapMem[localMem[0+362]*10 + 4];
              ip = 980;
      end

        980 :
      begin                                                                     // mov
              localMem[0 + 442] = heapMem[localMem[0+428]*10 + 4];
              ip = 981;
      end

        981 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+375]) begin
                  heapMem[NArea * localMem[0+442] + 0 + i] = heapMem[NArea * localMem[0+441] + localMem[376] + i];
                end
              end
              ip = 982;
      end

        982 :
      begin                                                                     // mov
              localMem[0 + 443] = heapMem[localMem[0+362]*10 + 5];
              ip = 983;
      end

        983 :
      begin                                                                     // mov
              localMem[0 + 444] = heapMem[localMem[0+428]*10 + 5];
              ip = 984;
      end

        984 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+375]) begin
                  heapMem[NArea * localMem[0+444] + 0 + i] = heapMem[NArea * localMem[0+443] + localMem[376] + i];
                end
              end
              ip = 985;
      end

        985 :
      begin                                                                     // mov
              localMem[0 + 445] = heapMem[localMem[0+362]*10 + 6];
              ip = 986;
      end

        986 :
      begin                                                                     // mov
              localMem[0 + 446] = heapMem[localMem[0+428]*10 + 6];
              ip = 987;
      end

        987 :
      begin                                                                     // add
              localMem[0 + 447] = localMem[0+375] + 1;
              ip = 988;
      end

        988 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+447]) begin
                  heapMem[NArea * localMem[0+446] + 0 + i] = heapMem[NArea * localMem[0+445] + localMem[376] + i];
                end
              end
              ip = 989;
      end

        989 :
      begin                                                                     // mov
              localMem[0 + 448] = heapMem[localMem[0+425]*10 + 0];
              ip = 990;
      end

        990 :
      begin                                                                     // add
              localMem[0 + 449] = localMem[0+448] + 1;
              ip = 991;
      end

        991 :
      begin                                                                     // mov
              localMem[0 + 450] = heapMem[localMem[0+425]*10 + 6];
              ip = 992;
      end

        992 :
      begin                                                                     // label
              ip = 993;
      end

        993 :
      begin                                                                     // mov
              localMem[0 + 451] = 0;
              ip = 994;
      end

        994 :
      begin                                                                     // label
              ip = 995;
      end

        995 :
      begin                                                                     // jGe
              ip = localMem[0+451] >= localMem[0+449] ? 1001 : 996;
      end

        996 :
      begin                                                                     // mov
              localMem[0 + 452] = heapMem[localMem[0+450]*10 + localMem[0+451]];
              ip = 997;
      end

        997 :
      begin                                                                     // mov
              heapMem[localMem[0+452]*10 + 2] = localMem[0+425];
              ip = 998;
      end

        998 :
      begin                                                                     // label
              ip = 999;
      end

        999 :
      begin                                                                     // add
              localMem[0 + 451] = localMem[0+451] + 1;
              ip = 1000;
      end

       1000 :
      begin                                                                     // jmp
              ip = 994;
      end

       1001 :
      begin                                                                     // label
              ip = 1002;
      end

       1002 :
      begin                                                                     // mov
              localMem[0 + 453] = heapMem[localMem[0+428]*10 + 0];
              ip = 1003;
      end

       1003 :
      begin                                                                     // add
              localMem[0 + 454] = localMem[0+453] + 1;
              ip = 1004;
      end

       1004 :
      begin                                                                     // mov
              localMem[0 + 455] = heapMem[localMem[0+428]*10 + 6];
              ip = 1005;
      end

       1005 :
      begin                                                                     // label
              ip = 1006;
      end

       1006 :
      begin                                                                     // mov
              localMem[0 + 456] = 0;
              ip = 1007;
      end

       1007 :
      begin                                                                     // label
              ip = 1008;
      end

       1008 :
      begin                                                                     // jGe
              ip = localMem[0+456] >= localMem[0+454] ? 1014 : 1009;
      end

       1009 :
      begin                                                                     // mov
              localMem[0 + 457] = heapMem[localMem[0+455]*10 + localMem[0+456]];
              ip = 1010;
      end

       1010 :
      begin                                                                     // mov
              heapMem[localMem[0+457]*10 + 2] = localMem[0+428];
              ip = 1011;
      end

       1011 :
      begin                                                                     // label
              ip = 1012;
      end

       1012 :
      begin                                                                     // add
              localMem[0 + 456] = localMem[0+456] + 1;
              ip = 1013;
      end

       1013 :
      begin                                                                     // jmp
              ip = 1007;
      end

       1014 :
      begin                                                                     // label
              ip = 1015;
      end

       1015 :
      begin                                                                     // jmp
              ip = 1031;
      end

       1016 :
      begin                                                                     // label
              ip = 1017;
      end

       1017 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 458] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 458] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 458]] = 0;
              ip = 1018;
      end

       1018 :
      begin                                                                     // mov
              heapMem[localMem[0+362]*10 + 6] = localMem[0+458];
              ip = 1019;
      end

       1019 :
      begin                                                                     // mov
              localMem[0 + 459] = heapMem[localMem[0+362]*10 + 4];
              ip = 1020;
      end

       1020 :
      begin                                                                     // mov
              localMem[0 + 460] = heapMem[localMem[0+425]*10 + 4];
              ip = 1021;
      end

       1021 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+375]) begin
                  heapMem[NArea * localMem[0+460] + 0 + i] = heapMem[NArea * localMem[0+459] + 0 + i];
                end
              end
              ip = 1022;
      end

       1022 :
      begin                                                                     // mov
              localMem[0 + 461] = heapMem[localMem[0+362]*10 + 5];
              ip = 1023;
      end

       1023 :
      begin                                                                     // mov
              localMem[0 + 462] = heapMem[localMem[0+425]*10 + 5];
              ip = 1024;
      end

       1024 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+375]) begin
                  heapMem[NArea * localMem[0+462] + 0 + i] = heapMem[NArea * localMem[0+461] + 0 + i];
                end
              end
              ip = 1025;
      end

       1025 :
      begin                                                                     // mov
              localMem[0 + 463] = heapMem[localMem[0+362]*10 + 4];
              ip = 1026;
      end

       1026 :
      begin                                                                     // mov
              localMem[0 + 464] = heapMem[localMem[0+428]*10 + 4];
              ip = 1027;
      end

       1027 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+375]) begin
                  heapMem[NArea * localMem[0+464] + 0 + i] = heapMem[NArea * localMem[0+463] + localMem[376] + i];
                end
              end
              ip = 1028;
      end

       1028 :
      begin                                                                     // mov
              localMem[0 + 465] = heapMem[localMem[0+362]*10 + 5];
              ip = 1029;
      end

       1029 :
      begin                                                                     // mov
              localMem[0 + 466] = heapMem[localMem[0+428]*10 + 5];
              ip = 1030;
      end

       1030 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+375]) begin
                  heapMem[NArea * localMem[0+466] + 0 + i] = heapMem[NArea * localMem[0+465] + localMem[376] + i];
                end
              end
              ip = 1031;
      end

       1031 :
      begin                                                                     // label
              ip = 1032;
      end

       1032 :
      begin                                                                     // mov
              heapMem[localMem[0+425]*10 + 2] = localMem[0+362];
              ip = 1033;
      end

       1033 :
      begin                                                                     // mov
              heapMem[localMem[0+428]*10 + 2] = localMem[0+362];
              ip = 1034;
      end

       1034 :
      begin                                                                     // mov
              localMem[0 + 467] = heapMem[localMem[0+362]*10 + 4];
              ip = 1035;
      end

       1035 :
      begin                                                                     // mov
              localMem[0 + 468] = heapMem[localMem[0+467]*10 + localMem[0+375]];
              ip = 1036;
      end

       1036 :
      begin                                                                     // mov
              localMem[0 + 469] = heapMem[localMem[0+362]*10 + 5];
              ip = 1037;
      end

       1037 :
      begin                                                                     // mov
              localMem[0 + 470] = heapMem[localMem[0+469]*10 + localMem[0+375]];
              ip = 1038;
      end

       1038 :
      begin                                                                     // mov
              localMem[0 + 471] = heapMem[localMem[0+362]*10 + 4];
              ip = 1039;
      end

       1039 :
      begin                                                                     // mov
              heapMem[localMem[0+471]*10 + 0] = localMem[0+468];
              ip = 1040;
      end

       1040 :
      begin                                                                     // mov
              localMem[0 + 472] = heapMem[localMem[0+362]*10 + 5];
              ip = 1041;
      end

       1041 :
      begin                                                                     // mov
              heapMem[localMem[0+472]*10 + 0] = localMem[0+470];
              ip = 1042;
      end

       1042 :
      begin                                                                     // mov
              localMem[0 + 473] = heapMem[localMem[0+362]*10 + 6];
              ip = 1043;
      end

       1043 :
      begin                                                                     // mov
              heapMem[localMem[0+473]*10 + 0] = localMem[0+425];
              ip = 1044;
      end

       1044 :
      begin                                                                     // mov
              localMem[0 + 474] = heapMem[localMem[0+362]*10 + 6];
              ip = 1045;
      end

       1045 :
      begin                                                                     // mov
              heapMem[localMem[0+474]*10 + 1] = localMem[0+428];
              ip = 1046;
      end

       1046 :
      begin                                                                     // mov
              heapMem[localMem[0+362]*10 + 0] = 1;
              ip = 1047;
      end

       1047 :
      begin                                                                     // mov
              localMem[0 + 475] = heapMem[localMem[0+362]*10 + 4];
              ip = 1048;
      end

       1048 :
      begin                                                                     // resize
              arraySizes[localMem[0+475]] = 1;
              ip = 1049;
      end

       1049 :
      begin                                                                     // mov
              localMem[0 + 476] = heapMem[localMem[0+362]*10 + 5];
              ip = 1050;
      end

       1050 :
      begin                                                                     // resize
              arraySizes[localMem[0+476]] = 1;
              ip = 1051;
      end

       1051 :
      begin                                                                     // mov
              localMem[0 + 477] = heapMem[localMem[0+362]*10 + 6];
              ip = 1052;
      end

       1052 :
      begin                                                                     // resize
              arraySizes[localMem[0+477]] = 2;
              ip = 1053;
      end

       1053 :
      begin                                                                     // jmp
              ip = 1055;
      end

       1054 :
      begin                                                                     // jmp
              ip = 1060;
      end

       1055 :
      begin                                                                     // label
              ip = 1056;
      end

       1056 :
      begin                                                                     // mov
              localMem[0 + 371] = 1;
              ip = 1057;
      end

       1057 :
      begin                                                                     // jmp
              ip = 1060;
      end

       1058 :
      begin                                                                     // label
              ip = 1059;
      end

       1059 :
      begin                                                                     // mov
              localMem[0 + 371] = 0;
              ip = 1060;
      end

       1060 :
      begin                                                                     // label
              ip = 1061;
      end

       1061 :
      begin                                                                     // label
              ip = 1062;
      end

       1062 :
      begin                                                                     // label
              ip = 1063;
      end

       1063 :
      begin                                                                     // label
              ip = 1064;
      end

       1064 :
      begin                                                                     // free
              freedArrays[freedArraysTop] = localMem[0+6];
              freedArraysTop = freedArraysTop + 1;
              ip = 1065;
      end

       1065 :
      begin                                                                     // jmp
              ip = 1138;
      end

       1066 :
      begin                                                                     // label
              ip = 1067;
      end

       1067 :
      begin                                                                     // jNe
              ip = localMem[0+2] != 2 ? 1136 : 1068;
      end

       1068 :
      begin                                                                     // in
              if (inMemPos < NIn) begin
                localMem[0 + 478] = inMem[inMemPos];
                inMemPos = inMemPos + 1;
              end
              ip = 1069;
      end

       1069 :
      begin                                                                     // label
              ip = 1070;
      end

       1070 :
      begin                                                                     // mov
              localMem[0 + 479] = heapMem[localMem[0+3]*10 + 3];
              ip = 1071;
      end

       1071 :
      begin                                                                     // jNe
              ip = localMem[0+479] != 0 ? 1076 : 1072;
      end

       1072 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 0] = localMem[0+479];
              ip = 1073;
      end

       1073 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 1] = 3;
              ip = 1074;
      end

       1074 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 2] = 0;
              ip = 1075;
      end

       1075 :
      begin                                                                     // jmp
              ip = 1122;
      end

       1076 :
      begin                                                                     // label
              ip = 1077;
      end

       1077 :
      begin                                                                     // label
              ip = 1078;
      end

       1078 :
      begin                                                                     // mov
              localMem[0 + 480] = 0;
              ip = 1079;
      end

       1079 :
      begin                                                                     // label
              ip = 1080;
      end

       1080 :
      begin                                                                     // jGe
              ip = localMem[0+480] >= 99 ? 1118 : 1081;
      end

       1081 :
      begin                                                                     // subtract
              localMem[0 + 481] = heapMem[localMem[0+479]*10 + 0] - 1;
              ip = 1082;
      end

       1082 :
      begin                                                                     // mov
              localMem[0 + 482] = heapMem[localMem[0+479]*10 + 4];
              ip = 1083;
      end

       1083 :
      begin                                                                     // jLe
              ip = localMem[0+478] <= heapMem[localMem[0+482]*10 + localMem[0+481]] ? 1096 : 1084;
      end

       1084 :
      begin                                                                     // add
              localMem[0 + 483] = localMem[0+481] + 1;
              ip = 1085;
      end

       1085 :
      begin                                                                     // not
              localMem[0 + 484] = !heapMem[localMem[0+479]*10 + 6];
              ip = 1086;
      end

       1086 :
      begin                                                                     // jEq
              ip = localMem[0+484] == 0 ? 1091 : 1087;
      end

       1087 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 0] = localMem[0+479];
              ip = 1088;
      end

       1088 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 1] = 2;
              ip = 1089;
      end

       1089 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 2] = localMem[0+483];
              ip = 1090;
      end

       1090 :
      begin                                                                     // jmp
              ip = 1122;
      end

       1091 :
      begin                                                                     // label
              ip = 1092;
      end

       1092 :
      begin                                                                     // mov
              localMem[0 + 485] = heapMem[localMem[0+479]*10 + 6];
              ip = 1093;
      end

       1093 :
      begin                                                                     // mov
              localMem[0 + 486] = heapMem[localMem[0+485]*10 + localMem[0+483]];
              ip = 1094;
      end

       1094 :
      begin                                                                     // mov
              localMem[0 + 479] = localMem[0+486];
              ip = 1095;
      end

       1095 :
      begin                                                                     // jmp
              ip = 1115;
      end

       1096 :
      begin                                                                     // label
              ip = 1097;
      end

       1097 :
      begin                                                                     // arrayIndex
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+482] * NArea + i] == localMem[0+478]) localMem[0 + 487] = i + 1;
              end
              ip = 1098;
      end

       1098 :
      begin                                                                     // jEq
              ip = localMem[0+487] == 0 ? 1103 : 1099;
      end

       1099 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 0] = localMem[0+479];
              ip = 1100;
      end

       1100 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 1] = 1;
              ip = 1101;
      end

       1101 :
      begin                                                                     // subtract
              heapMem[localMem[0+0]*10 + 2] = localMem[0+487] - 1;
              ip = 1102;
      end

       1102 :
      begin                                                                     // jmp
              ip = 1122;
      end

       1103 :
      begin                                                                     // label
              ip = 1104;
      end

       1104 :
      begin                                                                     // arrayCountLess
              j = 0;
              for(i = 0; i < NArea; i = i + 1) begin
                if (heapMem[localMem[0+482] * NArea + i] < localMem[0+478]) j = j + 1;
              end
              localMem[0 + 488] = j;
              ip = 1105;
      end

       1105 :
      begin                                                                     // not
              localMem[0 + 489] = !heapMem[localMem[0+479]*10 + 6];
              ip = 1106;
      end

       1106 :
      begin                                                                     // jEq
              ip = localMem[0+489] == 0 ? 1111 : 1107;
      end

       1107 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 0] = localMem[0+479];
              ip = 1108;
      end

       1108 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 1] = 0;
              ip = 1109;
      end

       1109 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 2] = localMem[0+488];
              ip = 1110;
      end

       1110 :
      begin                                                                     // jmp
              ip = 1122;
      end

       1111 :
      begin                                                                     // label
              ip = 1112;
      end

       1112 :
      begin                                                                     // mov
              localMem[0 + 490] = heapMem[localMem[0+479]*10 + 6];
              ip = 1113;
      end

       1113 :
      begin                                                                     // mov
              localMem[0 + 491] = heapMem[localMem[0+490]*10 + localMem[0+488]];
              ip = 1114;
      end

       1114 :
      begin                                                                     // mov
              localMem[0 + 479] = localMem[0+491];
              ip = 1115;
      end

       1115 :
      begin                                                                     // label
              ip = 1116;
      end

       1116 :
      begin                                                                     // add
              localMem[0 + 480] = localMem[0+480] + 1;
              ip = 1117;
      end

       1117 :
      begin                                                                     // jmp
              ip = 1079;
      end

       1118 :
      begin                                                                     // label
              ip = 1119;
      end

       1119 :
      begin                                                                     // assert
            ip = 1120;
      end

       1120 :
      begin                                                                     // label
              ip = 1121;
      end

       1121 :
      begin                                                                     // label
              ip = 1122;
      end

       1122 :
      begin                                                                     // label
              ip = 1123;
      end

       1123 :
      begin                                                                     // mov
              localMem[0 + 492] = heapMem[localMem[0+0]*10 + 1];
              ip = 1124;
      end

       1124 :
      begin                                                                     // jNe
              ip = localMem[0+492] != 1 ? 1132 : 1125;
      end

       1125 :
      begin                                                                     // out
              outMem[outMemPos] = 1;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 1126;
      end

       1126 :
      begin                                                                     // mov
              localMem[0 + 493] = heapMem[localMem[0+0]*10 + 0];
              ip = 1127;
      end

       1127 :
      begin                                                                     // mov
              localMem[0 + 494] = heapMem[localMem[0+0]*10 + 2];
              ip = 1128;
      end

       1128 :
      begin                                                                     // mov
              localMem[0 + 495] = heapMem[localMem[0+493]*10 + 5];
              ip = 1129;
      end

       1129 :
      begin                                                                     // mov
              localMem[0 + 496] = heapMem[localMem[0+495]*10 + localMem[0+494]];
              ip = 1130;
      end

       1130 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+496];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 1131;
      end

       1131 :
      begin                                                                     // jmp
              ip = 1134;
      end

       1132 :
      begin                                                                     // label
              ip = 1133;
      end

       1133 :
      begin                                                                     // out
              outMem[outMemPos] = 0;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 1134;
      end

       1134 :
      begin                                                                     // label
              ip = 1135;
      end

       1135 :
      begin                                                                     // jmp
              ip = 1138;
      end

       1136 :
      begin                                                                     // label
              ip = 1137;
      end

       1137 :
      begin                                                                     // jmp
              ip = 1140;
      end

       1138 :
      begin                                                                     // label
              ip = 1139;
      end

       1139 :
      begin                                                                     // jmp
              ip = 1;
      end

       1140 :
      begin                                                                     // label
              ip = 1141;
      end
      default: begin
        success  = 1;
        success  = success && outMem[0] == 0;
        success  = success && outMem[1] == 1;
        success  = success && outMem[2] == 22;
        success  = success && outMem[3] == 0;
        success  = success && outMem[4] == 1;
        success  = success && outMem[5] == 33;
        finished = 1;
      end
    endcase
    if (steps <=    513) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
  end
endmodule
