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
  integer i, j, k;                                                              // A useful counter

  task updateArrayLength(integer arena, integer array, integer index);          // Update array length if we are updating an array
    begin
      if (arena == 1 && arraySizes[array] < index + 1) arraySizes[array] = index + 1;
    end
  endtask

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
//  for(i = 0; i < NHeap;   ++i)    heapMem[i] = 0;
//  for(i = 0; i < NLocal;  ++i)   localMem[i] = 0;
//  for(i = 0; i < NArrays; ++i) arraySizes[i] = 0;
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
//$display("AAAA %4d %4d array", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[0]*10 + 2] = 3;
              updateArrayLength(1, localMem[0], 2);
              ip = 2;
      end

          2 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[0]*10 + 3] = 0;
              updateArrayLength(1, localMem[0], 3);
              ip = 3;
      end

          3 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[0]*10 + 0] = 0;
              updateArrayLength(1, localMem[0], 0);
              ip = 4;
      end

          4 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[0]*10 + 1] = 0;
              updateArrayLength(1, localMem[0], 1);
              ip = 5;
      end

          5 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
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
//$display("AAAA %4d %4d label", steps, ip);
              ip = 7;
      end

          7 :
      begin                                                                     // inSize
//$display("AAAA %4d %4d inSize", steps, ip);
              localMem[0 + 2] = NIn - inMemPos;
              ip = 8;
      end

          8 :
      begin                                                                     // jFalse
//$display("AAAA %4d %4d jFalse", steps, ip);
              ip = localMem[2] == 0 ? 1054 : 9;
      end

          9 :
      begin                                                                     // in
//$display("AAAA %4d %4d in", steps, ip);
              if (inMemPos < NIn) begin
                localMem[0 + 3] = inMem[inMemPos];
                inMemPos = inMemPos + 1;
              end
              ip = 10;
      end

         10 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 4] = heapMem[localMem[0]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 11;
      end

         11 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 5] = localMem[3] + localMem[3];
              ip = 12;
      end

         12 :
      begin                                                                     // tally
//$display("AAAA %4d %4d tally", steps, ip);
            ip = 13;
      end

         13 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 14;
      end

         14 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 6] = heapMem[localMem[0]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 15;
      end

         15 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[6] != 0 ? 38 : 16;
      end

         16 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[7]*10 + 0] = 1;
              updateArrayLength(1, localMem[7], 0);
              ip = 18;
      end

         18 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[7]*10 + 2] = 0;
              updateArrayLength(1, localMem[7], 2);
              ip = 19;
      end

         19 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[7]*10 + 4] = localMem[8];
              updateArrayLength(1, localMem[7], 4);
              ip = 21;
      end

         21 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[7]*10 + 5] = localMem[9];
              updateArrayLength(1, localMem[7], 5);
              ip = 23;
      end

         23 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[7]*10 + 6] = 0;
              updateArrayLength(1, localMem[7], 6);
              ip = 24;
      end

         24 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[7]*10 + 3] = localMem[0];
              updateArrayLength(1, localMem[7], 3);
              ip = 25;
      end

         25 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 1] = heapMem[localMem[0]*10 + 1] + 1;
              ip = 26;
      end

         26 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[7]*10 + 1] = heapMem[localMem[0]*10 + 1];
              updateArrayLength(1, localMem[7], 1);
              ip = 27;
      end

         27 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 10] = heapMem[localMem[7]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 28;
      end

         28 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[10]*10 + 0] = localMem[3];
              updateArrayLength(1, localMem[10], 0);
              ip = 29;
      end

         29 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 11] = heapMem[localMem[7]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 30;
      end

         30 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[11]*10 + 0] = localMem[5];
              updateArrayLength(1, localMem[11], 0);
              ip = 31;
      end

         31 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              ip = 32;
      end

         32 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[0]*10 + 3] = localMem[7];
              updateArrayLength(1, localMem[0], 3);
              ip = 33;
      end

         33 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 12] = heapMem[localMem[7]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 34;
      end

         34 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[12]] = 1;
              ip = 35;
      end

         35 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 13] = heapMem[localMem[7]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 36;
      end

         36 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[13]] = 1;
              ip = 37;
      end

         37 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1050;
      end

         38 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 39;
      end

         39 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 14] = heapMem[localMem[6]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 40;
      end

         40 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 15] = heapMem[localMem[0]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 41;
      end

         41 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[14] >= localMem[15] ? 77 : 42;
      end

         42 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 16] = heapMem[localMem[6]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 43;
      end

         43 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[16] != 0 ? 76 : 44;
      end

         44 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 17] = !heapMem[localMem[6]*10 + 6];
              ip = 45;
      end

         45 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[17] == 0 ? 75 : 46;
      end

         46 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 18] = heapMem[localMem[6]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 47;
      end

         47 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 19] = 0; k = arraySizes[localMem[18]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[18] * NArea + i] == localMem[3]) localMem[0 + 19] = i + 1;
              end
              ip = 48;
      end

         48 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[19] == 0 ? 53 : 49;
      end

         49 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 19] = localMem[19] - 1;
              ip = 50;
      end

         50 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 20] = heapMem[localMem[6]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 51;
      end

         51 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[20]*10 + localMem[19]] = localMem[5];
              updateArrayLength(1, localMem[20], localMem[19]);
              ip = 52;
      end

         52 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1050;
      end

         53 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 54;
      end

         54 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[18]] = localMem[14];
              ip = 55;
      end

         55 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 21] = heapMem[localMem[6]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 56;
      end

         56 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[21]] = localMem[14];
              ip = 57;
      end

         57 :
      begin                                                                     // arrayCountGreater
//$display("AAAA %4d %4d arrayCountGreater", steps, ip);
              j = 0; k = arraySizes[localMem[18]];
//$display("AAAAA k=%d  source2=%d", k, localMem[3]);
              for(i = 0; i < NArea; i = i + 1) begin
//$display("AAAAA i=%d  value=%d", i, heapMem[localMem[18] * NArea + i]);
                if (i < k && heapMem[localMem[18] * NArea + i] > localMem[3]) j = j + 1;
              end
              localMem[0 + 22] = j;
              ip = 58;
      end

         58 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[22] != 0 ? 66 : 59;
      end

         59 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 23] = heapMem[localMem[6]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 60;
      end

         60 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[23]*10 + localMem[14]] = localMem[3];
              updateArrayLength(1, localMem[23], localMem[14]);
              ip = 61;
      end

         61 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 24] = heapMem[localMem[6]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 62;
      end

         62 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[24]*10 + localMem[14]] = localMem[5];
              updateArrayLength(1, localMem[24], localMem[14]);
              ip = 63;
      end

         63 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[6]*10 + 0] = localMem[14] + 1;
              ip = 64;
      end

         64 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              ip = 65;
      end

         65 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1050;
      end

         66 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 67;
      end

         67 :
      begin                                                                     // arrayCountLess
