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
  parameter integer NArrays        =  2000;                                      // Maximum number of arrays
  parameter integer NHeap          = 10000;                                      // Amount of heap memory
  parameter integer NLocal         = 10000;                                      // Size of local memory
  parameter integer NOut           =  2000;                                      // Size of output area
  parameter integer NIn            =    41;                                       // Size of input area
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

  task updateArrayLength(input integer arena, input integer array, input integer index); // Update array length if we are updating an array
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
    for(i = 0; i < NHeap;   ++i)    heapMem[i] = 0;
    for(i = 0; i < NLocal;  ++i)   localMem[i] = 0;
    for(i = 0; i < NArrays; ++i) arraySizes[i] = 0;
    inMem[0] = 40;
    inMem[1] = 19;
    inMem[2] = 6;
    inMem[3] = 18;
    inMem[4] = 16;
    inMem[5] = 34;
    inMem[6] = 10;
    inMem[7] = 41;
    inMem[8] = 24;
    inMem[9] = 29;
    inMem[10] = 9;
    inMem[11] = 36;
    inMem[12] = 21;
    inMem[13] = 8;
    inMem[14] = 1;
    inMem[15] = 37;
    inMem[16] = 25;
    inMem[17] = 27;
    inMem[18] = 2;
    inMem[19] = 12;
    inMem[20] = 31;
    inMem[21] = 13;
    inMem[22] = 22;
    inMem[23] = 26;
    inMem[24] = 4;
    inMem[25] = 15;
    inMem[26] = 11;
    inMem[27] = 3;
    inMem[28] = 20;
    inMem[29] = 30;
    inMem[30] = 17;
    inMem[31] = 39;
    inMem[32] = 33;
    inMem[33] = 32;
    inMem[34] = 14;
    inMem[35] = 28;
    inMem[36] = 5;
    inMem[37] = 38;
    inMem[38] = 23;
    inMem[39] = 35;
    inMem[40] = 7;
  end

  always @(clock) begin                                                         // Each instruction
    steps = steps + 1;
    case(ip)

          0 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0]] = 0;
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
                localMem[1] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[1] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[1]] = 0;
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
              localMem[2] = NIn - inMemPos;
              ip = 8;
      end

          8 :
      begin                                                                     // jFalse
//$display("AAAA %4d %4d jFalse", steps, ip);
              ip = localMem[2] == 0 ? 1069 : 9;
      end

          9 :
      begin                                                                     // in
