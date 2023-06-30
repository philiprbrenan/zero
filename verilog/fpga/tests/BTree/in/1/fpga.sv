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
  parameter integer NIn            =    10;                                       // Size of input area
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
    inMem[0] = 1;
    inMem[1] = 8;
    inMem[2] = 5;
    inMem[3] = 6;
    inMem[4] = 3;
    inMem[5] = 4;
    inMem[6] = 7;
    inMem[7] = 2;
    inMem[8] = 9;
    inMem[9] = 0;
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
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 6;
      end

          6 :
      begin                                                                     // inSize
//$display("AAAA %4d %4d inSize", steps, ip);
              localMem[1] = NIn - inMemPos;
              ip = 7;
      end

          7 :
      begin                                                                     // jFalse
//$display("AAAA %4d %4d jFalse", steps, ip);
              ip = localMem[1] == 0 ? 1068 : 8;
      end

          8 :
      begin                                                                     // in
//$display("AAAA %4d %4d in", steps, ip);
              if (inMemPos < NIn) begin
                localMem[2] = inMem[inMemPos];
                inMemPos = inMemPos + 1;
              end
              ip = 9;
      end

          9 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[3] = localMem[2] + localMem[2];
              updateArrayLength(2, 0, 0);
              ip = 10;
      end

         10 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[4] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[4] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[4]] = 0;
              ip = 11;
      end

         11 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 12;
      end

         12 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[5] = heapMem[localMem[0]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 13;
      end

         13 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[5] != 0 ? 36 : 14;
      end

         14 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[6] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[6] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[6]] = 0;
              ip = 15;
      end

         15 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[6]*10 + 0] = 1;
              updateArrayLength(1, localMem[6], 0);
              ip = 16;
      end

         16 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[6]*10 + 2] = 0;
              updateArrayLength(1, localMem[6], 2);
              ip = 17;
      end

         17 :
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
              ip = 18;
      end

         18 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[6]*10 + 4] = localMem[7];
              updateArrayLength(1, localMem[6], 4);
              ip = 19;
      end

         19 :
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
              ip = 20;
      end

         20 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[6]*10 + 5] = localMem[8];
              updateArrayLength(1, localMem[6], 5);
              ip = 21;
      end

         21 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[6]*10 + 6] = 0;
              updateArrayLength(1, localMem[6], 6);
              ip = 22;
      end

         22 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[6]*10 + 3] = localMem[0];
              updateArrayLength(1, localMem[6], 3);
              ip = 23;
      end

         23 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 1] = heapMem[localMem[0]*10 + 1] + 1;
              updateArrayLength(1, localMem[0], 1);
              ip = 24;
      end

         24 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[6]*10 + 1] = heapMem[localMem[0]*10 + 1];
              updateArrayLength(1, localMem[6], 1);
              ip = 25;
      end

         25 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[9] = heapMem[localMem[6]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 26;
      end

         26 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[9]*10 + 0] = localMem[2];
              updateArrayLength(1, localMem[9], 0);
              ip = 27;
      end

         27 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[10] = heapMem[localMem[6]*10 + 5];
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
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              updateArrayLength(1, localMem[0], 0);
              ip = 30;
      end

         30 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[0]*10 + 3] = localMem[6];
              updateArrayLength(1, localMem[0], 3);
              ip = 31;
      end

         31 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[11] = heapMem[localMem[6]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 32;
      end

         32 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[11]] = 1;
              ip = 33;
      end

         33 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[12] = heapMem[localMem[6]*10 + 5];
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
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1064;
      end

         36 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 37;
      end

         37 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[13] = heapMem[localMem[5]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 38;
      end

         38 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[14] = heapMem[localMem[0]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 39;
      end

         39 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[13] >= localMem[14] ? 75 : 40;
      end

         40 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[15] = heapMem[localMem[5]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 41;
      end

         41 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[15] != 0 ? 74 : 42;
      end

         42 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[16] = !heapMem[localMem[5]*10 + 6];
              ip = 43;
      end

         43 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[16] == 0 ? 73 : 44;
      end

         44 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[17] = heapMem[localMem[5]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 45;
      end

         45 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[18] = 0; k = arraySizes[localMem[17]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[17] * NArea + i] == localMem[2]) localMem[18] = i + 1;
              end
              ip = 46;
      end

         46 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[18] == 0 ? 51 : 47;
      end

         47 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[18] = localMem[18] - 1;
              updateArrayLength(2, 0, 0);
              ip = 48;
      end

         48 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[19] = heapMem[localMem[5]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 49;
      end

         49 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[19]*10 + localMem[18]] = localMem[3];
              updateArrayLength(1, localMem[19], localMem[18]);
              ip = 50;
      end

         50 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1064;
      end

         51 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 52;
      end

         52 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[17]] = localMem[13];
              ip = 53;
      end

         53 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[20] = heapMem[localMem[5]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 54;
      end

         54 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[20]] = localMem[13];
              ip = 55;
      end

         55 :
      begin                                                                     // arrayCountGreater
//$display("AAAA %4d %4d arrayCountGreater", steps, ip);
              j = 0; k = arraySizes[localMem[17]];
//$display("AAAAA k=%d  source2=%d", k, localMem[2]);
              for(i = 0; i < NArea; i = i + 1) begin
//$display("AAAAA i=%d  value=%d", i, heapMem[localMem[17] * NArea + i]);
                if (i < k && heapMem[localMem[17] * NArea + i] > localMem[2]) j = j + 1;
              end
              localMem[21] = j;
              ip = 56;
      end

         56 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[21] != 0 ? 64 : 57;
      end

         57 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[22] = heapMem[localMem[5]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 58;
      end

         58 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[22]*10 + localMem[13]] = localMem[2];
              updateArrayLength(1, localMem[22], localMem[13]);
              ip = 59;
      end

         59 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[23] = heapMem[localMem[5]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 60;
      end

         60 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[23]*10 + localMem[13]] = localMem[3];
              updateArrayLength(1, localMem[23], localMem[13]);
              ip = 61;
      end

         61 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[5]*10 + 0] = localMem[13] + 1;
              updateArrayLength(1, localMem[5], 0);
              ip = 62;
      end

         62 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              updateArrayLength(1, localMem[0], 0);
              ip = 63;
      end

         63 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1064;
      end

         64 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 65;
      end

         65 :
      begin                                                                     // arrayCountLess
//$display("AAAA %4d %4d arrayCountLess", steps, ip);
              j = 0; k = arraySizes[localMem[17]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[17] * NArea + i] < localMem[2]) j = j + 1;
              end
              localMem[24] = j;
              ip = 66;
      end

         66 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[25] = heapMem[localMem[5]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 67;
      end

         67 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[25] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[24], localMem[25], arraySizes[localMem[25]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[24] && i <= arraySizes[localMem[25]]) begin
                  heapMem[NArea * localMem[25] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[25] + localMem[24]] = localMem[2];                                    // Insert new value
              arraySizes[localMem[25]] = arraySizes[localMem[25]] + 1;                              // Increase array size
              ip = 68;
      end

         68 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[26] = heapMem[localMem[5]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 69;
      end

         69 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[26] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[24], localMem[26], arraySizes[localMem[26]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[24] && i <= arraySizes[localMem[26]]) begin
                  heapMem[NArea * localMem[26] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[26] + localMem[24]] = localMem[3];                                    // Insert new value
              arraySizes[localMem[26]] = arraySizes[localMem[26]] + 1;                              // Increase array size
              ip = 70;
      end

         70 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[5]*10 + 0] = heapMem[localMem[5]*10 + 0] + 1;
              updateArrayLength(1, localMem[5], 0);
              ip = 71;
      end

         71 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              updateArrayLength(1, localMem[0], 0);
              ip = 72;
      end

         72 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1064;
      end

         73 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 74;
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
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[27] = heapMem[localMem[0]*10 + 3];
              updateArrayLength(2, 0, 0);
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
              localMem[29] = heapMem[localMem[27]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 79;
      end

         79 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[30] = heapMem[localMem[27]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 80;
      end

         80 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[31] = heapMem[localMem[30]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 81;
      end

         81 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[29] <  localMem[31] ? 301 : 82;
      end

         82 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[32] = localMem[31];
              updateArrayLength(2, 0, 0);
              ip = 83;
      end

         83 :
      begin                                                                     // shiftRight
//$display("AAAA %4d %4d shiftRight", steps, ip);
              localMem[32] = localMem[32] >> 1;
              ip = 84;
      end

         84 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[33] = localMem[32] + 1;
              updateArrayLength(2, 0, 0);
              ip = 85;
      end

         85 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[34] = heapMem[localMem[27]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 86;
      end

         86 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[34] == 0 ? 183 : 87;
      end

         87 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[35] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[35] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[35]] = 0;
              ip = 88;
      end

         88 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[35]*10 + 0] = localMem[32];
              updateArrayLength(1, localMem[35], 0);
              ip = 89;
      end

         89 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[35]*10 + 2] = 0;
              updateArrayLength(1, localMem[35], 2);
              ip = 90;
      end

         90 :
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
              ip = 91;
      end

         91 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[35]*10 + 4] = localMem[36];
              updateArrayLength(1, localMem[35], 4);
              ip = 92;
      end

         92 :
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
              ip = 93;
      end

         93 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[35]*10 + 5] = localMem[37];
              updateArrayLength(1, localMem[35], 5);
              ip = 94;
      end

         94 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[35]*10 + 6] = 0;
              updateArrayLength(1, localMem[35], 6);
              ip = 95;
      end

         95 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[35]*10 + 3] = localMem[30];
              updateArrayLength(1, localMem[35], 3);
              ip = 96;
      end

         96 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[30]*10 + 1] = heapMem[localMem[30]*10 + 1] + 1;
              updateArrayLength(1, localMem[30], 1);
              ip = 97;
      end

         97 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[35]*10 + 1] = heapMem[localMem[30]*10 + 1];
              updateArrayLength(1, localMem[35], 1);
              ip = 98;
      end

         98 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[38] = !heapMem[localMem[27]*10 + 6];
              ip = 99;
      end

         99 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[38] != 0 ? 128 : 100;
      end

        100 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[39] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[39] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[39]] = 0;
              ip = 101;
      end

        101 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[35]*10 + 6] = localMem[39];
              updateArrayLength(1, localMem[35], 6);
              ip = 102;
      end

        102 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[40] = heapMem[localMem[27]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 103;
      end

        103 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[41] = heapMem[localMem[35]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 104;
      end

        104 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[32]) begin
                  heapMem[NArea * localMem[41] + 0 + i] = heapMem[NArea * localMem[40] + localMem[33] + i];
                  updateArrayLength(1, localMem[41], 0 + i);
                end
              end
              ip = 105;
      end

        105 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[42] = heapMem[localMem[27]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 106;
      end

        106 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[43] = heapMem[localMem[35]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 107;
      end

        107 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[32]) begin
                  heapMem[NArea * localMem[43] + 0 + i] = heapMem[NArea * localMem[42] + localMem[33] + i];
                  updateArrayLength(1, localMem[43], 0 + i);
                end
              end
              ip = 108;
      end

        108 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[44] = heapMem[localMem[27]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 109;
      end

        109 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[45] = heapMem[localMem[35]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 110;
      end

        110 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[46] = localMem[32] + 1;
              updateArrayLength(2, 0, 0);
              ip = 111;
      end

        111 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[46]) begin
                  heapMem[NArea * localMem[45] + 0 + i] = heapMem[NArea * localMem[44] + localMem[33] + i];
                  updateArrayLength(1, localMem[45], 0 + i);
                end
              end
              ip = 112;
      end

        112 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[47] = heapMem[localMem[35]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 113;
      end

        113 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[48] = localMem[47] + 1;
              updateArrayLength(2, 0, 0);
              ip = 114;
      end

        114 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[49] = heapMem[localMem[35]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 115;
      end

        115 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 116;
      end

        116 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[50] = 0;
              updateArrayLength(2, 0, 0);
              ip = 117;
      end

        117 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 118;
      end

        118 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[50] >= localMem[48] ? 124 : 119;
      end

        119 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[51] = heapMem[localMem[49]*10 + localMem[50]];
              updateArrayLength(2, 0, 0);
              ip = 120;
      end

        120 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[51]*10 + 2] = localMem[35];
              updateArrayLength(1, localMem[51], 2);
              ip = 121;
      end

        121 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 122;
      end

        122 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[50] = localMem[50] + 1;
              updateArrayLength(2, 0, 0);
              ip = 123;
      end

        123 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 117;
      end

        124 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 125;
      end

        125 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[52] = heapMem[localMem[27]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 126;
      end

        126 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[52]] = localMem[33];
              ip = 127;
      end

        127 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 135;
      end

        128 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 129;
      end

        129 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[53] = heapMem[localMem[27]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 130;
      end

        130 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[54] = heapMem[localMem[35]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 131;
      end

        131 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[32]) begin
                  heapMem[NArea * localMem[54] + 0 + i] = heapMem[NArea * localMem[53] + localMem[33] + i];
                  updateArrayLength(1, localMem[54], 0 + i);
                end
              end
              ip = 132;
      end

        132 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[55] = heapMem[localMem[27]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 133;
      end

        133 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[56] = heapMem[localMem[35]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 134;
      end

        134 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[32]) begin
                  heapMem[NArea * localMem[56] + 0 + i] = heapMem[NArea * localMem[55] + localMem[33] + i];
                  updateArrayLength(1, localMem[56], 0 + i);
                end
              end
              ip = 135;
      end

        135 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 136;
      end

        136 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[27]*10 + 0] = localMem[32];
              updateArrayLength(1, localMem[27], 0);
              ip = 137;
      end

        137 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[35]*10 + 2] = localMem[34];
              updateArrayLength(1, localMem[35], 2);
              ip = 138;
      end

        138 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[57] = heapMem[localMem[34]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 139;
      end

        139 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[58] = heapMem[localMem[34]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 140;
      end

        140 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[59] = heapMem[localMem[58]*10 + localMem[57]];
              updateArrayLength(2, 0, 0);
              ip = 141;
      end

        141 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[59] != localMem[27] ? 160 : 142;
      end

        142 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[60] = heapMem[localMem[27]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 143;
      end

        143 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[61] = heapMem[localMem[60]*10 + localMem[32]];
              updateArrayLength(2, 0, 0);
              ip = 144;
      end

        144 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[62] = heapMem[localMem[34]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 145;
      end

        145 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[62]*10 + localMem[57]] = localMem[61];
              updateArrayLength(1, localMem[62], localMem[57]);
              ip = 146;
      end

        146 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[63] = heapMem[localMem[27]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 147;
      end

        147 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[64] = heapMem[localMem[63]*10 + localMem[32]];
              updateArrayLength(2, 0, 0);
              ip = 148;
      end

        148 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[65] = heapMem[localMem[34]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 149;
      end

        149 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[65]*10 + localMem[57]] = localMem[64];
              updateArrayLength(1, localMem[65], localMem[57]);
              ip = 150;
      end

        150 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[66] = heapMem[localMem[27]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 151;
      end

        151 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[66]] = localMem[32];
              ip = 152;
      end

        152 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[67] = heapMem[localMem[27]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 153;
      end

        153 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[67]] = localMem[32];
              ip = 154;
      end

        154 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[68] = localMem[57] + 1;
              updateArrayLength(2, 0, 0);
              ip = 155;
      end

        155 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[34]*10 + 0] = localMem[68];
              updateArrayLength(1, localMem[34], 0);
              ip = 156;
      end

        156 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[69] = heapMem[localMem[34]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 157;
      end

        157 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[69]*10 + localMem[68]] = localMem[35];
              updateArrayLength(1, localMem[69], localMem[68]);
              ip = 158;
      end

        158 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 298;
      end

        159 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 182;
      end

        160 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 161;
      end

        161 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 162;
      end

        162 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[70] = heapMem[localMem[34]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 163;
      end

        163 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[71] = 0; k = arraySizes[localMem[70]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[70] * NArea + i] == localMem[27]) localMem[71] = i + 1;
              end
              ip = 164;
      end

        164 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[71] = localMem[71] - 1;
              updateArrayLength(2, 0, 0);
              ip = 165;
      end

        165 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[72] = heapMem[localMem[27]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 166;
      end

        166 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[73] = heapMem[localMem[72]*10 + localMem[32]];
              updateArrayLength(2, 0, 0);
              ip = 167;
      end

        167 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[74] = heapMem[localMem[27]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 168;
      end

        168 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[75] = heapMem[localMem[74]*10 + localMem[32]];
              updateArrayLength(2, 0, 0);
              ip = 169;
      end

        169 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[76] = heapMem[localMem[27]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 170;
      end

        170 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[76]] = localMem[32];
              ip = 171;
      end

        171 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[77] = heapMem[localMem[27]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 172;
      end

        172 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[77]] = localMem[32];
              ip = 173;
      end

        173 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[78] = heapMem[localMem[34]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 174;
      end

        174 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[78] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[71], localMem[78], arraySizes[localMem[78]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[71] && i <= arraySizes[localMem[78]]) begin
                  heapMem[NArea * localMem[78] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[78] + localMem[71]] = localMem[73];                                    // Insert new value
              arraySizes[localMem[78]] = arraySizes[localMem[78]] + 1;                              // Increase array size
              ip = 175;
      end

        175 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[79] = heapMem[localMem[34]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 176;
      end

        176 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[79] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[71], localMem[79], arraySizes[localMem[79]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[71] && i <= arraySizes[localMem[79]]) begin
                  heapMem[NArea * localMem[79] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[79] + localMem[71]] = localMem[75];                                    // Insert new value
              arraySizes[localMem[79]] = arraySizes[localMem[79]] + 1;                              // Increase array size
              ip = 177;
      end

        177 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[80] = heapMem[localMem[34]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 178;
      end

        178 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[81] = localMem[71] + 1;
              updateArrayLength(2, 0, 0);
              ip = 179;
      end

        179 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[80] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[81], localMem[80], arraySizes[localMem[80]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[81] && i <= arraySizes[localMem[80]]) begin
                  heapMem[NArea * localMem[80] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[80] + localMem[81]] = localMem[35];                                    // Insert new value
              arraySizes[localMem[80]] = arraySizes[localMem[80]] + 1;                              // Increase array size
              ip = 180;
      end

        180 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[34]*10 + 0] = heapMem[localMem[34]*10 + 0] + 1;
              updateArrayLength(1, localMem[34], 0);
              ip = 181;
      end

        181 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 298;
      end

        182 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 183;
      end

        183 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 184;
      end

        184 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[82] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[82] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[82]] = 0;
              ip = 185;
      end

        185 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[82]*10 + 0] = localMem[32];
              updateArrayLength(1, localMem[82], 0);
              ip = 186;
      end

        186 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[82]*10 + 2] = 0;
              updateArrayLength(1, localMem[82], 2);
              ip = 187;
      end

        187 :
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
              ip = 188;
      end

        188 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[82]*10 + 4] = localMem[83];
              updateArrayLength(1, localMem[82], 4);
              ip = 189;
      end

        189 :
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
              ip = 190;
      end

        190 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[82]*10 + 5] = localMem[84];
              updateArrayLength(1, localMem[82], 5);
              ip = 191;
      end

        191 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[82]*10 + 6] = 0;
              updateArrayLength(1, localMem[82], 6);
              ip = 192;
      end

        192 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[82]*10 + 3] = localMem[30];
              updateArrayLength(1, localMem[82], 3);
              ip = 193;
      end

        193 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[30]*10 + 1] = heapMem[localMem[30]*10 + 1] + 1;
              updateArrayLength(1, localMem[30], 1);
              ip = 194;
      end

        194 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[82]*10 + 1] = heapMem[localMem[30]*10 + 1];
              updateArrayLength(1, localMem[82], 1);
              ip = 195;
      end

        195 :
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
              ip = 196;
      end

        196 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[85]*10 + 0] = localMem[32];
              updateArrayLength(1, localMem[85], 0);
              ip = 197;
      end

        197 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[85]*10 + 2] = 0;
              updateArrayLength(1, localMem[85], 2);
              ip = 198;
      end

        198 :
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
              ip = 199;
      end

        199 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[85]*10 + 4] = localMem[86];
              updateArrayLength(1, localMem[85], 4);
              ip = 200;
      end

        200 :
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
              ip = 201;
      end

        201 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[85]*10 + 5] = localMem[87];
              updateArrayLength(1, localMem[85], 5);
              ip = 202;
      end

        202 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[85]*10 + 6] = 0;
              updateArrayLength(1, localMem[85], 6);
              ip = 203;
      end

        203 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[85]*10 + 3] = localMem[30];
              updateArrayLength(1, localMem[85], 3);
              ip = 204;
      end

        204 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[30]*10 + 1] = heapMem[localMem[30]*10 + 1] + 1;
              updateArrayLength(1, localMem[30], 1);
              ip = 205;
      end

        205 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[85]*10 + 1] = heapMem[localMem[30]*10 + 1];
              updateArrayLength(1, localMem[85], 1);
              ip = 206;
      end

        206 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[88] = !heapMem[localMem[27]*10 + 6];
              ip = 207;
      end

        207 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[88] != 0 ? 259 : 208;
      end

        208 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[89] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[89] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[89]] = 0;
              ip = 209;
      end

        209 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[82]*10 + 6] = localMem[89];
              updateArrayLength(1, localMem[82], 6);
              ip = 210;
      end

        210 :
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
              ip = 211;
      end

        211 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[85]*10 + 6] = localMem[90];
              updateArrayLength(1, localMem[85], 6);
              ip = 212;
      end

        212 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[91] = heapMem[localMem[27]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 213;
      end

        213 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[92] = heapMem[localMem[82]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 214;
      end

        214 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[32]) begin
                  heapMem[NArea * localMem[92] + 0 + i] = heapMem[NArea * localMem[91] + 0 + i];
                  updateArrayLength(1, localMem[92], 0 + i);
                end
              end
              ip = 215;
      end

        215 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[93] = heapMem[localMem[27]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 216;
      end

        216 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[94] = heapMem[localMem[82]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 217;
      end

        217 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[32]) begin
                  heapMem[NArea * localMem[94] + 0 + i] = heapMem[NArea * localMem[93] + 0 + i];
                  updateArrayLength(1, localMem[94], 0 + i);
                end
              end
              ip = 218;
      end

        218 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[95] = heapMem[localMem[27]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 219;
      end

        219 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[96] = heapMem[localMem[82]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 220;
      end

        220 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[97] = localMem[32] + 1;
              updateArrayLength(2, 0, 0);
              ip = 221;
      end

        221 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[97]) begin
                  heapMem[NArea * localMem[96] + 0 + i] = heapMem[NArea * localMem[95] + 0 + i];
                  updateArrayLength(1, localMem[96], 0 + i);
                end
              end
              ip = 222;
      end

        222 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[98] = heapMem[localMem[27]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 223;
      end

        223 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[99] = heapMem[localMem[85]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 224;
      end

        224 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[32]) begin
                  heapMem[NArea * localMem[99] + 0 + i] = heapMem[NArea * localMem[98] + localMem[33] + i];
                  updateArrayLength(1, localMem[99], 0 + i);
                end
              end
              ip = 225;
      end

        225 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[100] = heapMem[localMem[27]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 226;
      end

        226 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[101] = heapMem[localMem[85]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 227;
      end

        227 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[32]) begin
                  heapMem[NArea * localMem[101] + 0 + i] = heapMem[NArea * localMem[100] + localMem[33] + i];
                  updateArrayLength(1, localMem[101], 0 + i);
                end
              end
              ip = 228;
      end

        228 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[102] = heapMem[localMem[27]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 229;
      end

        229 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[103] = heapMem[localMem[85]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 230;
      end

        230 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[104] = localMem[32] + 1;
              updateArrayLength(2, 0, 0);
              ip = 231;
      end

        231 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[104]) begin
                  heapMem[NArea * localMem[103] + 0 + i] = heapMem[NArea * localMem[102] + localMem[33] + i];
                  updateArrayLength(1, localMem[103], 0 + i);
                end
              end
              ip = 232;
      end

        232 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[105] = heapMem[localMem[82]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 233;
      end

        233 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[106] = localMem[105] + 1;
              updateArrayLength(2, 0, 0);
              ip = 234;
      end

        234 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[107] = heapMem[localMem[82]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 235;
      end

        235 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 236;
      end

        236 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[108] = 0;
              updateArrayLength(2, 0, 0);
              ip = 237;
      end

        237 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 238;
      end

        238 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[108] >= localMem[106] ? 244 : 239;
      end

        239 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[109] = heapMem[localMem[107]*10 + localMem[108]];
              updateArrayLength(2, 0, 0);
              ip = 240;
      end

        240 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[109]*10 + 2] = localMem[82];
              updateArrayLength(1, localMem[109], 2);
              ip = 241;
      end

        241 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 242;
      end

        242 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[108] = localMem[108] + 1;
              updateArrayLength(2, 0, 0);
              ip = 243;
      end

        243 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 237;
      end

        244 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 245;
      end

        245 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[110] = heapMem[localMem[85]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 246;
      end

        246 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[111] = localMem[110] + 1;
              updateArrayLength(2, 0, 0);
              ip = 247;
      end

        247 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[112] = heapMem[localMem[85]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 248;
      end

        248 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 249;
      end

        249 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[113] = 0;
              updateArrayLength(2, 0, 0);
              ip = 250;
      end

        250 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 251;
      end

        251 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[113] >= localMem[111] ? 257 : 252;
      end

        252 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[114] = heapMem[localMem[112]*10 + localMem[113]];
              updateArrayLength(2, 0, 0);
              ip = 253;
      end

        253 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[114]*10 + 2] = localMem[85];
              updateArrayLength(1, localMem[114], 2);
              ip = 254;
      end

        254 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 255;
      end

        255 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[113] = localMem[113] + 1;
              updateArrayLength(2, 0, 0);
              ip = 256;
      end

        256 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 250;
      end

        257 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 258;
      end

        258 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 274;
      end

        259 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 260;
      end

        260 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[115] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[115] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[115]] = 0;
              ip = 261;
      end

        261 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[27]*10 + 6] = localMem[115];
              updateArrayLength(1, localMem[27], 6);
              ip = 262;
      end

        262 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[116] = heapMem[localMem[27]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 263;
      end

        263 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[117] = heapMem[localMem[82]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 264;
      end

        264 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[32]) begin
                  heapMem[NArea * localMem[117] + 0 + i] = heapMem[NArea * localMem[116] + 0 + i];
                  updateArrayLength(1, localMem[117], 0 + i);
                end
              end
              ip = 265;
      end

        265 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[118] = heapMem[localMem[27]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 266;
      end

        266 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[119] = heapMem[localMem[82]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 267;
      end

        267 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[32]) begin
                  heapMem[NArea * localMem[119] + 0 + i] = heapMem[NArea * localMem[118] + 0 + i];
                  updateArrayLength(1, localMem[119], 0 + i);
                end
              end
              ip = 268;
      end

        268 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[120] = heapMem[localMem[27]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 269;
      end

        269 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[121] = heapMem[localMem[85]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 270;
      end

        270 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[32]) begin
                  heapMem[NArea * localMem[121] + 0 + i] = heapMem[NArea * localMem[120] + localMem[33] + i];
                  updateArrayLength(1, localMem[121], 0 + i);
                end
              end
              ip = 271;
      end

        271 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[122] = heapMem[localMem[27]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 272;
      end

        272 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[123] = heapMem[localMem[85]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 273;
      end

        273 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[32]) begin
                  heapMem[NArea * localMem[123] + 0 + i] = heapMem[NArea * localMem[122] + localMem[33] + i];
                  updateArrayLength(1, localMem[123], 0 + i);
                end
              end
              ip = 274;
      end

        274 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 275;
      end

        275 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[82]*10 + 2] = localMem[27];
              updateArrayLength(1, localMem[82], 2);
              ip = 276;
      end

        276 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[85]*10 + 2] = localMem[27];
              updateArrayLength(1, localMem[85], 2);
              ip = 277;
      end

        277 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[124] = heapMem[localMem[27]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 278;
      end

        278 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[125] = heapMem[localMem[124]*10 + localMem[32]];
              updateArrayLength(2, 0, 0);
              ip = 279;
      end

        279 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[126] = heapMem[localMem[27]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 280;
      end

        280 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[127] = heapMem[localMem[126]*10 + localMem[32]];
              updateArrayLength(2, 0, 0);
              ip = 281;
      end

        281 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[128] = heapMem[localMem[27]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 282;
      end

        282 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[128]*10 + 0] = localMem[125];
              updateArrayLength(1, localMem[128], 0);
              ip = 283;
      end

        283 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[129] = heapMem[localMem[27]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 284;
      end

        284 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[129]*10 + 0] = localMem[127];
              updateArrayLength(1, localMem[129], 0);
              ip = 285;
      end

        285 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[130] = heapMem[localMem[27]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 286;
      end

        286 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[130]*10 + 0] = localMem[82];
              updateArrayLength(1, localMem[130], 0);
              ip = 287;
      end

        287 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[131] = heapMem[localMem[27]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 288;
      end

        288 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[131]*10 + 1] = localMem[85];
              updateArrayLength(1, localMem[131], 1);
              ip = 289;
      end

        289 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[27]*10 + 0] = 1;
              updateArrayLength(1, localMem[27], 0);
              ip = 290;
      end

        290 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[132] = heapMem[localMem[27]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 291;
      end

        291 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[132]] = 1;
              ip = 292;
      end

        292 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[133] = heapMem[localMem[27]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 293;
      end

        293 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[133]] = 1;
              ip = 294;
      end

        294 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[134] = heapMem[localMem[27]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 295;
      end

        295 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[134]] = 2;
              ip = 296;
      end

        296 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 298;
      end

        297 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 303;
      end

        298 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 299;
      end

        299 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[28] = 1;
              updateArrayLength(2, 0, 0);
              ip = 300;
      end

        300 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 303;
      end

        301 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 302;
      end

        302 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[28] = 0;
              updateArrayLength(2, 0, 0);
              ip = 303;
      end

        303 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
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
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[135] = 0;
              updateArrayLength(2, 0, 0);
              ip = 307;
      end

        307 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 308;
      end

        308 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[135] >= 99 ? 806 : 309;
      end

        309 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[136] = heapMem[localMem[27]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 310;
      end

        310 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[137] = localMem[136] - 1;
              updateArrayLength(2, 0, 0);
              ip = 311;
      end

        311 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[138] = heapMem[localMem[27]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 312;
      end

        312 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[139] = heapMem[localMem[138]*10 + localMem[137]];
              updateArrayLength(2, 0, 0);
              ip = 313;
      end

        313 :
      begin                                                                     // jLe
//$display("AAAA %4d %4d jLe", steps, ip);
              ip = localMem[2] <= localMem[139] ? 554 : 314;
      end

        314 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[140] = !heapMem[localMem[27]*10 + 6];
              ip = 315;
      end

        315 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[140] == 0 ? 320 : 316;
      end

        316 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[4]*10 + 0] = localMem[27];
              updateArrayLength(1, localMem[4], 0);
              ip = 317;
      end

        317 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[4]*10 + 1] = 2;
              updateArrayLength(1, localMem[4], 1);
              ip = 318;
      end

        318 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              heapMem[localMem[4]*10 + 2] = localMem[136] - 1;
              updateArrayLength(1, localMem[4], 2);
              ip = 319;
      end

        319 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 810;
      end

        320 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 321;
      end

        321 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[141] = heapMem[localMem[27]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 322;
      end

        322 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[142] = heapMem[localMem[141]*10 + localMem[136]];
              updateArrayLength(2, 0, 0);
              ip = 323;
      end

        323 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 324;
      end

        324 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[144] = heapMem[localMem[142]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 325;
      end

        325 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[145] = heapMem[localMem[142]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 326;
      end

        326 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[146] = heapMem[localMem[145]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 327;
      end

        327 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[144] <  localMem[146] ? 547 : 328;
      end

        328 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[147] = localMem[146];
              updateArrayLength(2, 0, 0);
              ip = 329;
      end

        329 :
      begin                                                                     // shiftRight
//$display("AAAA %4d %4d shiftRight", steps, ip);
              localMem[147] = localMem[147] >> 1;
              ip = 330;
      end

        330 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[148] = localMem[147] + 1;
              updateArrayLength(2, 0, 0);
              ip = 331;
      end

        331 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[149] = heapMem[localMem[142]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 332;
      end

        332 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[149] == 0 ? 429 : 333;
      end

        333 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[150] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[150] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[150]] = 0;
              ip = 334;
      end

        334 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[150]*10 + 0] = localMem[147];
              updateArrayLength(1, localMem[150], 0);
              ip = 335;
      end

        335 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[150]*10 + 2] = 0;
              updateArrayLength(1, localMem[150], 2);
              ip = 336;
      end

        336 :
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
              ip = 337;
      end

        337 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[150]*10 + 4] = localMem[151];
              updateArrayLength(1, localMem[150], 4);
              ip = 338;
      end

        338 :
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
              ip = 339;
      end

        339 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[150]*10 + 5] = localMem[152];
              updateArrayLength(1, localMem[150], 5);
              ip = 340;
      end

        340 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[150]*10 + 6] = 0;
              updateArrayLength(1, localMem[150], 6);
              ip = 341;
      end

        341 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[150]*10 + 3] = localMem[145];
              updateArrayLength(1, localMem[150], 3);
              ip = 342;
      end

        342 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[145]*10 + 1] = heapMem[localMem[145]*10 + 1] + 1;
              updateArrayLength(1, localMem[145], 1);
              ip = 343;
      end

        343 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[150]*10 + 1] = heapMem[localMem[145]*10 + 1];
              updateArrayLength(1, localMem[150], 1);
              ip = 344;
      end

        344 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[153] = !heapMem[localMem[142]*10 + 6];
              ip = 345;
      end

        345 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[153] != 0 ? 374 : 346;
      end

        346 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[154] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[154] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[154]] = 0;
              ip = 347;
      end

        347 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[150]*10 + 6] = localMem[154];
              updateArrayLength(1, localMem[150], 6);
              ip = 348;
      end

        348 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[155] = heapMem[localMem[142]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 349;
      end

        349 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[156] = heapMem[localMem[150]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 350;
      end

        350 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[147]) begin
                  heapMem[NArea * localMem[156] + 0 + i] = heapMem[NArea * localMem[155] + localMem[148] + i];
                  updateArrayLength(1, localMem[156], 0 + i);
                end
              end
              ip = 351;
      end

        351 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[157] = heapMem[localMem[142]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 352;
      end

        352 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[158] = heapMem[localMem[150]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 353;
      end

        353 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[147]) begin
                  heapMem[NArea * localMem[158] + 0 + i] = heapMem[NArea * localMem[157] + localMem[148] + i];
                  updateArrayLength(1, localMem[158], 0 + i);
                end
              end
              ip = 354;
      end

        354 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[159] = heapMem[localMem[142]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 355;
      end

        355 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[160] = heapMem[localMem[150]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 356;
      end

        356 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[161] = localMem[147] + 1;
              updateArrayLength(2, 0, 0);
              ip = 357;
      end

        357 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[161]) begin
                  heapMem[NArea * localMem[160] + 0 + i] = heapMem[NArea * localMem[159] + localMem[148] + i];
                  updateArrayLength(1, localMem[160], 0 + i);
                end
              end
              ip = 358;
      end

        358 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[162] = heapMem[localMem[150]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 359;
      end

        359 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[163] = localMem[162] + 1;
              updateArrayLength(2, 0, 0);
              ip = 360;
      end

        360 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[164] = heapMem[localMem[150]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 361;
      end

        361 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 362;
      end

        362 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[165] = 0;
              updateArrayLength(2, 0, 0);
              ip = 363;
      end

        363 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 364;
      end

        364 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[165] >= localMem[163] ? 370 : 365;
      end

        365 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[166] = heapMem[localMem[164]*10 + localMem[165]];
              updateArrayLength(2, 0, 0);
              ip = 366;
      end

        366 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[166]*10 + 2] = localMem[150];
              updateArrayLength(1, localMem[166], 2);
              ip = 367;
      end

        367 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 368;
      end

        368 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[165] = localMem[165] + 1;
              updateArrayLength(2, 0, 0);
              ip = 369;
      end

        369 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 363;
      end

        370 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 371;
      end

        371 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[167] = heapMem[localMem[142]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 372;
      end

        372 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[167]] = localMem[148];
              ip = 373;
      end

        373 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 381;
      end

        374 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 375;
      end

        375 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[168] = heapMem[localMem[142]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 376;
      end

        376 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[169] = heapMem[localMem[150]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 377;
      end

        377 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[147]) begin
                  heapMem[NArea * localMem[169] + 0 + i] = heapMem[NArea * localMem[168] + localMem[148] + i];
                  updateArrayLength(1, localMem[169], 0 + i);
                end
              end
              ip = 378;
      end

        378 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[170] = heapMem[localMem[142]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 379;
      end

        379 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[171] = heapMem[localMem[150]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 380;
      end

        380 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[147]) begin
                  heapMem[NArea * localMem[171] + 0 + i] = heapMem[NArea * localMem[170] + localMem[148] + i];
                  updateArrayLength(1, localMem[171], 0 + i);
                end
              end
              ip = 381;
      end

        381 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 382;
      end

        382 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[142]*10 + 0] = localMem[147];
              updateArrayLength(1, localMem[142], 0);
              ip = 383;
      end

        383 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[150]*10 + 2] = localMem[149];
              updateArrayLength(1, localMem[150], 2);
              ip = 384;
      end

        384 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[172] = heapMem[localMem[149]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 385;
      end

        385 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[173] = heapMem[localMem[149]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 386;
      end

        386 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[174] = heapMem[localMem[173]*10 + localMem[172]];
              updateArrayLength(2, 0, 0);
              ip = 387;
      end

        387 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[174] != localMem[142] ? 406 : 388;
      end

        388 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[175] = heapMem[localMem[142]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 389;
      end

        389 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[176] = heapMem[localMem[175]*10 + localMem[147]];
              updateArrayLength(2, 0, 0);
              ip = 390;
      end

        390 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[177] = heapMem[localMem[149]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 391;
      end

        391 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[177]*10 + localMem[172]] = localMem[176];
              updateArrayLength(1, localMem[177], localMem[172]);
              ip = 392;
      end

        392 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[178] = heapMem[localMem[142]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 393;
      end

        393 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[179] = heapMem[localMem[178]*10 + localMem[147]];
              updateArrayLength(2, 0, 0);
              ip = 394;
      end

        394 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[180] = heapMem[localMem[149]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 395;
      end

        395 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[180]*10 + localMem[172]] = localMem[179];
              updateArrayLength(1, localMem[180], localMem[172]);
              ip = 396;
      end

        396 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[181] = heapMem[localMem[142]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 397;
      end

        397 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[181]] = localMem[147];
              ip = 398;
      end

        398 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[182] = heapMem[localMem[142]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 399;
      end

        399 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[182]] = localMem[147];
              ip = 400;
      end

        400 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[183] = localMem[172] + 1;
              updateArrayLength(2, 0, 0);
              ip = 401;
      end

        401 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[149]*10 + 0] = localMem[183];
              updateArrayLength(1, localMem[149], 0);
              ip = 402;
      end

        402 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[184] = heapMem[localMem[149]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 403;
      end

        403 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[184]*10 + localMem[183]] = localMem[150];
              updateArrayLength(1, localMem[184], localMem[183]);
              ip = 404;
      end

        404 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 544;
      end

        405 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 428;
      end

        406 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 407;
      end

        407 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 408;
      end

        408 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[185] = heapMem[localMem[149]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 409;
      end

        409 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[186] = 0; k = arraySizes[localMem[185]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[185] * NArea + i] == localMem[142]) localMem[186] = i + 1;
              end
              ip = 410;
      end

        410 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[186] = localMem[186] - 1;
              updateArrayLength(2, 0, 0);
              ip = 411;
      end

        411 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[187] = heapMem[localMem[142]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 412;
      end

        412 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[188] = heapMem[localMem[187]*10 + localMem[147]];
              updateArrayLength(2, 0, 0);
              ip = 413;
      end

        413 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[189] = heapMem[localMem[142]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 414;
      end

        414 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[190] = heapMem[localMem[189]*10 + localMem[147]];
              updateArrayLength(2, 0, 0);
              ip = 415;
      end

        415 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[191] = heapMem[localMem[142]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 416;
      end

        416 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[191]] = localMem[147];
              ip = 417;
      end

        417 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[192] = heapMem[localMem[142]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 418;
      end

        418 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[192]] = localMem[147];
              ip = 419;
      end

        419 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[193] = heapMem[localMem[149]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 420;
      end

        420 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[193] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[186], localMem[193], arraySizes[localMem[193]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[186] && i <= arraySizes[localMem[193]]) begin
                  heapMem[NArea * localMem[193] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[193] + localMem[186]] = localMem[188];                                    // Insert new value
              arraySizes[localMem[193]] = arraySizes[localMem[193]] + 1;                              // Increase array size
              ip = 421;
      end

        421 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[194] = heapMem[localMem[149]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 422;
      end

        422 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[194] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[186], localMem[194], arraySizes[localMem[194]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[186] && i <= arraySizes[localMem[194]]) begin
                  heapMem[NArea * localMem[194] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[194] + localMem[186]] = localMem[190];                                    // Insert new value
              arraySizes[localMem[194]] = arraySizes[localMem[194]] + 1;                              // Increase array size
              ip = 423;
      end

        423 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[195] = heapMem[localMem[149]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 424;
      end

        424 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[196] = localMem[186] + 1;
              updateArrayLength(2, 0, 0);
              ip = 425;
      end

        425 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[195] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[196], localMem[195], arraySizes[localMem[195]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[196] && i <= arraySizes[localMem[195]]) begin
                  heapMem[NArea * localMem[195] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[195] + localMem[196]] = localMem[150];                                    // Insert new value
              arraySizes[localMem[195]] = arraySizes[localMem[195]] + 1;                              // Increase array size
              ip = 426;
      end

        426 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[149]*10 + 0] = heapMem[localMem[149]*10 + 0] + 1;
              updateArrayLength(1, localMem[149], 0);
              ip = 427;
      end

        427 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 544;
      end

        428 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 429;
      end

        429 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 430;
      end

        430 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[197] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[197] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[197]] = 0;
              ip = 431;
      end

        431 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[197]*10 + 0] = localMem[147];
              updateArrayLength(1, localMem[197], 0);
              ip = 432;
      end

        432 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[197]*10 + 2] = 0;
              updateArrayLength(1, localMem[197], 2);
              ip = 433;
      end

        433 :
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
              ip = 434;
      end

        434 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[197]*10 + 4] = localMem[198];
              updateArrayLength(1, localMem[197], 4);
              ip = 435;
      end

        435 :
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
              ip = 436;
      end

        436 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[197]*10 + 5] = localMem[199];
              updateArrayLength(1, localMem[197], 5);
              ip = 437;
      end

        437 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[197]*10 + 6] = 0;
              updateArrayLength(1, localMem[197], 6);
              ip = 438;
      end

        438 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[197]*10 + 3] = localMem[145];
              updateArrayLength(1, localMem[197], 3);
              ip = 439;
      end

        439 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[145]*10 + 1] = heapMem[localMem[145]*10 + 1] + 1;
              updateArrayLength(1, localMem[145], 1);
              ip = 440;
      end

        440 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[197]*10 + 1] = heapMem[localMem[145]*10 + 1];
              updateArrayLength(1, localMem[197], 1);
              ip = 441;
      end

        441 :
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
              ip = 442;
      end

        442 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[200]*10 + 0] = localMem[147];
              updateArrayLength(1, localMem[200], 0);
              ip = 443;
      end

        443 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[200]*10 + 2] = 0;
              updateArrayLength(1, localMem[200], 2);
              ip = 444;
      end

        444 :
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
              ip = 445;
      end

        445 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[200]*10 + 4] = localMem[201];
              updateArrayLength(1, localMem[200], 4);
              ip = 446;
      end

        446 :
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
              ip = 447;
      end

        447 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[200]*10 + 5] = localMem[202];
              updateArrayLength(1, localMem[200], 5);
              ip = 448;
      end

        448 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[200]*10 + 6] = 0;
              updateArrayLength(1, localMem[200], 6);
              ip = 449;
      end

        449 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[200]*10 + 3] = localMem[145];
              updateArrayLength(1, localMem[200], 3);
              ip = 450;
      end

        450 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[145]*10 + 1] = heapMem[localMem[145]*10 + 1] + 1;
              updateArrayLength(1, localMem[145], 1);
              ip = 451;
      end

        451 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[200]*10 + 1] = heapMem[localMem[145]*10 + 1];
              updateArrayLength(1, localMem[200], 1);
              ip = 452;
      end

        452 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[203] = !heapMem[localMem[142]*10 + 6];
              ip = 453;
      end

        453 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[203] != 0 ? 505 : 454;
      end

        454 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[204] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[204] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[204]] = 0;
              ip = 455;
      end

        455 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[197]*10 + 6] = localMem[204];
              updateArrayLength(1, localMem[197], 6);
              ip = 456;
      end

        456 :
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
              ip = 457;
      end

        457 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[200]*10 + 6] = localMem[205];
              updateArrayLength(1, localMem[200], 6);
              ip = 458;
      end

        458 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[206] = heapMem[localMem[142]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 459;
      end

        459 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[207] = heapMem[localMem[197]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 460;
      end

        460 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[147]) begin
                  heapMem[NArea * localMem[207] + 0 + i] = heapMem[NArea * localMem[206] + 0 + i];
                  updateArrayLength(1, localMem[207], 0 + i);
                end
              end
              ip = 461;
      end

        461 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[208] = heapMem[localMem[142]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 462;
      end

        462 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[209] = heapMem[localMem[197]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 463;
      end

        463 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[147]) begin
                  heapMem[NArea * localMem[209] + 0 + i] = heapMem[NArea * localMem[208] + 0 + i];
                  updateArrayLength(1, localMem[209], 0 + i);
                end
              end
              ip = 464;
      end

        464 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[210] = heapMem[localMem[142]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 465;
      end

        465 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[211] = heapMem[localMem[197]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 466;
      end

        466 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[212] = localMem[147] + 1;
              updateArrayLength(2, 0, 0);
              ip = 467;
      end

        467 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[212]) begin
                  heapMem[NArea * localMem[211] + 0 + i] = heapMem[NArea * localMem[210] + 0 + i];
                  updateArrayLength(1, localMem[211], 0 + i);
                end
              end
              ip = 468;
      end

        468 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[213] = heapMem[localMem[142]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 469;
      end

        469 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[214] = heapMem[localMem[200]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 470;
      end

        470 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[147]) begin
                  heapMem[NArea * localMem[214] + 0 + i] = heapMem[NArea * localMem[213] + localMem[148] + i];
                  updateArrayLength(1, localMem[214], 0 + i);
                end
              end
              ip = 471;
      end

        471 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[215] = heapMem[localMem[142]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 472;
      end

        472 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[216] = heapMem[localMem[200]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 473;
      end

        473 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[147]) begin
                  heapMem[NArea * localMem[216] + 0 + i] = heapMem[NArea * localMem[215] + localMem[148] + i];
                  updateArrayLength(1, localMem[216], 0 + i);
                end
              end
              ip = 474;
      end

        474 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[217] = heapMem[localMem[142]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 475;
      end

        475 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[218] = heapMem[localMem[200]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 476;
      end

        476 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[219] = localMem[147] + 1;
              updateArrayLength(2, 0, 0);
              ip = 477;
      end

        477 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[219]) begin
                  heapMem[NArea * localMem[218] + 0 + i] = heapMem[NArea * localMem[217] + localMem[148] + i];
                  updateArrayLength(1, localMem[218], 0 + i);
                end
              end
              ip = 478;
      end

        478 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[220] = heapMem[localMem[197]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 479;
      end

        479 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[221] = localMem[220] + 1;
              updateArrayLength(2, 0, 0);
              ip = 480;
      end

        480 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[222] = heapMem[localMem[197]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 481;
      end

        481 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 482;
      end

        482 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[223] = 0;
              updateArrayLength(2, 0, 0);
              ip = 483;
      end

        483 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 484;
      end

        484 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[223] >= localMem[221] ? 490 : 485;
      end

        485 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[224] = heapMem[localMem[222]*10 + localMem[223]];
              updateArrayLength(2, 0, 0);
              ip = 486;
      end

        486 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[224]*10 + 2] = localMem[197];
              updateArrayLength(1, localMem[224], 2);
              ip = 487;
      end

        487 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 488;
      end

        488 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[223] = localMem[223] + 1;
              updateArrayLength(2, 0, 0);
              ip = 489;
      end

        489 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 483;
      end

        490 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 491;
      end

        491 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[225] = heapMem[localMem[200]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 492;
      end

        492 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[226] = localMem[225] + 1;
              updateArrayLength(2, 0, 0);
              ip = 493;
      end

        493 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[227] = heapMem[localMem[200]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 494;
      end

        494 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 495;
      end

        495 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[228] = 0;
              updateArrayLength(2, 0, 0);
              ip = 496;
      end

        496 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 497;
      end

        497 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[228] >= localMem[226] ? 503 : 498;
      end

        498 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[229] = heapMem[localMem[227]*10 + localMem[228]];
              updateArrayLength(2, 0, 0);
              ip = 499;
      end

        499 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[229]*10 + 2] = localMem[200];
              updateArrayLength(1, localMem[229], 2);
              ip = 500;
      end

        500 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 501;
      end

        501 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[228] = localMem[228] + 1;
              updateArrayLength(2, 0, 0);
              ip = 502;
      end

        502 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 496;
      end

        503 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 504;
      end

        504 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 520;
      end

        505 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 506;
      end

        506 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[230] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[230] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[230]] = 0;
              ip = 507;
      end

        507 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[142]*10 + 6] = localMem[230];
              updateArrayLength(1, localMem[142], 6);
              ip = 508;
      end

        508 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[231] = heapMem[localMem[142]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 509;
      end

        509 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[232] = heapMem[localMem[197]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 510;
      end

        510 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[147]) begin
                  heapMem[NArea * localMem[232] + 0 + i] = heapMem[NArea * localMem[231] + 0 + i];
                  updateArrayLength(1, localMem[232], 0 + i);
                end
              end
              ip = 511;
      end

        511 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[233] = heapMem[localMem[142]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 512;
      end

        512 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[234] = heapMem[localMem[197]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 513;
      end

        513 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[147]) begin
                  heapMem[NArea * localMem[234] + 0 + i] = heapMem[NArea * localMem[233] + 0 + i];
                  updateArrayLength(1, localMem[234], 0 + i);
                end
              end
              ip = 514;
      end

        514 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[235] = heapMem[localMem[142]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 515;
      end

        515 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[236] = heapMem[localMem[200]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 516;
      end

        516 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[147]) begin
                  heapMem[NArea * localMem[236] + 0 + i] = heapMem[NArea * localMem[235] + localMem[148] + i];
                  updateArrayLength(1, localMem[236], 0 + i);
                end
              end
              ip = 517;
      end

        517 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[237] = heapMem[localMem[142]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 518;
      end

        518 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[238] = heapMem[localMem[200]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 519;
      end

        519 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[147]) begin
                  heapMem[NArea * localMem[238] + 0 + i] = heapMem[NArea * localMem[237] + localMem[148] + i];
                  updateArrayLength(1, localMem[238], 0 + i);
                end
              end
              ip = 520;
      end

        520 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 521;
      end

        521 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[197]*10 + 2] = localMem[142];
              updateArrayLength(1, localMem[197], 2);
              ip = 522;
      end

        522 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[200]*10 + 2] = localMem[142];
              updateArrayLength(1, localMem[200], 2);
              ip = 523;
      end

        523 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[239] = heapMem[localMem[142]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 524;
      end

        524 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[240] = heapMem[localMem[239]*10 + localMem[147]];
              updateArrayLength(2, 0, 0);
              ip = 525;
      end

        525 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[241] = heapMem[localMem[142]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 526;
      end

        526 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[242] = heapMem[localMem[241]*10 + localMem[147]];
              updateArrayLength(2, 0, 0);
              ip = 527;
      end

        527 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[243] = heapMem[localMem[142]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 528;
      end

        528 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[243]*10 + 0] = localMem[240];
              updateArrayLength(1, localMem[243], 0);
              ip = 529;
      end

        529 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[244] = heapMem[localMem[142]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 530;
      end

        530 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[244]*10 + 0] = localMem[242];
              updateArrayLength(1, localMem[244], 0);
              ip = 531;
      end

        531 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[245] = heapMem[localMem[142]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 532;
      end

        532 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[245]*10 + 0] = localMem[197];
              updateArrayLength(1, localMem[245], 0);
              ip = 533;
      end

        533 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[246] = heapMem[localMem[142]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 534;
      end

        534 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[246]*10 + 1] = localMem[200];
              updateArrayLength(1, localMem[246], 1);
              ip = 535;
      end

        535 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[142]*10 + 0] = 1;
              updateArrayLength(1, localMem[142], 0);
              ip = 536;
      end

        536 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[247] = heapMem[localMem[142]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 537;
      end

        537 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[247]] = 1;
              ip = 538;
      end

        538 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[248] = heapMem[localMem[142]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 539;
      end

        539 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[248]] = 1;
              ip = 540;
      end

        540 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[249] = heapMem[localMem[142]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 541;
      end

        541 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[249]] = 2;
              ip = 542;
      end

        542 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 544;
      end

        543 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 549;
      end

        544 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 545;
      end

        545 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[143] = 1;
              updateArrayLength(2, 0, 0);
              ip = 546;
      end

        546 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 549;
      end

        547 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 548;
      end

        548 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[143] = 0;
              updateArrayLength(2, 0, 0);
              ip = 549;
      end

        549 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 550;
      end

        550 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[143] != 0 ? 552 : 551;
      end

        551 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[27] = localMem[142];
              updateArrayLength(2, 0, 0);
              ip = 552;
      end

        552 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 553;
      end

        553 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 803;
      end

        554 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 555;
      end

        555 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[250] = heapMem[localMem[27]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 556;
      end

        556 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[251] = 0; k = arraySizes[localMem[250]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[250] * NArea + i] == localMem[2]) localMem[251] = i + 1;
              end
              ip = 557;
      end

        557 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[251] == 0 ? 562 : 558;
      end

        558 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[4]*10 + 0] = localMem[27];
              updateArrayLength(1, localMem[4], 0);
              ip = 559;
      end

        559 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[4]*10 + 1] = 1;
              updateArrayLength(1, localMem[4], 1);
              ip = 560;
      end

        560 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              heapMem[localMem[4]*10 + 2] = localMem[251] - 1;
              updateArrayLength(1, localMem[4], 2);
              ip = 561;
      end

        561 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 810;
      end

        562 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 563;
      end

        563 :
      begin                                                                     // arrayCountLess
//$display("AAAA %4d %4d arrayCountLess", steps, ip);
              j = 0; k = arraySizes[localMem[250]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[250] * NArea + i] < localMem[2]) j = j + 1;
              end
              localMem[252] = j;
              ip = 564;
      end

        564 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[253] = !heapMem[localMem[27]*10 + 6];
              ip = 565;
      end

        565 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[253] == 0 ? 570 : 566;
      end

        566 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[4]*10 + 0] = localMem[27];
              updateArrayLength(1, localMem[4], 0);
              ip = 567;
      end

        567 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[4]*10 + 1] = 0;
              updateArrayLength(1, localMem[4], 1);
              ip = 568;
      end

        568 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[4]*10 + 2] = localMem[252];
              updateArrayLength(1, localMem[4], 2);
              ip = 569;
      end

        569 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 810;
      end

        570 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 571;
      end

        571 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[254] = heapMem[localMem[27]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 572;
      end

        572 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[255] = heapMem[localMem[254]*10 + localMem[252]];
              updateArrayLength(2, 0, 0);
              ip = 573;
      end

        573 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 574;
      end

        574 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[257] = heapMem[localMem[255]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 575;
      end

        575 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[258] = heapMem[localMem[255]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 576;
      end

        576 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[259] = heapMem[localMem[258]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 577;
      end

        577 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[257] <  localMem[259] ? 797 : 578;
      end

        578 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[260] = localMem[259];
              updateArrayLength(2, 0, 0);
              ip = 579;
      end

        579 :
      begin                                                                     // shiftRight
//$display("AAAA %4d %4d shiftRight", steps, ip);
              localMem[260] = localMem[260] >> 1;
              ip = 580;
      end

        580 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[261] = localMem[260] + 1;
              updateArrayLength(2, 0, 0);
              ip = 581;
      end

        581 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[262] = heapMem[localMem[255]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 582;
      end

        582 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[262] == 0 ? 679 : 583;
      end

        583 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[263] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[263] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[263]] = 0;
              ip = 584;
      end

        584 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[263]*10 + 0] = localMem[260];
              updateArrayLength(1, localMem[263], 0);
              ip = 585;
      end

        585 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[263]*10 + 2] = 0;
              updateArrayLength(1, localMem[263], 2);
              ip = 586;
      end

        586 :
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
              ip = 587;
      end

        587 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[263]*10 + 4] = localMem[264];
              updateArrayLength(1, localMem[263], 4);
              ip = 588;
      end

        588 :
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
              ip = 589;
      end

        589 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[263]*10 + 5] = localMem[265];
              updateArrayLength(1, localMem[263], 5);
              ip = 590;
      end

        590 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[263]*10 + 6] = 0;
              updateArrayLength(1, localMem[263], 6);
              ip = 591;
      end

        591 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[263]*10 + 3] = localMem[258];
              updateArrayLength(1, localMem[263], 3);
              ip = 592;
      end

        592 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[258]*10 + 1] = heapMem[localMem[258]*10 + 1] + 1;
              updateArrayLength(1, localMem[258], 1);
              ip = 593;
      end

        593 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[263]*10 + 1] = heapMem[localMem[258]*10 + 1];
              updateArrayLength(1, localMem[263], 1);
              ip = 594;
      end

        594 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[266] = !heapMem[localMem[255]*10 + 6];
              ip = 595;
      end

        595 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[266] != 0 ? 624 : 596;
      end

        596 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[267] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[267] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[267]] = 0;
              ip = 597;
      end

        597 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[263]*10 + 6] = localMem[267];
              updateArrayLength(1, localMem[263], 6);
              ip = 598;
      end

        598 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[268] = heapMem[localMem[255]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 599;
      end

        599 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[269] = heapMem[localMem[263]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 600;
      end

        600 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[260]) begin
                  heapMem[NArea * localMem[269] + 0 + i] = heapMem[NArea * localMem[268] + localMem[261] + i];
                  updateArrayLength(1, localMem[269], 0 + i);
                end
              end
              ip = 601;
      end

        601 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[270] = heapMem[localMem[255]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 602;
      end

        602 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[271] = heapMem[localMem[263]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 603;
      end

        603 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[260]) begin
                  heapMem[NArea * localMem[271] + 0 + i] = heapMem[NArea * localMem[270] + localMem[261] + i];
                  updateArrayLength(1, localMem[271], 0 + i);
                end
              end
              ip = 604;
      end

        604 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[272] = heapMem[localMem[255]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 605;
      end

        605 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[273] = heapMem[localMem[263]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 606;
      end

        606 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[274] = localMem[260] + 1;
              updateArrayLength(2, 0, 0);
              ip = 607;
      end

        607 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[274]) begin
                  heapMem[NArea * localMem[273] + 0 + i] = heapMem[NArea * localMem[272] + localMem[261] + i];
                  updateArrayLength(1, localMem[273], 0 + i);
                end
              end
              ip = 608;
      end

        608 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[275] = heapMem[localMem[263]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 609;
      end

        609 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[276] = localMem[275] + 1;
              updateArrayLength(2, 0, 0);
              ip = 610;
      end

        610 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[277] = heapMem[localMem[263]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 611;
      end

        611 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 612;
      end

        612 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[278] = 0;
              updateArrayLength(2, 0, 0);
              ip = 613;
      end

        613 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 614;
      end

        614 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[278] >= localMem[276] ? 620 : 615;
      end

        615 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[279] = heapMem[localMem[277]*10 + localMem[278]];
              updateArrayLength(2, 0, 0);
              ip = 616;
      end

        616 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[279]*10 + 2] = localMem[263];
              updateArrayLength(1, localMem[279], 2);
              ip = 617;
      end

        617 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 618;
      end

        618 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[278] = localMem[278] + 1;
              updateArrayLength(2, 0, 0);
              ip = 619;
      end

        619 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 613;
      end

        620 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 621;
      end

        621 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[280] = heapMem[localMem[255]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 622;
      end

        622 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[280]] = localMem[261];
              ip = 623;
      end

        623 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 631;
      end

        624 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 625;
      end

        625 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[281] = heapMem[localMem[255]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 626;
      end

        626 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[282] = heapMem[localMem[263]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 627;
      end

        627 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[260]) begin
                  heapMem[NArea * localMem[282] + 0 + i] = heapMem[NArea * localMem[281] + localMem[261] + i];
                  updateArrayLength(1, localMem[282], 0 + i);
                end
              end
              ip = 628;
      end

        628 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[283] = heapMem[localMem[255]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 629;
      end

        629 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[284] = heapMem[localMem[263]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 630;
      end

        630 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[260]) begin
                  heapMem[NArea * localMem[284] + 0 + i] = heapMem[NArea * localMem[283] + localMem[261] + i];
                  updateArrayLength(1, localMem[284], 0 + i);
                end
              end
              ip = 631;
      end

        631 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 632;
      end

        632 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[255]*10 + 0] = localMem[260];
              updateArrayLength(1, localMem[255], 0);
              ip = 633;
      end

        633 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[263]*10 + 2] = localMem[262];
              updateArrayLength(1, localMem[263], 2);
              ip = 634;
      end

        634 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[285] = heapMem[localMem[262]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 635;
      end

        635 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[286] = heapMem[localMem[262]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 636;
      end

        636 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[287] = heapMem[localMem[286]*10 + localMem[285]];
              updateArrayLength(2, 0, 0);
              ip = 637;
      end

        637 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[287] != localMem[255] ? 656 : 638;
      end

        638 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[288] = heapMem[localMem[255]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 639;
      end

        639 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[289] = heapMem[localMem[288]*10 + localMem[260]];
              updateArrayLength(2, 0, 0);
              ip = 640;
      end

        640 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[290] = heapMem[localMem[262]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 641;
      end

        641 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[290]*10 + localMem[285]] = localMem[289];
              updateArrayLength(1, localMem[290], localMem[285]);
              ip = 642;
      end

        642 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[291] = heapMem[localMem[255]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 643;
      end

        643 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[292] = heapMem[localMem[291]*10 + localMem[260]];
              updateArrayLength(2, 0, 0);
              ip = 644;
      end

        644 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[293] = heapMem[localMem[262]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 645;
      end

        645 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[293]*10 + localMem[285]] = localMem[292];
              updateArrayLength(1, localMem[293], localMem[285]);
              ip = 646;
      end

        646 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[294] = heapMem[localMem[255]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 647;
      end

        647 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[294]] = localMem[260];
              ip = 648;
      end

        648 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[295] = heapMem[localMem[255]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 649;
      end

        649 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[295]] = localMem[260];
              ip = 650;
      end

        650 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[296] = localMem[285] + 1;
              updateArrayLength(2, 0, 0);
              ip = 651;
      end

        651 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[262]*10 + 0] = localMem[296];
              updateArrayLength(1, localMem[262], 0);
              ip = 652;
      end

        652 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[297] = heapMem[localMem[262]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 653;
      end

        653 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[297]*10 + localMem[296]] = localMem[263];
              updateArrayLength(1, localMem[297], localMem[296]);
              ip = 654;
      end

        654 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 794;
      end

        655 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 678;
      end

        656 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 657;
      end

        657 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 658;
      end

        658 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[298] = heapMem[localMem[262]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 659;
      end

        659 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[299] = 0; k = arraySizes[localMem[298]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[298] * NArea + i] == localMem[255]) localMem[299] = i + 1;
              end
              ip = 660;
      end

        660 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[299] = localMem[299] - 1;
              updateArrayLength(2, 0, 0);
              ip = 661;
      end

        661 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[300] = heapMem[localMem[255]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 662;
      end

        662 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[301] = heapMem[localMem[300]*10 + localMem[260]];
              updateArrayLength(2, 0, 0);
              ip = 663;
      end

        663 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[302] = heapMem[localMem[255]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 664;
      end

        664 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[303] = heapMem[localMem[302]*10 + localMem[260]];
              updateArrayLength(2, 0, 0);
              ip = 665;
      end

        665 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[304] = heapMem[localMem[255]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 666;
      end

        666 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[304]] = localMem[260];
              ip = 667;
      end

        667 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[305] = heapMem[localMem[255]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 668;
      end

        668 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[305]] = localMem[260];
              ip = 669;
      end

        669 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[306] = heapMem[localMem[262]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 670;
      end

        670 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[306] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[299], localMem[306], arraySizes[localMem[306]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[299] && i <= arraySizes[localMem[306]]) begin
                  heapMem[NArea * localMem[306] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[306] + localMem[299]] = localMem[301];                                    // Insert new value
              arraySizes[localMem[306]] = arraySizes[localMem[306]] + 1;                              // Increase array size
              ip = 671;
      end

        671 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[307] = heapMem[localMem[262]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 672;
      end

        672 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[307] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[299], localMem[307], arraySizes[localMem[307]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[299] && i <= arraySizes[localMem[307]]) begin
                  heapMem[NArea * localMem[307] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[307] + localMem[299]] = localMem[303];                                    // Insert new value
              arraySizes[localMem[307]] = arraySizes[localMem[307]] + 1;                              // Increase array size
              ip = 673;
      end

        673 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[308] = heapMem[localMem[262]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 674;
      end

        674 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[309] = localMem[299] + 1;
              updateArrayLength(2, 0, 0);
              ip = 675;
      end

        675 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[308] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[309], localMem[308], arraySizes[localMem[308]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[309] && i <= arraySizes[localMem[308]]) begin
                  heapMem[NArea * localMem[308] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[308] + localMem[309]] = localMem[263];                                    // Insert new value
              arraySizes[localMem[308]] = arraySizes[localMem[308]] + 1;                              // Increase array size
              ip = 676;
      end

        676 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[262]*10 + 0] = heapMem[localMem[262]*10 + 0] + 1;
              updateArrayLength(1, localMem[262], 0);
              ip = 677;
      end

        677 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 794;
      end

        678 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 679;
      end

        679 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 680;
      end

        680 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[310] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[310] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[310]] = 0;
              ip = 681;
      end

        681 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[310]*10 + 0] = localMem[260];
              updateArrayLength(1, localMem[310], 0);
              ip = 682;
      end

        682 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[310]*10 + 2] = 0;
              updateArrayLength(1, localMem[310], 2);
              ip = 683;
      end

        683 :
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
              ip = 684;
      end

        684 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[310]*10 + 4] = localMem[311];
              updateArrayLength(1, localMem[310], 4);
              ip = 685;
      end

        685 :
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
              ip = 686;
      end

        686 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[310]*10 + 5] = localMem[312];
              updateArrayLength(1, localMem[310], 5);
              ip = 687;
      end

        687 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[310]*10 + 6] = 0;
              updateArrayLength(1, localMem[310], 6);
              ip = 688;
      end

        688 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[310]*10 + 3] = localMem[258];
              updateArrayLength(1, localMem[310], 3);
              ip = 689;
      end

        689 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[258]*10 + 1] = heapMem[localMem[258]*10 + 1] + 1;
              updateArrayLength(1, localMem[258], 1);
              ip = 690;
      end

        690 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[310]*10 + 1] = heapMem[localMem[258]*10 + 1];
              updateArrayLength(1, localMem[310], 1);
              ip = 691;
      end

        691 :
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
              ip = 692;
      end

        692 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[313]*10 + 0] = localMem[260];
              updateArrayLength(1, localMem[313], 0);
              ip = 693;
      end

        693 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[313]*10 + 2] = 0;
              updateArrayLength(1, localMem[313], 2);
              ip = 694;
      end

        694 :
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
              ip = 695;
      end

        695 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[313]*10 + 4] = localMem[314];
              updateArrayLength(1, localMem[313], 4);
              ip = 696;
      end

        696 :
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
              ip = 697;
      end

        697 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[313]*10 + 5] = localMem[315];
              updateArrayLength(1, localMem[313], 5);
              ip = 698;
      end

        698 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[313]*10 + 6] = 0;
              updateArrayLength(1, localMem[313], 6);
              ip = 699;
      end

        699 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[313]*10 + 3] = localMem[258];
              updateArrayLength(1, localMem[313], 3);
              ip = 700;
      end

        700 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[258]*10 + 1] = heapMem[localMem[258]*10 + 1] + 1;
              updateArrayLength(1, localMem[258], 1);
              ip = 701;
      end

        701 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[313]*10 + 1] = heapMem[localMem[258]*10 + 1];
              updateArrayLength(1, localMem[313], 1);
              ip = 702;
      end

        702 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[316] = !heapMem[localMem[255]*10 + 6];
              ip = 703;
      end

        703 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[316] != 0 ? 755 : 704;
      end

        704 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[317] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[317] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[317]] = 0;
              ip = 705;
      end

        705 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[310]*10 + 6] = localMem[317];
              updateArrayLength(1, localMem[310], 6);
              ip = 706;
      end

        706 :
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
              ip = 707;
      end

        707 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[313]*10 + 6] = localMem[318];
              updateArrayLength(1, localMem[313], 6);
              ip = 708;
      end

        708 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[319] = heapMem[localMem[255]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 709;
      end

        709 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[320] = heapMem[localMem[310]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 710;
      end

        710 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[260]) begin
                  heapMem[NArea * localMem[320] + 0 + i] = heapMem[NArea * localMem[319] + 0 + i];
                  updateArrayLength(1, localMem[320], 0 + i);
                end
              end
              ip = 711;
      end

        711 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[321] = heapMem[localMem[255]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 712;
      end

        712 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[322] = heapMem[localMem[310]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 713;
      end

        713 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[260]) begin
                  heapMem[NArea * localMem[322] + 0 + i] = heapMem[NArea * localMem[321] + 0 + i];
                  updateArrayLength(1, localMem[322], 0 + i);
                end
              end
              ip = 714;
      end

        714 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[323] = heapMem[localMem[255]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 715;
      end

        715 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[324] = heapMem[localMem[310]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 716;
      end

        716 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[325] = localMem[260] + 1;
              updateArrayLength(2, 0, 0);
              ip = 717;
      end

        717 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[325]) begin
                  heapMem[NArea * localMem[324] + 0 + i] = heapMem[NArea * localMem[323] + 0 + i];
                  updateArrayLength(1, localMem[324], 0 + i);
                end
              end
              ip = 718;
      end

        718 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[326] = heapMem[localMem[255]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 719;
      end

        719 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[327] = heapMem[localMem[313]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 720;
      end

        720 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[260]) begin
                  heapMem[NArea * localMem[327] + 0 + i] = heapMem[NArea * localMem[326] + localMem[261] + i];
                  updateArrayLength(1, localMem[327], 0 + i);
                end
              end
              ip = 721;
      end

        721 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[328] = heapMem[localMem[255]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 722;
      end

        722 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[329] = heapMem[localMem[313]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 723;
      end

        723 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[260]) begin
                  heapMem[NArea * localMem[329] + 0 + i] = heapMem[NArea * localMem[328] + localMem[261] + i];
                  updateArrayLength(1, localMem[329], 0 + i);
                end
              end
              ip = 724;
      end

        724 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[330] = heapMem[localMem[255]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 725;
      end

        725 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[331] = heapMem[localMem[313]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 726;
      end

        726 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[332] = localMem[260] + 1;
              updateArrayLength(2, 0, 0);
              ip = 727;
      end

        727 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[332]) begin
                  heapMem[NArea * localMem[331] + 0 + i] = heapMem[NArea * localMem[330] + localMem[261] + i];
                  updateArrayLength(1, localMem[331], 0 + i);
                end
              end
              ip = 728;
      end

        728 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[333] = heapMem[localMem[310]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 729;
      end

        729 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[334] = localMem[333] + 1;
              updateArrayLength(2, 0, 0);
              ip = 730;
      end

        730 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[335] = heapMem[localMem[310]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 731;
      end

        731 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 732;
      end

        732 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[336] = 0;
              updateArrayLength(2, 0, 0);
              ip = 733;
      end

        733 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 734;
      end

        734 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[336] >= localMem[334] ? 740 : 735;
      end

        735 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[337] = heapMem[localMem[335]*10 + localMem[336]];
              updateArrayLength(2, 0, 0);
              ip = 736;
      end

        736 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[337]*10 + 2] = localMem[310];
              updateArrayLength(1, localMem[337], 2);
              ip = 737;
      end

        737 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 738;
      end

        738 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[336] = localMem[336] + 1;
              updateArrayLength(2, 0, 0);
              ip = 739;
      end

        739 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 733;
      end

        740 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 741;
      end

        741 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[338] = heapMem[localMem[313]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 742;
      end

        742 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[339] = localMem[338] + 1;
              updateArrayLength(2, 0, 0);
              ip = 743;
      end

        743 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[340] = heapMem[localMem[313]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 744;
      end

        744 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 745;
      end

        745 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[341] = 0;
              updateArrayLength(2, 0, 0);
              ip = 746;
      end

        746 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 747;
      end

        747 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[341] >= localMem[339] ? 753 : 748;
      end

        748 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[342] = heapMem[localMem[340]*10 + localMem[341]];
              updateArrayLength(2, 0, 0);
              ip = 749;
      end

        749 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[342]*10 + 2] = localMem[313];
              updateArrayLength(1, localMem[342], 2);
              ip = 750;
      end

        750 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 751;
      end

        751 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[341] = localMem[341] + 1;
              updateArrayLength(2, 0, 0);
              ip = 752;
      end

        752 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 746;
      end

        753 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 754;
      end

        754 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 770;
      end

        755 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 756;
      end

        756 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[343] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[343] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[343]] = 0;
              ip = 757;
      end

        757 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[255]*10 + 6] = localMem[343];
              updateArrayLength(1, localMem[255], 6);
              ip = 758;
      end

        758 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[344] = heapMem[localMem[255]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 759;
      end

        759 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[345] = heapMem[localMem[310]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 760;
      end

        760 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[260]) begin
                  heapMem[NArea * localMem[345] + 0 + i] = heapMem[NArea * localMem[344] + 0 + i];
                  updateArrayLength(1, localMem[345], 0 + i);
                end
              end
              ip = 761;
      end

        761 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[346] = heapMem[localMem[255]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 762;
      end

        762 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[347] = heapMem[localMem[310]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 763;
      end

        763 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[260]) begin
                  heapMem[NArea * localMem[347] + 0 + i] = heapMem[NArea * localMem[346] + 0 + i];
                  updateArrayLength(1, localMem[347], 0 + i);
                end
              end
              ip = 764;
      end

        764 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[348] = heapMem[localMem[255]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 765;
      end

        765 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[349] = heapMem[localMem[313]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 766;
      end

        766 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[260]) begin
                  heapMem[NArea * localMem[349] + 0 + i] = heapMem[NArea * localMem[348] + localMem[261] + i];
                  updateArrayLength(1, localMem[349], 0 + i);
                end
              end
              ip = 767;
      end

        767 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[350] = heapMem[localMem[255]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 768;
      end

        768 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[351] = heapMem[localMem[313]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 769;
      end

        769 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[260]) begin
                  heapMem[NArea * localMem[351] + 0 + i] = heapMem[NArea * localMem[350] + localMem[261] + i];
                  updateArrayLength(1, localMem[351], 0 + i);
                end
              end
              ip = 770;
      end

        770 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 771;
      end

        771 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[310]*10 + 2] = localMem[255];
              updateArrayLength(1, localMem[310], 2);
              ip = 772;
      end

        772 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[313]*10 + 2] = localMem[255];
              updateArrayLength(1, localMem[313], 2);
              ip = 773;
      end

        773 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[352] = heapMem[localMem[255]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 774;
      end

        774 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[353] = heapMem[localMem[352]*10 + localMem[260]];
              updateArrayLength(2, 0, 0);
              ip = 775;
      end

        775 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[354] = heapMem[localMem[255]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 776;
      end

        776 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[355] = heapMem[localMem[354]*10 + localMem[260]];
              updateArrayLength(2, 0, 0);
              ip = 777;
      end

        777 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[356] = heapMem[localMem[255]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 778;
      end

        778 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[356]*10 + 0] = localMem[353];
              updateArrayLength(1, localMem[356], 0);
              ip = 779;
      end

        779 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[357] = heapMem[localMem[255]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 780;
      end

        780 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[357]*10 + 0] = localMem[355];
              updateArrayLength(1, localMem[357], 0);
              ip = 781;
      end

        781 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[358] = heapMem[localMem[255]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 782;
      end

        782 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[358]*10 + 0] = localMem[310];
              updateArrayLength(1, localMem[358], 0);
              ip = 783;
      end

        783 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[359] = heapMem[localMem[255]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 784;
      end

        784 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[359]*10 + 1] = localMem[313];
              updateArrayLength(1, localMem[359], 1);
              ip = 785;
      end

        785 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[255]*10 + 0] = 1;
              updateArrayLength(1, localMem[255], 0);
              ip = 786;
      end

        786 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[360] = heapMem[localMem[255]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 787;
      end

        787 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[360]] = 1;
              ip = 788;
      end

        788 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[361] = heapMem[localMem[255]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 789;
      end

        789 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[361]] = 1;
              ip = 790;
      end

        790 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[362] = heapMem[localMem[255]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 791;
      end

        791 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[362]] = 2;
              ip = 792;
      end

        792 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 794;
      end

        793 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 799;
      end

        794 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 795;
      end

        795 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[256] = 1;
              updateArrayLength(2, 0, 0);
              ip = 796;
      end

        796 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 799;
      end

        797 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 798;
      end

        798 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[256] = 0;
              updateArrayLength(2, 0, 0);
              ip = 799;
      end

        799 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 800;
      end

        800 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[256] != 0 ? 802 : 801;
      end

        801 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[27] = localMem[255];
              updateArrayLength(2, 0, 0);
              ip = 802;
      end

        802 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 803;
      end

        803 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 804;
      end

        804 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[135] = localMem[135] + 1;
              updateArrayLength(2, 0, 0);
              ip = 805;
      end

        805 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 307;
      end

        806 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 807;
      end

        807 :
      begin                                                                     // assert
//$display("AAAA %4d %4d assert", steps, ip);
            ip = 808;
      end

        808 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
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
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[363] = heapMem[localMem[4]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 812;
      end

        812 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[364] = heapMem[localMem[4]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 813;
      end

        813 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[365] = heapMem[localMem[4]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 814;
      end

        814 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[364] != 1 ? 818 : 815;
      end

        815 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[366] = heapMem[localMem[363]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 816;
      end

        816 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[366]*10 + localMem[365]] = localMem[3];
              updateArrayLength(1, localMem[366], localMem[365]);
              ip = 817;
      end

        817 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1064;
      end

        818 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 819;
      end

        819 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[364] != 2 ? 827 : 820;
      end

        820 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[367] = localMem[365] + 1;
              updateArrayLength(2, 0, 0);
              ip = 821;
      end

        821 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[368] = heapMem[localMem[363]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 822;
      end

        822 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[368] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[367], localMem[368], arraySizes[localMem[368]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[367] && i <= arraySizes[localMem[368]]) begin
                  heapMem[NArea * localMem[368] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[368] + localMem[367]] = localMem[2];                                    // Insert new value
              arraySizes[localMem[368]] = arraySizes[localMem[368]] + 1;                              // Increase array size
              ip = 823;
      end

        823 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[369] = heapMem[localMem[363]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 824;
      end

        824 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[369] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[367], localMem[369], arraySizes[localMem[369]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[367] && i <= arraySizes[localMem[369]]) begin
                  heapMem[NArea * localMem[369] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[369] + localMem[367]] = localMem[3];                                    // Insert new value
              arraySizes[localMem[369]] = arraySizes[localMem[369]] + 1;                              // Increase array size
              ip = 825;
      end

        825 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[363]*10 + 0] = heapMem[localMem[363]*10 + 0] + 1;
              updateArrayLength(1, localMem[363], 0);
              ip = 826;
      end

        826 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 833;
      end

        827 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 828;
      end

        828 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[370] = heapMem[localMem[363]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 829;
      end

        829 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[370] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[365], localMem[370], arraySizes[localMem[370]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[365] && i <= arraySizes[localMem[370]]) begin
                  heapMem[NArea * localMem[370] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[370] + localMem[365]] = localMem[2];                                    // Insert new value
              arraySizes[localMem[370]] = arraySizes[localMem[370]] + 1;                              // Increase array size
              ip = 830;
      end

        830 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[371] = heapMem[localMem[363]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 831;
      end

        831 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[371] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[365], localMem[371], arraySizes[localMem[371]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[365] && i <= arraySizes[localMem[371]]) begin
                  heapMem[NArea * localMem[371] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[371] + localMem[365]] = localMem[3];                                    // Insert new value
              arraySizes[localMem[371]] = arraySizes[localMem[371]] + 1;                              // Increase array size
              ip = 832;
      end

        832 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[363]*10 + 0] = heapMem[localMem[363]*10 + 0] + 1;
              updateArrayLength(1, localMem[363], 0);
              ip = 833;
      end

        833 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 834;
      end

        834 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              updateArrayLength(1, localMem[0], 0);
              ip = 835;
      end

        835 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 836;
      end

        836 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[373] = heapMem[localMem[363]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 837;
      end

        837 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[374] = heapMem[localMem[363]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 838;
      end

        838 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[375] = heapMem[localMem[374]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 839;
      end

        839 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[373] <  localMem[375] ? 1059 : 840;
      end

        840 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[376] = localMem[375];
              updateArrayLength(2, 0, 0);
              ip = 841;
      end

        841 :
      begin                                                                     // shiftRight
//$display("AAAA %4d %4d shiftRight", steps, ip);
              localMem[376] = localMem[376] >> 1;
              ip = 842;
      end

        842 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[377] = localMem[376] + 1;
              updateArrayLength(2, 0, 0);
              ip = 843;
      end

        843 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[378] = heapMem[localMem[363]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 844;
      end

        844 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[378] == 0 ? 941 : 845;
      end

        845 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[379] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[379] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[379]] = 0;
              ip = 846;
      end

        846 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[379]*10 + 0] = localMem[376];
              updateArrayLength(1, localMem[379], 0);
              ip = 847;
      end

        847 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[379]*10 + 2] = 0;
              updateArrayLength(1, localMem[379], 2);
              ip = 848;
      end

        848 :
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
              ip = 849;
      end

        849 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[379]*10 + 4] = localMem[380];
              updateArrayLength(1, localMem[379], 4);
              ip = 850;
      end

        850 :
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
              ip = 851;
      end

        851 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[379]*10 + 5] = localMem[381];
              updateArrayLength(1, localMem[379], 5);
              ip = 852;
      end

        852 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[379]*10 + 6] = 0;
              updateArrayLength(1, localMem[379], 6);
              ip = 853;
      end

        853 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[379]*10 + 3] = localMem[374];
              updateArrayLength(1, localMem[379], 3);
              ip = 854;
      end

        854 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[374]*10 + 1] = heapMem[localMem[374]*10 + 1] + 1;
              updateArrayLength(1, localMem[374], 1);
              ip = 855;
      end

        855 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[379]*10 + 1] = heapMem[localMem[374]*10 + 1];
              updateArrayLength(1, localMem[379], 1);
              ip = 856;
      end

        856 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[382] = !heapMem[localMem[363]*10 + 6];
              ip = 857;
      end

        857 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[382] != 0 ? 886 : 858;
      end

        858 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[383] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[383] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[383]] = 0;
              ip = 859;
      end

        859 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[379]*10 + 6] = localMem[383];
              updateArrayLength(1, localMem[379], 6);
              ip = 860;
      end

        860 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[384] = heapMem[localMem[363]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 861;
      end

        861 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[385] = heapMem[localMem[379]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 862;
      end

        862 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[376]) begin
                  heapMem[NArea * localMem[385] + 0 + i] = heapMem[NArea * localMem[384] + localMem[377] + i];
                  updateArrayLength(1, localMem[385], 0 + i);
                end
              end
              ip = 863;
      end

        863 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[386] = heapMem[localMem[363]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 864;
      end

        864 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[387] = heapMem[localMem[379]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 865;
      end

        865 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[376]) begin
                  heapMem[NArea * localMem[387] + 0 + i] = heapMem[NArea * localMem[386] + localMem[377] + i];
                  updateArrayLength(1, localMem[387], 0 + i);
                end
              end
              ip = 866;
      end

        866 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[388] = heapMem[localMem[363]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 867;
      end

        867 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[389] = heapMem[localMem[379]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 868;
      end

        868 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[390] = localMem[376] + 1;
              updateArrayLength(2, 0, 0);
              ip = 869;
      end

        869 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[390]) begin
                  heapMem[NArea * localMem[389] + 0 + i] = heapMem[NArea * localMem[388] + localMem[377] + i];
                  updateArrayLength(1, localMem[389], 0 + i);
                end
              end
              ip = 870;
      end

        870 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[391] = heapMem[localMem[379]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 871;
      end

        871 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[392] = localMem[391] + 1;
              updateArrayLength(2, 0, 0);
              ip = 872;
      end

        872 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[393] = heapMem[localMem[379]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 873;
      end

        873 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 874;
      end

        874 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[394] = 0;
              updateArrayLength(2, 0, 0);
              ip = 875;
      end

        875 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 876;
      end

        876 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[394] >= localMem[392] ? 882 : 877;
      end

        877 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[395] = heapMem[localMem[393]*10 + localMem[394]];
              updateArrayLength(2, 0, 0);
              ip = 878;
      end

        878 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[395]*10 + 2] = localMem[379];
              updateArrayLength(1, localMem[395], 2);
              ip = 879;
      end

        879 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 880;
      end

        880 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[394] = localMem[394] + 1;
              updateArrayLength(2, 0, 0);
              ip = 881;
      end

        881 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 875;
      end

        882 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 883;
      end

        883 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[396] = heapMem[localMem[363]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 884;
      end

        884 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[396]] = localMem[377];
              ip = 885;
      end

        885 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 893;
      end

        886 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 887;
      end

        887 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[397] = heapMem[localMem[363]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 888;
      end

        888 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[398] = heapMem[localMem[379]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 889;
      end

        889 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[376]) begin
                  heapMem[NArea * localMem[398] + 0 + i] = heapMem[NArea * localMem[397] + localMem[377] + i];
                  updateArrayLength(1, localMem[398], 0 + i);
                end
              end
              ip = 890;
      end

        890 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[399] = heapMem[localMem[363]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 891;
      end

        891 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[400] = heapMem[localMem[379]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 892;
      end

        892 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[376]) begin
                  heapMem[NArea * localMem[400] + 0 + i] = heapMem[NArea * localMem[399] + localMem[377] + i];
                  updateArrayLength(1, localMem[400], 0 + i);
                end
              end
              ip = 893;
      end

        893 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 894;
      end

        894 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[363]*10 + 0] = localMem[376];
              updateArrayLength(1, localMem[363], 0);
              ip = 895;
      end

        895 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[379]*10 + 2] = localMem[378];
              updateArrayLength(1, localMem[379], 2);
              ip = 896;
      end

        896 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[401] = heapMem[localMem[378]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 897;
      end

        897 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[402] = heapMem[localMem[378]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 898;
      end

        898 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[403] = heapMem[localMem[402]*10 + localMem[401]];
              updateArrayLength(2, 0, 0);
              ip = 899;
      end

        899 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[403] != localMem[363] ? 918 : 900;
      end

        900 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[404] = heapMem[localMem[363]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 901;
      end

        901 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[405] = heapMem[localMem[404]*10 + localMem[376]];
              updateArrayLength(2, 0, 0);
              ip = 902;
      end

        902 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[406] = heapMem[localMem[378]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 903;
      end

        903 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[406]*10 + localMem[401]] = localMem[405];
              updateArrayLength(1, localMem[406], localMem[401]);
              ip = 904;
      end

        904 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[407] = heapMem[localMem[363]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 905;
      end

        905 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[408] = heapMem[localMem[407]*10 + localMem[376]];
              updateArrayLength(2, 0, 0);
              ip = 906;
      end

        906 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[409] = heapMem[localMem[378]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 907;
      end

        907 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[409]*10 + localMem[401]] = localMem[408];
              updateArrayLength(1, localMem[409], localMem[401]);
              ip = 908;
      end

        908 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[410] = heapMem[localMem[363]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 909;
      end

        909 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[410]] = localMem[376];
              ip = 910;
      end

        910 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[411] = heapMem[localMem[363]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 911;
      end

        911 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[411]] = localMem[376];
              ip = 912;
      end

        912 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[412] = localMem[401] + 1;
              updateArrayLength(2, 0, 0);
              ip = 913;
      end

        913 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[378]*10 + 0] = localMem[412];
              updateArrayLength(1, localMem[378], 0);
              ip = 914;
      end

        914 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[413] = heapMem[localMem[378]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 915;
      end

        915 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[413]*10 + localMem[412]] = localMem[379];
              updateArrayLength(1, localMem[413], localMem[412]);
              ip = 916;
      end

        916 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1056;
      end

        917 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 940;
      end

        918 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 919;
      end

        919 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 920;
      end

        920 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[414] = heapMem[localMem[378]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 921;
      end

        921 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[415] = 0; k = arraySizes[localMem[414]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[414] * NArea + i] == localMem[363]) localMem[415] = i + 1;
              end
              ip = 922;
      end

        922 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[415] = localMem[415] - 1;
              updateArrayLength(2, 0, 0);
              ip = 923;
      end

        923 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[416] = heapMem[localMem[363]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 924;
      end

        924 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[417] = heapMem[localMem[416]*10 + localMem[376]];
              updateArrayLength(2, 0, 0);
              ip = 925;
      end

        925 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[418] = heapMem[localMem[363]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 926;
      end

        926 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[419] = heapMem[localMem[418]*10 + localMem[376]];
              updateArrayLength(2, 0, 0);
              ip = 927;
      end

        927 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[420] = heapMem[localMem[363]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 928;
      end

        928 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[420]] = localMem[376];
              ip = 929;
      end

        929 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[421] = heapMem[localMem[363]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 930;
      end

        930 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[421]] = localMem[376];
              ip = 931;
      end

        931 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[422] = heapMem[localMem[378]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 932;
      end

        932 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[422] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[415], localMem[422], arraySizes[localMem[422]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[415] && i <= arraySizes[localMem[422]]) begin
                  heapMem[NArea * localMem[422] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[422] + localMem[415]] = localMem[417];                                    // Insert new value
              arraySizes[localMem[422]] = arraySizes[localMem[422]] + 1;                              // Increase array size
              ip = 933;
      end

        933 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[423] = heapMem[localMem[378]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 934;
      end

        934 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[423] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[415], localMem[423], arraySizes[localMem[423]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[415] && i <= arraySizes[localMem[423]]) begin
                  heapMem[NArea * localMem[423] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[423] + localMem[415]] = localMem[419];                                    // Insert new value
              arraySizes[localMem[423]] = arraySizes[localMem[423]] + 1;                              // Increase array size
              ip = 935;
      end

        935 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[424] = heapMem[localMem[378]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 936;
      end

        936 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[425] = localMem[415] + 1;
              updateArrayLength(2, 0, 0);
              ip = 937;
      end

        937 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[424] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[425], localMem[424], arraySizes[localMem[424]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[425] && i <= arraySizes[localMem[424]]) begin
                  heapMem[NArea * localMem[424] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[424] + localMem[425]] = localMem[379];                                    // Insert new value
              arraySizes[localMem[424]] = arraySizes[localMem[424]] + 1;                              // Increase array size
              ip = 938;
      end

        938 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[378]*10 + 0] = heapMem[localMem[378]*10 + 0] + 1;
              updateArrayLength(1, localMem[378], 0);
              ip = 939;
      end

        939 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1056;
      end

        940 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 941;
      end

        941 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 942;
      end

        942 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[426] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[426] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[426]] = 0;
              ip = 943;
      end

        943 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[426]*10 + 0] = localMem[376];
              updateArrayLength(1, localMem[426], 0);
              ip = 944;
      end

        944 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[426]*10 + 2] = 0;
              updateArrayLength(1, localMem[426], 2);
              ip = 945;
      end

        945 :
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
              ip = 946;
      end

        946 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[426]*10 + 4] = localMem[427];
              updateArrayLength(1, localMem[426], 4);
              ip = 947;
      end

        947 :
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
              ip = 948;
      end

        948 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[426]*10 + 5] = localMem[428];
              updateArrayLength(1, localMem[426], 5);
              ip = 949;
      end

        949 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[426]*10 + 6] = 0;
              updateArrayLength(1, localMem[426], 6);
              ip = 950;
      end

        950 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[426]*10 + 3] = localMem[374];
              updateArrayLength(1, localMem[426], 3);
              ip = 951;
      end

        951 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[374]*10 + 1] = heapMem[localMem[374]*10 + 1] + 1;
              updateArrayLength(1, localMem[374], 1);
              ip = 952;
      end

        952 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[426]*10 + 1] = heapMem[localMem[374]*10 + 1];
              updateArrayLength(1, localMem[426], 1);
              ip = 953;
      end

        953 :
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
              ip = 954;
      end

        954 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[429]*10 + 0] = localMem[376];
              updateArrayLength(1, localMem[429], 0);
              ip = 955;
      end

        955 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[429]*10 + 2] = 0;
              updateArrayLength(1, localMem[429], 2);
              ip = 956;
      end

        956 :
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
              ip = 957;
      end

        957 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[429]*10 + 4] = localMem[430];
              updateArrayLength(1, localMem[429], 4);
              ip = 958;
      end

        958 :
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
              ip = 959;
      end

        959 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[429]*10 + 5] = localMem[431];
              updateArrayLength(1, localMem[429], 5);
              ip = 960;
      end

        960 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[429]*10 + 6] = 0;
              updateArrayLength(1, localMem[429], 6);
              ip = 961;
      end

        961 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[429]*10 + 3] = localMem[374];
              updateArrayLength(1, localMem[429], 3);
              ip = 962;
      end

        962 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[374]*10 + 1] = heapMem[localMem[374]*10 + 1] + 1;
              updateArrayLength(1, localMem[374], 1);
              ip = 963;
      end

        963 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[429]*10 + 1] = heapMem[localMem[374]*10 + 1];
              updateArrayLength(1, localMem[429], 1);
              ip = 964;
      end

        964 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[432] = !heapMem[localMem[363]*10 + 6];
              ip = 965;
      end

        965 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[432] != 0 ? 1017 : 966;
      end

        966 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[433] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[433] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[433]] = 0;
              ip = 967;
      end

        967 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[426]*10 + 6] = localMem[433];
              updateArrayLength(1, localMem[426], 6);
              ip = 968;
      end

        968 :
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
              ip = 969;
      end

        969 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[429]*10 + 6] = localMem[434];
              updateArrayLength(1, localMem[429], 6);
              ip = 970;
      end

        970 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[435] = heapMem[localMem[363]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 971;
      end

        971 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[436] = heapMem[localMem[426]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 972;
      end

        972 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[376]) begin
                  heapMem[NArea * localMem[436] + 0 + i] = heapMem[NArea * localMem[435] + 0 + i];
                  updateArrayLength(1, localMem[436], 0 + i);
                end
              end
              ip = 973;
      end

        973 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[437] = heapMem[localMem[363]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 974;
      end

        974 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[438] = heapMem[localMem[426]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 975;
      end

        975 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[376]) begin
                  heapMem[NArea * localMem[438] + 0 + i] = heapMem[NArea * localMem[437] + 0 + i];
                  updateArrayLength(1, localMem[438], 0 + i);
                end
              end
              ip = 976;
      end

        976 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[439] = heapMem[localMem[363]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 977;
      end

        977 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[440] = heapMem[localMem[426]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 978;
      end

        978 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[441] = localMem[376] + 1;
              updateArrayLength(2, 0, 0);
              ip = 979;
      end

        979 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[441]) begin
                  heapMem[NArea * localMem[440] + 0 + i] = heapMem[NArea * localMem[439] + 0 + i];
                  updateArrayLength(1, localMem[440], 0 + i);
                end
              end
              ip = 980;
      end

        980 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[442] = heapMem[localMem[363]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 981;
      end

        981 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[443] = heapMem[localMem[429]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 982;
      end

        982 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[376]) begin
                  heapMem[NArea * localMem[443] + 0 + i] = heapMem[NArea * localMem[442] + localMem[377] + i];
                  updateArrayLength(1, localMem[443], 0 + i);
                end
              end
              ip = 983;
      end

        983 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[444] = heapMem[localMem[363]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 984;
      end

        984 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[445] = heapMem[localMem[429]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 985;
      end

        985 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[376]) begin
                  heapMem[NArea * localMem[445] + 0 + i] = heapMem[NArea * localMem[444] + localMem[377] + i];
                  updateArrayLength(1, localMem[445], 0 + i);
                end
              end
              ip = 986;
      end

        986 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[446] = heapMem[localMem[363]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 987;
      end

        987 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[447] = heapMem[localMem[429]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 988;
      end

        988 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[448] = localMem[376] + 1;
              updateArrayLength(2, 0, 0);
              ip = 989;
      end

        989 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[448]) begin
                  heapMem[NArea * localMem[447] + 0 + i] = heapMem[NArea * localMem[446] + localMem[377] + i];
                  updateArrayLength(1, localMem[447], 0 + i);
                end
              end
              ip = 990;
      end

        990 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[449] = heapMem[localMem[426]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 991;
      end

        991 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[450] = localMem[449] + 1;
              updateArrayLength(2, 0, 0);
              ip = 992;
      end

        992 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[451] = heapMem[localMem[426]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 993;
      end

        993 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 994;
      end

        994 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[452] = 0;
              updateArrayLength(2, 0, 0);
              ip = 995;
      end

        995 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 996;
      end

        996 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[452] >= localMem[450] ? 1002 : 997;
      end

        997 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[453] = heapMem[localMem[451]*10 + localMem[452]];
              updateArrayLength(2, 0, 0);
              ip = 998;
      end

        998 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[453]*10 + 2] = localMem[426];
              updateArrayLength(1, localMem[453], 2);
              ip = 999;
      end

        999 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1000;
      end

       1000 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[452] = localMem[452] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1001;
      end

       1001 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 995;
      end

       1002 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1003;
      end

       1003 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[454] = heapMem[localMem[429]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1004;
      end

       1004 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[455] = localMem[454] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1005;
      end

       1005 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[456] = heapMem[localMem[429]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1006;
      end

       1006 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1007;
      end

       1007 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[457] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1008;
      end

       1008 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1009;
      end

       1009 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[457] >= localMem[455] ? 1015 : 1010;
      end

       1010 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[458] = heapMem[localMem[456]*10 + localMem[457]];
              updateArrayLength(2, 0, 0);
              ip = 1011;
      end

       1011 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[458]*10 + 2] = localMem[429];
              updateArrayLength(1, localMem[458], 2);
              ip = 1012;
      end

       1012 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1013;
      end

       1013 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[457] = localMem[457] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1014;
      end

       1014 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1008;
      end

       1015 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1016;
      end

       1016 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1032;
      end

       1017 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1018;
      end

       1018 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[459] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[459] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[459]] = 0;
              ip = 1019;
      end

       1019 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[363]*10 + 6] = localMem[459];
              updateArrayLength(1, localMem[363], 6);
              ip = 1020;
      end

       1020 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[460] = heapMem[localMem[363]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1021;
      end

       1021 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[461] = heapMem[localMem[426]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1022;
      end

       1022 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[376]) begin
                  heapMem[NArea * localMem[461] + 0 + i] = heapMem[NArea * localMem[460] + 0 + i];
                  updateArrayLength(1, localMem[461], 0 + i);
                end
              end
              ip = 1023;
      end

       1023 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[462] = heapMem[localMem[363]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1024;
      end

       1024 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[463] = heapMem[localMem[426]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1025;
      end

       1025 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[376]) begin
                  heapMem[NArea * localMem[463] + 0 + i] = heapMem[NArea * localMem[462] + 0 + i];
                  updateArrayLength(1, localMem[463], 0 + i);
                end
              end
              ip = 1026;
      end

       1026 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[464] = heapMem[localMem[363]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1027;
      end

       1027 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[465] = heapMem[localMem[429]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1028;
      end

       1028 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[376]) begin
                  heapMem[NArea * localMem[465] + 0 + i] = heapMem[NArea * localMem[464] + localMem[377] + i];
                  updateArrayLength(1, localMem[465], 0 + i);
                end
              end
              ip = 1029;
      end

       1029 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[466] = heapMem[localMem[363]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1030;
      end

       1030 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[467] = heapMem[localMem[429]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1031;
      end

       1031 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[376]) begin
                  heapMem[NArea * localMem[467] + 0 + i] = heapMem[NArea * localMem[466] + localMem[377] + i];
                  updateArrayLength(1, localMem[467], 0 + i);
                end
              end
              ip = 1032;
      end

       1032 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1033;
      end

       1033 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[426]*10 + 2] = localMem[363];
              updateArrayLength(1, localMem[426], 2);
              ip = 1034;
      end

       1034 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[429]*10 + 2] = localMem[363];
              updateArrayLength(1, localMem[429], 2);
              ip = 1035;
      end

       1035 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[468] = heapMem[localMem[363]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1036;
      end

       1036 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[469] = heapMem[localMem[468]*10 + localMem[376]];
              updateArrayLength(2, 0, 0);
              ip = 1037;
      end

       1037 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[470] = heapMem[localMem[363]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1038;
      end

       1038 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[471] = heapMem[localMem[470]*10 + localMem[376]];
              updateArrayLength(2, 0, 0);
              ip = 1039;
      end

       1039 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[472] = heapMem[localMem[363]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1040;
      end

       1040 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[472]*10 + 0] = localMem[469];
              updateArrayLength(1, localMem[472], 0);
              ip = 1041;
      end

       1041 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[473] = heapMem[localMem[363]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1042;
      end

       1042 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[473]*10 + 0] = localMem[471];
              updateArrayLength(1, localMem[473], 0);
              ip = 1043;
      end

       1043 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[474] = heapMem[localMem[363]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1044;
      end

       1044 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[474]*10 + 0] = localMem[426];
              updateArrayLength(1, localMem[474], 0);
              ip = 1045;
      end

       1045 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[475] = heapMem[localMem[363]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1046;
      end

       1046 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[475]*10 + 1] = localMem[429];
              updateArrayLength(1, localMem[475], 1);
              ip = 1047;
      end

       1047 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[363]*10 + 0] = 1;
              updateArrayLength(1, localMem[363], 0);
              ip = 1048;
      end

       1048 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[476] = heapMem[localMem[363]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1049;
      end

       1049 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[476]] = 1;
              ip = 1050;
      end

       1050 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[477] = heapMem[localMem[363]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1051;
      end

       1051 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[477]] = 1;
              ip = 1052;
      end

       1052 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[478] = heapMem[localMem[363]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1053;
      end

       1053 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[478]] = 2;
              ip = 1054;
      end

       1054 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1056;
      end

       1055 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1061;
      end

       1056 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1057;
      end

       1057 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[372] = 1;
              updateArrayLength(2, 0, 0);
              ip = 1058;
      end

       1058 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1061;
      end

       1059 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1060;
      end

       1060 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[372] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1061;
      end

       1061 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
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
      begin                                                                     // free
//$display("AAAA %4d %4d free", steps, ip);
                                 arraySizes[localMem[4]] = 0;
              freedArrays[freedArraysTop] = localMem[4];
              freedArraysTop = freedArraysTop + 1;
              ip = 1066;
      end

       1066 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1067;
      end

       1067 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 5;
      end

       1068 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1069;
      end

       1069 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[479] = 1;
              updateArrayLength(2, 0, 0);
              ip = 1070;
      end

       1070 :
      begin                                                                     // shiftLeft
//$display("AAAA %4d %4d shiftLeft", steps, ip);
              localMem[479] = localMem[479] << 31;
              ip = 1071;
      end

       1071 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[480] = heapMem[localMem[0]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 1072;
      end

       1072 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[481] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[481] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[481]] = 0;
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
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[480] != 0 ? 1079 : 1075;
      end

       1075 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[481]*10 + 0] = localMem[480];
              updateArrayLength(1, localMem[481], 0);
              ip = 1076;
      end

       1076 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[481]*10 + 1] = 3;
              updateArrayLength(1, localMem[481], 1);
              ip = 1077;
      end

       1077 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[481]*10 + 2] = 0;
              updateArrayLength(1, localMem[481], 2);
              ip = 1078;
      end

       1078 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1096;
      end

       1079 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1080;
      end

       1080 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1081;
      end

       1081 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[483] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1082;
      end

       1082 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1083;
      end

       1083 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[483] >= 99 ? 1092 : 1084;
      end

       1084 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[484] = !heapMem[localMem[480]*10 + 6];
              ip = 1085;
      end

       1085 :
      begin                                                                     // jTrue
//$display("AAAA %4d %4d jTrue", steps, ip);
              ip = localMem[484] != 0 ? 1092 : 1086;
      end

       1086 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[485] = heapMem[localMem[480]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1087;
      end

       1087 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[486] = heapMem[localMem[485]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1088;
      end

       1088 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[480] = localMem[486];
              updateArrayLength(2, 0, 0);
              ip = 1089;
      end

       1089 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1090;
      end

       1090 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[483] = localMem[483] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1091;
      end

       1091 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1082;
      end

       1092 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1093;
      end

       1093 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[481]*10 + 0] = localMem[480];
              updateArrayLength(1, localMem[481], 0);
              ip = 1094;
      end

       1094 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[481]*10 + 1] = 1;
              updateArrayLength(1, localMem[481], 1);
              ip = 1095;
      end

       1095 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[481]*10 + 2] = 0;
              updateArrayLength(1, localMem[481], 2);
              ip = 1096;
      end

       1096 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1097;
      end

       1097 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1098;
      end

       1098 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[487] = heapMem[localMem[481]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 1099;
      end

       1099 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[487] == 3 ? 1182 : 1100;
      end

       1100 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 3) begin
                  heapMem[NArea * localMem[482] + 0 + i] = heapMem[NArea * localMem[481] + 0 + i];
                  updateArrayLength(1, localMem[482], 0 + i);
                end
              end
              ip = 1101;
      end

       1101 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[488] = heapMem[localMem[482]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1102;
      end

       1102 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[489] = heapMem[localMem[482]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1103;
      end

       1103 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[490] = heapMem[localMem[488]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1104;
      end

       1104 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[491] = heapMem[localMem[490]*10 + localMem[489]];
              updateArrayLength(2, 0, 0);
              ip = 1105;
      end

       1105 :
      begin                                                                     // out
//$display("AAAA %4d %4d out", steps, ip);
              outMem[outMemPos] = localMem[491];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 1106;
      end

       1106 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1107;
      end

       1107 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[492] = heapMem[localMem[481]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1108;
      end

       1108 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[493] = !heapMem[localMem[492]*10 + 6];
              ip = 1109;
      end

       1109 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[493] == 0 ? 1149 : 1110;
      end

       1110 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[494] = heapMem[localMem[481]*10 + 2] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1111;
      end

       1111 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[495] = heapMem[localMem[492]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1112;
      end

       1112 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[494] >= localMem[495] ? 1117 : 1113;
      end

       1113 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[481]*10 + 0] = localMem[492];
              updateArrayLength(1, localMem[481], 0);
              ip = 1114;
      end

       1114 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[481]*10 + 1] = 1;
              updateArrayLength(1, localMem[481], 1);
              ip = 1115;
      end

       1115 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[481]*10 + 2] = localMem[494];
              updateArrayLength(1, localMem[481], 2);
              ip = 1116;
      end

       1116 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1178;
      end

       1117 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1118;
      end

       1118 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[496] = heapMem[localMem[492]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1119;
      end

       1119 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[496] == 0 ? 1144 : 1120;
      end

       1120 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1121;
      end

       1121 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[497] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1122;
      end

       1122 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1123;
      end

       1123 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[497] >= 99 ? 1143 : 1124;
      end

       1124 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[498] = heapMem[localMem[496]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1125;
      end

       1125 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 1126;
      end

       1126 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[499] = heapMem[localMem[496]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1127;
      end

       1127 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[500] = 0; k = arraySizes[localMem[499]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[499] * NArea + i] == localMem[492]) localMem[500] = i + 1;
              end
              ip = 1128;
      end

       1128 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[500] = localMem[500] - 1;
              updateArrayLength(2, 0, 0);
              ip = 1129;
      end

       1129 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[500] != localMem[498] ? 1134 : 1130;
      end

       1130 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[492] = localMem[496];
              updateArrayLength(2, 0, 0);
              ip = 1131;
      end

       1131 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[496] = heapMem[localMem[492]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1132;
      end

       1132 :
      begin                                                                     // jFalse
//$display("AAAA %4d %4d jFalse", steps, ip);
              ip = localMem[496] == 0 ? 1143 : 1133;
      end

       1133 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1139;
      end

       1134 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1135;
      end

       1135 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[481]*10 + 0] = localMem[496];
              updateArrayLength(1, localMem[481], 0);
              ip = 1136;
      end

       1136 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[481]*10 + 1] = 1;
              updateArrayLength(1, localMem[481], 1);
              ip = 1137;
      end

       1137 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[481]*10 + 2] = localMem[500];
              updateArrayLength(1, localMem[481], 2);
              ip = 1138;
      end

       1138 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1178;
      end

       1139 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1140;
      end

       1140 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1141;
      end

       1141 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[497] = localMem[497] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1142;
      end

       1142 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1122;
      end

       1143 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1144;
      end

       1144 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1145;
      end

       1145 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[481]*10 + 0] = localMem[492];
              updateArrayLength(1, localMem[481], 0);
              ip = 1146;
      end

       1146 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[481]*10 + 1] = 3;
              updateArrayLength(1, localMem[481], 1);
              ip = 1147;
      end

       1147 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[481]*10 + 2] = 0;
              updateArrayLength(1, localMem[481], 2);
              ip = 1148;
      end

       1148 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1178;
      end

       1149 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1150;
      end

       1150 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[501] = heapMem[localMem[481]*10 + 2] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1151;
      end

       1151 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[502] = heapMem[localMem[492]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1152;
      end

       1152 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[503] = heapMem[localMem[502]*10 + localMem[501]];
              updateArrayLength(2, 0, 0);
              ip = 1153;
      end

       1153 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[503] != 0 ? 1158 : 1154;
      end

       1154 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[481]*10 + 0] = localMem[503];
              updateArrayLength(1, localMem[481], 0);
              ip = 1155;
      end

       1155 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[481]*10 + 1] = 3;
              updateArrayLength(1, localMem[481], 1);
              ip = 1156;
      end

       1156 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[481]*10 + 2] = 0;
              updateArrayLength(1, localMem[481], 2);
              ip = 1157;
      end

       1157 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1175;
      end

       1158 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1159;
      end

       1159 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1160;
      end

       1160 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[504] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1161;
      end

       1161 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1162;
      end

       1162 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[504] >= 99 ? 1171 : 1163;
      end

       1163 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[505] = !heapMem[localMem[503]*10 + 6];
              ip = 1164;
      end

       1164 :
      begin                                                                     // jTrue
//$display("AAAA %4d %4d jTrue", steps, ip);
              ip = localMem[505] != 0 ? 1171 : 1165;
      end

       1165 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[506] = heapMem[localMem[503]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1166;
      end

       1166 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[507] = heapMem[localMem[506]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1167;
      end

       1167 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[503] = localMem[507];
              updateArrayLength(2, 0, 0);
              ip = 1168;
      end

       1168 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1169;
      end

       1169 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[504] = localMem[504] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1170;
      end

       1170 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1161;
      end

       1171 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1172;
      end

       1172 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[481]*10 + 0] = localMem[503];
              updateArrayLength(1, localMem[481], 0);
              ip = 1173;
      end

       1173 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[481]*10 + 1] = 1;
              updateArrayLength(1, localMem[481], 1);
              ip = 1174;
      end

       1174 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[481]*10 + 2] = 0;
              updateArrayLength(1, localMem[481], 2);
              ip = 1175;
      end

       1175 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
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
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1097;
      end

       1180 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1181;
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
      begin                                                                     // free
//$display("AAAA %4d %4d free", steps, ip);
                                 arraySizes[localMem[481]] = 0;
              freedArrays[freedArraysTop] = localMem[481];
              freedArraysTop = freedArraysTop + 1;
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
      default: begin
        success  = 1;
        success  = success && outMem[0] == 0;
        success  = success && outMem[1] == 1;
        success  = success && outMem[2] == 2;
        success  = success && outMem[3] == 3;
        success  = success && outMem[4] == 4;
        success  = success && outMem[5] == 5;
        success  = success && outMem[6] == 6;
        success  = success && outMem[7] == 7;
        success  = success && outMem[8] == 8;
        success  = success && outMem[9] == 9;
        finished = 1;
      end
    endcase
    if (steps <=   1729) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
//for(i = 0; i < 200; ++i) $write("%2d",   localMem[i]); $display("");
//for(i = 0; i < 200; ++i) $write("%2d",    heapMem[i]); $display("");
//for(i = 0; i < 200; ++i) $write("%2d", arraySizes[i]); $display("");
  end
endmodule