//$display("AAAA %4d %4d arrayCountLess", steps, ip);
              j = 0; k = arraySizes[localMem[18]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[18] * NArea + i] < localMem[3]) j = j + 1;
              end
              localMem[0 + 25] = j;
              ip = 68;
      end

         68 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 26] = heapMem[localMem[6]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 69;
      end

         69 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[26] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[25], localMem[26], arraySizes[localMem[26]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[25] && i <= arraySizes[localMem[26]]) begin
                  heapMem[NArea * localMem[26] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[26] + localMem[25]] = localMem[3];                                    // Insert new value
              arraySizes[localMem[26]] = arraySizes[localMem[26]] + 1;                              // Increase array size
              ip = 70;
      end

         70 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 27] = heapMem[localMem[6]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 71;
      end

         71 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[27] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[25], localMem[27], arraySizes[localMem[27]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[25] && i <= arraySizes[localMem[27]]) begin
                  heapMem[NArea * localMem[27] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[27] + localMem[25]] = localMem[5];                                    // Insert new value
              arraySizes[localMem[27]] = arraySizes[localMem[27]] + 1;                              // Increase array size
              ip = 72;
      end

         72 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[6]*10 + 0] = heapMem[localMem[6]*10 + 0] + 1;
              ip = 73;
      end

         73 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              ip = 74;
      end

         74 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1050;
      end

         75 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 76;
      end

         76 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 77;
      end

         77 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 78;
      end

         78 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 28] = heapMem[localMem[0]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 79;
      end

         79 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 80;
      end

         80 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 30] = heapMem[localMem[28]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 81;
      end

         81 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[30] <  3 ? 299 : 82;
      end

         82 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 31] = heapMem[localMem[28]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 83;
      end

         83 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 32] = heapMem[localMem[28]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 84;
      end

         84 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[32] == 0 ? 181 : 85;
      end

         85 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[33]*10 + 0] = 1;
              updateArrayLength(1, localMem[33], 0);
              ip = 87;
      end

         87 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[33]*10 + 2] = 0;
              updateArrayLength(1, localMem[33], 2);
              ip = 88;
      end

         88 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 34] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 34] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 34]] = 0;
              ip = 89;
      end

         89 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[33]*10 + 4] = localMem[34];
              updateArrayLength(1, localMem[33], 4);
              ip = 90;
      end

         90 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 35] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 35] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 35]] = 0;
              ip = 91;
      end

         91 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[33]*10 + 5] = localMem[35];
              updateArrayLength(1, localMem[33], 5);
              ip = 92;
      end

         92 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[33]*10 + 6] = 0;
              updateArrayLength(1, localMem[33], 6);
              ip = 93;
      end

         93 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[33]*10 + 3] = localMem[31];
              updateArrayLength(1, localMem[33], 3);
              ip = 94;
      end

         94 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[31]*10 + 1] = heapMem[localMem[31]*10 + 1] + 1;
              ip = 95;
      end

         95 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[33]*10 + 1] = heapMem[localMem[31]*10 + 1];
              updateArrayLength(1, localMem[33], 1);
              ip = 96;
      end

         96 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 36] = !heapMem[localMem[28]*10 + 6];
              ip = 97;
      end

         97 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[36] != 0 ? 126 : 98;
      end

         98 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 37] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 37] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 37]] = 0;
              ip = 99;
      end

         99 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[33]*10 + 6] = localMem[37];
              updateArrayLength(1, localMem[33], 6);
              ip = 100;
      end

        100 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 38] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 101;
      end

        101 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 39] = heapMem[localMem[33]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 102;
      end

        102 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[39] + 0 + i] = heapMem[NArea * localMem[38] + 2 + i];
                  updateArrayLength(1, localMem[39], 0 + i);
                end
              end
              ip = 103;
      end

        103 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 40] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 104;
      end

        104 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 41] = heapMem[localMem[33]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 105;
      end

        105 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[41] + 0 + i] = heapMem[NArea * localMem[40] + 2 + i];
                  updateArrayLength(1, localMem[41], 0 + i);
                end
              end
              ip = 106;
      end

        106 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 42] = heapMem[localMem[28]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 107;
      end

        107 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 43] = heapMem[localMem[33]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 108;
      end

        108 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 44] = 1 + 1;
              ip = 109;
      end

        109 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[44]) begin
                  heapMem[NArea * localMem[43] + 0 + i] = heapMem[NArea * localMem[42] + 2 + i];
                  updateArrayLength(1, localMem[43], 0 + i);
                end
              end
              ip = 110;
      end

        110 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 45] = heapMem[localMem[33]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 111;
      end

        111 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 46] = localMem[45] + 1;
              ip = 112;
      end

        112 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 47] = heapMem[localMem[33]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 113;
      end

        113 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 114;
      end

        114 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 48] = 0;
              updateArrayLength(2, 0, 0);
              ip = 115;
      end

        115 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 116;
      end

        116 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[48] >= localMem[46] ? 122 : 117;
      end

        117 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 49] = heapMem[localMem[47]*10 + localMem[48]];
              updateArrayLength(2, 0, 0);
              ip = 118;
      end

        118 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[49]*10 + 2] = localMem[33];
              updateArrayLength(1, localMem[49], 2);
              ip = 119;
      end

        119 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 120;
      end

        120 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 48] = localMem[48] + 1;
              ip = 121;
      end

        121 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 115;
      end

        122 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 123;
      end

        123 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 50] = heapMem[localMem[28]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 124;
      end

        124 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[50]] = 2;
              ip = 125;
      end

        125 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 133;
      end

        126 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 127;
      end

        127 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 51] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 128;
      end

        128 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 52] = heapMem[localMem[33]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 129;
      end

        129 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[52] + 0 + i] = heapMem[NArea * localMem[51] + 2 + i];
                  updateArrayLength(1, localMem[52], 0 + i);
                end
              end
              ip = 130;
      end

        130 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 53] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 131;
      end

        131 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 54] = heapMem[localMem[33]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 132;
      end

        132 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[54] + 0 + i] = heapMem[NArea * localMem[53] + 2 + i];
                  updateArrayLength(1, localMem[54], 0 + i);
                end
              end
              ip = 133;
      end

        133 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 134;
      end

        134 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[28]*10 + 0] = 1;
              updateArrayLength(1, localMem[28], 0);
              ip = 135;
      end

        135 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[33]*10 + 2] = localMem[32];
              updateArrayLength(1, localMem[33], 2);
              ip = 136;
      end

        136 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 55] = heapMem[localMem[32]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 137;
      end

        137 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 56] = heapMem[localMem[32]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 138;
      end

        138 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 57] = heapMem[localMem[56]*10 + localMem[55]];
              updateArrayLength(2, 0, 0);
              ip = 139;
      end

        139 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[57] != localMem[28] ? 158 : 140;
      end

        140 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 58] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 141;
      end

        141 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 59] = heapMem[localMem[58]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 142;
      end

        142 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 60] = heapMem[localMem[32]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 143;
      end

        143 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[60]*10 + localMem[55]] = localMem[59];
              updateArrayLength(1, localMem[60], localMem[55]);
              ip = 144;
      end

        144 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 61] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 145;
      end

        145 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 62] = heapMem[localMem[61]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 146;
      end

        146 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 63] = heapMem[localMem[32]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 147;
      end

        147 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[63]*10 + localMem[55]] = localMem[62];
              updateArrayLength(1, localMem[63], localMem[55]);
              ip = 148;
      end

        148 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 64] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 149;
      end

        149 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[64]] = 1;
              ip = 150;
      end

        150 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 65] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 151;
      end

        151 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[65]] = 1;
              ip = 152;
      end

        152 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 66] = localMem[55] + 1;
              ip = 153;
      end

        153 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[32]*10 + 0] = localMem[66];
              updateArrayLength(1, localMem[32], 0);
              ip = 154;
      end

        154 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 67] = heapMem[localMem[32]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 155;
      end

        155 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[67]*10 + localMem[66]] = localMem[33];
              updateArrayLength(1, localMem[67], localMem[66]);
              ip = 156;
      end

        156 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 296;
      end

        157 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 180;
      end

        158 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 159;
      end

        159 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 160;
      end

        160 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 68] = heapMem[localMem[32]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 161;
      end

        161 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 69] = 0; k = arraySizes[localMem[68]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[68] * NArea + i] == localMem[28]) localMem[0 + 69] = i + 1;
              end
              ip = 162;
      end

        162 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 69] = localMem[69] - 1;
              ip = 163;
      end

        163 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 70] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 164;
      end

        164 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 71] = heapMem[localMem[70]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 165;
      end

        165 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 72] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 166;
      end

        166 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 73] = heapMem[localMem[72]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 167;
      end

        167 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 74] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 168;
      end

        168 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[74]] = 1;
              ip = 169;
      end

        169 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 75] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 170;
      end

        170 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[75]] = 1;
              ip = 171;
      end

        171 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 76] = heapMem[localMem[32]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 172;
      end

        172 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[76] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[69], localMem[76], arraySizes[localMem[76]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[69] && i <= arraySizes[localMem[76]]) begin
                  heapMem[NArea * localMem[76] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[76] + localMem[69]] = localMem[71];                                    // Insert new value
              arraySizes[localMem[76]] = arraySizes[localMem[76]] + 1;                              // Increase array size
              ip = 173;
      end

        173 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 77] = heapMem[localMem[32]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 174;
      end

        174 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[77] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[69], localMem[77], arraySizes[localMem[77]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[69] && i <= arraySizes[localMem[77]]) begin
                  heapMem[NArea * localMem[77] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[77] + localMem[69]] = localMem[73];                                    // Insert new value
              arraySizes[localMem[77]] = arraySizes[localMem[77]] + 1;                              // Increase array size
              ip = 175;
      end

        175 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 78] = heapMem[localMem[32]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 176;
      end

        176 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 79] = localMem[69] + 1;
              ip = 177;
      end

        177 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[78] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[79], localMem[78], arraySizes[localMem[78]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[79] && i <= arraySizes[localMem[78]]) begin
                  heapMem[NArea * localMem[78] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[78] + localMem[79]] = localMem[33];                                    // Insert new value
              arraySizes[localMem[78]] = arraySizes[localMem[78]] + 1;                              // Increase array size
              ip = 178;
      end

        178 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[32]*10 + 0] = heapMem[localMem[32]*10 + 0] + 1;
              ip = 179;
      end

        179 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 296;
      end

        180 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 181;
      end

        181 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 182;
      end

        182 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[80]*10 + 0] = 1;
              updateArrayLength(1, localMem[80], 0);
              ip = 184;
      end

        184 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[80]*10 + 2] = 0;
              updateArrayLength(1, localMem[80], 2);
              ip = 185;
      end

        185 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 81] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 81] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 81]] = 0;
              ip = 186;
      end

        186 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[80]*10 + 4] = localMem[81];
              updateArrayLength(1, localMem[80], 4);
              ip = 187;
      end

        187 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 82] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 82] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 82]] = 0;
              ip = 188;
      end

        188 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[80]*10 + 5] = localMem[82];
              updateArrayLength(1, localMem[80], 5);
              ip = 189;
      end

        189 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[80]*10 + 6] = 0;
              updateArrayLength(1, localMem[80], 6);
              ip = 190;
      end

        190 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[80]*10 + 3] = localMem[31];
              updateArrayLength(1, localMem[80], 3);
              ip = 191;
      end

        191 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[31]*10 + 1] = heapMem[localMem[31]*10 + 1] + 1;
              ip = 192;
      end

        192 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[80]*10 + 1] = heapMem[localMem[31]*10 + 1];
              updateArrayLength(1, localMem[80], 1);
              ip = 193;
      end

        193 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[83]*10 + 0] = 1;
              updateArrayLength(1, localMem[83], 0);
              ip = 195;
      end

        195 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[83]*10 + 2] = 0;
              updateArrayLength(1, localMem[83], 2);
              ip = 196;
      end

        196 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 84] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 84] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 84]] = 0;
              ip = 197;
      end

        197 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[83]*10 + 4] = localMem[84];
              updateArrayLength(1, localMem[83], 4);
              ip = 198;
      end

        198 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 85] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 85] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 85]] = 0;
              ip = 199;
      end

        199 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[83]*10 + 5] = localMem[85];
              updateArrayLength(1, localMem[83], 5);
              ip = 200;
      end

        200 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[83]*10 + 6] = 0;
              updateArrayLength(1, localMem[83], 6);
              ip = 201;
      end

        201 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[83]*10 + 3] = localMem[31];
              updateArrayLength(1, localMem[83], 3);
              ip = 202;
      end

        202 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[31]*10 + 1] = heapMem[localMem[31]*10 + 1] + 1;
              ip = 203;
      end

        203 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[83]*10 + 1] = heapMem[localMem[31]*10 + 1];
              updateArrayLength(1, localMem[83], 1);
              ip = 204;
      end

        204 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 86] = !heapMem[localMem[28]*10 + 6];
              ip = 205;
      end

        205 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[86] != 0 ? 257 : 206;
      end

        206 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 87] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 87] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 87]] = 0;
              ip = 207;
      end

        207 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[80]*10 + 6] = localMem[87];
              updateArrayLength(1, localMem[80], 6);
              ip = 208;
      end

        208 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 88] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 88] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 88]] = 0;
              ip = 209;
      end

        209 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[83]*10 + 6] = localMem[88];
              updateArrayLength(1, localMem[83], 6);
              ip = 210;
      end

        210 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 89] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 211;
      end

        211 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 90] = heapMem[localMem[80]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 212;
      end

        212 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[90] + 0 + i] = heapMem[NArea * localMem[89] + 0 + i];
                  updateArrayLength(1, localMem[90], 0 + i);
                end
              end
              ip = 213;
      end

        213 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 91] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 214;
      end

        214 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 92] = heapMem[localMem[80]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 215;
      end

        215 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[92] + 0 + i] = heapMem[NArea * localMem[91] + 0 + i];
                  updateArrayLength(1, localMem[92], 0 + i);
                end
              end
              ip = 216;
      end

        216 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 93] = heapMem[localMem[28]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 217;
      end

        217 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 94] = heapMem[localMem[80]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 218;
      end

        218 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 95] = 1 + 1;
              ip = 219;
      end

        219 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[95]) begin
                  heapMem[NArea * localMem[94] + 0 + i] = heapMem[NArea * localMem[93] + 0 + i];
                  updateArrayLength(1, localMem[94], 0 + i);
                end
              end
              ip = 220;
      end

        220 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 96] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 221;
      end

        221 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 97] = heapMem[localMem[83]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 222;
      end

        222 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[97] + 0 + i] = heapMem[NArea * localMem[96] + 2 + i];
                  updateArrayLength(1, localMem[97], 0 + i);
                end
              end
              ip = 223;
      end

        223 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 98] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 224;
      end

        224 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 99] = heapMem[localMem[83]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 225;
      end

        225 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[99] + 0 + i] = heapMem[NArea * localMem[98] + 2 + i];
                  updateArrayLength(1, localMem[99], 0 + i);
                end
              end
              ip = 226;
      end

        226 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 100] = heapMem[localMem[28]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 227;
      end

        227 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 101] = heapMem[localMem[83]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 228;
      end

        228 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 102] = 1 + 1;
              ip = 229;
      end

        229 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[102]) begin
                  heapMem[NArea * localMem[101] + 0 + i] = heapMem[NArea * localMem[100] + 2 + i];
                  updateArrayLength(1, localMem[101], 0 + i);
                end
              end
              ip = 230;
      end

        230 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 103] = heapMem[localMem[80]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 231;
      end

        231 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 104] = localMem[103] + 1;
              ip = 232;
      end

        232 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 105] = heapMem[localMem[80]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 233;
      end

        233 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 234;
      end

        234 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 106] = 0;
              updateArrayLength(2, 0, 0);
              ip = 235;
      end

        235 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 236;
      end

        236 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[106] >= localMem[104] ? 242 : 237;
      end

        237 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 107] = heapMem[localMem[105]*10 + localMem[106]];
              updateArrayLength(2, 0, 0);
              ip = 238;
      end

        238 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[107]*10 + 2] = localMem[80];
              updateArrayLength(1, localMem[107], 2);
              ip = 239;
      end

        239 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 240;
      end

        240 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 106] = localMem[106] + 1;
              ip = 241;
      end

        241 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 235;
      end

        242 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 243;
      end

        243 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 108] = heapMem[localMem[83]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 244;
      end

        244 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 109] = localMem[108] + 1;
              ip = 245;
      end

        245 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 110] = heapMem[localMem[83]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 246;
      end

        246 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 247;
      end

        247 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 111] = 0;
              updateArrayLength(2, 0, 0);
              ip = 248;
      end

        248 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 249;
      end

        249 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[111] >= localMem[109] ? 255 : 250;
      end

        250 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 112] = heapMem[localMem[110]*10 + localMem[111]];
              updateArrayLength(2, 0, 0);
              ip = 251;
      end

        251 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[112]*10 + 2] = localMem[83];
              updateArrayLength(1, localMem[112], 2);
              ip = 252;
      end

        252 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 253;
      end

        253 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 111] = localMem[111] + 1;
              ip = 254;
      end

        254 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 248;
      end

        255 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 256;
      end

        256 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 272;
      end

        257 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 258;
      end

        258 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 113] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 113] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 113]] = 0;
              ip = 259;
      end

        259 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[28]*10 + 6] = localMem[113];
              updateArrayLength(1, localMem[28], 6);
              ip = 260;
      end

        260 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 114] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 261;
      end

        261 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 115] = heapMem[localMem[80]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 262;
      end

        262 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[115] + 0 + i] = heapMem[NArea * localMem[114] + 0 + i];
                  updateArrayLength(1, localMem[115], 0 + i);
                end
              end
              ip = 263;
      end

        263 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 116] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 264;
      end

        264 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 117] = heapMem[localMem[80]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 265;
      end

        265 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[117] + 0 + i] = heapMem[NArea * localMem[116] + 0 + i];
                  updateArrayLength(1, localMem[117], 0 + i);
                end
              end
              ip = 266;
      end

        266 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 118] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 267;
      end

        267 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 119] = heapMem[localMem[83]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 268;
      end

        268 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[119] + 0 + i] = heapMem[NArea * localMem[118] + 2 + i];
                  updateArrayLength(1, localMem[119], 0 + i);
                end
              end
              ip = 269;
      end

        269 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 120] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 270;
      end

        270 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 121] = heapMem[localMem[83]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 271;
      end

        271 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[121] + 0 + i] = heapMem[NArea * localMem[120] + 2 + i];
                  updateArrayLength(1, localMem[121], 0 + i);
                end
              end
              ip = 272;
      end

        272 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 273;
      end

        273 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[80]*10 + 2] = localMem[28];
              updateArrayLength(1, localMem[80], 2);
              ip = 274;
      end

        274 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[83]*10 + 2] = localMem[28];
              updateArrayLength(1, localMem[83], 2);
              ip = 275;
      end

        275 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 122] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 276;
      end

        276 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 123] = heapMem[localMem[122]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 277;
      end

        277 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 124] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 278;
      end

        278 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 125] = heapMem[localMem[124]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 279;
      end

        279 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 126] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 280;
      end

        280 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[126]*10 + 0] = localMem[123];
              updateArrayLength(1, localMem[126], 0);
              ip = 281;
      end

        281 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 127] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 282;
      end

        282 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[127]*10 + 0] = localMem[125];
              updateArrayLength(1, localMem[127], 0);
              ip = 283;
      end

        283 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 128] = heapMem[localMem[28]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 284;
      end

        284 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[128]*10 + 0] = localMem[80];
              updateArrayLength(1, localMem[128], 0);
              ip = 285;
      end

        285 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 129] = heapMem[localMem[28]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 286;
      end

        286 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[129]*10 + 1] = localMem[83];
              updateArrayLength(1, localMem[129], 1);
              ip = 287;
      end

        287 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[28]*10 + 0] = 1;
              updateArrayLength(1, localMem[28], 0);
              ip = 288;
      end

        288 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 130] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 289;
      end

        289 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[130]] = 1;
              ip = 290;
      end

        290 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 131] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 291;
      end

        291 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[131]] = 1;
              ip = 292;
      end

        292 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 132] = heapMem[localMem[28]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 293;
      end

        293 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[132]] = 2;
              ip = 294;
      end

        294 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 296;
      end

        295 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 301;
      end

        296 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 297;
      end

        297 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 29] = 1;
              updateArrayLength(2, 0, 0);
              ip = 298;
      end

        298 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 301;
      end

        299 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 300;
      end

        300 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 29] = 0;
              updateArrayLength(2, 0, 0);
              ip = 301;
      end

        301 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 302;
      end

        302 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 303;
      end

        303 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 304;
      end

        304 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 133] = 0;
              updateArrayLength(2, 0, 0);
              ip = 305;
      end

        305 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 306;
      end

        306 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[133] >= 99 ? 796 : 307;
      end

        307 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 134] = heapMem[localMem[28]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 308;
      end

        308 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 135] = localMem[134] - 1;
              ip = 309;
      end

        309 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 136] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 310;
      end

        310 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 137] = heapMem[localMem[136]*10 + localMem[135]];
              updateArrayLength(2, 0, 0);
              ip = 311;
      end

        311 :
      begin                                                                     // jLe