//$display("AAAA %4d %4d in", steps, ip);
              if (inMemPos < NIn) begin
                localMem[3] = inMem[inMemPos];
                inMemPos = inMemPos + 1;
              end
              ip = 10;
      end

         10 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[4] = localMem[3] + localMem[3];
              updateArrayLength(2, 0, 0);
              ip = 11;
      end

         11 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[5] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[5] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[5]] = 0;
              ip = 12;
      end

         12 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 13;
      end

         13 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[6] = heapMem[localMem[0]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 14;
      end

         14 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[6] != 0 ? 37 : 15;
      end

         15 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[7] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[7] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[7]] = 0;
              ip = 16;
      end

         16 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[7]*10 + 0] = 1;
              updateArrayLength(1, localMem[7], 0);
              ip = 17;
      end

         17 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[7]*10 + 2] = 0;
              updateArrayLength(1, localMem[7], 2);
              ip = 18;
      end

         18 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[8] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[8] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[8]] = 0;
              ip = 19;
      end

         19 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[7]*10 + 4] = localMem[8];
              updateArrayLength(1, localMem[7], 4);
              ip = 20;
      end

         20 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[9] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[9] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[9]] = 0;
              ip = 21;
      end

         21 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[7]*10 + 5] = localMem[9];
              updateArrayLength(1, localMem[7], 5);
              ip = 22;
      end

         22 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[7]*10 + 6] = 0;
              updateArrayLength(1, localMem[7], 6);
              ip = 23;
      end

         23 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[7]*10 + 3] = localMem[0];
              updateArrayLength(1, localMem[7], 3);
              ip = 24;
      end

         24 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 1] = heapMem[localMem[0]*10 + 1] + 1;
              updateArrayLength(1, localMem[0], 1);
              ip = 25;
      end

         25 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[7]*10 + 1] = heapMem[localMem[0]*10 + 1];
              updateArrayLength(1, localMem[7], 1);
              ip = 26;
      end

         26 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[10] = heapMem[localMem[7]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 27;
      end

         27 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[10]*10 + 0] = localMem[3];
              updateArrayLength(1, localMem[10], 0);
              ip = 28;
      end

         28 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[11] = heapMem[localMem[7]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 29;
      end

         29 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[11]*10 + 0] = localMem[4];
              updateArrayLength(1, localMem[11], 0);
              ip = 30;
      end

         30 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              updateArrayLength(1, localMem[0], 0);
              ip = 31;
      end

         31 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[0]*10 + 3] = localMem[7];
              updateArrayLength(1, localMem[0], 3);
              ip = 32;
      end

         32 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[12] = heapMem[localMem[7]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 33;
      end

         33 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[12]] = 1;
              ip = 34;
      end

         34 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[13] = heapMem[localMem[7]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 35;
      end

         35 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[13]] = 1;
              ip = 36;
      end

         36 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1065;
      end

         37 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 38;
      end

         38 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[14] = heapMem[localMem[6]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 39;
      end

         39 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[15] = heapMem[localMem[0]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 40;
      end

         40 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[14] >= localMem[15] ? 76 : 41;
      end

         41 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[16] = heapMem[localMem[6]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 42;
      end

         42 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[16] != 0 ? 75 : 43;
      end

         43 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[17] = !heapMem[localMem[6]*10 + 6];
              ip = 44;
      end

         44 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[17] == 0 ? 74 : 45;
      end

         45 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[18] = heapMem[localMem[6]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 46;
      end

         46 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[19] = 0; k = arraySizes[localMem[18]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[18] * NArea + i] == localMem[3]) localMem[19] = i + 1;
              end
              ip = 47;
      end

         47 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[19] == 0 ? 52 : 48;
      end

         48 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[19] = localMem[19] - 1;
              updateArrayLength(2, 0, 0);
              ip = 49;
      end

         49 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[20] = heapMem[localMem[6]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 50;
      end

         50 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[20]*10 + localMem[19]] = localMem[4];
              updateArrayLength(1, localMem[20], localMem[19]);
              ip = 51;
      end

         51 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1065;
      end

         52 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 53;
      end

         53 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[18]] = localMem[14];
              ip = 54;
      end

         54 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[21] = heapMem[localMem[6]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 55;
      end

         55 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[21]] = localMem[14];
              ip = 56;
      end

         56 :
      begin                                                                     // arrayCountGreater
//$display("AAAA %4d %4d arrayCountGreater", steps, ip);
              j = 0; k = arraySizes[localMem[18]];
//$display("AAAAA k=%d  source2=%d", k, localMem[3]);
              for(i = 0; i < NArea; i = i + 1) begin
//$display("AAAAA i=%d  value=%d", i, heapMem[localMem[18] * NArea + i]);
                if (i < k && heapMem[localMem[18] * NArea + i] > localMem[3]) j = j + 1;
              end
              localMem[22] = j;
              ip = 57;
      end

         57 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[22] != 0 ? 65 : 58;
      end

         58 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[23] = heapMem[localMem[6]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 59;
      end

         59 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[23]*10 + localMem[14]] = localMem[3];
              updateArrayLength(1, localMem[23], localMem[14]);
              ip = 60;
      end

         60 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[24] = heapMem[localMem[6]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 61;
      end

         61 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[24]*10 + localMem[14]] = localMem[4];
              updateArrayLength(1, localMem[24], localMem[14]);
              ip = 62;
      end

         62 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[6]*10 + 0] = localMem[14] + 1;
              updateArrayLength(1, localMem[6], 0);
              ip = 63;
      end

         63 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              updateArrayLength(1, localMem[0], 0);
              ip = 64;
      end

         64 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1065;
      end

         65 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 66;
      end

         66 :
      begin                                                                     // arrayCountLess
//$display("AAAA %4d %4d arrayCountLess", steps, ip);
              j = 0; k = arraySizes[localMem[18]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[18] * NArea + i] < localMem[3]) j = j + 1;
              end
              localMem[25] = j;
              ip = 67;
      end

         67 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[26] = heapMem[localMem[6]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 68;
      end

         68 :
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
              ip = 69;
      end

         69 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[27] = heapMem[localMem[6]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 70;
      end

         70 :
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
              heapMem[NArea * localMem[27] + localMem[25]] = localMem[4];                                    // Insert new value
              arraySizes[localMem[27]] = arraySizes[localMem[27]] + 1;                              // Increase array size
              ip = 71;
      end

         71 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[6]*10 + 0] = heapMem[localMem[6]*10 + 0] + 1;
              updateArrayLength(1, localMem[6], 0);
              ip = 72;
      end

         72 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              updateArrayLength(1, localMem[0], 0);
              ip = 73;
      end

         73 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1065;
      end

         74 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 75;
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
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[28] = heapMem[localMem[0]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 78;
      end

         78 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 79;
      end

         79 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[30] = heapMem[localMem[28]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 80;
      end

         80 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[31] = heapMem[localMem[28]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 81;
      end

         81 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[32] = heapMem[localMem[31]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 82;
      end

         82 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[30] <  localMem[32] ? 302 : 83;
      end

         83 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[33] = localMem[32];
              updateArrayLength(2, 0, 0);
              ip = 84;
      end

         84 :
      begin                                                                     // shiftRight
//$display("AAAA %4d %4d shiftRight", steps, ip);
              localMem[33] = localMem[33] >> 1;
              ip = 85;
      end

         85 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[34] = localMem[33] + 1;
              updateArrayLength(2, 0, 0);
              ip = 86;
      end

         86 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[35] = heapMem[localMem[28]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 87;
      end

         87 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[35] == 0 ? 184 : 88;
      end

         88 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[36] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[36] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[36]] = 0;
              ip = 89;
      end

         89 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[36]*10 + 0] = localMem[33];
              updateArrayLength(1, localMem[36], 0);
              ip = 90;
      end

         90 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[36]*10 + 2] = 0;
              updateArrayLength(1, localMem[36], 2);
              ip = 91;
      end

         91 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[37] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[37] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[37]] = 0;
              ip = 92;
      end

         92 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[36]*10 + 4] = localMem[37];
              updateArrayLength(1, localMem[36], 4);
              ip = 93;
      end

         93 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[38] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[38] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[38]] = 0;
              ip = 94;
      end

         94 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[36]*10 + 5] = localMem[38];
              updateArrayLength(1, localMem[36], 5);
              ip = 95;
      end

         95 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[36]*10 + 6] = 0;
              updateArrayLength(1, localMem[36], 6);
              ip = 96;
      end

         96 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[36]*10 + 3] = localMem[31];
              updateArrayLength(1, localMem[36], 3);
              ip = 97;
      end

         97 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[31]*10 + 1] = heapMem[localMem[31]*10 + 1] + 1;
              updateArrayLength(1, localMem[31], 1);
              ip = 98;
      end

         98 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[36]*10 + 1] = heapMem[localMem[31]*10 + 1];
              updateArrayLength(1, localMem[36], 1);
              ip = 99;
      end

         99 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[39] = !heapMem[localMem[28]*10 + 6];
              ip = 100;
      end

        100 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[39] != 0 ? 129 : 101;
      end

        101 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[40] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[40] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[40]] = 0;
              ip = 102;
      end

        102 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[36]*10 + 6] = localMem[40];
              updateArrayLength(1, localMem[36], 6);
              ip = 103;
      end

        103 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[41] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 104;
      end

        104 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[42] = heapMem[localMem[36]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 105;
      end

        105 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[33]) begin
                  heapMem[NArea * localMem[42] + 0 + i] = heapMem[NArea * localMem[41] + localMem[34] + i];
                  updateArrayLength(1, localMem[42], 0 + i);
                end
              end
              ip = 106;
      end

        106 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[43] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 107;
      end

        107 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[44] = heapMem[localMem[36]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 108;
      end

        108 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[33]) begin
                  heapMem[NArea * localMem[44] + 0 + i] = heapMem[NArea * localMem[43] + localMem[34] + i];
                  updateArrayLength(1, localMem[44], 0 + i);
                end
              end
              ip = 109;
      end

        109 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[45] = heapMem[localMem[28]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 110;
      end

        110 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[46] = heapMem[localMem[36]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 111;
      end

        111 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[47] = localMem[33] + 1;
              updateArrayLength(2, 0, 0);
              ip = 112;
      end

        112 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[47]) begin
                  heapMem[NArea * localMem[46] + 0 + i] = heapMem[NArea * localMem[45] + localMem[34] + i];
                  updateArrayLength(1, localMem[46], 0 + i);
                end
              end
              ip = 113;
      end

        113 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[48] = heapMem[localMem[36]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 114;
      end

        114 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[49] = localMem[48] + 1;
              updateArrayLength(2, 0, 0);
              ip = 115;
      end

        115 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[50] = heapMem[localMem[36]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 116;
      end

        116 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 117;
      end

        117 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[51] = 0;
              updateArrayLength(2, 0, 0);
              ip = 118;
      end

        118 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 119;
      end

        119 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[51] >= localMem[49] ? 125 : 120;
      end

        120 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[52] = heapMem[localMem[50]*10 + localMem[51]];
              updateArrayLength(2, 0, 0);
              ip = 121;
      end

        121 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[52]*10 + 2] = localMem[36];
              updateArrayLength(1, localMem[52], 2);
              ip = 122;
      end

        122 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 123;
      end

        123 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[51] = localMem[51] + 1;
              updateArrayLength(2, 0, 0);
              ip = 124;
      end

        124 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 118;
      end

        125 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 126;
      end

        126 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[53] = heapMem[localMem[28]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 127;
      end

        127 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[53]] = localMem[34];
              ip = 128;
      end

        128 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 136;
      end

        129 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 130;
      end

        130 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[54] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 131;
      end

        131 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[55] = heapMem[localMem[36]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 132;
      end

        132 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[33]) begin
                  heapMem[NArea * localMem[55] + 0 + i] = heapMem[NArea * localMem[54] + localMem[34] + i];
                  updateArrayLength(1, localMem[55], 0 + i);
                end
              end
              ip = 133;
      end

        133 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[56] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 134;
      end

        134 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[57] = heapMem[localMem[36]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 135;
      end

        135 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[33]) begin
                  heapMem[NArea * localMem[57] + 0 + i] = heapMem[NArea * localMem[56] + localMem[34] + i];
                  updateArrayLength(1, localMem[57], 0 + i);
                end
              end
              ip = 136;
      end

        136 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 137;
      end

        137 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[28]*10 + 0] = localMem[33];
              updateArrayLength(1, localMem[28], 0);
              ip = 138;
      end

        138 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[36]*10 + 2] = localMem[35];
              updateArrayLength(1, localMem[36], 2);
              ip = 139;
      end

        139 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[58] = heapMem[localMem[35]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 140;
      end

        140 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[59] = heapMem[localMem[35]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 141;
      end

        141 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[60] = heapMem[localMem[59]*10 + localMem[58]];
              updateArrayLength(2, 0, 0);
              ip = 142;
      end

        142 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[60] != localMem[28] ? 161 : 143;
      end

        143 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[61] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 144;
      end

        144 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[62] = heapMem[localMem[61]*10 + localMem[33]];
              updateArrayLength(2, 0, 0);
              ip = 145;
      end

        145 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[63] = heapMem[localMem[35]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 146;
      end

        146 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[63]*10 + localMem[58]] = localMem[62];
              updateArrayLength(1, localMem[63], localMem[58]);
              ip = 147;
      end

        147 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[64] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 148;
      end

        148 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[65] = heapMem[localMem[64]*10 + localMem[33]];
              updateArrayLength(2, 0, 0);
              ip = 149;
      end

        149 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[66] = heapMem[localMem[35]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 150;
      end

        150 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[66]*10 + localMem[58]] = localMem[65];
              updateArrayLength(1, localMem[66], localMem[58]);
              ip = 151;
      end

        151 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[67] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 152;
      end

        152 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[67]] = localMem[33];
              ip = 153;
      end

        153 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[68] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 154;
      end

        154 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[68]] = localMem[33];
              ip = 155;
      end

        155 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[69] = localMem[58] + 1;
              updateArrayLength(2, 0, 0);
              ip = 156;
      end

        156 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[35]*10 + 0] = localMem[69];
              updateArrayLength(1, localMem[35], 0);
              ip = 157;
      end

        157 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[70] = heapMem[localMem[35]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 158;
      end

        158 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[70]*10 + localMem[69]] = localMem[36];
              updateArrayLength(1, localMem[70], localMem[69]);
              ip = 159;
      end

        159 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 299;
      end

        160 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 183;
      end

        161 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 162;
      end

        162 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 163;
      end

        163 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[71] = heapMem[localMem[35]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 164;
      end

        164 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[72] = 0; k = arraySizes[localMem[71]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[71] * NArea + i] == localMem[28]) localMem[72] = i + 1;
              end
              ip = 165;
      end

        165 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[72] = localMem[72] - 1;
              updateArrayLength(2, 0, 0);
              ip = 166;
      end

        166 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[73] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 167;
      end

        167 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[74] = heapMem[localMem[73]*10 + localMem[33]];
              updateArrayLength(2, 0, 0);
              ip = 168;
      end

        168 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[75] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 169;
      end

        169 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[76] = heapMem[localMem[75]*10 + localMem[33]];
              updateArrayLength(2, 0, 0);
              ip = 170;
      end

        170 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[77] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 171;
      end

        171 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[77]] = localMem[33];
              ip = 172;
      end

        172 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[78] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 173;
      end

        173 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[78]] = localMem[33];
              ip = 174;
      end

        174 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[79] = heapMem[localMem[35]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 175;
      end

        175 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[79] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[72], localMem[79], arraySizes[localMem[79]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[72] && i <= arraySizes[localMem[79]]) begin
                  heapMem[NArea * localMem[79] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[79] + localMem[72]] = localMem[74];                                    // Insert new value
              arraySizes[localMem[79]] = arraySizes[localMem[79]] + 1;                              // Increase array size
              ip = 176;
      end

        176 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[80] = heapMem[localMem[35]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 177;
      end

        177 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[80] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[72], localMem[80], arraySizes[localMem[80]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[72] && i <= arraySizes[localMem[80]]) begin
                  heapMem[NArea * localMem[80] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[80] + localMem[72]] = localMem[76];                                    // Insert new value
              arraySizes[localMem[80]] = arraySizes[localMem[80]] + 1;                              // Increase array size
              ip = 178;
      end

        178 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[81] = heapMem[localMem[35]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 179;
      end

        179 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[82] = localMem[72] + 1;
              updateArrayLength(2, 0, 0);
              ip = 180;
      end

        180 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[81] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[82], localMem[81], arraySizes[localMem[81]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[82] && i <= arraySizes[localMem[81]]) begin
                  heapMem[NArea * localMem[81] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[81] + localMem[82]] = localMem[36];                                    // Insert new value
              arraySizes[localMem[81]] = arraySizes[localMem[81]] + 1;                              // Increase array size
              ip = 181;
      end

        181 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[35]*10 + 0] = heapMem[localMem[35]*10 + 0] + 1;
              updateArrayLength(1, localMem[35], 0);
              ip = 182;
      end

        182 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 299;
      end

        183 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 184;
      end

        184 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 185;
      end

        185 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[83] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[83] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[83]] = 0;
              ip = 186;
      end

        186 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[83]*10 + 0] = localMem[33];
              updateArrayLength(1, localMem[83], 0);
              ip = 187;
      end

        187 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[83]*10 + 2] = 0;
              updateArrayLength(1, localMem[83], 2);
              ip = 188;
      end

        188 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[84] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[84] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[84]] = 0;
              ip = 189;
      end

        189 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[83]*10 + 4] = localMem[84];
              updateArrayLength(1, localMem[83], 4);
              ip = 190;
      end

        190 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[85] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[85] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[85]] = 0;
              ip = 191;
      end

        191 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[83]*10 + 5] = localMem[85];
              updateArrayLength(1, localMem[83], 5);
              ip = 192;
      end

        192 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[83]*10 + 6] = 0;
              updateArrayLength(1, localMem[83], 6);
              ip = 193;
      end

        193 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[83]*10 + 3] = localMem[31];
              updateArrayLength(1, localMem[83], 3);
              ip = 194;
      end

        194 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[31]*10 + 1] = heapMem[localMem[31]*10 + 1] + 1;
              updateArrayLength(1, localMem[31], 1);
              ip = 195;
      end

        195 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[83]*10 + 1] = heapMem[localMem[31]*10 + 1];
              updateArrayLength(1, localMem[83], 1);
              ip = 196;
      end

        196 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[86] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[86] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[86]] = 0;
              ip = 197;
      end

        197 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[86]*10 + 0] = localMem[33];
              updateArrayLength(1, localMem[86], 0);
              ip = 198;
      end

        198 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[86]*10 + 2] = 0;
              updateArrayLength(1, localMem[86], 2);
              ip = 199;
      end

        199 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[87] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[87] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[87]] = 0;
              ip = 200;
      end

        200 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[86]*10 + 4] = localMem[87];
              updateArrayLength(1, localMem[86], 4);
              ip = 201;
      end

        201 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[88] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[88] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[88]] = 0;
              ip = 202;
      end

        202 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[86]*10 + 5] = localMem[88];
              updateArrayLength(1, localMem[86], 5);
              ip = 203;
      end

        203 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[86]*10 + 6] = 0;
              updateArrayLength(1, localMem[86], 6);
              ip = 204;
      end

        204 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[86]*10 + 3] = localMem[31];
              updateArrayLength(1, localMem[86], 3);
              ip = 205;
      end

        205 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[31]*10 + 1] = heapMem[localMem[31]*10 + 1] + 1;
              updateArrayLength(1, localMem[31], 1);
              ip = 206;
      end

        206 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[86]*10 + 1] = heapMem[localMem[31]*10 + 1];
              updateArrayLength(1, localMem[86], 1);
              ip = 207;
      end

        207 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[89] = !heapMem[localMem[28]*10 + 6];
              ip = 208;
      end

        208 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[89] != 0 ? 260 : 209;
      end

        209 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[90] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[90] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[90]] = 0;
              ip = 210;
      end

        210 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[83]*10 + 6] = localMem[90];
              updateArrayLength(1, localMem[83], 6);
              ip = 211;
      end

        211 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[91] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[91] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[91]] = 0;
              ip = 212;
      end

        212 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[86]*10 + 6] = localMem[91];
              updateArrayLength(1, localMem[86], 6);
              ip = 213;
      end

        213 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[92] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 214;
      end

        214 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[93] = heapMem[localMem[83]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 215;
      end

        215 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[33]) begin
                  heapMem[NArea * localMem[93] + 0 + i] = heapMem[NArea * localMem[92] + 0 + i];
                  updateArrayLength(1, localMem[93], 0 + i);
                end
              end
              ip = 216;
      end

        216 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[94] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 217;
      end

        217 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[95] = heapMem[localMem[83]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 218;
      end

        218 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[33]) begin
                  heapMem[NArea * localMem[95] + 0 + i] = heapMem[NArea * localMem[94] + 0 + i];
                  updateArrayLength(1, localMem[95], 0 + i);
                end
              end
              ip = 219;
      end

        219 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[96] = heapMem[localMem[28]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 220;
      end

        220 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[97] = heapMem[localMem[83]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 221;
      end

        221 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[98] = localMem[33] + 1;
              updateArrayLength(2, 0, 0);
              ip = 222;
      end

        222 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[98]) begin
                  heapMem[NArea * localMem[97] + 0 + i] = heapMem[NArea * localMem[96] + 0 + i];
                  updateArrayLength(1, localMem[97], 0 + i);
                end
              end
              ip = 223;
      end

        223 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[99] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 224;
      end

        224 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[100] = heapMem[localMem[86]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 225;
      end

        225 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[33]) begin
                  heapMem[NArea * localMem[100] + 0 + i] = heapMem[NArea * localMem[99] + localMem[34] + i];
                  updateArrayLength(1, localMem[100], 0 + i);
                end
              end
              ip = 226;
      end

        226 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[101] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 227;
      end

        227 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[102] = heapMem[localMem[86]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 228;
      end

        228 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[33]) begin
                  heapMem[NArea * localMem[102] + 0 + i] = heapMem[NArea * localMem[101] + localMem[34] + i];
                  updateArrayLength(1, localMem[102], 0 + i);
                end
              end
              ip = 229;
      end

        229 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[103] = heapMem[localMem[28]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 230;
      end

        230 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[104] = heapMem[localMem[86]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 231;
      end

        231 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[105] = localMem[33] + 1;
              updateArrayLength(2, 0, 0);
              ip = 232;
      end

        232 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[105]) begin
                  heapMem[NArea * localMem[104] + 0 + i] = heapMem[NArea * localMem[103] + localMem[34] + i];
                  updateArrayLength(1, localMem[104], 0 + i);
                end
              end
              ip = 233;
      end

        233 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[106] = heapMem[localMem[83]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 234;
      end

        234 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[107] = localMem[106] + 1;
              updateArrayLength(2, 0, 0);
              ip = 235;
      end

        235 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[108] = heapMem[localMem[83]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 236;
      end

        236 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 237;
      end

        237 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[109] = 0;
              updateArrayLength(2, 0, 0);
              ip = 238;
      end

        238 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 239;
      end

        239 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[109] >= localMem[107] ? 245 : 240;
      end

        240 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[110] = heapMem[localMem[108]*10 + localMem[109]];
              updateArrayLength(2, 0, 0);
              ip = 241;
      end

        241 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[110]*10 + 2] = localMem[83];
              updateArrayLength(1, localMem[110], 2);
              ip = 242;
      end

        242 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 243;
      end

        243 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[109] = localMem[109] + 1;
              updateArrayLength(2, 0, 0);
              ip = 244;
      end

        244 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 238;
      end

        245 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 246;
      end

        246 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[111] = heapMem[localMem[86]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 247;
      end

        247 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[112] = localMem[111] + 1;
              updateArrayLength(2, 0, 0);
              ip = 248;
      end

        248 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[113] = heapMem[localMem[86]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 249;
      end

        249 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 250;
      end

        250 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[114] = 0;
              updateArrayLength(2, 0, 0);
              ip = 251;
      end

        251 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 252;
      end

        252 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[114] >= localMem[112] ? 258 : 253;
      end

        253 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[115] = heapMem[localMem[113]*10 + localMem[114]];
              updateArrayLength(2, 0, 0);
              ip = 254;
      end

        254 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[115]*10 + 2] = localMem[86];
              updateArrayLength(1, localMem[115], 2);
              ip = 255;
      end

        255 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 256;
      end

        256 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[114] = localMem[114] + 1;
              updateArrayLength(2, 0, 0);
              ip = 257;
      end

        257 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 251;
      end

        258 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 259;
      end

        259 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 275;
      end

        260 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 261;
      end

        261 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[116] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[116] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[116]] = 0;
              ip = 262;
      end

        262 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[28]*10 + 6] = localMem[116];
              updateArrayLength(1, localMem[28], 6);
              ip = 263;
      end

        263 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[117] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 264;
      end

        264 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[118] = heapMem[localMem[83]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 265;
      end

        265 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[33]) begin
                  heapMem[NArea * localMem[118] + 0 + i] = heapMem[NArea * localMem[117] + 0 + i];
                  updateArrayLength(1, localMem[118], 0 + i);
                end
              end
              ip = 266;
      end

        266 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[119] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 267;
      end

        267 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[120] = heapMem[localMem[83]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 268;
      end

        268 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[33]) begin
                  heapMem[NArea * localMem[120] + 0 + i] = heapMem[NArea * localMem[119] + 0 + i];
                  updateArrayLength(1, localMem[120], 0 + i);
                end
              end
              ip = 269;
      end

        269 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[121] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 270;
      end

        270 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[122] = heapMem[localMem[86]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 271;
      end

        271 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[33]) begin
                  heapMem[NArea * localMem[122] + 0 + i] = heapMem[NArea * localMem[121] + localMem[34] + i];
                  updateArrayLength(1, localMem[122], 0 + i);
                end
              end
              ip = 272;
      end

        272 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[123] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 273;
      end

        273 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[124] = heapMem[localMem[86]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 274;
      end

        274 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[33]) begin
                  heapMem[NArea * localMem[124] + 0 + i] = heapMem[NArea * localMem[123] + localMem[34] + i];
                  updateArrayLength(1, localMem[124], 0 + i);
                end
              end
              ip = 275;
      end

        275 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 276;
      end

        276 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[83]*10 + 2] = localMem[28];
              updateArrayLength(1, localMem[83], 2);
              ip = 277;
      end

        277 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[86]*10 + 2] = localMem[28];
              updateArrayLength(1, localMem[86], 2);
              ip = 278;
      end

        278 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[125] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 279;
      end

        279 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[126] = heapMem[localMem[125]*10 + localMem[33]];
              updateArrayLength(2, 0, 0);
              ip = 280;
      end

        280 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[127] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 281;
      end

        281 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[128] = heapMem[localMem[127]*10 + localMem[33]];
              updateArrayLength(2, 0, 0);
              ip = 282;
      end

        282 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[129] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 283;
      end

        283 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[129]*10 + 0] = localMem[126];
              updateArrayLength(1, localMem[129], 0);
              ip = 284;
      end

        284 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[130] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 285;
      end

        285 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[130]*10 + 0] = localMem[128];
              updateArrayLength(1, localMem[130], 0);
              ip = 286;
      end

        286 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[131] = heapMem[localMem[28]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 287;
      end

        287 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[131]*10 + 0] = localMem[83];
              updateArrayLength(1, localMem[131], 0);
              ip = 288;
      end

        288 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[132] = heapMem[localMem[28]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 289;
      end

        289 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[132]*10 + 1] = localMem[86];
              updateArrayLength(1, localMem[132], 1);
              ip = 290;
      end

        290 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[28]*10 + 0] = 1;
              updateArrayLength(1, localMem[28], 0);
              ip = 291;
      end

        291 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[133] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 292;
      end

        292 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[133]] = 1;
              ip = 293;
      end

        293 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[134] = heapMem[localMem[28]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 294;
      end

        294 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[134]] = 1;
              ip = 295;
      end

        295 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[135] = heapMem[localMem[28]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 296;
      end

        296 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[135]] = 2;
              ip = 297;
      end

        297 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 299;
      end

        298 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 304;
      end

        299 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 300;
      end

        300 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[29] = 1;
              updateArrayLength(2, 0, 0);
              ip = 301;
      end

        301 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 304;
      end

        302 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 303;
      end

        303 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[29] = 0;
              updateArrayLength(2, 0, 0);
              ip = 304;
      end

        304 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 305;
      end

        305 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 306;
      end

        306 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 307;
      end

        307 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[136] = 0;
              updateArrayLength(2, 0, 0);
              ip = 308;
      end

        308 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 309;
      end

        309 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[136] >= 99 ? 807 : 310;
      end

        310 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[137] = heapMem[localMem[28]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 311;
      end

        311 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[138] = localMem[137] - 1;
              updateArrayLength(2, 0, 0);
              ip = 312;
      end

        312 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[139] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 313;
      end

        313 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[140] = heapMem[localMem[139]*10 + localMem[138]];
              updateArrayLength(2, 0, 0);
              ip = 314;
      end

        314 :
      begin                                                                     // jLe
//$display("AAAA %4d %4d jLe", steps, ip);
              ip = localMem[3] <= localMem[140] ? 555 : 315;
      end

        315 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[141] = !heapMem[localMem[28]*10 + 6];
              ip = 316;
      end

        316 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[141] == 0 ? 321 : 317;
      end

        317 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[5]*10 + 0] = localMem[28];
              updateArrayLength(1, localMem[5], 0);
              ip = 318;
      end

        318 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[5]*10 + 1] = 2;
              updateArrayLength(1, localMem[5], 1);
              ip = 319;
      end

        319 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              heapMem[localMem[5]*10 + 2] = localMem[137] - 1;
              updateArrayLength(1, localMem[5], 2);
              ip = 320;
      end

        320 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 811;
      end

        321 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 322;
      end

        322 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[142] = heapMem[localMem[28]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 323;
      end

        323 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[143] = heapMem[localMem[142]*10 + localMem[137]];
              updateArrayLength(2, 0, 0);
              ip = 324;
      end

        324 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 325;
      end

        325 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[145] = heapMem[localMem[143]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 326;
      end

        326 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[146] = heapMem[localMem[143]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 327;
      end

        327 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[147] = heapMem[localMem[146]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 328;
      end

        328 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[145] <  localMem[147] ? 548 : 329;
      end

        329 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[148] = localMem[147];
              updateArrayLength(2, 0, 0);
              ip = 330;
      end

        330 :
      begin                                                                     // shiftRight
//$display("AAAA %4d %4d shiftRight", steps, ip);
              localMem[148] = localMem[148] >> 1;
              ip = 331;
      end

        331 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[149] = localMem[148] + 1;
              updateArrayLength(2, 0, 0);
              ip = 332;
      end

        332 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[150] = heapMem[localMem[143]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 333;
      end

        333 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[150] == 0 ? 430 : 334;
      end

        334 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[151] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[151] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[151]] = 0;
              ip = 335;
      end

        335 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[151]*10 + 0] = localMem[148];
              updateArrayLength(1, localMem[151], 0);
              ip = 336;
      end

        336 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[151]*10 + 2] = 0;
              updateArrayLength(1, localMem[151], 2);
              ip = 337;
      end

        337 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[152] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[152] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[152]] = 0;
              ip = 338;
      end

        338 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[151]*10 + 4] = localMem[152];
              updateArrayLength(1, localMem[151], 4);
              ip = 339;
      end

        339 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[153] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[153] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[153]] = 0;
              ip = 340;
      end

        340 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[151]*10 + 5] = localMem[153];
              updateArrayLength(1, localMem[151], 5);
              ip = 341;
      end

        341 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[151]*10 + 6] = 0;
              updateArrayLength(1, localMem[151], 6);
              ip = 342;
      end

        342 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[151]*10 + 3] = localMem[146];
              updateArrayLength(1, localMem[151], 3);
              ip = 343;
      end

        343 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[146]*10 + 1] = heapMem[localMem[146]*10 + 1] + 1;
              updateArrayLength(1, localMem[146], 1);
              ip = 344;
      end

        344 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[151]*10 + 1] = heapMem[localMem[146]*10 + 1];
              updateArrayLength(1, localMem[151], 1);
              ip = 345;
      end

        345 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[154] = !heapMem[localMem[143]*10 + 6];
              ip = 346;
      end

        346 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[154] != 0 ? 375 : 347;
      end

        347 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[155] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[155] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[155]] = 0;
              ip = 348;
      end

        348 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[151]*10 + 6] = localMem[155];
              updateArrayLength(1, localMem[151], 6);
              ip = 349;
      end

        349 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[156] = heapMem[localMem[143]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 350;
      end

        350 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[157] = heapMem[localMem[151]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 351;
      end

        351 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[148]) begin
                  heapMem[NArea * localMem[157] + 0 + i] = heapMem[NArea * localMem[156] + localMem[149] + i];
                  updateArrayLength(1, localMem[157], 0 + i);
                end
              end
              ip = 352;
      end

        352 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[158] = heapMem[localMem[143]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 353;
      end

        353 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[159] = heapMem[localMem[151]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 354;
      end

        354 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[148]) begin
                  heapMem[NArea * localMem[159] + 0 + i] = heapMem[NArea * localMem[158] + localMem[149] + i];
                  updateArrayLength(1, localMem[159], 0 + i);
                end
              end
              ip = 355;
      end

        355 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[160] = heapMem[localMem[143]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 356;
      end

        356 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[161] = heapMem[localMem[151]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 357;
      end

        357 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[162] = localMem[148] + 1;
              updateArrayLength(2, 0, 0);
              ip = 358;
      end

        358 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[162]) begin
                  heapMem[NArea * localMem[161] + 0 + i] = heapMem[NArea * localMem[160] + localMem[149] + i];
                  updateArrayLength(1, localMem[161], 0 + i);
                end
              end
              ip = 359;
      end

        359 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[163] = heapMem[localMem[151]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 360;
      end

        360 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[164] = localMem[163] + 1;
              updateArrayLength(2, 0, 0);
              ip = 361;
      end

        361 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[165] = heapMem[localMem[151]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 362;
      end

        362 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 363;
      end

        363 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[166] = 0;
              updateArrayLength(2, 0, 0);
              ip = 364;
      end

        364 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 365;
      end

        365 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[166] >= localMem[164] ? 371 : 366;
      end

        366 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[167] = heapMem[localMem[165]*10 + localMem[166]];
              updateArrayLength(2, 0, 0);
              ip = 367;
      end

        367 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[167]*10 + 2] = localMem[151];
              updateArrayLength(1, localMem[167], 2);
              ip = 368;
      end

        368 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 369;
      end

        369 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[166] = localMem[166] + 1;
              updateArrayLength(2, 0, 0);
              ip = 370;
      end

        370 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 364;
      end

        371 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 372;
      end

        372 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[168] = heapMem[localMem[143]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 373;
      end

        373 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[168]] = localMem[149];
              ip = 374;
      end

        374 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 382;
      end

        375 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 376;
      end

        376 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[169] = heapMem[localMem[143]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 377;
      end

        377 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[170] = heapMem[localMem[151]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 378;
      end

        378 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[148]) begin
                  heapMem[NArea * localMem[170] + 0 + i] = heapMem[NArea * localMem[169] + localMem[149] + i];
                  updateArrayLength(1, localMem[170], 0 + i);
                end
              end
              ip = 379;
      end

        379 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[171] = heapMem[localMem[143]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 380;
      end

        380 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[172] = heapMem[localMem[151]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 381;
      end

        381 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[148]) begin
                  heapMem[NArea * localMem[172] + 0 + i] = heapMem[NArea * localMem[171] + localMem[149] + i];
                  updateArrayLength(1, localMem[172], 0 + i);
                end
              end
              ip = 382;
      end

        382 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 383;
      end

        383 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[143]*10 + 0] = localMem[148];
              updateArrayLength(1, localMem[143], 0);
              ip = 384;
      end

        384 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[151]*10 + 2] = localMem[150];
              updateArrayLength(1, localMem[151], 2);
              ip = 385;
      end

        385 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[173] = heapMem[localMem[150]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 386;
      end

        386 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[174] = heapMem[localMem[150]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 387;
      end

        387 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[175] = heapMem[localMem[174]*10 + localMem[173]];
              updateArrayLength(2, 0, 0);
              ip = 388;
      end

        388 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[175] != localMem[143] ? 407 : 389;
      end

        389 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[176] = heapMem[localMem[143]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 390;
      end

        390 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[177] = heapMem[localMem[176]*10 + localMem[148]];
              updateArrayLength(2, 0, 0);
              ip = 391;
      end

        391 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[178] = heapMem[localMem[150]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 392;
      end

        392 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[178]*10 + localMem[173]] = localMem[177];
              updateArrayLength(1, localMem[178], localMem[173]);
              ip = 393;
      end

        393 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[179] = heapMem[localMem[143]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 394;
      end

        394 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[180] = heapMem[localMem[179]*10 + localMem[148]];
              updateArrayLength(2, 0, 0);
              ip = 395;
      end

        395 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[181] = heapMem[localMem[150]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 396;
      end

        396 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[181]*10 + localMem[173]] = localMem[180];
              updateArrayLength(1, localMem[181], localMem[173]);
              ip = 397;
      end

        397 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[182] = heapMem[localMem[143]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 398;
      end

        398 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[182]] = localMem[148];
              ip = 399;
      end

        399 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[183] = heapMem[localMem[143]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 400;
      end

        400 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[183]] = localMem[148];
              ip = 401;
      end

        401 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[184] = localMem[173] + 1;
              updateArrayLength(2, 0, 0);
              ip = 402;
      end

        402 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[150]*10 + 0] = localMem[184];
              updateArrayLength(1, localMem[150], 0);
              ip = 403;
      end

        403 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[185] = heapMem[localMem[150]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 404;
      end

        404 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[185]*10 + localMem[184]] = localMem[151];
              updateArrayLength(1, localMem[185], localMem[184]);
              ip = 405;
      end

        405 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 545;
      end

        406 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 429;
      end

        407 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 408;
      end

        408 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 409;
      end

        409 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[186] = heapMem[localMem[150]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 410;
      end

        410 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[187] = 0; k = arraySizes[localMem[186]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[186] * NArea + i] == localMem[143]) localMem[187] = i + 1;
              end
              ip = 411;
      end

        411 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[187] = localMem[187] - 1;
              updateArrayLength(2, 0, 0);
              ip = 412;
      end

        412 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[188] = heapMem[localMem[143]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 413;
      end

        413 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[189] = heapMem[localMem[188]*10 + localMem[148]];
              updateArrayLength(2, 0, 0);
              ip = 414;
      end

        414 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[190] = heapMem[localMem[143]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 415;
      end

        415 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[191] = heapMem[localMem[190]*10 + localMem[148]];
              updateArrayLength(2, 0, 0);
              ip = 416;
      end

        416 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[192] = heapMem[localMem[143]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 417;
      end

        417 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[192]] = localMem[148];
              ip = 418;
      end

        418 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[193] = heapMem[localMem[143]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 419;
      end

        419 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[193]] = localMem[148];
              ip = 420;
      end

        420 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[194] = heapMem[localMem[150]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 421;
      end

        421 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[194] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[187], localMem[194], arraySizes[localMem[194]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[187] && i <= arraySizes[localMem[194]]) begin
                  heapMem[NArea * localMem[194] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[194] + localMem[187]] = localMem[189];                                    // Insert new value
              arraySizes[localMem[194]] = arraySizes[localMem[194]] + 1;                              // Increase array size
              ip = 422;
      end

        422 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[195] = heapMem[localMem[150]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 423;
      end

        423 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[195] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[187], localMem[195], arraySizes[localMem[195]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[187] && i <= arraySizes[localMem[195]]) begin
                  heapMem[NArea * localMem[195] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[195] + localMem[187]] = localMem[191];                                    // Insert new value
              arraySizes[localMem[195]] = arraySizes[localMem[195]] + 1;                              // Increase array size
              ip = 424;
      end

        424 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[196] = heapMem[localMem[150]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 425;
      end

        425 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[197] = localMem[187] + 1;
              updateArrayLength(2, 0, 0);
              ip = 426;
      end

        426 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[196] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[197], localMem[196], arraySizes[localMem[196]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[197] && i <= arraySizes[localMem[196]]) begin
                  heapMem[NArea * localMem[196] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[196] + localMem[197]] = localMem[151];                                    // Insert new value
              arraySizes[localMem[196]] = arraySizes[localMem[196]] + 1;                              // Increase array size
              ip = 427;
      end

        427 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[150]*10 + 0] = heapMem[localMem[150]*10 + 0] + 1;
              updateArrayLength(1, localMem[150], 0);
              ip = 428;
      end

        428 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 545;
      end

        429 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 430;
      end

        430 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 431;
      end

        431 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[198] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[198] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[198]] = 0;
              ip = 432;
      end

        432 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[198]*10 + 0] = localMem[148];
              updateArrayLength(1, localMem[198], 0);
              ip = 433;
      end

        433 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[198]*10 + 2] = 0;
              updateArrayLength(1, localMem[198], 2);
              ip = 434;
      end

        434 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[199] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[199] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[199]] = 0;
              ip = 435;
      end

        435 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[198]*10 + 4] = localMem[199];
              updateArrayLength(1, localMem[198], 4);
              ip = 436;
      end

        436 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[200] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[200] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[200]] = 0;
              ip = 437;
      end

        437 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[198]*10 + 5] = localMem[200];
              updateArrayLength(1, localMem[198], 5);
              ip = 438;
      end

        438 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[198]*10 + 6] = 0;
              updateArrayLength(1, localMem[198], 6);
              ip = 439;
      end

        439 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[198]*10 + 3] = localMem[146];
              updateArrayLength(1, localMem[198], 3);
              ip = 440;
      end

        440 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[146]*10 + 1] = heapMem[localMem[146]*10 + 1] + 1;
              updateArrayLength(1, localMem[146], 1);
              ip = 441;
      end

        441 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[198]*10 + 1] = heapMem[localMem[146]*10 + 1];
              updateArrayLength(1, localMem[198], 1);
              ip = 442;
      end

        442 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[201] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[201] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[201]] = 0;
              ip = 443;
      end

        443 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[201]*10 + 0] = localMem[148];
              updateArrayLength(1, localMem[201], 0);
              ip = 444;
      end

        444 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[201]*10 + 2] = 0;
              updateArrayLength(1, localMem[201], 2);
              ip = 445;
      end

        445 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[202] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[202] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[202]] = 0;
              ip = 446;
      end

        446 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[201]*10 + 4] = localMem[202];
              updateArrayLength(1, localMem[201], 4);
              ip = 447;
      end

        447 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[203] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[203] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[203]] = 0;
              ip = 448;
      end

        448 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[201]*10 + 5] = localMem[203];
              updateArrayLength(1, localMem[201], 5);
              ip = 449;
      end

        449 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[201]*10 + 6] = 0;
              updateArrayLength(1, localMem[201], 6);
              ip = 450;
      end

        450 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[201]*10 + 3] = localMem[146];
              updateArrayLength(1, localMem[201], 3);
              ip = 451;
      end

        451 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[146]*10 + 1] = heapMem[localMem[146]*10 + 1] + 1;
              updateArrayLength(1, localMem[146], 1);
              ip = 452;
      end

        452 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[201]*10 + 1] = heapMem[localMem[146]*10 + 1];
              updateArrayLength(1, localMem[201], 1);
              ip = 453;
      end

        453 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[204] = !heapMem[localMem[143]*10 + 6];
              ip = 454;
      end

        454 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[204] != 0 ? 506 : 455;
      end

        455 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[205] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[205] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[205]] = 0;
              ip = 456;
      end

        456 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[198]*10 + 6] = localMem[205];
              updateArrayLength(1, localMem[198], 6);
              ip = 457;
      end

        457 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[206] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[206] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[206]] = 0;
              ip = 458;
      end

        458 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[201]*10 + 6] = localMem[206];
              updateArrayLength(1, localMem[201], 6);
              ip = 459;
      end

        459 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[207] = heapMem[localMem[143]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 460;
      end

        460 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[208] = heapMem[localMem[198]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 461;
      end

        461 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[148]) begin
                  heapMem[NArea * localMem[208] + 0 + i] = heapMem[NArea * localMem[207] + 0 + i];
                  updateArrayLength(1, localMem[208], 0 + i);
                end
              end
              ip = 462;
      end

        462 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[209] = heapMem[localMem[143]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 463;
      end

        463 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[210] = heapMem[localMem[198]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 464;
      end

        464 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[148]) begin
                  heapMem[NArea * localMem[210] + 0 + i] = heapMem[NArea * localMem[209] + 0 + i];
                  updateArrayLength(1, localMem[210], 0 + i);
                end
              end
              ip = 465;
      end

        465 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[211] = heapMem[localMem[143]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 466;
      end

        466 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[212] = heapMem[localMem[198]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 467;
      end

        467 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[213] = localMem[148] + 1;
              updateArrayLength(2, 0, 0);
              ip = 468;
      end

        468 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[213]) begin
                  heapMem[NArea * localMem[212] + 0 + i] = heapMem[NArea * localMem[211] + 0 + i];
                  updateArrayLength(1, localMem[212], 0 + i);
                end
              end
              ip = 469;
      end

        469 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[214] = heapMem[localMem[143]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 470;
      end

        470 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[215] = heapMem[localMem[201]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 471;
      end

        471 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[148]) begin
                  heapMem[NArea * localMem[215] + 0 + i] = heapMem[NArea * localMem[214] + localMem[149] + i];
                  updateArrayLength(1, localMem[215], 0 + i);
                end
              end
              ip = 472;
      end

        472 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[216] = heapMem[localMem[143]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 473;
      end

        473 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[217] = heapMem[localMem[201]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 474;
      end

        474 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[148]) begin
                  heapMem[NArea * localMem[217] + 0 + i] = heapMem[NArea * localMem[216] + localMem[149] + i];
                  updateArrayLength(1, localMem[217], 0 + i);
                end
              end
              ip = 475;
      end

        475 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[218] = heapMem[localMem[143]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 476;
      end

        476 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[219] = heapMem[localMem[201]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 477;
      end

        477 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[220] = localMem[148] + 1;
              updateArrayLength(2, 0, 0);
              ip = 478;
      end

        478 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[220]) begin
                  heapMem[NArea * localMem[219] + 0 + i] = heapMem[NArea * localMem[218] + localMem[149] + i];
                  updateArrayLength(1, localMem[219], 0 + i);
                end
              end
              ip = 479;
      end

        479 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[221] = heapMem[localMem[198]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 480;
      end

        480 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[222] = localMem[221] + 1;
              updateArrayLength(2, 0, 0);
              ip = 481;
      end

        481 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[223] = heapMem[localMem[198]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 482;
      end

        482 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 483;
      end

        483 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[224] = 0;
              updateArrayLength(2, 0, 0);
              ip = 484;
      end

        484 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 485;
      end

        485 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[224] >= localMem[222] ? 491 : 486;
      end

        486 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[225] = heapMem[localMem[223]*10 + localMem[224]];
              updateArrayLength(2, 0, 0);
              ip = 487;
      end

        487 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[225]*10 + 2] = localMem[198];
              updateArrayLength(1, localMem[225], 2);
              ip = 488;
      end

        488 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 489;
      end

        489 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[224] = localMem[224] + 1;
              updateArrayLength(2, 0, 0);
              ip = 490;
      end

        490 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 484;
      end

        491 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 492;
      end

        492 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[226] = heapMem[localMem[201]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 493;
      end

        493 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[227] = localMem[226] + 1;
              updateArrayLength(2, 0, 0);
              ip = 494;
      end

        494 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[228] = heapMem[localMem[201]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 495;
      end

        495 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 496;
      end

        496 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[229] = 0;
              updateArrayLength(2, 0, 0);
              ip = 497;
      end

        497 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 498;
      end

        498 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[229] >= localMem[227] ? 504 : 499;
      end

        499 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[230] = heapMem[localMem[228]*10 + localMem[229]];
              updateArrayLength(2, 0, 0);
              ip = 500;
      end

        500 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[230]*10 + 2] = localMem[201];
              updateArrayLength(1, localMem[230], 2);
              ip = 501;
      end

        501 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 502;
      end

        502 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[229] = localMem[229] + 1;
              updateArrayLength(2, 0, 0);
              ip = 503;
      end

        503 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 497;
      end

        504 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 505;
      end

        505 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 521;
      end

        506 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 507;
      end

        507 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[231] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[231] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[231]] = 0;
              ip = 508;
      end

        508 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[143]*10 + 6] = localMem[231];
              updateArrayLength(1, localMem[143], 6);
              ip = 509;
      end

        509 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[232] = heapMem[localMem[143]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 510;
      end

        510 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[233] = heapMem[localMem[198]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 511;
      end

        511 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[148]) begin
                  heapMem[NArea * localMem[233] + 0 + i] = heapMem[NArea * localMem[232] + 0 + i];
                  updateArrayLength(1, localMem[233], 0 + i);
                end
              end
              ip = 512;
      end

        512 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[234] = heapMem[localMem[143]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 513;
      end

        513 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[235] = heapMem[localMem[198]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 514;
      end

        514 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[148]) begin
                  heapMem[NArea * localMem[235] + 0 + i] = heapMem[NArea * localMem[234] + 0 + i];
                  updateArrayLength(1, localMem[235], 0 + i);
                end
              end
              ip = 515;
      end

        515 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[236] = heapMem[localMem[143]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 516;
      end

        516 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[237] = heapMem[localMem[201]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 517;
      end

        517 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[148]) begin
                  heapMem[NArea * localMem[237] + 0 + i] = heapMem[NArea * localMem[236] + localMem[149] + i];
                  updateArrayLength(1, localMem[237], 0 + i);
                end
              end
              ip = 518;
      end

        518 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[238] = heapMem[localMem[143]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 519;
      end

        519 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[239] = heapMem[localMem[201]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 520;
      end

        520 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[148]) begin
                  heapMem[NArea * localMem[239] + 0 + i] = heapMem[NArea * localMem[238] + localMem[149] + i];
                  updateArrayLength(1, localMem[239], 0 + i);
                end
              end
              ip = 521;
      end

        521 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 522;
      end

        522 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[198]*10 + 2] = localMem[143];
              updateArrayLength(1, localMem[198], 2);
              ip = 523;
      end

        523 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[201]*10 + 2] = localMem[143];
              updateArrayLength(1, localMem[201], 2);
              ip = 524;
      end

        524 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[240] = heapMem[localMem[143]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 525;
      end

        525 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[241] = heapMem[localMem[240]*10 + localMem[148]];
              updateArrayLength(2, 0, 0);
              ip = 526;
      end

        526 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[242] = heapMem[localMem[143]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 527;
      end

        527 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[243] = heapMem[localMem[242]*10 + localMem[148]];
              updateArrayLength(2, 0, 0);
              ip = 528;
      end

        528 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[244] = heapMem[localMem[143]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 529;
      end

        529 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[244]*10 + 0] = localMem[241];
              updateArrayLength(1, localMem[244], 0);
              ip = 530;
      end

        530 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[245] = heapMem[localMem[143]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 531;
      end

        531 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[245]*10 + 0] = localMem[243];
              updateArrayLength(1, localMem[245], 0);
              ip = 532;
      end

        532 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[246] = heapMem[localMem[143]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 533;
      end

        533 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[246]*10 + 0] = localMem[198];
              updateArrayLength(1, localMem[246], 0);
              ip = 534;
      end

        534 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[247] = heapMem[localMem[143]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 535;
      end

        535 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[247]*10 + 1] = localMem[201];
              updateArrayLength(1, localMem[247], 1);
              ip = 536;
      end

        536 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[143]*10 + 0] = 1;
              updateArrayLength(1, localMem[143], 0);
              ip = 537;
      end

        537 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[248] = heapMem[localMem[143]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 538;
      end

        538 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[248]] = 1;
              ip = 539;
      end

        539 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[249] = heapMem[localMem[143]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 540;
      end

        540 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[249]] = 1;
              ip = 541;
      end

        541 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[250] = heapMem[localMem[143]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 542;
      end

        542 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[250]] = 2;
              ip = 543;
      end

        543 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 545;
      end

        544 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 550;
      end

        545 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 546;
      end

        546 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[144] = 1;
              updateArrayLength(2, 0, 0);
              ip = 547;
      end

        547 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 550;
      end

        548 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 549;
      end

        549 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[144] = 0;
              updateArrayLength(2, 0, 0);
              ip = 550;
      end

        550 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 551;
      end

        551 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[144] != 0 ? 553 : 552;
      end

        552 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[28] = localMem[143];
              updateArrayLength(2, 0, 0);
              ip = 553;
      end

        553 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 554;
      end

        554 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 804;
      end

        555 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 556;
      end

        556 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[251] = heapMem[localMem[28]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 557;
      end

        557 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[252] = 0; k = arraySizes[localMem[251]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[251] * NArea + i] == localMem[3]) localMem[252] = i + 1;
              end
              ip = 558;
      end

        558 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[252] == 0 ? 563 : 559;
      end

        559 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[5]*10 + 0] = localMem[28];
              updateArrayLength(1, localMem[5], 0);
              ip = 560;
      end

        560 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[5]*10 + 1] = 1;
              updateArrayLength(1, localMem[5], 1);
              ip = 561;
      end

        561 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              heapMem[localMem[5]*10 + 2] = localMem[252] - 1;
              updateArrayLength(1, localMem[5], 2);
              ip = 562;
      end

        562 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 811;
      end

        563 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 564;
      end

        564 :
      begin                                                                     // arrayCountLess
//$display("AAAA %4d %4d arrayCountLess", steps, ip);
              j = 0; k = arraySizes[localMem[251]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[251] * NArea + i] < localMem[3]) j = j + 1;
              end
              localMem[253] = j;
              ip = 565;
      end

        565 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[254] = !heapMem[localMem[28]*10 + 6];
              ip = 566;
      end

        566 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[254] == 0 ? 571 : 567;
      end

        567 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[5]*10 + 0] = localMem[28];
              updateArrayLength(1, localMem[5], 0);
              ip = 568;
      end

        568 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[5]*10 + 1] = 0;
              updateArrayLength(1, localMem[5], 1);
              ip = 569;
      end

        569 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[5]*10 + 2] = localMem[253];
              updateArrayLength(1, localMem[5], 2);
              ip = 570;
      end

        570 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 811;
      end

        571 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 572;
      end

        572 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[255] = heapMem[localMem[28]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 573;
      end

        573 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[256] = heapMem[localMem[255]*10 + localMem[253]];
              updateArrayLength(2, 0, 0);
              ip = 574;
      end

        574 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 575;
      end

        575 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[258] = heapMem[localMem[256]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 576;
      end

        576 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[259] = heapMem[localMem[256]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 577;
      end

        577 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[260] = heapMem[localMem[259]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 578;
      end

        578 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[258] <  localMem[260] ? 798 : 579;
      end

        579 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[261] = localMem[260];
              updateArrayLength(2, 0, 0);
              ip = 580;
      end

        580 :
      begin                                                                     // shiftRight
//$display("AAAA %4d %4d shiftRight", steps, ip);
              localMem[261] = localMem[261] >> 1;
              ip = 581;
      end

        581 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[262] = localMem[261] + 1;
              updateArrayLength(2, 0, 0);
              ip = 582;
      end

        582 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[263] = heapMem[localMem[256]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 583;
      end

        583 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[263] == 0 ? 680 : 584;
      end

        584 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[264] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[264] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[264]] = 0;
              ip = 585;
      end

        585 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[264]*10 + 0] = localMem[261];
              updateArrayLength(1, localMem[264], 0);
              ip = 586;
      end

        586 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[264]*10 + 2] = 0;
              updateArrayLength(1, localMem[264], 2);
              ip = 587;
      end

        587 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[265] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[265] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[265]] = 0;
              ip = 588;
      end

        588 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[264]*10 + 4] = localMem[265];
              updateArrayLength(1, localMem[264], 4);
              ip = 589;
      end

        589 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[266] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[266] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[266]] = 0;
              ip = 590;
      end

        590 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[264]*10 + 5] = localMem[266];
              updateArrayLength(1, localMem[264], 5);
              ip = 591;
      end

        591 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[264]*10 + 6] = 0;
              updateArrayLength(1, localMem[264], 6);
              ip = 592;
      end

        592 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[264]*10 + 3] = localMem[259];
              updateArrayLength(1, localMem[264], 3);
              ip = 593;
      end

        593 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[259]*10 + 1] = heapMem[localMem[259]*10 + 1] + 1;
              updateArrayLength(1, localMem[259], 1);
              ip = 594;
      end

        594 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[264]*10 + 1] = heapMem[localMem[259]*10 + 1];
              updateArrayLength(1, localMem[264], 1);
              ip = 595;
      end

        595 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[267] = !heapMem[localMem[256]*10 + 6];
              ip = 596;
      end

        596 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[267] != 0 ? 625 : 597;
      end

        597 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[268] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[268] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[268]] = 0;
              ip = 598;
      end

        598 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[264]*10 + 6] = localMem[268];
              updateArrayLength(1, localMem[264], 6);
              ip = 599;
      end

        599 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[269] = heapMem[localMem[256]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 600;
      end

        600 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[270] = heapMem[localMem[264]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 601;
      end

        601 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[261]) begin
                  heapMem[NArea * localMem[270] + 0 + i] = heapMem[NArea * localMem[269] + localMem[262] + i];
                  updateArrayLength(1, localMem[270], 0 + i);
                end
              end
              ip = 602;
      end

        602 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[271] = heapMem[localMem[256]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 603;
      end

        603 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[272] = heapMem[localMem[264]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 604;
      end

        604 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[261]) begin
                  heapMem[NArea * localMem[272] + 0 + i] = heapMem[NArea * localMem[271] + localMem[262] + i];
                  updateArrayLength(1, localMem[272], 0 + i);
                end
              end
              ip = 605;
      end

        605 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[273] = heapMem[localMem[256]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 606;
      end

        606 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[274] = heapMem[localMem[264]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 607;
      end

        607 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[275] = localMem[261] + 1;
              updateArrayLength(2, 0, 0);
              ip = 608;
      end

        608 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[275]) begin
                  heapMem[NArea * localMem[274] + 0 + i] = heapMem[NArea * localMem[273] + localMem[262] + i];
                  updateArrayLength(1, localMem[274], 0 + i);
                end
              end
              ip = 609;
      end

        609 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[276] = heapMem[localMem[264]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 610;
      end

        610 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[277] = localMem[276] + 1;
              updateArrayLength(2, 0, 0);
              ip = 611;
      end

        611 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[278] = heapMem[localMem[264]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 612;
      end

        612 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 613;
      end

        613 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[279] = 0;
              updateArrayLength(2, 0, 0);
              ip = 614;
      end

        614 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 615;
      end

        615 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[279] >= localMem[277] ? 621 : 616;
      end

        616 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[280] = heapMem[localMem[278]*10 + localMem[279]];
              updateArrayLength(2, 0, 0);
              ip = 617;
      end

        617 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[280]*10 + 2] = localMem[264];
              updateArrayLength(1, localMem[280], 2);
              ip = 618;
      end

        618 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 619;
      end

        619 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[279] = localMem[279] + 1;
              updateArrayLength(2, 0, 0);
              ip = 620;
      end

        620 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 614;
      end

        621 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 622;
      end

        622 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[281] = heapMem[localMem[256]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 623;
      end

        623 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[281]] = localMem[262];
              ip = 624;
      end

        624 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 632;
      end

        625 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 626;
      end

        626 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[282] = heapMem[localMem[256]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 627;
      end

        627 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[283] = heapMem[localMem[264]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 628;
      end

        628 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[261]) begin
                  heapMem[NArea * localMem[283] + 0 + i] = heapMem[NArea * localMem[282] + localMem[262] + i];
                  updateArrayLength(1, localMem[283], 0 + i);
                end
              end
              ip = 629;
      end

        629 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[284] = heapMem[localMem[256]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 630;
      end

        630 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[285] = heapMem[localMem[264]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 631;
      end

        631 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[261]) begin
                  heapMem[NArea * localMem[285] + 0 + i] = heapMem[NArea * localMem[284] + localMem[262] + i];
                  updateArrayLength(1, localMem[285], 0 + i);
                end
              end
              ip = 632;
      end

        632 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 633;
      end

        633 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[256]*10 + 0] = localMem[261];
              updateArrayLength(1, localMem[256], 0);
              ip = 634;
      end

        634 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[264]*10 + 2] = localMem[263];
              updateArrayLength(1, localMem[264], 2);
              ip = 635;
      end

        635 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[286] = heapMem[localMem[263]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 636;
      end

        636 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[287] = heapMem[localMem[263]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 637;
      end

        637 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[288] = heapMem[localMem[287]*10 + localMem[286]];
              updateArrayLength(2, 0, 0);
              ip = 638;
      end

        638 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[288] != localMem[256] ? 657 : 639;
      end

        639 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[289] = heapMem[localMem[256]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 640;
      end

        640 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[290] = heapMem[localMem[289]*10 + localMem[261]];
              updateArrayLength(2, 0, 0);
              ip = 641;
      end

        641 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[291] = heapMem[localMem[263]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 642;
      end

        642 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[291]*10 + localMem[286]] = localMem[290];
              updateArrayLength(1, localMem[291], localMem[286]);
              ip = 643;
      end

        643 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[292] = heapMem[localMem[256]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 644;
      end

        644 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[293] = heapMem[localMem[292]*10 + localMem[261]];
              updateArrayLength(2, 0, 0);
              ip = 645;
      end

        645 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[294] = heapMem[localMem[263]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 646;
      end

        646 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[294]*10 + localMem[286]] = localMem[293];
              updateArrayLength(1, localMem[294], localMem[286]);
              ip = 647;
      end

        647 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[295] = heapMem[localMem[256]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 648;
      end

        648 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[295]] = localMem[261];
              ip = 649;
      end

        649 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[296] = heapMem[localMem[256]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 650;
      end

        650 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[296]] = localMem[261];
              ip = 651;
      end

        651 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[297] = localMem[286] + 1;
              updateArrayLength(2, 0, 0);
              ip = 652;
      end

        652 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[263]*10 + 0] = localMem[297];
              updateArrayLength(1, localMem[263], 0);
              ip = 653;
      end

        653 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[298] = heapMem[localMem[263]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 654;
      end

        654 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[298]*10 + localMem[297]] = localMem[264];
              updateArrayLength(1, localMem[298], localMem[297]);
              ip = 655;
      end

        655 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 795;
      end

        656 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 679;
      end

        657 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 658;
      end

        658 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 659;
      end

        659 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[299] = heapMem[localMem[263]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 660;
      end

        660 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[300] = 0; k = arraySizes[localMem[299]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[299] * NArea + i] == localMem[256]) localMem[300] = i + 1;
              end
              ip = 661;
      end

        661 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[300] = localMem[300] - 1;
              updateArrayLength(2, 0, 0);
              ip = 662;
      end

        662 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[301] = heapMem[localMem[256]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 663;
      end

        663 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[302] = heapMem[localMem[301]*10 + localMem[261]];
              updateArrayLength(2, 0, 0);
              ip = 664;
      end

        664 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[303] = heapMem[localMem[256]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 665;
      end

        665 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[304] = heapMem[localMem[303]*10 + localMem[261]];
              updateArrayLength(2, 0, 0);
              ip = 666;
      end

        666 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[305] = heapMem[localMem[256]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 667;
      end

        667 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[305]] = localMem[261];
              ip = 668;
      end

        668 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[306] = heapMem[localMem[256]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 669;
      end

        669 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[306]] = localMem[261];
              ip = 670;
      end

        670 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[307] = heapMem[localMem[263]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 671;
      end

        671 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[307] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[300], localMem[307], arraySizes[localMem[307]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[300] && i <= arraySizes[localMem[307]]) begin
                  heapMem[NArea * localMem[307] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[307] + localMem[300]] = localMem[302];                                    // Insert new value
              arraySizes[localMem[307]] = arraySizes[localMem[307]] + 1;                              // Increase array size
              ip = 672;
      end

        672 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[308] = heapMem[localMem[263]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 673;
      end

        673 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[308] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[300], localMem[308], arraySizes[localMem[308]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[300] && i <= arraySizes[localMem[308]]) begin
                  heapMem[NArea * localMem[308] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[308] + localMem[300]] = localMem[304];                                    // Insert new value
              arraySizes[localMem[308]] = arraySizes[localMem[308]] + 1;                              // Increase array size
              ip = 674;
      end

        674 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[309] = heapMem[localMem[263]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 675;
      end

        675 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[310] = localMem[300] + 1;
              updateArrayLength(2, 0, 0);
              ip = 676;
      end

        676 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[309] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[310], localMem[309], arraySizes[localMem[309]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[310] && i <= arraySizes[localMem[309]]) begin
                  heapMem[NArea * localMem[309] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[309] + localMem[310]] = localMem[264];                                    // Insert new value
              arraySizes[localMem[309]] = arraySizes[localMem[309]] + 1;                              // Increase array size
              ip = 677;
      end

        677 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[263]*10 + 0] = heapMem[localMem[263]*10 + 0] + 1;
              updateArrayLength(1, localMem[263], 0);
              ip = 678;
      end

        678 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 795;
      end

        679 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 680;
      end

        680 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 681;
      end

        681 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[311] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[311] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[311]] = 0;
              ip = 682;
      end

        682 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[311]*10 + 0] = localMem[261];
              updateArrayLength(1, localMem[311], 0);
              ip = 683;
      end

        683 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[311]*10 + 2] = 0;
              updateArrayLength(1, localMem[311], 2);
              ip = 684;
      end

        684 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[312] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[312] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[312]] = 0;
              ip = 685;
      end

        685 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[311]*10 + 4] = localMem[312];
              updateArrayLength(1, localMem[311], 4);
              ip = 686;
      end

        686 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[313] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[313] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[313]] = 0;
              ip = 687;
      end

        687 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[311]*10 + 5] = localMem[313];
              updateArrayLength(1, localMem[311], 5);
              ip = 688;
      end

        688 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[311]*10 + 6] = 0;
              updateArrayLength(1, localMem[311], 6);
              ip = 689;
      end

        689 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[311]*10 + 3] = localMem[259];
              updateArrayLength(1, localMem[311], 3);
              ip = 690;
      end

        690 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[259]*10 + 1] = heapMem[localMem[259]*10 + 1] + 1;
              updateArrayLength(1, localMem[259], 1);
              ip = 691;
      end

        691 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[311]*10 + 1] = heapMem[localMem[259]*10 + 1];
              updateArrayLength(1, localMem[311], 1);
              ip = 692;
      end

        692 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[314] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[314] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[314]] = 0;
              ip = 693;
      end

        693 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[314]*10 + 0] = localMem[261];
              updateArrayLength(1, localMem[314], 0);
              ip = 694;
      end

        694 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[314]*10 + 2] = 0;
              updateArrayLength(1, localMem[314], 2);
              ip = 695;
      end

        695 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[315] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[315] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[315]] = 0;
              ip = 696;
      end

        696 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[314]*10 + 4] = localMem[315];
              updateArrayLength(1, localMem[314], 4);
              ip = 697;
      end

        697 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[316] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[316] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[316]] = 0;
              ip = 698;
      end

        698 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[314]*10 + 5] = localMem[316];
              updateArrayLength(1, localMem[314], 5);
              ip = 699;
      end

        699 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[314]*10 + 6] = 0;
              updateArrayLength(1, localMem[314], 6);
              ip = 700;
      end

        700 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[314]*10 + 3] = localMem[259];
              updateArrayLength(1, localMem[314], 3);
              ip = 701;
      end

        701 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[259]*10 + 1] = heapMem[localMem[259]*10 + 1] + 1;
              updateArrayLength(1, localMem[259], 1);
              ip = 702;
      end

        702 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[314]*10 + 1] = heapMem[localMem[259]*10 + 1];
              updateArrayLength(1, localMem[314], 1);
              ip = 703;
      end

        703 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[317] = !heapMem[localMem[256]*10 + 6];
              ip = 704;
      end

        704 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[317] != 0 ? 756 : 705;
      end

        705 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[318] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[318] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[318]] = 0;
              ip = 706;
      end

        706 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[311]*10 + 6] = localMem[318];
              updateArrayLength(1, localMem[311], 6);
              ip = 707;
      end

        707 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[319] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[319] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[319]] = 0;
              ip = 708;
      end

        708 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[314]*10 + 6] = localMem[319];
              updateArrayLength(1, localMem[314], 6);
              ip = 709;
      end

        709 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[320] = heapMem[localMem[256]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 710;
      end

        710 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[321] = heapMem[localMem[311]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 711;
      end

        711 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[261]) begin
                  heapMem[NArea * localMem[321] + 0 + i] = heapMem[NArea * localMem[320] + 0 + i];
                  updateArrayLength(1, localMem[321], 0 + i);
                end
              end
              ip = 712;
      end

        712 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[322] = heapMem[localMem[256]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 713;
      end

        713 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[323] = heapMem[localMem[311]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 714;
      end

        714 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[261]) begin
                  heapMem[NArea * localMem[323] + 0 + i] = heapMem[NArea * localMem[322] + 0 + i];
                  updateArrayLength(1, localMem[323], 0 + i);
                end
              end
              ip = 715;
      end

        715 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[324] = heapMem[localMem[256]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 716;
      end

        716 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[325] = heapMem[localMem[311]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 717;
      end

        717 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[326] = localMem[261] + 1;
              updateArrayLength(2, 0, 0);
              ip = 718;
      end

        718 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[326]) begin
                  heapMem[NArea * localMem[325] + 0 + i] = heapMem[NArea * localMem[324] + 0 + i];
                  updateArrayLength(1, localMem[325], 0 + i);
                end
              end
              ip = 719;
      end

        719 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[327] = heapMem[localMem[256]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 720;
      end

        720 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[328] = heapMem[localMem[314]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 721;
      end

        721 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[261]) begin
                  heapMem[NArea * localMem[328] + 0 + i] = heapMem[NArea * localMem[327] + localMem[262] + i];
                  updateArrayLength(1, localMem[328], 0 + i);
                end
              end
              ip = 722;
      end

        722 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[329] = heapMem[localMem[256]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 723;
      end

        723 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[330] = heapMem[localMem[314]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 724;
      end

        724 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[261]) begin
                  heapMem[NArea * localMem[330] + 0 + i] = heapMem[NArea * localMem[329] + localMem[262] + i];
                  updateArrayLength(1, localMem[330], 0 + i);
                end
              end
              ip = 725;
      end

        725 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[331] = heapMem[localMem[256]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 726;
      end

        726 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[332] = heapMem[localMem[314]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 727;
      end

        727 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[333] = localMem[261] + 1;
              updateArrayLength(2, 0, 0);
              ip = 728;
      end

        728 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[333]) begin
                  heapMem[NArea * localMem[332] + 0 + i] = heapMem[NArea * localMem[331] + localMem[262] + i];
                  updateArrayLength(1, localMem[332], 0 + i);
                end
              end
              ip = 729;
      end

        729 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[334] = heapMem[localMem[311]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 730;
      end

        730 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[335] = localMem[334] + 1;
              updateArrayLength(2, 0, 0);
              ip = 731;
      end

        731 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[336] = heapMem[localMem[311]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 732;
      end

        732 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 733;
      end

        733 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[337] = 0;
              updateArrayLength(2, 0, 0);
              ip = 734;
      end

        734 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 735;
      end

        735 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[337] >= localMem[335] ? 741 : 736;
      end

        736 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[338] = heapMem[localMem[336]*10 + localMem[337]];
              updateArrayLength(2, 0, 0);
              ip = 737;
      end

        737 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[338]*10 + 2] = localMem[311];
              updateArrayLength(1, localMem[338], 2);
              ip = 738;
      end

        738 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 739;
      end

        739 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[337] = localMem[337] + 1;
              updateArrayLength(2, 0, 0);
              ip = 740;
      end

        740 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 734;
      end

        741 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 742;
      end

        742 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[339] = heapMem[localMem[314]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 743;
      end

        743 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[340] = localMem[339] + 1;
              updateArrayLength(2, 0, 0);
              ip = 744;
      end

        744 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[341] = heapMem[localMem[314]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 745;
      end

        745 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 746;
      end

        746 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[342] = 0;
              updateArrayLength(2, 0, 0);
              ip = 747;
      end

        747 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 748;
      end

        748 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[342] >= localMem[340] ? 754 : 749;
      end

        749 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[343] = heapMem[localMem[341]*10 + localMem[342]];
              updateArrayLength(2, 0, 0);
              ip = 750;
      end

        750 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[343]*10 + 2] = localMem[314];
              updateArrayLength(1, localMem[343], 2);
              ip = 751;
      end

        751 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 752;
      end

        752 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[342] = localMem[342] + 1;
              updateArrayLength(2, 0, 0);
              ip = 753;
      end

        753 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 747;
      end

        754 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 755;
      end

        755 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 771;
      end

        756 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 757;
      end

        757 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[344] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[344] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[344]] = 0;
              ip = 758;
      end

        758 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[256]*10 + 6] = localMem[344];
              updateArrayLength(1, localMem[256], 6);
              ip = 759;
      end

        759 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[345] = heapMem[localMem[256]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 760;
      end

        760 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[346] = heapMem[localMem[311]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 761;
      end

        761 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[261]) begin
                  heapMem[NArea * localMem[346] + 0 + i] = heapMem[NArea * localMem[345] + 0 + i];
                  updateArrayLength(1, localMem[346], 0 + i);
                end
              end
              ip = 762;
      end

        762 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[347] = heapMem[localMem[256]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 763;
      end

        763 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[348] = heapMem[localMem[311]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 764;
      end

        764 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[261]) begin
                  heapMem[NArea * localMem[348] + 0 + i] = heapMem[NArea * localMem[347] + 0 + i];
                  updateArrayLength(1, localMem[348], 0 + i);
                end
              end
              ip = 765;
      end

        765 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[349] = heapMem[localMem[256]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 766;
      end

        766 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[350] = heapMem[localMem[314]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 767;
      end

        767 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[261]) begin
                  heapMem[NArea * localMem[350] + 0 + i] = heapMem[NArea * localMem[349] + localMem[262] + i];
                  updateArrayLength(1, localMem[350], 0 + i);
                end
              end
              ip = 768;
      end

        768 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[351] = heapMem[localMem[256]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 769;
      end

        769 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[352] = heapMem[localMem[314]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 770;
      end

        770 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[261]) begin
                  heapMem[NArea * localMem[352] + 0 + i] = heapMem[NArea * localMem[351] + localMem[262] + i];
                  updateArrayLength(1, localMem[352], 0 + i);
                end
              end
              ip = 771;
      end

        771 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 772;
      end

        772 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[311]*10 + 2] = localMem[256];
              updateArrayLength(1, localMem[311], 2);
              ip = 773;
      end

        773 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[314]*10 + 2] = localMem[256];
              updateArrayLength(1, localMem[314], 2);
              ip = 774;
      end

        774 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[353] = heapMem[localMem[256]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 775;
      end

        775 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[354] = heapMem[localMem[353]*10 + localMem[261]];
              updateArrayLength(2, 0, 0);
              ip = 776;
      end

        776 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[355] = heapMem[localMem[256]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 777;
      end

        777 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[356] = heapMem[localMem[355]*10 + localMem[261]];
              updateArrayLength(2, 0, 0);
              ip = 778;
      end

        778 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[357] = heapMem[localMem[256]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 779;
      end

        779 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[357]*10 + 0] = localMem[354];
              updateArrayLength(1, localMem[357], 0);
              ip = 780;
      end

        780 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[358] = heapMem[localMem[256]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 781;
      end

        781 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[358]*10 + 0] = localMem[356];
              updateArrayLength(1, localMem[358], 0);
              ip = 782;
      end

        782 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[359] = heapMem[localMem[256]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 783;
      end

        783 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[359]*10 + 0] = localMem[311];
              updateArrayLength(1, localMem[359], 0);
              ip = 784;
      end

        784 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[360] = heapMem[localMem[256]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 785;
      end

        785 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[360]*10 + 1] = localMem[314];
              updateArrayLength(1, localMem[360], 1);
              ip = 786;
      end

        786 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[256]*10 + 0] = 1;
              updateArrayLength(1, localMem[256], 0);
              ip = 787;
      end

        787 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[361] = heapMem[localMem[256]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 788;
      end

        788 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[361]] = 1;
              ip = 789;
      end

        789 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[362] = heapMem[localMem[256]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 790;
      end

        790 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[362]] = 1;
              ip = 791;
      end

        791 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[363] = heapMem[localMem[256]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 792;
      end

        792 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[363]] = 2;
              ip = 793;
      end

        793 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 795;
      end

        794 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 800;
      end

        795 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 796;
      end

        796 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[257] = 1;
              updateArrayLength(2, 0, 0);
              ip = 797;
      end

        797 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 800;
      end

        798 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 799;
      end

        799 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[257] = 0;
              updateArrayLength(2, 0, 0);
              ip = 800;
      end

        800 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 801;
      end

        801 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[257] != 0 ? 803 : 802;
      end

        802 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[28] = localMem[256];
              updateArrayLength(2, 0, 0);
              ip = 803;
      end

        803 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 804;
      end

        804 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 805;
      end

        805 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[136] = localMem[136] + 1;
              updateArrayLength(2, 0, 0);
              ip = 806;
      end

        806 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 308;
      end

        807 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 808;
      end

        808 :
      begin                                                                     // assert
//$display("AAAA %4d %4d assert", steps, ip);
            ip = 809;
      end

        809 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 810;
      end

        810 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 811;
      end

        811 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 812;
      end

        812 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[364] = heapMem[localMem[5]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 813;
      end

        813 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[365] = heapMem[localMem[5]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 814;
      end

        814 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[366] = heapMem[localMem[5]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 815;
      end

        815 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[365] != 1 ? 819 : 816;
      end

        816 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[367] = heapMem[localMem[364]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 817;
      end

        817 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[367]*10 + localMem[366]] = localMem[4];
              updateArrayLength(1, localMem[367], localMem[366]);
              ip = 818;
      end

        818 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1065;
      end

        819 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 820;
      end

        820 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[365] != 2 ? 828 : 821;
      end

        821 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[368] = localMem[366] + 1;
              updateArrayLength(2, 0, 0);
              ip = 822;
      end

        822 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[369] = heapMem[localMem[364]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 823;
      end

        823 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[369] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[368], localMem[369], arraySizes[localMem[369]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[368] && i <= arraySizes[localMem[369]]) begin
                  heapMem[NArea * localMem[369] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[369] + localMem[368]] = localMem[3];                                    // Insert new value
              arraySizes[localMem[369]] = arraySizes[localMem[369]] + 1;                              // Increase array size
              ip = 824;
      end

        824 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[370] = heapMem[localMem[364]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 825;
      end

        825 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[370] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[368], localMem[370], arraySizes[localMem[370]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[368] && i <= arraySizes[localMem[370]]) begin
                  heapMem[NArea * localMem[370] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[370] + localMem[368]] = localMem[4];                                    // Insert new value
              arraySizes[localMem[370]] = arraySizes[localMem[370]] + 1;                              // Increase array size
              ip = 826;
      end

        826 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[364]*10 + 0] = heapMem[localMem[364]*10 + 0] + 1;
              updateArrayLength(1, localMem[364], 0);
              ip = 827;
      end

        827 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 834;
      end

        828 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 829;
      end

        829 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[371] = heapMem[localMem[364]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 830;
      end

        830 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[371] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[366], localMem[371], arraySizes[localMem[371]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[366] && i <= arraySizes[localMem[371]]) begin
                  heapMem[NArea * localMem[371] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[371] + localMem[366]] = localMem[3];                                    // Insert new value
              arraySizes[localMem[371]] = arraySizes[localMem[371]] + 1;                              // Increase array size
              ip = 831;
      end

        831 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[372] = heapMem[localMem[364]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 832;
      end

        832 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[372] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[366], localMem[372], arraySizes[localMem[372]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[366] && i <= arraySizes[localMem[372]]) begin
                  heapMem[NArea * localMem[372] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[372] + localMem[366]] = localMem[4];                                    // Insert new value
              arraySizes[localMem[372]] = arraySizes[localMem[372]] + 1;                              // Increase array size
              ip = 833;
      end

        833 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[364]*10 + 0] = heapMem[localMem[364]*10 + 0] + 1;
              updateArrayLength(1, localMem[364], 0);
              ip = 834;
      end

        834 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 835;
      end

        835 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              updateArrayLength(1, localMem[0], 0);
              ip = 836;
      end

        836 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 837;
      end

        837 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[374] = heapMem[localMem[364]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 838;
      end

        838 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[375] = heapMem[localMem[364]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 839;
      end

        839 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[376] = heapMem[localMem[375]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 840;
      end

        840 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[374] <  localMem[376] ? 1060 : 841;
      end

        841 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[377] = localMem[376];
              updateArrayLength(2, 0, 0);
              ip = 842;
      end

        842 :
      begin                                                                     // shiftRight
//$display("AAAA %4d %4d shiftRight", steps, ip);
              localMem[377] = localMem[377] >> 1;
              ip = 843;
      end

        843 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[378] = localMem[377] + 1;
              updateArrayLength(2, 0, 0);
              ip = 844;
      end

        844 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[379] = heapMem[localMem[364]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 845;
      end

        845 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[379] == 0 ? 942 : 846;
      end

        846 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[380] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[380] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[380]] = 0;
              ip = 847;
      end

        847 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[380]*10 + 0] = localMem[377];
              updateArrayLength(1, localMem[380], 0);
              ip = 848;
      end

        848 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[380]*10 + 2] = 0;
              updateArrayLength(1, localMem[380], 2);
              ip = 849;
      end

        849 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[381] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[381] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[381]] = 0;
              ip = 850;
      end

        850 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[380]*10 + 4] = localMem[381];
              updateArrayLength(1, localMem[380], 4);
              ip = 851;
      end

        851 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[382] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[382] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[382]] = 0;
              ip = 852;
      end

        852 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[380]*10 + 5] = localMem[382];
              updateArrayLength(1, localMem[380], 5);
              ip = 853;
      end

        853 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[380]*10 + 6] = 0;
              updateArrayLength(1, localMem[380], 6);
              ip = 854;
      end

        854 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[380]*10 + 3] = localMem[375];
              updateArrayLength(1, localMem[380], 3);
              ip = 855;
      end

        855 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[375]*10 + 1] = heapMem[localMem[375]*10 + 1] + 1;
              updateArrayLength(1, localMem[375], 1);
              ip = 856;
      end

        856 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[380]*10 + 1] = heapMem[localMem[375]*10 + 1];
              updateArrayLength(1, localMem[380], 1);
              ip = 857;
      end

        857 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[383] = !heapMem[localMem[364]*10 + 6];
              ip = 858;
      end

        858 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[383] != 0 ? 887 : 859;
      end

        859 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[384] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[384] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[384]] = 0;
              ip = 860;
      end

        860 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[380]*10 + 6] = localMem[384];
              updateArrayLength(1, localMem[380], 6);
              ip = 861;
      end

        861 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[385] = heapMem[localMem[364]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 862;
      end

        862 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[386] = heapMem[localMem[380]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 863;
      end

        863 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[377]) begin
                  heapMem[NArea * localMem[386] + 0 + i] = heapMem[NArea * localMem[385] + localMem[378] + i];
                  updateArrayLength(1, localMem[386], 0 + i);
                end
              end
              ip = 864;
      end

        864 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[387] = heapMem[localMem[364]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 865;
      end

        865 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[388] = heapMem[localMem[380]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 866;
      end

        866 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[377]) begin
                  heapMem[NArea * localMem[388] + 0 + i] = heapMem[NArea * localMem[387] + localMem[378] + i];
                  updateArrayLength(1, localMem[388], 0 + i);
                end
              end
              ip = 867;
      end

        867 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[389] = heapMem[localMem[364]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 868;
      end

        868 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[390] = heapMem[localMem[380]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 869;
      end

        869 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[391] = localMem[377] + 1;
              updateArrayLength(2, 0, 0);
              ip = 870;
      end

        870 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[391]) begin
                  heapMem[NArea * localMem[390] + 0 + i] = heapMem[NArea * localMem[389] + localMem[378] + i];
                  updateArrayLength(1, localMem[390], 0 + i);
                end
              end
              ip = 871;
      end

        871 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[392] = heapMem[localMem[380]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 872;
      end

        872 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[393] = localMem[392] + 1;
              updateArrayLength(2, 0, 0);
              ip = 873;
      end

        873 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[394] = heapMem[localMem[380]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 874;
      end

        874 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 875;
      end

        875 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[395] = 0;
              updateArrayLength(2, 0, 0);
              ip = 876;
      end

        876 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 877;
      end

        877 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[395] >= localMem[393] ? 883 : 878;
      end

        878 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[396] = heapMem[localMem[394]*10 + localMem[395]];
              updateArrayLength(2, 0, 0);
              ip = 879;
      end

        879 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[396]*10 + 2] = localMem[380];
              updateArrayLength(1, localMem[396], 2);
              ip = 880;
      end

        880 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 881;
      end

        881 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[395] = localMem[395] + 1;
              updateArrayLength(2, 0, 0);
              ip = 882;
      end

        882 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 876;
      end

        883 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 884;
      end

        884 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[397] = heapMem[localMem[364]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 885;
      end

        885 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[397]] = localMem[378];
              ip = 886;
      end

        886 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 894;
      end

        887 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 888;
      end

        888 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[398] = heapMem[localMem[364]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 889;
      end

        889 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[399] = heapMem[localMem[380]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 890;
      end

        890 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[377]) begin
                  heapMem[NArea * localMem[399] + 0 + i] = heapMem[NArea * localMem[398] + localMem[378] + i];
                  updateArrayLength(1, localMem[399], 0 + i);
                end
              end
              ip = 891;
      end

        891 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[400] = heapMem[localMem[364]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 892;
      end

        892 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[401] = heapMem[localMem[380]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 893;
      end

        893 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[377]) begin
                  heapMem[NArea * localMem[401] + 0 + i] = heapMem[NArea * localMem[400] + localMem[378] + i];
                  updateArrayLength(1, localMem[401], 0 + i);
                end
              end
              ip = 894;
      end

        894 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 895;
      end

        895 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[364]*10 + 0] = localMem[377];
              updateArrayLength(1, localMem[364], 0);
              ip = 896;
      end

        896 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[380]*10 + 2] = localMem[379];
              updateArrayLength(1, localMem[380], 2);
              ip = 897;
      end

        897 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[402] = heapMem[localMem[379]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 898;
      end

        898 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[403] = heapMem[localMem[379]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 899;
      end

        899 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[404] = heapMem[localMem[403]*10 + localMem[402]];
              updateArrayLength(2, 0, 0);
              ip = 900;
      end

        900 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[404] != localMem[364] ? 919 : 901;
      end

        901 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[405] = heapMem[localMem[364]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 902;
      end

        902 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[406] = heapMem[localMem[405]*10 + localMem[377]];
              updateArrayLength(2, 0, 0);
              ip = 903;
      end

        903 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[407] = heapMem[localMem[379]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 904;
      end

        904 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[407]*10 + localMem[402]] = localMem[406];
              updateArrayLength(1, localMem[407], localMem[402]);
              ip = 905;
      end

        905 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[408] = heapMem[localMem[364]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 906;
      end

        906 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[409] = heapMem[localMem[408]*10 + localMem[377]];
              updateArrayLength(2, 0, 0);
              ip = 907;
      end

        907 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[410] = heapMem[localMem[379]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 908;
      end

        908 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[410]*10 + localMem[402]] = localMem[409];
              updateArrayLength(1, localMem[410], localMem[402]);
              ip = 909;
      end

        909 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[411] = heapMem[localMem[364]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 910;
      end

        910 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[411]] = localMem[377];
              ip = 911;
      end

        911 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[412] = heapMem[localMem[364]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 912;
      end

        912 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[412]] = localMem[377];
              ip = 913;
      end

        913 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[413] = localMem[402] + 1;
              updateArrayLength(2, 0, 0);
              ip = 914;
      end

        914 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[379]*10 + 0] = localMem[413];
              updateArrayLength(1, localMem[379], 0);
              ip = 915;
      end

        915 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[414] = heapMem[localMem[379]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 916;
      end

        916 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[414]*10 + localMem[413]] = localMem[380];
              updateArrayLength(1, localMem[414], localMem[413]);
              ip = 917;
      end

        917 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1057;
      end

        918 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 941;
      end

        919 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 920;
      end

        920 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 921;
      end

        921 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[415] = heapMem[localMem[379]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 922;
      end

        922 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[416] = 0; k = arraySizes[localMem[415]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[415] * NArea + i] == localMem[364]) localMem[416] = i + 1;
              end
              ip = 923;
      end

        923 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[416] = localMem[416] - 1;
              updateArrayLength(2, 0, 0);
              ip = 924;
      end

        924 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[417] = heapMem[localMem[364]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 925;
      end

        925 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[418] = heapMem[localMem[417]*10 + localMem[377]];
              updateArrayLength(2, 0, 0);
              ip = 926;
      end

        926 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[419] = heapMem[localMem[364]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 927;
      end

        927 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[420] = heapMem[localMem[419]*10 + localMem[377]];
              updateArrayLength(2, 0, 0);
              ip = 928;
      end

        928 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[421] = heapMem[localMem[364]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 929;
      end

        929 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[421]] = localMem[377];
              ip = 930;
      end

        930 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[422] = heapMem[localMem[364]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 931;
      end

        931 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[422]] = localMem[377];
              ip = 932;
      end

        932 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[423] = heapMem[localMem[379]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 933;
      end

        933 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[423] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[416], localMem[423], arraySizes[localMem[423]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[416] && i <= arraySizes[localMem[423]]) begin
                  heapMem[NArea * localMem[423] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[423] + localMem[416]] = localMem[418];                                    // Insert new value
              arraySizes[localMem[423]] = arraySizes[localMem[423]] + 1;                              // Increase array size
              ip = 934;
      end

        934 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[424] = heapMem[localMem[379]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 935;
      end

        935 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[424] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[416], localMem[424], arraySizes[localMem[424]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[416] && i <= arraySizes[localMem[424]]) begin
                  heapMem[NArea * localMem[424] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[424] + localMem[416]] = localMem[420];                                    // Insert new value
              arraySizes[localMem[424]] = arraySizes[localMem[424]] + 1;                              // Increase array size
              ip = 936;
      end

        936 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[425] = heapMem[localMem[379]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 937;
      end

        937 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[426] = localMem[416] + 1;
              updateArrayLength(2, 0, 0);
              ip = 938;
      end

        938 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[425] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[426], localMem[425], arraySizes[localMem[425]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[426] && i <= arraySizes[localMem[425]]) begin
                  heapMem[NArea * localMem[425] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[425] + localMem[426]] = localMem[380];                                    // Insert new value
              arraySizes[localMem[425]] = arraySizes[localMem[425]] + 1;                              // Increase array size
              ip = 939;
      end

        939 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[379]*10 + 0] = heapMem[localMem[379]*10 + 0] + 1;
              updateArrayLength(1, localMem[379], 0);
              ip = 940;
      end

        940 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1057;
      end

        941 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 942;
      end

        942 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 943;
      end

        943 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[427] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[427] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[427]] = 0;
              ip = 944;
      end

        944 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[427]*10 + 0] = localMem[377];
              updateArrayLength(1, localMem[427], 0);
              ip = 945;
      end

        945 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[427]*10 + 2] = 0;
              updateArrayLength(1, localMem[427], 2);
              ip = 946;
      end

        946 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[428] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[428] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[428]] = 0;
              ip = 947;
      end

        947 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[427]*10 + 4] = localMem[428];
              updateArrayLength(1, localMem[427], 4);
              ip = 948;
      end

        948 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[429] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[429] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[429]] = 0;
              ip = 949;
      end

        949 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[427]*10 + 5] = localMem[429];
              updateArrayLength(1, localMem[427], 5);
              ip = 950;
      end

        950 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[427]*10 + 6] = 0;
              updateArrayLength(1, localMem[427], 6);
              ip = 951;
      end

        951 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[427]*10 + 3] = localMem[375];
              updateArrayLength(1, localMem[427], 3);
              ip = 952;
      end

        952 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[375]*10 + 1] = heapMem[localMem[375]*10 + 1] + 1;
              updateArrayLength(1, localMem[375], 1);
              ip = 953;
      end

        953 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[427]*10 + 1] = heapMem[localMem[375]*10 + 1];
              updateArrayLength(1, localMem[427], 1);
              ip = 954;
      end

        954 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[430] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[430] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[430]] = 0;
              ip = 955;
      end

        955 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[430]*10 + 0] = localMem[377];
              updateArrayLength(1, localMem[430], 0);
              ip = 956;
      end

        956 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[430]*10 + 2] = 0;
              updateArrayLength(1, localMem[430], 2);
              ip = 957;
      end

        957 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[431] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[431] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[431]] = 0;
              ip = 958;
      end

        958 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[430]*10 + 4] = localMem[431];
              updateArrayLength(1, localMem[430], 4);
              ip = 959;
      end

        959 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[432] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[432] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[432]] = 0;
              ip = 960;
      end

        960 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[430]*10 + 5] = localMem[432];
              updateArrayLength(1, localMem[430], 5);
              ip = 961;
      end

        961 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[430]*10 + 6] = 0;
              updateArrayLength(1, localMem[430], 6);
              ip = 962;
      end

        962 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[430]*10 + 3] = localMem[375];
              updateArrayLength(1, localMem[430], 3);
              ip = 963;
      end

        963 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[375]*10 + 1] = heapMem[localMem[375]*10 + 1] + 1;
              updateArrayLength(1, localMem[375], 1);
              ip = 964;
      end

        964 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[430]*10 + 1] = heapMem[localMem[375]*10 + 1];
              updateArrayLength(1, localMem[430], 1);
              ip = 965;
      end

        965 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[433] = !heapMem[localMem[364]*10 + 6];
              ip = 966;
      end

        966 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[433] != 0 ? 1018 : 967;
      end

        967 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[434] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[434] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[434]] = 0;
              ip = 968;
      end

        968 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[427]*10 + 6] = localMem[434];
              updateArrayLength(1, localMem[427], 6);
              ip = 969;
      end

        969 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[435] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[435] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[435]] = 0;
              ip = 970;
      end

        970 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[430]*10 + 6] = localMem[435];
              updateArrayLength(1, localMem[430], 6);
              ip = 971;
      end

        971 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[436] = heapMem[localMem[364]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 972;
      end

        972 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[437] = heapMem[localMem[427]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 973;
      end

        973 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[377]) begin
                  heapMem[NArea * localMem[437] + 0 + i] = heapMem[NArea * localMem[436] + 0 + i];
                  updateArrayLength(1, localMem[437], 0 + i);
                end
              end
              ip = 974;
      end

        974 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[438] = heapMem[localMem[364]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 975;
      end

        975 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[439] = heapMem[localMem[427]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 976;
      end

        976 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[377]) begin
                  heapMem[NArea * localMem[439] + 0 + i] = heapMem[NArea * localMem[438] + 0 + i];
                  updateArrayLength(1, localMem[439], 0 + i);
                end
              end
              ip = 977;
      end

        977 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[440] = heapMem[localMem[364]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 978;
      end

        978 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[441] = heapMem[localMem[427]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 979;
      end

        979 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[442] = localMem[377] + 1;
              updateArrayLength(2, 0, 0);
              ip = 980;
      end

        980 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[442]) begin
                  heapMem[NArea * localMem[441] + 0 + i] = heapMem[NArea * localMem[440] + 0 + i];
                  updateArrayLength(1, localMem[441], 0 + i);
                end
              end
              ip = 981;
      end

        981 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[443] = heapMem[localMem[364]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 982;
      end

        982 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[444] = heapMem[localMem[430]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 983;
      end

        983 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[377]) begin
                  heapMem[NArea * localMem[444] + 0 + i] = heapMem[NArea * localMem[443] + localMem[378] + i];
                  updateArrayLength(1, localMem[444], 0 + i);
                end
              end
              ip = 984;
      end

        984 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[445] = heapMem[localMem[364]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 985;
      end

        985 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[446] = heapMem[localMem[430]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 986;
      end

        986 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[377]) begin
                  heapMem[NArea * localMem[446] + 0 + i] = heapMem[NArea * localMem[445] + localMem[378] + i];
                  updateArrayLength(1, localMem[446], 0 + i);
                end
              end
              ip = 987;
      end

        987 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[447] = heapMem[localMem[364]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 988;
      end

        988 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[448] = heapMem[localMem[430]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 989;
      end

        989 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[449] = localMem[377] + 1;
              updateArrayLength(2, 0, 0);
              ip = 990;
      end

        990 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[449]) begin
                  heapMem[NArea * localMem[448] + 0 + i] = heapMem[NArea * localMem[447] + localMem[378] + i];
                  updateArrayLength(1, localMem[448], 0 + i);
                end
              end
              ip = 991;
      end

        991 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[450] = heapMem[localMem[427]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 992;
      end

        992 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[451] = localMem[450] + 1;
              updateArrayLength(2, 0, 0);
              ip = 993;
      end

        993 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[452] = heapMem[localMem[427]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 994;
      end

        994 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 995;
      end

        995 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[453] = 0;
              updateArrayLength(2, 0, 0);
              ip = 996;
      end

        996 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 997;
      end

        997 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[453] >= localMem[451] ? 1003 : 998;
      end

        998 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[454] = heapMem[localMem[452]*10 + localMem[453]];
              updateArrayLength(2, 0, 0);
              ip = 999;
      end

        999 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[454]*10 + 2] = localMem[427];
              updateArrayLength(1, localMem[454], 2);
              ip = 1000;
      end

       1000 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1001;
      end

       1001 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[453] = localMem[453] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1002;
      end

       1002 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 996;
      end

       1003 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1004;
      end

       1004 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[455] = heapMem[localMem[430]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1005;
      end

       1005 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[456] = localMem[455] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1006;
      end

       1006 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[457] = heapMem[localMem[430]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1007;
      end

       1007 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1008;
      end

       1008 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[458] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1009;
      end

       1009 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1010;
      end

       1010 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[458] >= localMem[456] ? 1016 : 1011;
      end

       1011 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[459] = heapMem[localMem[457]*10 + localMem[458]];
              updateArrayLength(2, 0, 0);
              ip = 1012;
      end

       1012 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[459]*10 + 2] = localMem[430];
              updateArrayLength(1, localMem[459], 2);
              ip = 1013;
      end

       1013 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1014;
      end

       1014 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[458] = localMem[458] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1015;
      end

       1015 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1009;
      end

       1016 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1017;
      end

       1017 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1033;
      end

       1018 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1019;
      end

       1019 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[460] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[460] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[460]] = 0;
              ip = 1020;
      end

       1020 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[364]*10 + 6] = localMem[460];
              updateArrayLength(1, localMem[364], 6);
              ip = 1021;
      end

       1021 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[461] = heapMem[localMem[364]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1022;
      end

       1022 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[462] = heapMem[localMem[427]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1023;
      end

       1023 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[377]) begin
                  heapMem[NArea * localMem[462] + 0 + i] = heapMem[NArea * localMem[461] + 0 + i];
                  updateArrayLength(1, localMem[462], 0 + i);
                end
              end
              ip = 1024;
      end

       1024 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[463] = heapMem[localMem[364]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1025;
      end

       1025 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[464] = heapMem[localMem[427]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1026;
      end

       1026 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[377]) begin
                  heapMem[NArea * localMem[464] + 0 + i] = heapMem[NArea * localMem[463] + 0 + i];
                  updateArrayLength(1, localMem[464], 0 + i);
                end
              end
              ip = 1027;
      end

       1027 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[465] = heapMem[localMem[364]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1028;
      end

       1028 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[466] = heapMem[localMem[430]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1029;
      end

       1029 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[377]) begin
                  heapMem[NArea * localMem[466] + 0 + i] = heapMem[NArea * localMem[465] + localMem[378] + i];
                  updateArrayLength(1, localMem[466], 0 + i);
                end
              end
              ip = 1030;
      end

       1030 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[467] = heapMem[localMem[364]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1031;
      end

       1031 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[468] = heapMem[localMem[430]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1032;
      end

       1032 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[377]) begin
                  heapMem[NArea * localMem[468] + 0 + i] = heapMem[NArea * localMem[467] + localMem[378] + i];
                  updateArrayLength(1, localMem[468], 0 + i);
                end
              end
              ip = 1033;
      end

       1033 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1034;
      end

       1034 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[427]*10 + 2] = localMem[364];
              updateArrayLength(1, localMem[427], 2);
              ip = 1035;
      end

       1035 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[430]*10 + 2] = localMem[364];
              updateArrayLength(1, localMem[430], 2);
              ip = 1036;
      end

       1036 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[469] = heapMem[localMem[364]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1037;
      end

       1037 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[470] = heapMem[localMem[469]*10 + localMem[377]];
              updateArrayLength(2, 0, 0);
              ip = 1038;
      end

       1038 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[471] = heapMem[localMem[364]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1039;
      end

       1039 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[472] = heapMem[localMem[471]*10 + localMem[377]];
              updateArrayLength(2, 0, 0);
              ip = 1040;
      end

       1040 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[473] = heapMem[localMem[364]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1041;
      end

       1041 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[473]*10 + 0] = localMem[470];
              updateArrayLength(1, localMem[473], 0);
              ip = 1042;
      end

       1042 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[474] = heapMem[localMem[364]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1043;
      end

       1043 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[474]*10 + 0] = localMem[472];
              updateArrayLength(1, localMem[474], 0);
              ip = 1044;
      end

       1044 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[475] = heapMem[localMem[364]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1045;
      end

       1045 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[475]*10 + 0] = localMem[427];
              updateArrayLength(1, localMem[475], 0);
              ip = 1046;
      end

       1046 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[476] = heapMem[localMem[364]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1047;
      end

       1047 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[476]*10 + 1] = localMem[430];
              updateArrayLength(1, localMem[476], 1);
              ip = 1048;
      end

       1048 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[364]*10 + 0] = 1;
              updateArrayLength(1, localMem[364], 0);
              ip = 1049;
      end

       1049 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[477] = heapMem[localMem[364]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1050;
      end

       1050 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[477]] = 1;
              ip = 1051;
      end

       1051 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[478] = heapMem[localMem[364]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1052;
      end

       1052 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[478]] = 1;
              ip = 1053;
      end

       1053 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[479] = heapMem[localMem[364]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1054;
      end

       1054 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[479]] = 2;
              ip = 1055;
      end

       1055 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1057;
      end

       1056 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1062;
      end

       1057 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1058;
      end

       1058 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[373] = 1;
              updateArrayLength(2, 0, 0);
              ip = 1059;
      end

       1059 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1062;
      end

       1060 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1061;
      end

       1061 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[373] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1062;
      end

       1062 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1063;
      end

       1063 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1064;
      end

       1064 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1065;
      end

       1065 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1066;
      end

       1066 :
      begin                                                                     // free
//$display("AAAA %4d %4d free", steps, ip);
                                 arraySizes[localMem[5]] = 0;
              freedArrays[freedArraysTop] = localMem[5];
              freedArraysTop = freedArraysTop + 1;
              ip = 1067;
      end

       1067 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1068;
      end

       1068 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 6;
      end

       1069 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1070;
      end

       1070 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[480] = 1;
              updateArrayLength(2, 0, 0);
              ip = 1071;
      end

       1071 :
      begin                                                                     // shiftLeft
//$display("AAAA %4d %4d shiftLeft", steps, ip);
              localMem[480] = localMem[480] << 31;
              ip = 1072;
      end

       1072 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[481] = heapMem[localMem[0]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 1073;
      end

       1073 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[482] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[482] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[482]] = 0;
              ip = 1074;
      end

       1074 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[483] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[483] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[483]] = 0;
              ip = 1075;
      end

       1075 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[481] != 0 ? 1080 : 1076;
      end

       1076 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[482]*10 + 0] = localMem[481];
              updateArrayLength(1, localMem[482], 0);
              ip = 1077;
      end

       1077 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[482]*10 + 1] = 3;
              updateArrayLength(1, localMem[482], 1);
              ip = 1078;
      end

       1078 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[482]*10 + 2] = 0;
              updateArrayLength(1, localMem[482], 2);
              ip = 1079;
      end

       1079 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1097;
      end

       1080 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1081;
      end

       1081 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1082;
      end

       1082 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[484] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1083;
      end

       1083 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1084;
      end

       1084 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[484] >= 99 ? 1093 : 1085;
      end

       1085 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[485] = !heapMem[localMem[481]*10 + 6];
              ip = 1086;
      end

       1086 :
      begin                                                                     // jTrue
//$display("AAAA %4d %4d jTrue", steps, ip);
              ip = localMem[485] != 0 ? 1093 : 1087;
      end

       1087 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[486] = heapMem[localMem[481]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1088;
      end

       1088 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[487] = heapMem[localMem[486]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1089;
      end

       1089 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[481] = localMem[487];
              updateArrayLength(2, 0, 0);
              ip = 1090;
      end

       1090 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1091;
      end

       1091 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[484] = localMem[484] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1092;
      end

       1092 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1083;
      end

       1093 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1094;
      end

       1094 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[482]*10 + 0] = localMem[481];
              updateArrayLength(1, localMem[482], 0);
              ip = 1095;
      end

       1095 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[482]*10 + 1] = 1;
              updateArrayLength(1, localMem[482], 1);
              ip = 1096;
      end

       1096 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[482]*10 + 2] = 0;
              updateArrayLength(1, localMem[482], 2);
              ip = 1097;
      end

       1097 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1098;
      end

       1098 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1099;
      end

       1099 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[488] = heapMem[localMem[482]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 1100;
      end

       1100 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[488] == 3 ? 1183 : 1101;
      end

       1101 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 3) begin
                  heapMem[NArea * localMem[483] + 0 + i] = heapMem[NArea * localMem[482] + 0 + i];
                  updateArrayLength(1, localMem[483], 0 + i);
                end
              end
              ip = 1102;
      end

       1102 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[489] = heapMem[localMem[483]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1103;
      end

       1103 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[490] = heapMem[localMem[483]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1104;
      end

       1104 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[491] = heapMem[localMem[489]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1105;
      end

       1105 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[492] = heapMem[localMem[491]*10 + localMem[490]];
              updateArrayLength(2, 0, 0);
              ip = 1106;
      end

       1106 :
      begin                                                                     // out
//$display("AAAA %4d %4d out", steps, ip);
              outMem[outMemPos] = localMem[492];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 1107;
      end

       1107 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1108;
      end

       1108 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[493] = heapMem[localMem[482]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1109;
      end

       1109 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[494] = !heapMem[localMem[493]*10 + 6];
              ip = 1110;
      end

       1110 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[494] == 0 ? 1150 : 1111;
      end

       1111 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[495] = heapMem[localMem[482]*10 + 2] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1112;
      end

       1112 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[496] = heapMem[localMem[493]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1113;
      end

       1113 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[495] >= localMem[496] ? 1118 : 1114;
      end

       1114 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[482]*10 + 0] = localMem[493];
              updateArrayLength(1, localMem[482], 0);
              ip = 1115;
      end

       1115 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[482]*10 + 1] = 1;
              updateArrayLength(1, localMem[482], 1);
              ip = 1116;
      end

       1116 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[482]*10 + 2] = localMem[495];
              updateArrayLength(1, localMem[482], 2);
              ip = 1117;
      end

       1117 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1179;
      end

       1118 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1119;
      end

       1119 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[497] = heapMem[localMem[493]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1120;
      end

       1120 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[497] == 0 ? 1145 : 1121;
      end

       1121 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1122;
      end

       1122 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[498] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1123;
      end

       1123 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1124;
      end

       1124 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[498] >= 99 ? 1144 : 1125;
      end

       1125 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[499] = heapMem[localMem[497]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1126;
      end

       1126 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 1127;
      end

       1127 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[500] = heapMem[localMem[497]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1128;
      end

       1128 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[501] = 0; k = arraySizes[localMem[500]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[500] * NArea + i] == localMem[493]) localMem[501] = i + 1;
              end
              ip = 1129;
      end

       1129 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[501] = localMem[501] - 1;
              updateArrayLength(2, 0, 0);
              ip = 1130;
      end

       1130 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[501] != localMem[499] ? 1135 : 1131;
      end

       1131 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[493] = localMem[497];
              updateArrayLength(2, 0, 0);
              ip = 1132;
      end

       1132 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[497] = heapMem[localMem[493]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1133;
      end

       1133 :
      begin                                                                     // jFalse
//$display("AAAA %4d %4d jFalse", steps, ip);
              ip = localMem[497] == 0 ? 1144 : 1134;
      end

       1134 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1140;
      end

       1135 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1136;
      end

       1136 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[482]*10 + 0] = localMem[497];
              updateArrayLength(1, localMem[482], 0);
              ip = 1137;
      end

       1137 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[482]*10 + 1] = 1;
              updateArrayLength(1, localMem[482], 1);
              ip = 1138;
      end

       1138 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[482]*10 + 2] = localMem[501];
              updateArrayLength(1, localMem[482], 2);
              ip = 1139;
      end

       1139 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1179;
      end

       1140 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1141;
      end

       1141 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1142;
      end

       1142 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[498] = localMem[498] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1143;
      end

       1143 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1123;
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
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[482]*10 + 0] = localMem[493];
              updateArrayLength(1, localMem[482], 0);
              ip = 1147;
      end

       1147 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[482]*10 + 1] = 3;
              updateArrayLength(1, localMem[482], 1);
              ip = 1148;
      end

       1148 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[482]*10 + 2] = 0;
              updateArrayLength(1, localMem[482], 2);
              ip = 1149;
      end

       1149 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1179;
      end

       1150 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1151;
      end

       1151 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[502] = heapMem[localMem[482]*10 + 2] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1152;
      end

       1152 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[503] = heapMem[localMem[493]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1153;
      end

       1153 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[504] = heapMem[localMem[503]*10 + localMem[502]];
              updateArrayLength(2, 0, 0);
              ip = 1154;
      end

       1154 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[504] != 0 ? 1159 : 1155;
      end

       1155 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[482]*10 + 0] = localMem[504];
              updateArrayLength(1, localMem[482], 0);
              ip = 1156;
      end

       1156 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[482]*10 + 1] = 3;
              updateArrayLength(1, localMem[482], 1);
              ip = 1157;
      end

       1157 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[482]*10 + 2] = 0;
              updateArrayLength(1, localMem[482], 2);
              ip = 1158;
      end

       1158 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1176;
      end

       1159 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1160;
      end

       1160 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1161;
      end

       1161 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[505] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1162;
      end

       1162 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1163;
      end

       1163 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[505] >= 99 ? 1172 : 1164;
      end

       1164 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[506] = !heapMem[localMem[504]*10 + 6];
              ip = 1165;
      end

       1165 :
      begin                                                                     // jTrue
//$display("AAAA %4d %4d jTrue", steps, ip);
              ip = localMem[506] != 0 ? 1172 : 1166;
      end

       1166 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[507] = heapMem[localMem[504]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1167;
      end

       1167 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[508] = heapMem[localMem[507]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1168;
      end

       1168 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[504] = localMem[508];
              updateArrayLength(2, 0, 0);
              ip = 1169;
      end

       1169 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1170;
      end

       1170 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[505] = localMem[505] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1171;
      end

       1171 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1162;
      end

       1172 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1173;
      end

       1173 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[482]*10 + 0] = localMem[504];
              updateArrayLength(1, localMem[482], 0);
              ip = 1174;
      end

       1174 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[482]*10 + 1] = 1;
              updateArrayLength(1, localMem[482], 1);
              ip = 1175;
      end

       1175 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[482]*10 + 2] = 0;
              updateArrayLength(1, localMem[482], 2);
              ip = 1176;
      end

       1176 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1177;
      end

       1177 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1178;
      end

       1178 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1179;
      end

       1179 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1180;
      end

       1180 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1098;
      end

       1181 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1182;
      end

       1182 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1183;
      end

       1183 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1184;
      end

       1184 :
      begin                                                                     // free
//$display("AAAA %4d %4d free", steps, ip);
                                 arraySizes[localMem[482]] = 0;
              freedArrays[freedArraysTop] = localMem[482];
              freedArraysTop = freedArraysTop + 1;
              ip = 1185;
      end

       1185 :
      begin                                                                     // free
//$display("AAAA %4d %4d free", steps, ip);
                                 arraySizes[localMem[483]] = 0;
              freedArrays[freedArraysTop] = localMem[483];
              freedArraysTop = freedArraysTop + 1;
              ip = 1186;
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
        finished = 1;
      end
    endcase
    if (steps <=   9369) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
//for(i = 0; i < 200; ++i) $write("%2d",   localMem[i]); $display("");
//for(i = 0; i < 200; ++i) $write("%2d",    heapMem[i]); $display("");
//for(i = 0; i < 200; ++i) $write("%2d", arraySizes[i]); $display("");
  end
endmodule