//$display("AAAA %4d %4d jLe", steps, ip);
              ip = localMem[3] <= localMem[137] ? 548 : 312;
      end

        312 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 138] = !heapMem[localMem[28]*10 + 6];
              ip = 313;
      end

        313 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[138] == 0 ? 318 : 314;
      end

        314 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 0] = localMem[28];
              updateArrayLength(1, localMem[1], 0);
              ip = 315;
      end

        315 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 1] = 2;
              updateArrayLength(1, localMem[1], 1);
              ip = 316;
      end

        316 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              heapMem[localMem[1]*10 + 2] = localMem[134] - 1;
              ip = 317;
      end

        317 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 800;
      end

        318 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 319;
      end

        319 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 139] = heapMem[localMem[28]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 320;
      end

        320 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 140] = heapMem[localMem[139]*10 + localMem[134]];
              updateArrayLength(2, 0, 0);
              ip = 321;
      end

        321 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 322;
      end

        322 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 142] = heapMem[localMem[140]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 323;
      end

        323 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[142] <  3 ? 541 : 324;
      end

        324 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 143] = heapMem[localMem[140]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 325;
      end

        325 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 144] = heapMem[localMem[140]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 326;
      end

        326 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[144] == 0 ? 423 : 327;
      end

        327 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 145] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 145] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 145]] = 0;
              ip = 328;
      end

        328 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[145]*10 + 0] = 1;
              updateArrayLength(1, localMem[145], 0);
              ip = 329;
      end

        329 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[145]*10 + 2] = 0;
              updateArrayLength(1, localMem[145], 2);
              ip = 330;
      end

        330 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 146] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 146] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 146]] = 0;
              ip = 331;
      end

        331 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[145]*10 + 4] = localMem[146];
              updateArrayLength(1, localMem[145], 4);
              ip = 332;
      end

        332 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 147] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 147] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 147]] = 0;
              ip = 333;
      end

        333 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[145]*10 + 5] = localMem[147];
              updateArrayLength(1, localMem[145], 5);
              ip = 334;
      end

        334 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[145]*10 + 6] = 0;
              updateArrayLength(1, localMem[145], 6);
              ip = 335;
      end

        335 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[145]*10 + 3] = localMem[143];
              updateArrayLength(1, localMem[145], 3);
              ip = 336;
      end

        336 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[143]*10 + 1] = heapMem[localMem[143]*10 + 1] + 1;
              ip = 337;
      end

        337 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[145]*10 + 1] = heapMem[localMem[143]*10 + 1];
              updateArrayLength(1, localMem[145], 1);
              ip = 338;
      end

        338 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 148] = !heapMem[localMem[140]*10 + 6];
              ip = 339;
      end

        339 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[148] != 0 ? 368 : 340;
      end

        340 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 149] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 149] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 149]] = 0;
              ip = 341;
      end

        341 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[145]*10 + 6] = localMem[149];
              updateArrayLength(1, localMem[145], 6);
              ip = 342;
      end

        342 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 150] = heapMem[localMem[140]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 343;
      end

        343 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 151] = heapMem[localMem[145]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 344;
      end

        344 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[151] + 0 + i] = heapMem[NArea * localMem[150] + 2 + i];
                  updateArrayLength(1, localMem[151], 0 + i);
                end
              end
              ip = 345;
      end

        345 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 152] = heapMem[localMem[140]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 346;
      end

        346 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 153] = heapMem[localMem[145]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 347;
      end

        347 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[153] + 0 + i] = heapMem[NArea * localMem[152] + 2 + i];
                  updateArrayLength(1, localMem[153], 0 + i);
                end
              end
              ip = 348;
      end

        348 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 154] = heapMem[localMem[140]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 349;
      end

        349 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 155] = heapMem[localMem[145]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 350;
      end

        350 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 156] = 1 + 1;
              ip = 351;
      end

        351 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[156]) begin
                  heapMem[NArea * localMem[155] + 0 + i] = heapMem[NArea * localMem[154] + 2 + i];
                  updateArrayLength(1, localMem[155], 0 + i);
                end
              end
              ip = 352;
      end

        352 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 157] = heapMem[localMem[145]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 353;
      end

        353 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 158] = localMem[157] + 1;
              ip = 354;
      end

        354 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 159] = heapMem[localMem[145]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 355;
      end

        355 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 356;
      end

        356 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 160] = 0;
              updateArrayLength(2, 0, 0);
              ip = 357;
      end

        357 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 358;
      end

        358 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[160] >= localMem[158] ? 364 : 359;
      end

        359 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 161] = heapMem[localMem[159]*10 + localMem[160]];
              updateArrayLength(2, 0, 0);
              ip = 360;
      end

        360 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[161]*10 + 2] = localMem[145];
              updateArrayLength(1, localMem[161], 2);
              ip = 361;
      end

        361 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 362;
      end

        362 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 160] = localMem[160] + 1;
              ip = 363;
      end

        363 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 357;
      end

        364 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 365;
      end

        365 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 162] = heapMem[localMem[140]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 366;
      end

        366 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[162]] = 2;
              ip = 367;
      end

        367 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 375;
      end

        368 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 369;
      end

        369 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 163] = heapMem[localMem[140]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 370;
      end

        370 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 164] = heapMem[localMem[145]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 371;
      end

        371 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[164] + 0 + i] = heapMem[NArea * localMem[163] + 2 + i];
                  updateArrayLength(1, localMem[164], 0 + i);
                end
              end
              ip = 372;
      end

        372 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 165] = heapMem[localMem[140]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 373;
      end

        373 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 166] = heapMem[localMem[145]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 374;
      end

        374 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[166] + 0 + i] = heapMem[NArea * localMem[165] + 2 + i];
                  updateArrayLength(1, localMem[166], 0 + i);
                end
              end
              ip = 375;
      end

        375 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 376;
      end

        376 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[140]*10 + 0] = 1;
              updateArrayLength(1, localMem[140], 0);
              ip = 377;
      end

        377 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[145]*10 + 2] = localMem[144];
              updateArrayLength(1, localMem[145], 2);
              ip = 378;
      end

        378 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 167] = heapMem[localMem[144]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 379;
      end

        379 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 168] = heapMem[localMem[144]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 380;
      end

        380 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 169] = heapMem[localMem[168]*10 + localMem[167]];
              updateArrayLength(2, 0, 0);
              ip = 381;
      end

        381 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[169] != localMem[140] ? 400 : 382;
      end

        382 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 170] = heapMem[localMem[140]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 383;
      end

        383 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 171] = heapMem[localMem[170]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 384;
      end

        384 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 172] = heapMem[localMem[144]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 385;
      end

        385 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[172]*10 + localMem[167]] = localMem[171];
              updateArrayLength(1, localMem[172], localMem[167]);
              ip = 386;
      end

        386 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 173] = heapMem[localMem[140]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 387;
      end

        387 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 174] = heapMem[localMem[173]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 388;
      end

        388 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 175] = heapMem[localMem[144]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 389;
      end

        389 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[175]*10 + localMem[167]] = localMem[174];
              updateArrayLength(1, localMem[175], localMem[167]);
              ip = 390;
      end

        390 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 176] = heapMem[localMem[140]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 391;
      end

        391 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[176]] = 1;
              ip = 392;
      end

        392 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 177] = heapMem[localMem[140]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 393;
      end

        393 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[177]] = 1;
              ip = 394;
      end

        394 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 178] = localMem[167] + 1;
              ip = 395;
      end

        395 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[144]*10 + 0] = localMem[178];
              updateArrayLength(1, localMem[144], 0);
              ip = 396;
      end

        396 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 179] = heapMem[localMem[144]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 397;
      end

        397 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[179]*10 + localMem[178]] = localMem[145];
              updateArrayLength(1, localMem[179], localMem[178]);
              ip = 398;
      end

        398 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 538;
      end

        399 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 422;
      end

        400 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 401;
      end

        401 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 402;
      end

        402 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 180] = heapMem[localMem[144]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 403;
      end

        403 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 181] = 0; k = arraySizes[localMem[180]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[180] * NArea + i] == localMem[140]) localMem[0 + 181] = i + 1;
              end
              ip = 404;
      end

        404 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 181] = localMem[181] - 1;
              ip = 405;
      end

        405 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 182] = heapMem[localMem[140]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 406;
      end

        406 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 183] = heapMem[localMem[182]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 407;
      end

        407 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 184] = heapMem[localMem[140]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 408;
      end

        408 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 185] = heapMem[localMem[184]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 409;
      end

        409 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 186] = heapMem[localMem[140]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 410;
      end

        410 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[186]] = 1;
              ip = 411;
      end

        411 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 187] = heapMem[localMem[140]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 412;
      end

        412 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[187]] = 1;
              ip = 413;
      end

        413 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 188] = heapMem[localMem[144]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 414;
      end

        414 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[188] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[181], localMem[188], arraySizes[localMem[188]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[181] && i <= arraySizes[localMem[188]]) begin
                  heapMem[NArea * localMem[188] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[188] + localMem[181]] = localMem[183];                                    // Insert new value
              arraySizes[localMem[188]] = arraySizes[localMem[188]] + 1;                              // Increase array size
              ip = 415;
      end

        415 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 189] = heapMem[localMem[144]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 416;
      end

        416 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[189] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[181], localMem[189], arraySizes[localMem[189]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[181] && i <= arraySizes[localMem[189]]) begin
                  heapMem[NArea * localMem[189] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[189] + localMem[181]] = localMem[185];                                    // Insert new value
              arraySizes[localMem[189]] = arraySizes[localMem[189]] + 1;                              // Increase array size
              ip = 417;
      end

        417 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 190] = heapMem[localMem[144]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 418;
      end

        418 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 191] = localMem[181] + 1;
              ip = 419;
      end

        419 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[190] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[191], localMem[190], arraySizes[localMem[190]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[191] && i <= arraySizes[localMem[190]]) begin
                  heapMem[NArea * localMem[190] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[190] + localMem[191]] = localMem[145];                                    // Insert new value
              arraySizes[localMem[190]] = arraySizes[localMem[190]] + 1;                              // Increase array size
              ip = 420;
      end

        420 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[144]*10 + 0] = heapMem[localMem[144]*10 + 0] + 1;
              ip = 421;
      end

        421 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 538;
      end

        422 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 423;
      end

        423 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 424;
      end

        424 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 192] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 192] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 192]] = 0;
              ip = 425;
      end

        425 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[192]*10 + 0] = 1;
              updateArrayLength(1, localMem[192], 0);
              ip = 426;
      end

        426 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[192]*10 + 2] = 0;
              updateArrayLength(1, localMem[192], 2);
              ip = 427;
      end

        427 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 193] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 193] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 193]] = 0;
              ip = 428;
      end

        428 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[192]*10 + 4] = localMem[193];
              updateArrayLength(1, localMem[192], 4);
              ip = 429;
      end

        429 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[192]*10 + 5] = localMem[194];
              updateArrayLength(1, localMem[192], 5);
              ip = 431;
      end

        431 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[192]*10 + 6] = 0;
              updateArrayLength(1, localMem[192], 6);
              ip = 432;
      end

        432 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[192]*10 + 3] = localMem[143];
              updateArrayLength(1, localMem[192], 3);
              ip = 433;
      end

        433 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[143]*10 + 1] = heapMem[localMem[143]*10 + 1] + 1;
              ip = 434;
      end

        434 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[192]*10 + 1] = heapMem[localMem[143]*10 + 1];
              updateArrayLength(1, localMem[192], 1);
              ip = 435;
      end

        435 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 195] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 195] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 195]] = 0;
              ip = 436;
      end

        436 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[195]*10 + 0] = 1;
              updateArrayLength(1, localMem[195], 0);
              ip = 437;
      end

        437 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[195]*10 + 2] = 0;
              updateArrayLength(1, localMem[195], 2);
              ip = 438;
      end

        438 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 196] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 196] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 196]] = 0;
              ip = 439;
      end

        439 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[195]*10 + 4] = localMem[196];
              updateArrayLength(1, localMem[195], 4);
              ip = 440;
      end

        440 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 197] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 197] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 197]] = 0;
              ip = 441;
      end

        441 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[195]*10 + 5] = localMem[197];
              updateArrayLength(1, localMem[195], 5);
              ip = 442;
      end

        442 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[195]*10 + 6] = 0;
              updateArrayLength(1, localMem[195], 6);
              ip = 443;
      end

        443 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[195]*10 + 3] = localMem[143];
              updateArrayLength(1, localMem[195], 3);
              ip = 444;
      end

        444 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[143]*10 + 1] = heapMem[localMem[143]*10 + 1] + 1;
              ip = 445;
      end

        445 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[195]*10 + 1] = heapMem[localMem[143]*10 + 1];
              updateArrayLength(1, localMem[195], 1);
              ip = 446;
      end

        446 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 198] = !heapMem[localMem[140]*10 + 6];
              ip = 447;
      end

        447 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[198] != 0 ? 499 : 448;
      end

        448 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 199] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 199] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 199]] = 0;
              ip = 449;
      end

        449 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[192]*10 + 6] = localMem[199];
              updateArrayLength(1, localMem[192], 6);
              ip = 450;
      end

        450 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 200] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 200] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 200]] = 0;
              ip = 451;
      end

        451 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[195]*10 + 6] = localMem[200];
              updateArrayLength(1, localMem[195], 6);
              ip = 452;
      end

        452 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 201] = heapMem[localMem[140]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 453;
      end

        453 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 202] = heapMem[localMem[192]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 454;
      end

        454 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[202] + 0 + i] = heapMem[NArea * localMem[201] + 0 + i];
                  updateArrayLength(1, localMem[202], 0 + i);
                end
              end
              ip = 455;
      end

        455 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 203] = heapMem[localMem[140]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 456;
      end

        456 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 204] = heapMem[localMem[192]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 457;
      end

        457 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[204] + 0 + i] = heapMem[NArea * localMem[203] + 0 + i];
                  updateArrayLength(1, localMem[204], 0 + i);
                end
              end
              ip = 458;
      end

        458 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 205] = heapMem[localMem[140]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 459;
      end

        459 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 206] = heapMem[localMem[192]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 460;
      end

        460 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 207] = 1 + 1;
              ip = 461;
      end

        461 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[207]) begin
                  heapMem[NArea * localMem[206] + 0 + i] = heapMem[NArea * localMem[205] + 0 + i];
                  updateArrayLength(1, localMem[206], 0 + i);
                end
              end
              ip = 462;
      end

        462 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 208] = heapMem[localMem[140]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 463;
      end

        463 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 209] = heapMem[localMem[195]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 464;
      end

        464 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[209] + 0 + i] = heapMem[NArea * localMem[208] + 2 + i];
                  updateArrayLength(1, localMem[209], 0 + i);
                end
              end
              ip = 465;
      end

        465 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 210] = heapMem[localMem[140]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 466;
      end

        466 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 211] = heapMem[localMem[195]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 467;
      end

        467 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[211] + 0 + i] = heapMem[NArea * localMem[210] + 2 + i];
                  updateArrayLength(1, localMem[211], 0 + i);
                end
              end
              ip = 468;
      end

        468 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 212] = heapMem[localMem[140]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 469;
      end

        469 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 213] = heapMem[localMem[195]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 470;
      end

        470 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 214] = 1 + 1;
              ip = 471;
      end

        471 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[214]) begin
                  heapMem[NArea * localMem[213] + 0 + i] = heapMem[NArea * localMem[212] + 2 + i];
                  updateArrayLength(1, localMem[213], 0 + i);
                end
              end
              ip = 472;
      end

        472 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 215] = heapMem[localMem[192]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 473;
      end

        473 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 216] = localMem[215] + 1;
              ip = 474;
      end

        474 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 217] = heapMem[localMem[192]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 475;
      end

        475 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 476;
      end

        476 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 218] = 0;
              updateArrayLength(2, 0, 0);
              ip = 477;
      end

        477 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 478;
      end

        478 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[218] >= localMem[216] ? 484 : 479;
      end

        479 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 219] = heapMem[localMem[217]*10 + localMem[218]];
              updateArrayLength(2, 0, 0);
              ip = 480;
      end

        480 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[219]*10 + 2] = localMem[192];
              updateArrayLength(1, localMem[219], 2);
              ip = 481;
      end

        481 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 482;
      end

        482 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 218] = localMem[218] + 1;
              ip = 483;
      end

        483 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 477;
      end

        484 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 485;
      end

        485 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 220] = heapMem[localMem[195]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 486;
      end

        486 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 221] = localMem[220] + 1;
              ip = 487;
      end

        487 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 222] = heapMem[localMem[195]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 488;
      end

        488 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 489;
      end

        489 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 223] = 0;
              updateArrayLength(2, 0, 0);
              ip = 490;
      end

        490 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 491;
      end

        491 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[223] >= localMem[221] ? 497 : 492;
      end

        492 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 224] = heapMem[localMem[222]*10 + localMem[223]];
              updateArrayLength(2, 0, 0);
              ip = 493;
      end

        493 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[224]*10 + 2] = localMem[195];
              updateArrayLength(1, localMem[224], 2);
              ip = 494;
      end

        494 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 495;
      end

        495 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 223] = localMem[223] + 1;
              ip = 496;
      end

        496 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 490;
      end

        497 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 498;
      end

        498 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 514;
      end

        499 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 500;
      end

        500 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 225] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 225] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 225]] = 0;
              ip = 501;
      end

        501 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[140]*10 + 6] = localMem[225];
              updateArrayLength(1, localMem[140], 6);
              ip = 502;
      end

        502 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 226] = heapMem[localMem[140]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 503;
      end

        503 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 227] = heapMem[localMem[192]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 504;
      end

        504 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[227] + 0 + i] = heapMem[NArea * localMem[226] + 0 + i];
                  updateArrayLength(1, localMem[227], 0 + i);
                end
              end
              ip = 505;
      end

        505 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 228] = heapMem[localMem[140]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 506;
      end

        506 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 229] = heapMem[localMem[192]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 507;
      end

        507 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[229] + 0 + i] = heapMem[NArea * localMem[228] + 0 + i];
                  updateArrayLength(1, localMem[229], 0 + i);
                end
              end
              ip = 508;
      end

        508 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 230] = heapMem[localMem[140]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 509;
      end

        509 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 231] = heapMem[localMem[195]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 510;
      end

        510 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[231] + 0 + i] = heapMem[NArea * localMem[230] + 2 + i];
                  updateArrayLength(1, localMem[231], 0 + i);
                end
              end
              ip = 511;
      end

        511 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 232] = heapMem[localMem[140]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 512;
      end

        512 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 233] = heapMem[localMem[195]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 513;
      end

        513 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[233] + 0 + i] = heapMem[NArea * localMem[232] + 2 + i];
                  updateArrayLength(1, localMem[233], 0 + i);
                end
              end
              ip = 514;
      end

        514 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 515;
      end

        515 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[192]*10 + 2] = localMem[140];
              updateArrayLength(1, localMem[192], 2);
              ip = 516;
      end

        516 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[195]*10 + 2] = localMem[140];
              updateArrayLength(1, localMem[195], 2);
              ip = 517;
      end

        517 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 234] = heapMem[localMem[140]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 518;
      end

        518 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 235] = heapMem[localMem[234]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 519;
      end

        519 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 236] = heapMem[localMem[140]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 520;
      end

        520 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 237] = heapMem[localMem[236]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 521;
      end

        521 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 238] = heapMem[localMem[140]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 522;
      end

        522 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[238]*10 + 0] = localMem[235];
              updateArrayLength(1, localMem[238], 0);
              ip = 523;
      end

        523 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 239] = heapMem[localMem[140]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 524;
      end

        524 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[239]*10 + 0] = localMem[237];
              updateArrayLength(1, localMem[239], 0);
              ip = 525;
      end

        525 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 240] = heapMem[localMem[140]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 526;
      end

        526 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[240]*10 + 0] = localMem[192];
              updateArrayLength(1, localMem[240], 0);
              ip = 527;
      end

        527 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 241] = heapMem[localMem[140]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 528;
      end

        528 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[241]*10 + 1] = localMem[195];
              updateArrayLength(1, localMem[241], 1);
              ip = 529;
      end

        529 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[140]*10 + 0] = 1;
              updateArrayLength(1, localMem[140], 0);
              ip = 530;
      end

        530 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 242] = heapMem[localMem[140]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 531;
      end

        531 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[242]] = 1;
              ip = 532;
      end

        532 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 243] = heapMem[localMem[140]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 533;
      end

        533 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[243]] = 1;
              ip = 534;
      end

        534 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 244] = heapMem[localMem[140]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 535;
      end

        535 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[244]] = 2;
              ip = 536;
      end

        536 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 538;
      end

        537 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 543;
      end

        538 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 539;
      end

        539 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 141] = 1;
              updateArrayLength(2, 0, 0);
              ip = 540;
      end

        540 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 543;
      end

        541 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 542;
      end

        542 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 141] = 0;
              updateArrayLength(2, 0, 0);
              ip = 543;
      end

        543 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 544;
      end

        544 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[141] != 0 ? 546 : 545;
      end

        545 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 28] = localMem[140];
              updateArrayLength(2, 0, 0);
              ip = 546;
      end

        546 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 547;
      end

        547 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 793;
      end

        548 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 549;
      end

        549 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 245] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 550;
      end

        550 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 246] = 0; k = arraySizes[localMem[245]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[245] * NArea + i] == localMem[3]) localMem[0 + 246] = i + 1;
              end
              ip = 551;
      end

        551 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[246] == 0 ? 556 : 552;
      end

        552 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 0] = localMem[28];
              updateArrayLength(1, localMem[1], 0);
              ip = 553;
      end

        553 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 1] = 1;
              updateArrayLength(1, localMem[1], 1);
              ip = 554;
      end

        554 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              heapMem[localMem[1]*10 + 2] = localMem[246] - 1;
              ip = 555;
      end

        555 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 800;
      end

        556 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 557;
      end

        557 :
      begin                                                                     // arrayCountLess
//$display("AAAA %4d %4d arrayCountLess", steps, ip);
              j = 0; k = arraySizes[localMem[245]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[245] * NArea + i] < localMem[3]) j = j + 1;
              end
              localMem[0 + 247] = j;
              ip = 558;
      end

        558 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 248] = !heapMem[localMem[28]*10 + 6];
              ip = 559;
      end

        559 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[248] == 0 ? 564 : 560;
      end

        560 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 0] = localMem[28];
              updateArrayLength(1, localMem[1], 0);
              ip = 561;
      end

        561 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 1] = 0;
              updateArrayLength(1, localMem[1], 1);
              ip = 562;
      end

        562 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 2] = localMem[247];
              updateArrayLength(1, localMem[1], 2);
              ip = 563;
      end

        563 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 800;
      end

        564 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 565;
      end

        565 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 249] = heapMem[localMem[28]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 566;
      end

        566 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 250] = heapMem[localMem[249]*10 + localMem[247]];
              updateArrayLength(2, 0, 0);
              ip = 567;
      end

        567 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 568;
      end

        568 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 252] = heapMem[localMem[250]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 569;
      end

        569 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[252] <  3 ? 787 : 570;
      end

        570 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 253] = heapMem[localMem[250]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 571;
      end

        571 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 254] = heapMem[localMem[250]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 572;
      end

        572 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[254] == 0 ? 669 : 573;
      end

        573 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 255] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 255] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 255]] = 0;
              ip = 574;
      end

        574 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[255]*10 + 0] = 1;
              updateArrayLength(1, localMem[255], 0);
              ip = 575;
      end

        575 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[255]*10 + 2] = 0;
              updateArrayLength(1, localMem[255], 2);
              ip = 576;
      end

        576 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 256] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 256] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 256]] = 0;
              ip = 577;
      end

        577 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[255]*10 + 4] = localMem[256];
              updateArrayLength(1, localMem[255], 4);
              ip = 578;
      end

        578 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 257] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 257] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 257]] = 0;
              ip = 579;
      end

        579 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[255]*10 + 5] = localMem[257];
              updateArrayLength(1, localMem[255], 5);
              ip = 580;
      end

        580 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[255]*10 + 6] = 0;
              updateArrayLength(1, localMem[255], 6);
              ip = 581;
      end

        581 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[255]*10 + 3] = localMem[253];
              updateArrayLength(1, localMem[255], 3);
              ip = 582;
      end

        582 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[253]*10 + 1] = heapMem[localMem[253]*10 + 1] + 1;
              ip = 583;
      end

        583 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[255]*10 + 1] = heapMem[localMem[253]*10 + 1];
              updateArrayLength(1, localMem[255], 1);
              ip = 584;
      end

        584 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 258] = !heapMem[localMem[250]*10 + 6];
              ip = 585;
      end

        585 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[258] != 0 ? 614 : 586;
      end

        586 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 259] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 259] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 259]] = 0;
              ip = 587;
      end

        587 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[255]*10 + 6] = localMem[259];
              updateArrayLength(1, localMem[255], 6);
              ip = 588;
      end

        588 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 260] = heapMem[localMem[250]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 589;
      end

        589 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 261] = heapMem[localMem[255]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 590;
      end

        590 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[261] + 0 + i] = heapMem[NArea * localMem[260] + 2 + i];
                  updateArrayLength(1, localMem[261], 0 + i);
                end
              end
              ip = 591;
      end

        591 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 262] = heapMem[localMem[250]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 592;
      end

        592 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 263] = heapMem[localMem[255]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 593;
      end

        593 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[263] + 0 + i] = heapMem[NArea * localMem[262] + 2 + i];
                  updateArrayLength(1, localMem[263], 0 + i);
                end
              end
              ip = 594;
      end

        594 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 264] = heapMem[localMem[250]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 595;
      end

        595 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 265] = heapMem[localMem[255]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 596;
      end

        596 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 266] = 1 + 1;
              ip = 597;
      end

        597 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[266]) begin
                  heapMem[NArea * localMem[265] + 0 + i] = heapMem[NArea * localMem[264] + 2 + i];
                  updateArrayLength(1, localMem[265], 0 + i);
                end
              end
              ip = 598;
      end

        598 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 267] = heapMem[localMem[255]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 599;
      end

        599 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 268] = localMem[267] + 1;
              ip = 600;
      end

        600 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 269] = heapMem[localMem[255]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 601;
      end

        601 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 602;
      end

        602 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 270] = 0;
              updateArrayLength(2, 0, 0);
              ip = 603;
      end

        603 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 604;
      end

        604 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[270] >= localMem[268] ? 610 : 605;
      end

        605 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 271] = heapMem[localMem[269]*10 + localMem[270]];
              updateArrayLength(2, 0, 0);
              ip = 606;
      end

        606 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[271]*10 + 2] = localMem[255];
              updateArrayLength(1, localMem[271], 2);
              ip = 607;
      end

        607 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 608;
      end

        608 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 270] = localMem[270] + 1;
              ip = 609;
      end

        609 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 603;
      end

        610 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 611;
      end

        611 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 272] = heapMem[localMem[250]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 612;
      end

        612 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[272]] = 2;
              ip = 613;
      end

        613 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 621;
      end

        614 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 615;
      end

        615 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 273] = heapMem[localMem[250]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 616;
      end

        616 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 274] = heapMem[localMem[255]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 617;
      end

        617 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[274] + 0 + i] = heapMem[NArea * localMem[273] + 2 + i];
                  updateArrayLength(1, localMem[274], 0 + i);
                end
              end
              ip = 618;
      end

        618 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 275] = heapMem[localMem[250]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 619;
      end

        619 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 276] = heapMem[localMem[255]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 620;
      end

        620 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[276] + 0 + i] = heapMem[NArea * localMem[275] + 2 + i];
                  updateArrayLength(1, localMem[276], 0 + i);
                end
              end
              ip = 621;
      end

        621 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 622;
      end

        622 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[250]*10 + 0] = 1;
              updateArrayLength(1, localMem[250], 0);
              ip = 623;
      end

        623 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[255]*10 + 2] = localMem[254];
              updateArrayLength(1, localMem[255], 2);
              ip = 624;
      end

        624 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 277] = heapMem[localMem[254]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 625;
      end

        625 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 278] = heapMem[localMem[254]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 626;
      end

        626 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 279] = heapMem[localMem[278]*10 + localMem[277]];
              updateArrayLength(2, 0, 0);
              ip = 627;
      end

        627 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[279] != localMem[250] ? 646 : 628;
      end

        628 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 280] = heapMem[localMem[250]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 629;
      end

        629 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 281] = heapMem[localMem[280]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 630;
      end

        630 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 282] = heapMem[localMem[254]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 631;
      end

        631 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[282]*10 + localMem[277]] = localMem[281];
              updateArrayLength(1, localMem[282], localMem[277]);
              ip = 632;
      end

        632 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 283] = heapMem[localMem[250]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 633;
      end

        633 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 284] = heapMem[localMem[283]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 634;
      end

        634 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 285] = heapMem[localMem[254]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 635;
      end

        635 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[285]*10 + localMem[277]] = localMem[284];
              updateArrayLength(1, localMem[285], localMem[277]);
              ip = 636;
      end

        636 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 286] = heapMem[localMem[250]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 637;
      end

        637 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[286]] = 1;
              ip = 638;
      end

        638 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 287] = heapMem[localMem[250]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 639;
      end

        639 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[287]] = 1;
              ip = 640;
      end

        640 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 288] = localMem[277] + 1;
              ip = 641;
      end

        641 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[254]*10 + 0] = localMem[288];
              updateArrayLength(1, localMem[254], 0);
              ip = 642;
      end

        642 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 289] = heapMem[localMem[254]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 643;
      end

        643 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[289]*10 + localMem[288]] = localMem[255];
              updateArrayLength(1, localMem[289], localMem[288]);
              ip = 644;
      end

        644 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 784;
      end

        645 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 668;
      end

        646 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 647;
      end

        647 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 648;
      end

        648 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 290] = heapMem[localMem[254]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 649;
      end

        649 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 291] = 0; k = arraySizes[localMem[290]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[290] * NArea + i] == localMem[250]) localMem[0 + 291] = i + 1;
              end
              ip = 650;
      end

        650 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 291] = localMem[291] - 1;
              ip = 651;
      end

        651 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 292] = heapMem[localMem[250]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 652;
      end

        652 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 293] = heapMem[localMem[292]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 653;
      end

        653 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 294] = heapMem[localMem[250]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 654;
      end

        654 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 295] = heapMem[localMem[294]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 655;
      end

        655 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 296] = heapMem[localMem[250]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 656;
      end

        656 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[296]] = 1;
              ip = 657;
      end

        657 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 297] = heapMem[localMem[250]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 658;
      end

        658 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[297]] = 1;
              ip = 659;
      end

        659 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 298] = heapMem[localMem[254]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 660;
      end

        660 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[298] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[291], localMem[298], arraySizes[localMem[298]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[291] && i <= arraySizes[localMem[298]]) begin
                  heapMem[NArea * localMem[298] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[298] + localMem[291]] = localMem[293];                                    // Insert new value
              arraySizes[localMem[298]] = arraySizes[localMem[298]] + 1;                              // Increase array size
              ip = 661;
      end

        661 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 299] = heapMem[localMem[254]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 662;
      end

        662 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[299] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[291], localMem[299], arraySizes[localMem[299]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[291] && i <= arraySizes[localMem[299]]) begin
                  heapMem[NArea * localMem[299] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[299] + localMem[291]] = localMem[295];                                    // Insert new value
              arraySizes[localMem[299]] = arraySizes[localMem[299]] + 1;                              // Increase array size
              ip = 663;
      end

        663 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 300] = heapMem[localMem[254]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 664;
      end

        664 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 301] = localMem[291] + 1;
              ip = 665;
      end

        665 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[300] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[301], localMem[300], arraySizes[localMem[300]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[301] && i <= arraySizes[localMem[300]]) begin
                  heapMem[NArea * localMem[300] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[300] + localMem[301]] = localMem[255];                                    // Insert new value
              arraySizes[localMem[300]] = arraySizes[localMem[300]] + 1;                              // Increase array size
              ip = 666;
      end

        666 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[254]*10 + 0] = heapMem[localMem[254]*10 + 0] + 1;
              ip = 667;
      end

        667 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 784;
      end

        668 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 669;
      end

        669 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 670;
      end

        670 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 302] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 302] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 302]] = 0;
              ip = 671;
      end

        671 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[302]*10 + 0] = 1;
              updateArrayLength(1, localMem[302], 0);
              ip = 672;
      end

        672 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[302]*10 + 2] = 0;
              updateArrayLength(1, localMem[302], 2);
              ip = 673;
      end

        673 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 303] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 303] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 303]] = 0;
              ip = 674;
      end

        674 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[302]*10 + 4] = localMem[303];
              updateArrayLength(1, localMem[302], 4);
              ip = 675;
      end

        675 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 304] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 304] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 304]] = 0;
              ip = 676;
      end

        676 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[302]*10 + 5] = localMem[304];
              updateArrayLength(1, localMem[302], 5);
              ip = 677;
      end

        677 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[302]*10 + 6] = 0;
              updateArrayLength(1, localMem[302], 6);
              ip = 678;
      end

        678 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[302]*10 + 3] = localMem[253];
              updateArrayLength(1, localMem[302], 3);
              ip = 679;
      end

        679 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[253]*10 + 1] = heapMem[localMem[253]*10 + 1] + 1;
              ip = 680;
      end

        680 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[302]*10 + 1] = heapMem[localMem[253]*10 + 1];
              updateArrayLength(1, localMem[302], 1);
              ip = 681;
      end

        681 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 305] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 305] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 305]] = 0;
              ip = 682;
      end

        682 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[305]*10 + 0] = 1;
              updateArrayLength(1, localMem[305], 0);
              ip = 683;
      end

        683 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[305]*10 + 2] = 0;
              updateArrayLength(1, localMem[305], 2);
              ip = 684;
      end

        684 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 306] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 306] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 306]] = 0;
              ip = 685;
      end

        685 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[305]*10 + 4] = localMem[306];
              updateArrayLength(1, localMem[305], 4);
              ip = 686;
      end

        686 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 307] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 307] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 307]] = 0;
              ip = 687;
      end

        687 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[305]*10 + 5] = localMem[307];
              updateArrayLength(1, localMem[305], 5);
              ip = 688;
      end

        688 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[305]*10 + 6] = 0;
              updateArrayLength(1, localMem[305], 6);
              ip = 689;
      end

        689 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[305]*10 + 3] = localMem[253];
              updateArrayLength(1, localMem[305], 3);
              ip = 690;
      end

        690 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[253]*10 + 1] = heapMem[localMem[253]*10 + 1] + 1;
              ip = 691;
      end

        691 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[305]*10 + 1] = heapMem[localMem[253]*10 + 1];
              updateArrayLength(1, localMem[305], 1);
              ip = 692;
      end

        692 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 308] = !heapMem[localMem[250]*10 + 6];
              ip = 693;
      end

        693 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[308] != 0 ? 745 : 694;
      end

        694 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 309] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 309] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 309]] = 0;
              ip = 695;
      end

        695 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[302]*10 + 6] = localMem[309];
              updateArrayLength(1, localMem[302], 6);
              ip = 696;
      end

        696 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 310] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 310] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 310]] = 0;
              ip = 697;
      end

        697 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[305]*10 + 6] = localMem[310];
              updateArrayLength(1, localMem[305], 6);
              ip = 698;
      end

        698 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 311] = heapMem[localMem[250]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 699;
      end

        699 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 312] = heapMem[localMem[302]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 700;
      end

        700 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[312] + 0 + i] = heapMem[NArea * localMem[311] + 0 + i];
                  updateArrayLength(1, localMem[312], 0 + i);
                end
              end
              ip = 701;
      end

        701 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 313] = heapMem[localMem[250]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 702;
      end

        702 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 314] = heapMem[localMem[302]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 703;
      end

        703 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[314] + 0 + i] = heapMem[NArea * localMem[313] + 0 + i];
                  updateArrayLength(1, localMem[314], 0 + i);
                end
              end
              ip = 704;
      end

        704 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 315] = heapMem[localMem[250]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 705;
      end

        705 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 316] = heapMem[localMem[302]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 706;
      end

        706 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 317] = 1 + 1;
              ip = 707;
      end

        707 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[317]) begin
                  heapMem[NArea * localMem[316] + 0 + i] = heapMem[NArea * localMem[315] + 0 + i];
                  updateArrayLength(1, localMem[316], 0 + i);
                end
              end
              ip = 708;
      end

        708 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 318] = heapMem[localMem[250]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 709;
      end

        709 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 319] = heapMem[localMem[305]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 710;
      end

        710 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[319] + 0 + i] = heapMem[NArea * localMem[318] + 2 + i];
                  updateArrayLength(1, localMem[319], 0 + i);
                end
              end
              ip = 711;
      end

        711 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 320] = heapMem[localMem[250]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 712;
      end

        712 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 321] = heapMem[localMem[305]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 713;
      end

        713 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[321] + 0 + i] = heapMem[NArea * localMem[320] + 2 + i];
                  updateArrayLength(1, localMem[321], 0 + i);
                end
              end
              ip = 714;
      end

        714 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 322] = heapMem[localMem[250]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 715;
      end

        715 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 323] = heapMem[localMem[305]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 716;
      end

        716 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 324] = 1 + 1;
              ip = 717;
      end

        717 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[324]) begin
                  heapMem[NArea * localMem[323] + 0 + i] = heapMem[NArea * localMem[322] + 2 + i];
                  updateArrayLength(1, localMem[323], 0 + i);
                end
              end
              ip = 718;
      end

        718 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 325] = heapMem[localMem[302]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 719;
      end

        719 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 326] = localMem[325] + 1;
              ip = 720;
      end

        720 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 327] = heapMem[localMem[302]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 721;
      end

        721 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 722;
      end

        722 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 328] = 0;
              updateArrayLength(2, 0, 0);
              ip = 723;
      end

        723 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 724;
      end

        724 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[328] >= localMem[326] ? 730 : 725;
      end

        725 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 329] = heapMem[localMem[327]*10 + localMem[328]];
              updateArrayLength(2, 0, 0);
              ip = 726;
      end

        726 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[329]*10 + 2] = localMem[302];
              updateArrayLength(1, localMem[329], 2);
              ip = 727;
      end

        727 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 728;
      end

        728 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 328] = localMem[328] + 1;
              ip = 729;
      end

        729 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 723;
      end

        730 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 731;
      end

        731 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 330] = heapMem[localMem[305]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 732;
      end

        732 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 331] = localMem[330] + 1;
              ip = 733;
      end

        733 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 332] = heapMem[localMem[305]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 734;
      end

        734 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 735;
      end

        735 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 333] = 0;
              updateArrayLength(2, 0, 0);
              ip = 736;
      end

        736 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 737;
      end

        737 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[333] >= localMem[331] ? 743 : 738;
      end

        738 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 334] = heapMem[localMem[332]*10 + localMem[333]];
              updateArrayLength(2, 0, 0);
              ip = 739;
      end

        739 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[334]*10 + 2] = localMem[305];
              updateArrayLength(1, localMem[334], 2);
              ip = 740;
      end

        740 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 741;
      end

        741 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 333] = localMem[333] + 1;
              ip = 742;
      end

        742 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 736;
      end

        743 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 744;
      end

        744 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 760;
      end

        745 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 746;
      end

        746 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 335] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 335] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 335]] = 0;
              ip = 747;
      end

        747 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[250]*10 + 6] = localMem[335];
              updateArrayLength(1, localMem[250], 6);
              ip = 748;
      end

        748 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 336] = heapMem[localMem[250]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 749;
      end

        749 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 337] = heapMem[localMem[302]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 750;
      end

        750 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[337] + 0 + i] = heapMem[NArea * localMem[336] + 0 + i];
                  updateArrayLength(1, localMem[337], 0 + i);
                end
              end
              ip = 751;
      end

        751 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 338] = heapMem[localMem[250]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 752;
      end

        752 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 339] = heapMem[localMem[302]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 753;
      end

        753 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[339] + 0 + i] = heapMem[NArea * localMem[338] + 0 + i];
                  updateArrayLength(1, localMem[339], 0 + i);
                end
              end
              ip = 754;
      end

        754 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 340] = heapMem[localMem[250]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 755;
      end

        755 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 341] = heapMem[localMem[305]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 756;
      end

        756 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[341] + 0 + i] = heapMem[NArea * localMem[340] + 2 + i];
                  updateArrayLength(1, localMem[341], 0 + i);
                end
              end
              ip = 757;
      end

        757 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 342] = heapMem[localMem[250]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 758;
      end

        758 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 343] = heapMem[localMem[305]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 759;
      end

        759 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[343] + 0 + i] = heapMem[NArea * localMem[342] + 2 + i];
                  updateArrayLength(1, localMem[343], 0 + i);
                end
              end
              ip = 760;
      end

        760 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 761;
      end

        761 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[302]*10 + 2] = localMem[250];
              updateArrayLength(1, localMem[302], 2);
              ip = 762;
      end

        762 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[305]*10 + 2] = localMem[250];
              updateArrayLength(1, localMem[305], 2);
              ip = 763;
      end

        763 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 344] = heapMem[localMem[250]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 764;
      end

        764 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 345] = heapMem[localMem[344]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 765;
      end

        765 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 346] = heapMem[localMem[250]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 766;
      end

        766 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 347] = heapMem[localMem[346]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 767;
      end

        767 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 348] = heapMem[localMem[250]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 768;
      end

        768 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[348]*10 + 0] = localMem[345];
              updateArrayLength(1, localMem[348], 0);
              ip = 769;
      end

        769 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 349] = heapMem[localMem[250]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 770;
      end

        770 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[349]*10 + 0] = localMem[347];
              updateArrayLength(1, localMem[349], 0);
              ip = 771;
      end

        771 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 350] = heapMem[localMem[250]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 772;
      end

        772 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[350]*10 + 0] = localMem[302];
              updateArrayLength(1, localMem[350], 0);
              ip = 773;
      end

        773 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 351] = heapMem[localMem[250]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 774;
      end

        774 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[351]*10 + 1] = localMem[305];
              updateArrayLength(1, localMem[351], 1);
              ip = 775;
      end

        775 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[250]*10 + 0] = 1;
              updateArrayLength(1, localMem[250], 0);
              ip = 776;
      end

        776 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 352] = heapMem[localMem[250]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 777;
      end

        777 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[352]] = 1;
              ip = 778;
      end

        778 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 353] = heapMem[localMem[250]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 779;
      end

        779 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[353]] = 1;
              ip = 780;
      end

        780 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 354] = heapMem[localMem[250]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 781;
      end

        781 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[354]] = 2;
              ip = 782;
      end

        782 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 784;
      end

        783 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 789;
      end

        784 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 785;
      end

        785 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 251] = 1;
              updateArrayLength(2, 0, 0);
              ip = 786;
      end

        786 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 789;
      end

        787 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 788;
      end

        788 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 251] = 0;
              updateArrayLength(2, 0, 0);
              ip = 789;
      end

        789 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 790;
      end

        790 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[251] != 0 ? 792 : 791;
      end

        791 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 28] = localMem[250];
              updateArrayLength(2, 0, 0);
              ip = 792;
      end

        792 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 793;
      end

        793 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 794;
      end

        794 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 133] = localMem[133] + 1;
              ip = 795;
      end

        795 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 305;
      end

        796 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 797;
      end

        797 :
      begin                                                                     // assert
//$display("AAAA %4d %4d assert", steps, ip);
            ip = 798;
      end

        798 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 799;
      end

        799 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 800;
      end

        800 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 801;
      end

        801 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 355] = heapMem[localMem[1]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 802;
      end

        802 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 356] = heapMem[localMem[1]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 803;
      end

        803 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 357] = heapMem[localMem[1]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 804;
      end

        804 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[356] != 1 ? 808 : 805;
      end

        805 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 358] = heapMem[localMem[355]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 806;
      end

        806 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[358]*10 + localMem[357]] = localMem[5];
              updateArrayLength(1, localMem[358], localMem[357]);
              ip = 807;
      end

        807 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1050;
      end

        808 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 809;
      end

        809 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[356] != 2 ? 817 : 810;
      end

        810 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 359] = localMem[357] + 1;
              ip = 811;
      end

        811 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 360] = heapMem[localMem[355]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 812;
      end

        812 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[360] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[359], localMem[360], arraySizes[localMem[360]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[359] && i <= arraySizes[localMem[360]]) begin
                  heapMem[NArea * localMem[360] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[360] + localMem[359]] = localMem[3];                                    // Insert new value
              arraySizes[localMem[360]] = arraySizes[localMem[360]] + 1;                              // Increase array size
              ip = 813;
      end

        813 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 361] = heapMem[localMem[355]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 814;
      end

        814 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[361] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[359], localMem[361], arraySizes[localMem[361]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[359] && i <= arraySizes[localMem[361]]) begin
                  heapMem[NArea * localMem[361] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[361] + localMem[359]] = localMem[5];                                    // Insert new value
              arraySizes[localMem[361]] = arraySizes[localMem[361]] + 1;                              // Increase array size
              ip = 815;
      end

        815 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[355]*10 + 0] = heapMem[localMem[355]*10 + 0] + 1;
              ip = 816;
      end

        816 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 823;
      end

        817 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 818;
      end

        818 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 362] = heapMem[localMem[355]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 819;
      end

        819 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[362] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[357], localMem[362], arraySizes[localMem[362]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[357] && i <= arraySizes[localMem[362]]) begin
                  heapMem[NArea * localMem[362] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[362] + localMem[357]] = localMem[3];                                    // Insert new value
              arraySizes[localMem[362]] = arraySizes[localMem[362]] + 1;                              // Increase array size
              ip = 820;
      end

        820 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 363] = heapMem[localMem[355]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 821;
      end

        821 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[363] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[357], localMem[363], arraySizes[localMem[363]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[357] && i <= arraySizes[localMem[363]]) begin
                  heapMem[NArea * localMem[363] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[363] + localMem[357]] = localMem[5];                                    // Insert new value
              arraySizes[localMem[363]] = arraySizes[localMem[363]] + 1;                              // Increase array size
              ip = 822;
      end

        822 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[355]*10 + 0] = heapMem[localMem[355]*10 + 0] + 1;
              ip = 823;
      end

        823 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 824;
      end

        824 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              ip = 825;
      end

        825 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 826;
      end

        826 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 365] = heapMem[localMem[355]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 827;
      end

        827 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[365] <  3 ? 1045 : 828;
      end

        828 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 366] = heapMem[localMem[355]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 829;
      end

        829 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 367] = heapMem[localMem[355]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 830;
      end

        830 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[367] == 0 ? 927 : 831;
      end

        831 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 368] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 368] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 368]] = 0;
              ip = 832;
      end

        832 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[368]*10 + 0] = 1;
              updateArrayLength(1, localMem[368], 0);
              ip = 833;
      end

        833 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[368]*10 + 2] = 0;
              updateArrayLength(1, localMem[368], 2);
              ip = 834;
      end

        834 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 369] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 369] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 369]] = 0;
              ip = 835;
      end

        835 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[368]*10 + 4] = localMem[369];
              updateArrayLength(1, localMem[368], 4);
              ip = 836;
      end

        836 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 370] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 370] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 370]] = 0;
              ip = 837;
      end

        837 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[368]*10 + 5] = localMem[370];
              updateArrayLength(1, localMem[368], 5);
              ip = 838;
      end

        838 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[368]*10 + 6] = 0;
              updateArrayLength(1, localMem[368], 6);
              ip = 839;
      end

        839 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[368]*10 + 3] = localMem[366];
              updateArrayLength(1, localMem[368], 3);
              ip = 840;
      end

        840 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[366]*10 + 1] = heapMem[localMem[366]*10 + 1] + 1;
              ip = 841;
      end

        841 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[368]*10 + 1] = heapMem[localMem[366]*10 + 1];
              updateArrayLength(1, localMem[368], 1);
              ip = 842;
      end

        842 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 371] = !heapMem[localMem[355]*10 + 6];
              ip = 843;
      end

        843 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[371] != 0 ? 872 : 844;
      end

        844 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 372] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 372] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 372]] = 0;
              ip = 845;
      end

        845 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[368]*10 + 6] = localMem[372];
              updateArrayLength(1, localMem[368], 6);
              ip = 846;
      end

        846 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 373] = heapMem[localMem[355]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 847;
      end

        847 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 374] = heapMem[localMem[368]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 848;
      end

        848 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[374] + 0 + i] = heapMem[NArea * localMem[373] + 2 + i];
                  updateArrayLength(1, localMem[374], 0 + i);
                end
              end
              ip = 849;
      end

        849 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 375] = heapMem[localMem[355]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 850;
      end

        850 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 376] = heapMem[localMem[368]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 851;
      end

        851 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[376] + 0 + i] = heapMem[NArea * localMem[375] + 2 + i];
                  updateArrayLength(1, localMem[376], 0 + i);
                end
              end
              ip = 852;
      end

        852 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 377] = heapMem[localMem[355]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 853;
      end

        853 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 378] = heapMem[localMem[368]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 854;
      end

        854 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 379] = 1 + 1;
              ip = 855;
      end

        855 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[379]) begin
                  heapMem[NArea * localMem[378] + 0 + i] = heapMem[NArea * localMem[377] + 2 + i];
                  updateArrayLength(1, localMem[378], 0 + i);
                end
              end
              ip = 856;
      end

        856 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 380] = heapMem[localMem[368]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 857;
      end

        857 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 381] = localMem[380] + 1;
              ip = 858;
      end

        858 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 382] = heapMem[localMem[368]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 859;
      end

        859 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 860;
      end

        860 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 383] = 0;
              updateArrayLength(2, 0, 0);
              ip = 861;
      end

        861 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 862;
      end

        862 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[383] >= localMem[381] ? 868 : 863;
      end

        863 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 384] = heapMem[localMem[382]*10 + localMem[383]];
              updateArrayLength(2, 0, 0);
              ip = 864;
      end

        864 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[384]*10 + 2] = localMem[368];
              updateArrayLength(1, localMem[384], 2);
              ip = 865;
      end

        865 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 866;
      end

        866 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 383] = localMem[383] + 1;
              ip = 867;
      end

        867 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 861;
      end

        868 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 869;
      end

        869 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 385] = heapMem[localMem[355]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 870;
      end

        870 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[385]] = 2;
              ip = 871;
      end

        871 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 879;
      end

        872 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 873;
      end

        873 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 386] = heapMem[localMem[355]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 874;
      end

        874 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 387] = heapMem[localMem[368]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 875;
      end

        875 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[387] + 0 + i] = heapMem[NArea * localMem[386] + 2 + i];
                  updateArrayLength(1, localMem[387], 0 + i);
                end
              end
              ip = 876;
      end

        876 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 388] = heapMem[localMem[355]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 877;
      end

        877 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 389] = heapMem[localMem[368]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 878;
      end

        878 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[389] + 0 + i] = heapMem[NArea * localMem[388] + 2 + i];
                  updateArrayLength(1, localMem[389], 0 + i);
                end
              end
              ip = 879;
      end

        879 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 880;
      end

        880 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[355]*10 + 0] = 1;
              updateArrayLength(1, localMem[355], 0);
              ip = 881;
      end

        881 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[368]*10 + 2] = localMem[367];
              updateArrayLength(1, localMem[368], 2);
              ip = 882;
      end

        882 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 390] = heapMem[localMem[367]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 883;
      end

        883 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 391] = heapMem[localMem[367]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 884;
      end

        884 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 392] = heapMem[localMem[391]*10 + localMem[390]];
              updateArrayLength(2, 0, 0);
              ip = 885;
      end

        885 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[392] != localMem[355] ? 904 : 886;
      end

        886 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 393] = heapMem[localMem[355]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 887;
      end

        887 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 394] = heapMem[localMem[393]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 888;
      end

        888 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 395] = heapMem[localMem[367]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 889;
      end

        889 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[395]*10 + localMem[390]] = localMem[394];
              updateArrayLength(1, localMem[395], localMem[390]);
              ip = 890;
      end

        890 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 396] = heapMem[localMem[355]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 891;
      end

        891 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 397] = heapMem[localMem[396]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 892;
      end

        892 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 398] = heapMem[localMem[367]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 893;
      end

        893 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[398]*10 + localMem[390]] = localMem[397];
              updateArrayLength(1, localMem[398], localMem[390]);
              ip = 894;
      end

        894 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 399] = heapMem[localMem[355]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 895;
      end

        895 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[399]] = 1;
              ip = 896;
      end

        896 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 400] = heapMem[localMem[355]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 897;
      end

        897 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[400]] = 1;
              ip = 898;
      end

        898 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 401] = localMem[390] + 1;
              ip = 899;
      end

        899 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[367]*10 + 0] = localMem[401];
              updateArrayLength(1, localMem[367], 0);
              ip = 900;
      end

        900 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 402] = heapMem[localMem[367]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 901;
      end

        901 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[402]*10 + localMem[401]] = localMem[368];
              updateArrayLength(1, localMem[402], localMem[401]);
              ip = 902;
      end

        902 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1042;
      end

        903 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 926;
      end

        904 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 905;
      end

        905 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 906;
      end

        906 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 403] = heapMem[localMem[367]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 907;
      end

        907 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 404] = 0; k = arraySizes[localMem[403]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[403] * NArea + i] == localMem[355]) localMem[0 + 404] = i + 1;
              end
              ip = 908;
      end

        908 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 404] = localMem[404] - 1;
              ip = 909;
      end

        909 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 405] = heapMem[localMem[355]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 910;
      end

        910 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 406] = heapMem[localMem[405]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 911;
      end

        911 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 407] = heapMem[localMem[355]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 912;
      end

        912 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 408] = heapMem[localMem[407]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 913;
      end

        913 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 409] = heapMem[localMem[355]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 914;
      end

        914 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[409]] = 1;
              ip = 915;
      end

        915 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 410] = heapMem[localMem[355]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 916;
      end

        916 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[410]] = 1;
              ip = 917;
      end

        917 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 411] = heapMem[localMem[367]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 918;
      end

        918 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[411] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[404], localMem[411], arraySizes[localMem[411]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[404] && i <= arraySizes[localMem[411]]) begin
                  heapMem[NArea * localMem[411] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[411] + localMem[404]] = localMem[406];                                    // Insert new value
              arraySizes[localMem[411]] = arraySizes[localMem[411]] + 1;                              // Increase array size
              ip = 919;
      end

        919 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 412] = heapMem[localMem[367]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 920;
      end

        920 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[412] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[404], localMem[412], arraySizes[localMem[412]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[404] && i <= arraySizes[localMem[412]]) begin
                  heapMem[NArea * localMem[412] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[412] + localMem[404]] = localMem[408];                                    // Insert new value
              arraySizes[localMem[412]] = arraySizes[localMem[412]] + 1;                              // Increase array size
              ip = 921;
      end

        921 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 413] = heapMem[localMem[367]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 922;
      end

        922 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 414] = localMem[404] + 1;
              ip = 923;
      end

        923 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[413] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[414], localMem[413], arraySizes[localMem[413]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[414] && i <= arraySizes[localMem[413]]) begin
                  heapMem[NArea * localMem[413] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[413] + localMem[414]] = localMem[368];                                    // Insert new value
              arraySizes[localMem[413]] = arraySizes[localMem[413]] + 1;                              // Increase array size
              ip = 924;
      end

        924 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[367]*10 + 0] = heapMem[localMem[367]*10 + 0] + 1;
              ip = 925;
      end

        925 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1042;
      end

        926 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 927;
      end

        927 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 928;
      end

        928 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 415] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 415] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 415]] = 0;
              ip = 929;
      end

        929 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[415]*10 + 0] = 1;
              updateArrayLength(1, localMem[415], 0);
              ip = 930;
      end

        930 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[415]*10 + 2] = 0;
              updateArrayLength(1, localMem[415], 2);
              ip = 931;
      end

        931 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 416] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 416] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 416]] = 0;
              ip = 932;
      end

        932 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[415]*10 + 4] = localMem[416];
              updateArrayLength(1, localMem[415], 4);
              ip = 933;
      end

        933 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 417] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 417] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 417]] = 0;
              ip = 934;
      end

        934 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[415]*10 + 5] = localMem[417];
              updateArrayLength(1, localMem[415], 5);
              ip = 935;
      end

        935 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[415]*10 + 6] = 0;
              updateArrayLength(1, localMem[415], 6);
              ip = 936;
      end

        936 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[415]*10 + 3] = localMem[366];
              updateArrayLength(1, localMem[415], 3);
              ip = 937;
      end

        937 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[366]*10 + 1] = heapMem[localMem[366]*10 + 1] + 1;
              ip = 938;
      end

        938 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[415]*10 + 1] = heapMem[localMem[366]*10 + 1];
              updateArrayLength(1, localMem[415], 1);
              ip = 939;
      end

        939 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 418] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 418] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 418]] = 0;
              ip = 940;
      end

        940 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[418]*10 + 0] = 1;
              updateArrayLength(1, localMem[418], 0);
              ip = 941;
      end

        941 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[418]*10 + 2] = 0;
              updateArrayLength(1, localMem[418], 2);
              ip = 942;
      end

        942 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 419] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 419] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 419]] = 0;
              ip = 943;
      end

        943 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[418]*10 + 4] = localMem[419];
              updateArrayLength(1, localMem[418], 4);
              ip = 944;
      end

        944 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 420] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 420] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 420]] = 0;
              ip = 945;
      end

        945 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[418]*10 + 5] = localMem[420];
              updateArrayLength(1, localMem[418], 5);
              ip = 946;
      end

        946 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[418]*10 + 6] = 0;
              updateArrayLength(1, localMem[418], 6);
              ip = 947;
      end

        947 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[418]*10 + 3] = localMem[366];
              updateArrayLength(1, localMem[418], 3);
              ip = 948;
      end

        948 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[366]*10 + 1] = heapMem[localMem[366]*10 + 1] + 1;
              ip = 949;
      end

        949 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[418]*10 + 1] = heapMem[localMem[366]*10 + 1];
              updateArrayLength(1, localMem[418], 1);
              ip = 950;
      end

        950 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 421] = !heapMem[localMem[355]*10 + 6];
              ip = 951;
      end

        951 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[421] != 0 ? 1003 : 952;
      end

        952 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 422] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 422] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 422]] = 0;
              ip = 953;
      end

        953 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[415]*10 + 6] = localMem[422];
              updateArrayLength(1, localMem[415], 6);
              ip = 954;
      end

        954 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 423] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 423] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 423]] = 0;
              ip = 955;
      end

        955 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[418]*10 + 6] = localMem[423];
              updateArrayLength(1, localMem[418], 6);
              ip = 956;
      end

        956 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 424] = heapMem[localMem[355]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 957;
      end

        957 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 425] = heapMem[localMem[415]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 958;
      end

        958 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[425] + 0 + i] = heapMem[NArea * localMem[424] + 0 + i];
                  updateArrayLength(1, localMem[425], 0 + i);
                end
              end
              ip = 959;
      end

        959 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 426] = heapMem[localMem[355]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 960;
      end

        960 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 427] = heapMem[localMem[415]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 961;
      end

        961 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[427] + 0 + i] = heapMem[NArea * localMem[426] + 0 + i];
                  updateArrayLength(1, localMem[427], 0 + i);
                end
              end
              ip = 962;
      end

        962 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 428] = heapMem[localMem[355]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 963;
      end

        963 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 429] = heapMem[localMem[415]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 964;
      end

        964 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 430] = 1 + 1;
              ip = 965;
      end

        965 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[430]) begin
                  heapMem[NArea * localMem[429] + 0 + i] = heapMem[NArea * localMem[428] + 0 + i];
                  updateArrayLength(1, localMem[429], 0 + i);
                end
              end
              ip = 966;
      end

        966 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 431] = heapMem[localMem[355]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 967;
      end

        967 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 432] = heapMem[localMem[418]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 968;
      end

        968 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[432] + 0 + i] = heapMem[NArea * localMem[431] + 2 + i];
                  updateArrayLength(1, localMem[432], 0 + i);
                end
              end
              ip = 969;
      end

        969 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 433] = heapMem[localMem[355]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 970;
      end

        970 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 434] = heapMem[localMem[418]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 971;
      end

        971 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[434] + 0 + i] = heapMem[NArea * localMem[433] + 2 + i];
                  updateArrayLength(1, localMem[434], 0 + i);
                end
              end
              ip = 972;
      end

        972 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 435] = heapMem[localMem[355]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 973;
      end

        973 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 436] = heapMem[localMem[418]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 974;
      end

        974 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 437] = 1 + 1;
              ip = 975;
      end

        975 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[437]) begin
                  heapMem[NArea * localMem[436] + 0 + i] = heapMem[NArea * localMem[435] + 2 + i];
                  updateArrayLength(1, localMem[436], 0 + i);
                end
              end
              ip = 976;
      end

        976 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 438] = heapMem[localMem[415]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 977;
      end

        977 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 439] = localMem[438] + 1;
              ip = 978;
      end

        978 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 440] = heapMem[localMem[415]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 979;
      end

        979 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 980;
      end

        980 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 441] = 0;
              updateArrayLength(2, 0, 0);
              ip = 981;
      end

        981 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 982;
      end

        982 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[441] >= localMem[439] ? 988 : 983;
      end

        983 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 442] = heapMem[localMem[440]*10 + localMem[441]];
              updateArrayLength(2, 0, 0);
              ip = 984;
      end

        984 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[442]*10 + 2] = localMem[415];
              updateArrayLength(1, localMem[442], 2);
              ip = 985;
      end

        985 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 986;
      end

        986 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 441] = localMem[441] + 1;
              ip = 987;
      end

        987 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 981;
      end

        988 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 989;
      end

        989 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 443] = heapMem[localMem[418]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 990;
      end

        990 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 444] = localMem[443] + 1;
              ip = 991;
      end

        991 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 445] = heapMem[localMem[418]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 992;
      end

        992 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 993;
      end

        993 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 446] = 0;
              updateArrayLength(2, 0, 0);
              ip = 994;
      end

        994 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 995;
      end

        995 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[446] >= localMem[444] ? 1001 : 996;
      end

        996 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 447] = heapMem[localMem[445]*10 + localMem[446]];
              updateArrayLength(2, 0, 0);
              ip = 997;
      end

        997 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[447]*10 + 2] = localMem[418];
              updateArrayLength(1, localMem[447], 2);
              ip = 998;
      end

        998 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 999;
      end

        999 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 446] = localMem[446] + 1;
              ip = 1000;
      end

       1000 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 994;
      end

       1001 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1002;
      end

       1002 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1018;
      end

       1003 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1004;
      end

       1004 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 448] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 448] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 448]] = 0;
              ip = 1005;
      end

       1005 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[355]*10 + 6] = localMem[448];
              updateArrayLength(1, localMem[355], 6);
              ip = 1006;
      end

       1006 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 449] = heapMem[localMem[355]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1007;
      end

       1007 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 450] = heapMem[localMem[415]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1008;
      end

       1008 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[450] + 0 + i] = heapMem[NArea * localMem[449] + 0 + i];
                  updateArrayLength(1, localMem[450], 0 + i);
                end
              end
              ip = 1009;
      end

       1009 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 451] = heapMem[localMem[355]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1010;
      end

       1010 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 452] = heapMem[localMem[415]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1011;
      end

       1011 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[452] + 0 + i] = heapMem[NArea * localMem[451] + 0 + i];
                  updateArrayLength(1, localMem[452], 0 + i);
                end
              end
              ip = 1012;
      end

       1012 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 453] = heapMem[localMem[355]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1013;
      end

       1013 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 454] = heapMem[localMem[418]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1014;
      end

       1014 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[454] + 0 + i] = heapMem[NArea * localMem[453] + 2 + i];
                  updateArrayLength(1, localMem[454], 0 + i);
                end
              end
              ip = 1015;
      end

       1015 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 455] = heapMem[localMem[355]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1016;
      end

       1016 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 456] = heapMem[localMem[418]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1017;
      end

       1017 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 1) begin
                  heapMem[NArea * localMem[456] + 0 + i] = heapMem[NArea * localMem[455] + 2 + i];
                  updateArrayLength(1, localMem[456], 0 + i);
                end
              end
              ip = 1018;
      end

       1018 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1019;
      end

       1019 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[415]*10 + 2] = localMem[355];
              updateArrayLength(1, localMem[415], 2);
              ip = 1020;
      end

       1020 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[418]*10 + 2] = localMem[355];
              updateArrayLength(1, localMem[418], 2);
              ip = 1021;
      end

       1021 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 457] = heapMem[localMem[355]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1022;
      end

       1022 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 458] = heapMem[localMem[457]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 1023;
      end

       1023 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 459] = heapMem[localMem[355]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1024;
      end

       1024 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 460] = heapMem[localMem[459]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 1025;
      end

       1025 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 461] = heapMem[localMem[355]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1026;
      end

       1026 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[461]*10 + 0] = localMem[458];
              updateArrayLength(1, localMem[461], 0);
              ip = 1027;
      end

       1027 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 462] = heapMem[localMem[355]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1028;
      end

       1028 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[462]*10 + 0] = localMem[460];
              updateArrayLength(1, localMem[462], 0);
              ip = 1029;
      end

       1029 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 463] = heapMem[localMem[355]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1030;
      end

       1030 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[463]*10 + 0] = localMem[415];
              updateArrayLength(1, localMem[463], 0);
              ip = 1031;
      end

       1031 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 464] = heapMem[localMem[355]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1032;
      end

       1032 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[464]*10 + 1] = localMem[418];
              updateArrayLength(1, localMem[464], 1);
              ip = 1033;
      end

       1033 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[355]*10 + 0] = 1;
              updateArrayLength(1, localMem[355], 0);
              ip = 1034;
      end

       1034 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 465] = heapMem[localMem[355]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1035;
      end

       1035 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[465]] = 1;
              ip = 1036;
      end

       1036 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 466] = heapMem[localMem[355]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1037;
      end

       1037 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[466]] = 1;
              ip = 1038;
      end

       1038 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 467] = heapMem[localMem[355]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1039;
      end

       1039 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[467]] = 2;
              ip = 1040;
      end

       1040 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1042;
      end

       1041 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1047;
      end

       1042 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1043;
      end

       1043 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 364] = 1;
              updateArrayLength(2, 0, 0);
              ip = 1044;
      end

       1044 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1047;
      end

       1045 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1046;
      end

       1046 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 364] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1047;
      end

       1047 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1048;
      end

       1048 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1049;
      end

       1049 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1050;
      end

       1050 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1051;
      end

       1051 :
      begin                                                                     // tally
//$display("AAAA %4d %4d tally", steps, ip);
            ip = 1052;
      end

       1052 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1053;
      end

       1053 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 6;
      end

       1054 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1055;
      end

       1055 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 468] = 1;
              updateArrayLength(2, 0, 0);
              ip = 1056;
      end

       1056 :
      begin                                                                     // shiftLeft
//$display("AAAA %4d %4d shiftLeft", steps, ip);
              localMem[0 + 468] = localMem[468] << 31;
              ip = 1057;
      end

       1057 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 469] = heapMem[localMem[0]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 1058;
      end

       1058 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 470] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 470] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 470]] = 0;
              ip = 1059;
      end

       1059 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 471] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 471] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 471]] = 0;
              ip = 1060;
      end

       1060 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[469] != 0 ? 1065 : 1061;
      end

       1061 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[470]*10 + 0] = localMem[469];
              updateArrayLength(1, localMem[470], 0);
              ip = 1062;
      end

       1062 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[470]*10 + 1] = 3;
              updateArrayLength(1, localMem[470], 1);
              ip = 1063;
      end

       1063 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[470]*10 + 2] = 0;
              updateArrayLength(1, localMem[470], 2);
              ip = 1064;
      end

       1064 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1082;
      end

       1065 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1066;
      end

       1066 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1067;
      end

       1067 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 472] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1068;
      end

       1068 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1069;
      end

       1069 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[472] >= 99 ? 1078 : 1070;
      end

       1070 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 473] = !heapMem[localMem[469]*10 + 6];
              ip = 1071;
      end

       1071 :
      begin                                                                     // jTrue
//$display("AAAA %4d %4d jTrue", steps, ip);
              ip = localMem[473] != 0 ? 1078 : 1072;
      end

       1072 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 474] = heapMem[localMem[469]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1073;
      end

       1073 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 475] = heapMem[localMem[474]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1074;
      end

       1074 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 469] = localMem[475];
              updateArrayLength(2, 0, 0);
              ip = 1075;
      end

       1075 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1076;
      end

       1076 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 472] = localMem[472] + 1;
              ip = 1077;
      end

       1077 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1068;
      end

       1078 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1079;
      end

       1079 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[470]*10 + 0] = localMem[469];
              updateArrayLength(1, localMem[470], 0);
              ip = 1080;
      end

       1080 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[470]*10 + 1] = 1;
              updateArrayLength(1, localMem[470], 1);
              ip = 1081;
      end

       1081 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[470]*10 + 2] = 0;
              updateArrayLength(1, localMem[470], 2);
              ip = 1082;
      end

       1082 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1083;
      end

       1083 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1084;
      end

       1084 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 476] = heapMem[localMem[470]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 1085;
      end

       1085 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[476] == 3 ? 1230 : 1086;
      end

       1086 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 3) begin
                  heapMem[NArea * localMem[471] + 0 + i] = heapMem[NArea * localMem[470] + 0 + i];
                  updateArrayLength(1, localMem[471], 0 + i);
                end
              end
              ip = 1087;
      end

       1087 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 477] = heapMem[localMem[471]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1088;
      end

       1088 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 478] = heapMem[localMem[471]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1089;
      end

       1089 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 479] = heapMem[localMem[477]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1090;
      end

       1090 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 480] = heapMem[localMem[479]*10 + localMem[478]];
              updateArrayLength(2, 0, 0);
              ip = 1091;
      end

       1091 :
      begin                                                                     // out
//$display("AAAA %4d %4d out", steps, ip);
              outMem[outMemPos] = localMem[480];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 1092;
      end

       1092 :
      begin                                                                     // tally
//$display("AAAA %4d %4d tally", steps, ip);
            ip = 1093;
      end

       1093 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1094;
      end

       1094 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 481] = heapMem[localMem[0]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 1095;
      end

       1095 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[481] != 0 ? 1100 : 1096;
      end

       1096 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 0] = localMem[481];
              updateArrayLength(1, localMem[1], 0);
              ip = 1097;
      end

       1097 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 1] = 3;
              updateArrayLength(1, localMem[1], 1);
              ip = 1098;
      end

       1098 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 2] = 0;
              updateArrayLength(1, localMem[1], 2);
              ip = 1099;
      end

       1099 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1146;
      end

       1100 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1101;
      end

       1101 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1102;
      end

       1102 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 482] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1103;
      end

       1103 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1104;
      end

       1104 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[482] >= 99 ? 1142 : 1105;
      end

       1105 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 483] = heapMem[localMem[481]*10 + 0] - 1;
              ip = 1106;
      end

       1106 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 484] = heapMem[localMem[481]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1107;
      end

       1107 :
      begin                                                                     // jLe
//$display("AAAA %4d %4d jLe", steps, ip);
              ip = localMem[480] <= heapMem[localMem[484]*10 + localMem[483]] ? 1120 : 1108;
      end

       1108 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 485] = localMem[483] + 1;
              ip = 1109;
      end

       1109 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 486] = !heapMem[localMem[481]*10 + 6];
              ip = 1110;
      end

       1110 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[486] == 0 ? 1115 : 1111;
      end

       1111 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 0] = localMem[481];
              updateArrayLength(1, localMem[1], 0);
              ip = 1112;
      end

       1112 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 1] = 2;
              updateArrayLength(1, localMem[1], 1);
              ip = 1113;
      end

       1113 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 2] = localMem[485];
              updateArrayLength(1, localMem[1], 2);
              ip = 1114;
      end

       1114 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1146;
      end

       1115 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1116;
      end

       1116 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 487] = heapMem[localMem[481]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1117;
      end

       1117 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 488] = heapMem[localMem[487]*10 + localMem[485]];
              updateArrayLength(2, 0, 0);
              ip = 1118;
      end

       1118 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 481] = localMem[488];
              updateArrayLength(2, 0, 0);
              ip = 1119;
      end

       1119 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1139;
      end

       1120 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1121;
      end

       1121 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 489] = 0; k = arraySizes[localMem[484]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[484] * NArea + i] == localMem[480]) localMem[0 + 489] = i + 1;
              end
              ip = 1122;
      end

       1122 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[489] == 0 ? 1127 : 1123;
      end

       1123 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 0] = localMem[481];
              updateArrayLength(1, localMem[1], 0);
              ip = 1124;
      end

       1124 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 1] = 1;
              updateArrayLength(1, localMem[1], 1);
              ip = 1125;
      end

       1125 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              heapMem[localMem[1]*10 + 2] = localMem[489] - 1;
              ip = 1126;
      end

       1126 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1146;
      end

       1127 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1128;
      end

       1128 :
      begin                                                                     // arrayCountLess
//$display("AAAA %4d %4d arrayCountLess", steps, ip);
              j = 0; k = arraySizes[localMem[484]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[484] * NArea + i] < localMem[480]) j = j + 1;
              end
              localMem[0 + 490] = j;
              ip = 1129;
      end

       1129 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 491] = !heapMem[localMem[481]*10 + 6];
              ip = 1130;
      end

       1130 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[491] == 0 ? 1135 : 1131;
      end

       1131 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 0] = localMem[481];
              updateArrayLength(1, localMem[1], 0);
              ip = 1132;
      end

       1132 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 1] = 0;
              updateArrayLength(1, localMem[1], 1);
              ip = 1133;
      end

       1133 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 2] = localMem[490];
              updateArrayLength(1, localMem[1], 2);
              ip = 1134;
      end

       1134 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1146;
      end

       1135 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1136;
      end

       1136 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 492] = heapMem[localMem[481]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1137;
      end

       1137 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 493] = heapMem[localMem[492]*10 + localMem[490]];
              updateArrayLength(2, 0, 0);
              ip = 1138;
      end

       1138 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 481] = localMem[493];
              updateArrayLength(2, 0, 0);
              ip = 1139;
      end

       1139 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1140;
      end

       1140 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 482] = localMem[482] + 1;
              ip = 1141;
      end

       1141 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1103;
      end

       1142 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1143;
      end

       1143 :
      begin                                                                     // assert
//$display("AAAA %4d %4d assert", steps, ip);
            ip = 1144;
      end

       1144 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1145;
      end

       1145 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1146;
      end

       1146 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1147;
      end

       1147 :
      begin                                                                     // tally
//$display("AAAA %4d %4d tally", steps, ip);
            ip = 1148;
      end

       1148 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 494] = heapMem[localMem[1]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1149;
      end

       1149 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 495] = heapMem[localMem[1]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1150;
      end

       1150 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 496] = heapMem[localMem[494]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1151;
      end

       1151 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 497] = heapMem[localMem[496]*10 + localMem[495]];
              updateArrayLength(2, 0, 0);
              ip = 1152;
      end

       1152 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 498] = localMem[480] + localMem[480];
              ip = 1153;
      end

       1153 :
      begin                                                                     // assertEq
//$display("AAAA %4d %4d assertEq", steps, ip);
            ip = 1154;
      end

       1154 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1155;
      end

       1155 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 499] = heapMem[localMem[470]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1156;
      end

       1156 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 500] = !heapMem[localMem[499]*10 + 6];
              ip = 1157;
      end

       1157 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[500] == 0 ? 1197 : 1158;
      end

       1158 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 501] = heapMem[localMem[470]*10 + 2] + 1;
              ip = 1159;
      end

       1159 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 502] = heapMem[localMem[499]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1160;
      end

       1160 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[501] >= localMem[502] ? 1165 : 1161;
      end

       1161 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[470]*10 + 0] = localMem[499];
              updateArrayLength(1, localMem[470], 0);
              ip = 1162;
      end

       1162 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[470]*10 + 1] = 1;
              updateArrayLength(1, localMem[470], 1);
              ip = 1163;
      end

       1163 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[470]*10 + 2] = localMem[501];
              updateArrayLength(1, localMem[470], 2);
              ip = 1164;
      end

       1164 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1226;
      end

       1165 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1166;
      end

       1166 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 503] = heapMem[localMem[499]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1167;
      end

       1167 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[503] == 0 ? 1192 : 1168;
      end

       1168 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1169;
      end

       1169 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 504] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1170;
      end

       1170 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1171;
      end

       1171 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[504] >= 99 ? 1191 : 1172;
      end

       1172 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 505] = heapMem[localMem[503]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1173;
      end

       1173 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 1174;
      end

       1174 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 506] = heapMem[localMem[503]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1175;
      end

       1175 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 507] = 0; k = arraySizes[localMem[506]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[506] * NArea + i] == localMem[499]) localMem[0 + 507] = i + 1;
              end
              ip = 1176;
      end

       1176 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 507] = localMem[507] - 1;
              ip = 1177;
      end

       1177 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[507] != localMem[505] ? 1182 : 1178;
      end

       1178 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 499] = localMem[503];
              updateArrayLength(2, 0, 0);
              ip = 1179;
      end

       1179 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 503] = heapMem[localMem[499]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1180;
      end

       1180 :
      begin                                                                     // jFalse
//$display("AAAA %4d %4d jFalse", steps, ip);
              ip = localMem[503] == 0 ? 1191 : 1181;
      end

       1181 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1187;
      end

       1182 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1183;
      end

       1183 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[470]*10 + 0] = localMem[503];
              updateArrayLength(1, localMem[470], 0);
              ip = 1184;
      end

       1184 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[470]*10 + 1] = 1;
              updateArrayLength(1, localMem[470], 1);
              ip = 1185;
      end

       1185 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[470]*10 + 2] = localMem[507];
              updateArrayLength(1, localMem[470], 2);
              ip = 1186;
      end

       1186 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1226;
      end

       1187 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1188;
      end

       1188 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1189;
      end

       1189 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 504] = localMem[504] + 1;
              ip = 1190;
      end

       1190 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1170;
      end

       1191 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1192;
      end

       1192 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1193;
      end

       1193 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[470]*10 + 0] = localMem[499];
              updateArrayLength(1, localMem[470], 0);
              ip = 1194;
      end

       1194 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[470]*10 + 1] = 3;
              updateArrayLength(1, localMem[470], 1);
              ip = 1195;
      end

       1195 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[470]*10 + 2] = 0;
              updateArrayLength(1, localMem[470], 2);
              ip = 1196;
      end

       1196 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1226;
      end

       1197 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1198;
      end

       1198 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 508] = heapMem[localMem[470]*10 + 2] + 1;
              ip = 1199;
      end

       1199 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 509] = heapMem[localMem[499]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1200;
      end

       1200 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 510] = heapMem[localMem[509]*10 + localMem[508]];
              updateArrayLength(2, 0, 0);
              ip = 1201;
      end

       1201 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[510] != 0 ? 1206 : 1202;
      end

       1202 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[470]*10 + 0] = localMem[510];
              updateArrayLength(1, localMem[470], 0);
              ip = 1203;
      end

       1203 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[470]*10 + 1] = 3;
              updateArrayLength(1, localMem[470], 1);
              ip = 1204;
      end

       1204 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[470]*10 + 2] = 0;
              updateArrayLength(1, localMem[470], 2);
              ip = 1205;
      end

       1205 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1223;
      end

       1206 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1207;
      end

       1207 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1208;
      end

       1208 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 511] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1209;
      end

       1209 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1210;
      end

       1210 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[511] >= 99 ? 1219 : 1211;
      end

       1211 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 512] = !heapMem[localMem[510]*10 + 6];
              ip = 1212;
      end

       1212 :
      begin                                                                     // jTrue
//$display("AAAA %4d %4d jTrue", steps, ip);
              ip = localMem[512] != 0 ? 1219 : 1213;
      end

       1213 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 513] = heapMem[localMem[510]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1214;
      end

       1214 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 514] = heapMem[localMem[513]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1215;
      end

       1215 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 510] = localMem[514];
              updateArrayLength(2, 0, 0);
              ip = 1216;
      end

       1216 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1217;
      end

       1217 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 511] = localMem[511] + 1;
              ip = 1218;
      end

       1218 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1209;
      end

       1219 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1220;
      end

       1220 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[470]*10 + 0] = localMem[510];
              updateArrayLength(1, localMem[470], 0);
              ip = 1221;
      end

       1221 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[470]*10 + 1] = 1;
              updateArrayLength(1, localMem[470], 1);
              ip = 1222;
      end

       1222 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[470]*10 + 2] = 0;
              updateArrayLength(1, localMem[470], 2);
              ip = 1223;
      end

       1223 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1224;
      end

       1224 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1225;
      end

       1225 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1226;
      end

       1226 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1227;
      end

       1227 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1083;
      end

       1228 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1229;
      end

       1229 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1230;
      end

       1230 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1231;
      end

       1231 :
      begin                                                                     // free
//$display("AAAA %4d %4d free", steps, ip);
              freedArrays[freedArraysTop] = localMem[470];
              freedArraysTop = freedArraysTop + 1;
              ip = 1232;
      end

       1232 :
      begin                                                                     // free
//$display("AAAA %4d %4d free", steps, ip);
              freedArrays[freedArraysTop] = localMem[471];
              freedArraysTop = freedArraysTop + 1;
              ip = 1233;
      end

       1233 :
      begin                                                                     // tally
//$display("AAAA %4d %4d tally", steps, ip);
            ip = 1234;
      end

       1234 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 515] = 1;
              updateArrayLength(2, 0, 0);
              ip = 1235;
      end

       1235 :
      begin                                                                     // shiftLeft
//$display("AAAA %4d %4d shiftLeft", steps, ip);
              localMem[0 + 515] = localMem[515] << 31;
              ip = 1236;
      end

       1236 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 516] = heapMem[localMem[0]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 1237;
      end

       1237 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 517] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 517] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 517]] = 0;
              ip = 1238;
      end

       1238 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 518] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 518] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 518]] = 0;
              ip = 1239;
      end

       1239 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[516] != 0 ? 1244 : 1240;
      end

       1240 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[517]*10 + 0] = localMem[516];
              updateArrayLength(1, localMem[517], 0);
              ip = 1241;
      end

       1241 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[517]*10 + 1] = 3;
              updateArrayLength(1, localMem[517], 1);
              ip = 1242;
      end

       1242 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[517]*10 + 2] = 0;
              updateArrayLength(1, localMem[517], 2);
              ip = 1243;
      end

       1243 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1261;
      end

       1244 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1245;
      end

       1245 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1246;
      end

       1246 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 519] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1247;
      end

       1247 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1248;
      end

       1248 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[519] >= 99 ? 1257 : 1249;
      end

       1249 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 520] = !heapMem[localMem[516]*10 + 6];
              ip = 1250;
      end

       1250 :
      begin                                                                     // jTrue
//$display("AAAA %4d %4d jTrue", steps, ip);
              ip = localMem[520] != 0 ? 1257 : 1251;
      end

       1251 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 521] = heapMem[localMem[516]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1252;
      end

       1252 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 522] = heapMem[localMem[521]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1253;
      end

       1253 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 516] = localMem[522];
              updateArrayLength(2, 0, 0);
              ip = 1254;
      end

       1254 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1255;
      end

       1255 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 519] = localMem[519] + 1;
              ip = 1256;
      end

       1256 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1247;
      end

       1257 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1258;
      end

       1258 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[517]*10 + 0] = localMem[516];
              updateArrayLength(1, localMem[517], 0);
              ip = 1259;
      end

       1259 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[517]*10 + 1] = 1;
              updateArrayLength(1, localMem[517], 1);
              ip = 1260;
      end

       1260 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[517]*10 + 2] = 0;
              updateArrayLength(1, localMem[517], 2);
              ip = 1261;
      end

       1261 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1262;
      end

       1262 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1263;
      end

       1263 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 523] = heapMem[localMem[517]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 1264;
      end

       1264 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[523] == 3 ? 1342 : 1265;
      end

       1265 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 3) begin
                  heapMem[NArea * localMem[518] + 0 + i] = heapMem[NArea * localMem[517] + 0 + i];
                  updateArrayLength(1, localMem[518], 0 + i);
                end
              end
              ip = 1266;
      end

       1266 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1267;
      end

       1267 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 524] = heapMem[localMem[517]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1268;
      end

       1268 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 525] = !heapMem[localMem[524]*10 + 6];
              ip = 1269;
      end

       1269 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[525] == 0 ? 1309 : 1270;
      end

       1270 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 526] = heapMem[localMem[517]*10 + 2] + 1;
              ip = 1271;
      end

       1271 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 527] = heapMem[localMem[524]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1272;
      end

       1272 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[526] >= localMem[527] ? 1277 : 1273;
      end

       1273 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[517]*10 + 0] = localMem[524];
              updateArrayLength(1, localMem[517], 0);
              ip = 1274;
      end

       1274 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[517]*10 + 1] = 1;
              updateArrayLength(1, localMem[517], 1);
              ip = 1275;
      end

       1275 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[517]*10 + 2] = localMem[526];
              updateArrayLength(1, localMem[517], 2);
              ip = 1276;
      end

       1276 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1338;
      end

       1277 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1278;
      end

       1278 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 528] = heapMem[localMem[524]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1279;
      end

       1279 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[528] == 0 ? 1304 : 1280;
      end

       1280 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1281;
      end

       1281 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 529] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1282;
      end

       1282 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1283;
      end

       1283 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[529] >= 99 ? 1303 : 1284;
      end

       1284 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 530] = heapMem[localMem[528]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1285;
      end

       1285 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 1286;
      end

       1286 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 531] = heapMem[localMem[528]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1287;
      end

       1287 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 532] = 0; k = arraySizes[localMem[531]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[531] * NArea + i] == localMem[524]) localMem[0 + 532] = i + 1;
              end
              ip = 1288;
      end

       1288 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 532] = localMem[532] - 1;
              ip = 1289;
      end

       1289 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[532] != localMem[530] ? 1294 : 1290;
      end

       1290 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 524] = localMem[528];
              updateArrayLength(2, 0, 0);
              ip = 1291;
      end

       1291 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 528] = heapMem[localMem[524]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1292;
      end

       1292 :
      begin                                                                     // jFalse
//$display("AAAA %4d %4d jFalse", steps, ip);
              ip = localMem[528] == 0 ? 1303 : 1293;
      end

       1293 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1299;
      end

       1294 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1295;
      end

       1295 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[517]*10 + 0] = localMem[528];
              updateArrayLength(1, localMem[517], 0);
              ip = 1296;
      end

       1296 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[517]*10 + 1] = 1;
              updateArrayLength(1, localMem[517], 1);
              ip = 1297;
      end

       1297 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[517]*10 + 2] = localMem[532];
              updateArrayLength(1, localMem[517], 2);
              ip = 1298;
      end

       1298 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1338;
      end

       1299 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1300;
      end

       1300 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1301;
      end

       1301 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 529] = localMem[529] + 1;
              ip = 1302;
      end

       1302 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1282;
      end

       1303 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1304;
      end

       1304 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1305;
      end

       1305 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[517]*10 + 0] = localMem[524];
              updateArrayLength(1, localMem[517], 0);
              ip = 1306;
      end

       1306 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[517]*10 + 1] = 3;
              updateArrayLength(1, localMem[517], 1);
              ip = 1307;
      end

       1307 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[517]*10 + 2] = 0;
              updateArrayLength(1, localMem[517], 2);
              ip = 1308;
      end

       1308 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1338;
      end

       1309 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1310;
      end

       1310 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 533] = heapMem[localMem[517]*10 + 2] + 1;
              ip = 1311;
      end

       1311 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 534] = heapMem[localMem[524]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1312;
      end

       1312 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 535] = heapMem[localMem[534]*10 + localMem[533]];
              updateArrayLength(2, 0, 0);
              ip = 1313;
      end

       1313 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[535] != 0 ? 1318 : 1314;
      end

       1314 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[517]*10 + 0] = localMem[535];
              updateArrayLength(1, localMem[517], 0);
              ip = 1315;
      end

       1315 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[517]*10 + 1] = 3;
              updateArrayLength(1, localMem[517], 1);
              ip = 1316;
      end

       1316 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[517]*10 + 2] = 0;
              updateArrayLength(1, localMem[517], 2);
              ip = 1317;
      end

       1317 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1335;
      end

       1318 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1319;
      end

       1319 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1320;
      end

       1320 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 536] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1321;
      end

       1321 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1322;
      end

       1322 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[536] >= 99 ? 1331 : 1323;
      end

       1323 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 537] = !heapMem[localMem[535]*10 + 6];
              ip = 1324;
      end

       1324 :
      begin                                                                     // jTrue
//$display("AAAA %4d %4d jTrue", steps, ip);
              ip = localMem[537] != 0 ? 1331 : 1325;
      end

       1325 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 538] = heapMem[localMem[535]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1326;
      end

       1326 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 539] = heapMem[localMem[538]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1327;
      end

       1327 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 535] = localMem[539];
              updateArrayLength(2, 0, 0);
              ip = 1328;
      end

       1328 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1329;
      end

       1329 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 536] = localMem[536] + 1;
              ip = 1330;
      end

       1330 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1321;
      end

       1331 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1332;
      end

       1332 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[517]*10 + 0] = localMem[535];
              updateArrayLength(1, localMem[517], 0);
              ip = 1333;
      end

       1333 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[517]*10 + 1] = 1;
              updateArrayLength(1, localMem[517], 1);
              ip = 1334;
      end

       1334 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[517]*10 + 2] = 0;
              updateArrayLength(1, localMem[517], 2);
              ip = 1335;
      end

       1335 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1336;
      end

       1336 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1337;
      end

       1337 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1338;
      end

       1338 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1339;
      end

       1339 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1262;
      end

       1340 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1341;
      end

       1341 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1342;
      end

       1342 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1343;
      end

       1343 :
      begin                                                                     // free
//$display("AAAA %4d %4d free", steps, ip);
              freedArrays[freedArraysTop] = localMem[517];
              freedArraysTop = freedArraysTop + 1;
              ip = 1344;
      end

       1344 :
      begin                                                                     // free
//$display("AAAA %4d %4d free", steps, ip);
              freedArrays[freedArraysTop] = localMem[518];
              freedArraysTop = freedArraysTop + 1;
              ip = 1345;
      end

       1345 :
      begin                                                                     // tally
//$display("AAAA %4d %4d tally", steps, ip);
            ip = 1346;
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
    if (steps <=  39369) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
//for(i = 0; i < 200; ++i) $write("%4d",   localMem[i]); $display("");
//for(i = 0; i < 200; ++i) $write("%4d",    heapMem[i]); $display("");
//for(i = 0; i < 200; ++i) $write("%4d", arraySizes[i]); $display("");
  end
endmodule
