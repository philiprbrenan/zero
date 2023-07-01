//-----------------------------------------------------------------------------
// Fpga test
// Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
//------------------------------------------------------------------------------
module fpga                                                                     // Run test programs
 (input  wire run,                                                              // Run - clock at lest once to allow code to be loaded
  output reg  finished,                                                         // Goes high when the program has finished
  output reg  success);                                                         // Goes high on finish if all the tests passed

  parameter integer MemoryElementWidth =  12;                                   // Memory element width

  parameter integer NArea   =        7;                                         // Size of each area on the heap
  parameter integer NArrays =       30;                                         // Maximum number of arrays
  parameter integer NHeap   =      210;                                         // Amount of heap memory
  parameter integer NLocal  =      508;                                         // Size of local memory
  parameter integer NOut    =       10;                                         // Size of output area
  parameter integer NIn     =        10;                                        // Size of input area
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
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[0]*7 + 2] = 3;
              updateArrayLength(1, localMem[0], 2);
              ip = 2;
      end

          2 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[0]*7 + 3] = 0;
              updateArrayLength(1, localMem[0], 3);
              ip = 3;
      end

          3 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[0]*7 + 0] = 0;
              updateArrayLength(1, localMem[0], 0);
              ip = 4;
      end

          4 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[0]*7 + 1] = 0;
              updateArrayLength(1, localMem[0], 1);
              ip = 5;
      end

          5 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 6;
      end

          6 :
      begin                                                                     // inSize
if (0) begin
  $display("AAAA %4d %4d inSize", steps, ip);
end
              localMem[1] = NIn - inMemPos;
              ip = 7;
      end

          7 :
      begin                                                                     // jFalse
if (0) begin
  $display("AAAA %4d %4d jFalse", steps, ip);
end
              ip = localMem[1] == 0 ? 1068 : 8;
      end

          8 :
      begin                                                                     // in
if (0) begin
  $display("AAAA %4d %4d in", steps, ip);
end
              if (inMemPos < NIn) begin
                localMem[2] = inMem[inMemPos];
                inMemPos = inMemPos + 1;
              end
              ip = 9;
      end

          9 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[3] = localMem[2] + localMem[2];
              updateArrayLength(2, 0, 0);
              ip = 10;
      end

         10 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 12;
      end

         12 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[5] = heapMem[localMem[0]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 13;
      end

         13 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[5] != 0 ? 36 : 14;
      end

         14 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[6]*7 + 0] = 1;
              updateArrayLength(1, localMem[6], 0);
              ip = 16;
      end

         16 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[6]*7 + 2] = 0;
              updateArrayLength(1, localMem[6], 2);
              ip = 17;
      end

         17 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[6]*7 + 4] = localMem[7];
              updateArrayLength(1, localMem[6], 4);
              ip = 19;
      end

         19 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[6]*7 + 5] = localMem[8];
              updateArrayLength(1, localMem[6], 5);
              ip = 21;
      end

         21 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[6]*7 + 6] = 0;
              updateArrayLength(1, localMem[6], 6);
              ip = 22;
      end

         22 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[6]*7 + 3] = localMem[0];
              updateArrayLength(1, localMem[6], 3);
              ip = 23;
      end

         23 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[0]*7 + 1] = heapMem[localMem[0]*7 + 1] + 1;
              updateArrayLength(1, localMem[0], 1);
              ip = 24;
      end

         24 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[6]*7 + 1] = heapMem[localMem[0]*7 + 1];
              updateArrayLength(1, localMem[6], 1);
              ip = 25;
      end

         25 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[9] = heapMem[localMem[6]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 26;
      end

         26 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[9]*7 + 0] = localMem[2];
              updateArrayLength(1, localMem[9], 0);
              ip = 27;
      end

         27 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[10] = heapMem[localMem[6]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 28;
      end

         28 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[10]*7 + 0] = localMem[3];
              updateArrayLength(1, localMem[10], 0);
              ip = 29;
      end

         29 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[0]*7 + 0] = heapMem[localMem[0]*7 + 0] + 1;
              updateArrayLength(1, localMem[0], 0);
              ip = 30;
      end

         30 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[0]*7 + 3] = localMem[6];
              updateArrayLength(1, localMem[0], 3);
              ip = 31;
      end

         31 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[11] = heapMem[localMem[6]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 32;
      end

         32 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[11]] = 1;
              ip = 33;
      end

         33 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[12] = heapMem[localMem[6]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 34;
      end

         34 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[12]] = 1;
              ip = 35;
      end

         35 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1064;
      end

         36 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 37;
      end

         37 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[13] = heapMem[localMem[5]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 38;
      end

         38 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[14] = heapMem[localMem[0]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 39;
      end

         39 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[13] >= localMem[14] ? 75 : 40;
      end

         40 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[15] = heapMem[localMem[5]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 41;
      end

         41 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[15] != 0 ? 74 : 42;
      end

         42 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[16] = !heapMem[localMem[5]*7 + 6];
              ip = 43;
      end

         43 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[16] == 0 ? 73 : 44;
      end

         44 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[17] = heapMem[localMem[5]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 45;
      end

         45 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[18] = 0; k = arraySizes[localMem[17]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[17] * NArea + i] == localMem[2]) localMem[18] = i + 1;
              end
              ip = 46;
      end

         46 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[18] == 0 ? 51 : 47;
      end

         47 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[18] = localMem[18] - 1;
              updateArrayLength(2, 0, 0);
              ip = 48;
      end

         48 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[19] = heapMem[localMem[5]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 49;
      end

         49 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[19]*7 + localMem[18]] = localMem[3];
              updateArrayLength(1, localMem[19], localMem[18]);
              ip = 50;
      end

         50 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1064;
      end

         51 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 52;
      end

         52 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[17]] = localMem[13];
              ip = 53;
      end

         53 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[20] = heapMem[localMem[5]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 54;
      end

         54 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[20]] = localMem[13];
              ip = 55;
      end

         55 :
      begin                                                                     // arrayCountGreater
if (0) begin
  $display("AAAA %4d %4d arrayCountGreater", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[21] != 0 ? 64 : 57;
      end

         57 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[22] = heapMem[localMem[5]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 58;
      end

         58 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[22]*7 + localMem[13]] = localMem[2];
              updateArrayLength(1, localMem[22], localMem[13]);
              ip = 59;
      end

         59 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[23] = heapMem[localMem[5]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 60;
      end

         60 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[23]*7 + localMem[13]] = localMem[3];
              updateArrayLength(1, localMem[23], localMem[13]);
              ip = 61;
      end

         61 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[5]*7 + 0] = localMem[13] + 1;
              updateArrayLength(1, localMem[5], 0);
              ip = 62;
      end

         62 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[0]*7 + 0] = heapMem[localMem[0]*7 + 0] + 1;
              updateArrayLength(1, localMem[0], 0);
              ip = 63;
      end

         63 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1064;
      end

         64 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 65;
      end

         65 :
      begin                                                                     // arrayCountLess
if (0) begin
  $display("AAAA %4d %4d arrayCountLess", steps, ip);
end
              j = 0; k = arraySizes[localMem[17]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[17] * NArea + i] < localMem[2]) j = j + 1;
              end
              localMem[24] = j;
              ip = 66;
      end

         66 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[25] = heapMem[localMem[5]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 67;
      end

         67 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[26] = heapMem[localMem[5]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 69;
      end

         69 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[5]*7 + 0] = heapMem[localMem[5]*7 + 0] + 1;
              updateArrayLength(1, localMem[5], 0);
              ip = 71;
      end

         71 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[0]*7 + 0] = heapMem[localMem[0]*7 + 0] + 1;
              updateArrayLength(1, localMem[0], 0);
              ip = 72;
      end

         72 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1064;
      end

         73 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 74;
      end

         74 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 75;
      end

         75 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 76;
      end

         76 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[27] = heapMem[localMem[0]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 77;
      end

         77 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 78;
      end

         78 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[29] = heapMem[localMem[27]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 79;
      end

         79 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[30] = heapMem[localMem[27]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 80;
      end

         80 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[31] = heapMem[localMem[30]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 81;
      end

         81 :
      begin                                                                     // jLt
if (0) begin
  $display("AAAA %4d %4d jLt", steps, ip);
end
              ip = localMem[29] <  localMem[31] ? 301 : 82;
      end

         82 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[32] = localMem[31];
              updateArrayLength(2, 0, 0);
              ip = 83;
      end

         83 :
      begin                                                                     // shiftRight
if (0) begin
  $display("AAAA %4d %4d shiftRight", steps, ip);
end
              localMem[32] = localMem[32] >> 1;
              ip = 84;
      end

         84 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[33] = localMem[32] + 1;
              updateArrayLength(2, 0, 0);
              ip = 85;
      end

         85 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[34] = heapMem[localMem[27]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 86;
      end

         86 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[34] == 0 ? 183 : 87;
      end

         87 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[35]*7 + 0] = localMem[32];
              updateArrayLength(1, localMem[35], 0);
              ip = 89;
      end

         89 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[35]*7 + 2] = 0;
              updateArrayLength(1, localMem[35], 2);
              ip = 90;
      end

         90 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[35]*7 + 4] = localMem[36];
              updateArrayLength(1, localMem[35], 4);
              ip = 92;
      end

         92 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[35]*7 + 5] = localMem[37];
              updateArrayLength(1, localMem[35], 5);
              ip = 94;
      end

         94 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[35]*7 + 6] = 0;
              updateArrayLength(1, localMem[35], 6);
              ip = 95;
      end

         95 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[35]*7 + 3] = localMem[30];
              updateArrayLength(1, localMem[35], 3);
              ip = 96;
      end

         96 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[30]*7 + 1] = heapMem[localMem[30]*7 + 1] + 1;
              updateArrayLength(1, localMem[30], 1);
              ip = 97;
      end

         97 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[35]*7 + 1] = heapMem[localMem[30]*7 + 1];
              updateArrayLength(1, localMem[35], 1);
              ip = 98;
      end

         98 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[38] = !heapMem[localMem[27]*7 + 6];
              ip = 99;
      end

         99 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[38] != 0 ? 128 : 100;
      end

        100 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[35]*7 + 6] = localMem[39];
              updateArrayLength(1, localMem[35], 6);
              ip = 102;
      end

        102 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[40] = heapMem[localMem[27]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 103;
      end

        103 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[41] = heapMem[localMem[35]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 104;
      end

        104 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[42] = heapMem[localMem[27]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 106;
      end

        106 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[43] = heapMem[localMem[35]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 107;
      end

        107 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[44] = heapMem[localMem[27]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 109;
      end

        109 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[45] = heapMem[localMem[35]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 110;
      end

        110 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[46] = localMem[32] + 1;
              updateArrayLength(2, 0, 0);
              ip = 111;
      end

        111 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[47] = heapMem[localMem[35]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 113;
      end

        113 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[48] = localMem[47] + 1;
              updateArrayLength(2, 0, 0);
              ip = 114;
      end

        114 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[49] = heapMem[localMem[35]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 115;
      end

        115 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 116;
      end

        116 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[50] = 0;
              updateArrayLength(2, 0, 0);
              ip = 117;
      end

        117 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 118;
      end

        118 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[50] >= localMem[48] ? 124 : 119;
      end

        119 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[51] = heapMem[localMem[49]*7 + localMem[50]];
              updateArrayLength(2, 0, 0);
              ip = 120;
      end

        120 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[51]*7 + 2] = localMem[35];
              updateArrayLength(1, localMem[51], 2);
              ip = 121;
      end

        121 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 122;
      end

        122 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[50] = localMem[50] + 1;
              updateArrayLength(2, 0, 0);
              ip = 123;
      end

        123 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 117;
      end

        124 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 125;
      end

        125 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[52] = heapMem[localMem[27]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 126;
      end

        126 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[52]] = localMem[33];
              ip = 127;
      end

        127 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 135;
      end

        128 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 129;
      end

        129 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[53] = heapMem[localMem[27]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 130;
      end

        130 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[54] = heapMem[localMem[35]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 131;
      end

        131 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[55] = heapMem[localMem[27]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 133;
      end

        133 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[56] = heapMem[localMem[35]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 134;
      end

        134 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 136;
      end

        136 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[27]*7 + 0] = localMem[32];
              updateArrayLength(1, localMem[27], 0);
              ip = 137;
      end

        137 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[35]*7 + 2] = localMem[34];
              updateArrayLength(1, localMem[35], 2);
              ip = 138;
      end

        138 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[57] = heapMem[localMem[34]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 139;
      end

        139 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[58] = heapMem[localMem[34]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 140;
      end

        140 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[59] = heapMem[localMem[58]*7 + localMem[57]];
              updateArrayLength(2, 0, 0);
              ip = 141;
      end

        141 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[59] != localMem[27] ? 160 : 142;
      end

        142 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[60] = heapMem[localMem[27]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 143;
      end

        143 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[61] = heapMem[localMem[60]*7 + localMem[32]];
              updateArrayLength(2, 0, 0);
              ip = 144;
      end

        144 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[62] = heapMem[localMem[34]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 145;
      end

        145 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[62]*7 + localMem[57]] = localMem[61];
              updateArrayLength(1, localMem[62], localMem[57]);
              ip = 146;
      end

        146 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[63] = heapMem[localMem[27]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 147;
      end

        147 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[64] = heapMem[localMem[63]*7 + localMem[32]];
              updateArrayLength(2, 0, 0);
              ip = 148;
      end

        148 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[65] = heapMem[localMem[34]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 149;
      end

        149 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[65]*7 + localMem[57]] = localMem[64];
              updateArrayLength(1, localMem[65], localMem[57]);
              ip = 150;
      end

        150 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[66] = heapMem[localMem[27]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 151;
      end

        151 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[66]] = localMem[32];
              ip = 152;
      end

        152 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[67] = heapMem[localMem[27]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 153;
      end

        153 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[67]] = localMem[32];
              ip = 154;
      end

        154 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[68] = localMem[57] + 1;
              updateArrayLength(2, 0, 0);
              ip = 155;
      end

        155 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[34]*7 + 0] = localMem[68];
              updateArrayLength(1, localMem[34], 0);
              ip = 156;
      end

        156 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[69] = heapMem[localMem[34]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 157;
      end

        157 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[69]*7 + localMem[68]] = localMem[35];
              updateArrayLength(1, localMem[69], localMem[68]);
              ip = 158;
      end

        158 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 298;
      end

        159 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 182;
      end

        160 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 161;
      end

        161 :
      begin                                                                     // assertNe
if (0) begin
  $display("AAAA %4d %4d assertNe", steps, ip);
end
            ip = 162;
      end

        162 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[70] = heapMem[localMem[34]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 163;
      end

        163 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[71] = 0; k = arraySizes[localMem[70]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[70] * NArea + i] == localMem[27]) localMem[71] = i + 1;
              end
              ip = 164;
      end

        164 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[71] = localMem[71] - 1;
              updateArrayLength(2, 0, 0);
              ip = 165;
      end

        165 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[72] = heapMem[localMem[27]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 166;
      end

        166 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[73] = heapMem[localMem[72]*7 + localMem[32]];
              updateArrayLength(2, 0, 0);
              ip = 167;
      end

        167 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[74] = heapMem[localMem[27]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 168;
      end

        168 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[75] = heapMem[localMem[74]*7 + localMem[32]];
              updateArrayLength(2, 0, 0);
              ip = 169;
      end

        169 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[76] = heapMem[localMem[27]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 170;
      end

        170 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[76]] = localMem[32];
              ip = 171;
      end

        171 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[77] = heapMem[localMem[27]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 172;
      end

        172 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[77]] = localMem[32];
              ip = 173;
      end

        173 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[78] = heapMem[localMem[34]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 174;
      end

        174 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[79] = heapMem[localMem[34]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 176;
      end

        176 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[80] = heapMem[localMem[34]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 178;
      end

        178 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[81] = localMem[71] + 1;
              updateArrayLength(2, 0, 0);
              ip = 179;
      end

        179 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[34]*7 + 0] = heapMem[localMem[34]*7 + 0] + 1;
              updateArrayLength(1, localMem[34], 0);
              ip = 181;
      end

        181 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 298;
      end

        182 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 183;
      end

        183 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 184;
      end

        184 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[82]*7 + 0] = localMem[32];
              updateArrayLength(1, localMem[82], 0);
              ip = 186;
      end

        186 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[82]*7 + 2] = 0;
              updateArrayLength(1, localMem[82], 2);
              ip = 187;
      end

        187 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[82]*7 + 4] = localMem[83];
              updateArrayLength(1, localMem[82], 4);
              ip = 189;
      end

        189 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[82]*7 + 5] = localMem[84];
              updateArrayLength(1, localMem[82], 5);
              ip = 191;
      end

        191 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[82]*7 + 6] = 0;
              updateArrayLength(1, localMem[82], 6);
              ip = 192;
      end

        192 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[82]*7 + 3] = localMem[30];
              updateArrayLength(1, localMem[82], 3);
              ip = 193;
      end

        193 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[30]*7 + 1] = heapMem[localMem[30]*7 + 1] + 1;
              updateArrayLength(1, localMem[30], 1);
              ip = 194;
      end

        194 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[82]*7 + 1] = heapMem[localMem[30]*7 + 1];
              updateArrayLength(1, localMem[82], 1);
              ip = 195;
      end

        195 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[85]*7 + 0] = localMem[32];
              updateArrayLength(1, localMem[85], 0);
              ip = 197;
      end

        197 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[85]*7 + 2] = 0;
              updateArrayLength(1, localMem[85], 2);
              ip = 198;
      end

        198 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[85]*7 + 4] = localMem[86];
              updateArrayLength(1, localMem[85], 4);
              ip = 200;
      end

        200 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[85]*7 + 5] = localMem[87];
              updateArrayLength(1, localMem[85], 5);
              ip = 202;
      end

        202 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[85]*7 + 6] = 0;
              updateArrayLength(1, localMem[85], 6);
              ip = 203;
      end

        203 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[85]*7 + 3] = localMem[30];
              updateArrayLength(1, localMem[85], 3);
              ip = 204;
      end

        204 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[30]*7 + 1] = heapMem[localMem[30]*7 + 1] + 1;
              updateArrayLength(1, localMem[30], 1);
              ip = 205;
      end

        205 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[85]*7 + 1] = heapMem[localMem[30]*7 + 1];
              updateArrayLength(1, localMem[85], 1);
              ip = 206;
      end

        206 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[88] = !heapMem[localMem[27]*7 + 6];
              ip = 207;
      end

        207 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[88] != 0 ? 259 : 208;
      end

        208 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[82]*7 + 6] = localMem[89];
              updateArrayLength(1, localMem[82], 6);
              ip = 210;
      end

        210 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[85]*7 + 6] = localMem[90];
              updateArrayLength(1, localMem[85], 6);
              ip = 212;
      end

        212 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[91] = heapMem[localMem[27]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 213;
      end

        213 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[92] = heapMem[localMem[82]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 214;
      end

        214 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[93] = heapMem[localMem[27]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 216;
      end

        216 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[94] = heapMem[localMem[82]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 217;
      end

        217 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[95] = heapMem[localMem[27]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 219;
      end

        219 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[96] = heapMem[localMem[82]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 220;
      end

        220 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[97] = localMem[32] + 1;
              updateArrayLength(2, 0, 0);
              ip = 221;
      end

        221 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[98] = heapMem[localMem[27]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 223;
      end

        223 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[99] = heapMem[localMem[85]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 224;
      end

        224 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[100] = heapMem[localMem[27]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 226;
      end

        226 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[101] = heapMem[localMem[85]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 227;
      end

        227 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[102] = heapMem[localMem[27]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 229;
      end

        229 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[103] = heapMem[localMem[85]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 230;
      end

        230 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[104] = localMem[32] + 1;
              updateArrayLength(2, 0, 0);
              ip = 231;
      end

        231 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[105] = heapMem[localMem[82]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 233;
      end

        233 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[106] = localMem[105] + 1;
              updateArrayLength(2, 0, 0);
              ip = 234;
      end

        234 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[107] = heapMem[localMem[82]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 235;
      end

        235 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 236;
      end

        236 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[108] = 0;
              updateArrayLength(2, 0, 0);
              ip = 237;
      end

        237 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 238;
      end

        238 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[108] >= localMem[106] ? 244 : 239;
      end

        239 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[109] = heapMem[localMem[107]*7 + localMem[108]];
              updateArrayLength(2, 0, 0);
              ip = 240;
      end

        240 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[109]*7 + 2] = localMem[82];
              updateArrayLength(1, localMem[109], 2);
              ip = 241;
      end

        241 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 242;
      end

        242 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[108] = localMem[108] + 1;
              updateArrayLength(2, 0, 0);
              ip = 243;
      end

        243 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 237;
      end

        244 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 245;
      end

        245 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[110] = heapMem[localMem[85]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 246;
      end

        246 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[111] = localMem[110] + 1;
              updateArrayLength(2, 0, 0);
              ip = 247;
      end

        247 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[112] = heapMem[localMem[85]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 248;
      end

        248 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 249;
      end

        249 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[113] = 0;
              updateArrayLength(2, 0, 0);
              ip = 250;
      end

        250 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 251;
      end

        251 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[113] >= localMem[111] ? 257 : 252;
      end

        252 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[114] = heapMem[localMem[112]*7 + localMem[113]];
              updateArrayLength(2, 0, 0);
              ip = 253;
      end

        253 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[114]*7 + 2] = localMem[85];
              updateArrayLength(1, localMem[114], 2);
              ip = 254;
      end

        254 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 255;
      end

        255 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[113] = localMem[113] + 1;
              updateArrayLength(2, 0, 0);
              ip = 256;
      end

        256 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 250;
      end

        257 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 258;
      end

        258 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 274;
      end

        259 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 260;
      end

        260 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[27]*7 + 6] = localMem[115];
              updateArrayLength(1, localMem[27], 6);
              ip = 262;
      end

        262 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[116] = heapMem[localMem[27]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 263;
      end

        263 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[117] = heapMem[localMem[82]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 264;
      end

        264 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[118] = heapMem[localMem[27]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 266;
      end

        266 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[119] = heapMem[localMem[82]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 267;
      end

        267 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[120] = heapMem[localMem[27]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 269;
      end

        269 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[121] = heapMem[localMem[85]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 270;
      end

        270 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[122] = heapMem[localMem[27]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 272;
      end

        272 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[123] = heapMem[localMem[85]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 273;
      end

        273 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 275;
      end

        275 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[82]*7 + 2] = localMem[27];
              updateArrayLength(1, localMem[82], 2);
              ip = 276;
      end

        276 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[85]*7 + 2] = localMem[27];
              updateArrayLength(1, localMem[85], 2);
              ip = 277;
      end

        277 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[124] = heapMem[localMem[27]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 278;
      end

        278 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[125] = heapMem[localMem[124]*7 + localMem[32]];
              updateArrayLength(2, 0, 0);
              ip = 279;
      end

        279 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[126] = heapMem[localMem[27]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 280;
      end

        280 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[127] = heapMem[localMem[126]*7 + localMem[32]];
              updateArrayLength(2, 0, 0);
              ip = 281;
      end

        281 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[128] = heapMem[localMem[27]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 282;
      end

        282 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[128]*7 + 0] = localMem[125];
              updateArrayLength(1, localMem[128], 0);
              ip = 283;
      end

        283 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[129] = heapMem[localMem[27]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 284;
      end

        284 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[129]*7 + 0] = localMem[127];
              updateArrayLength(1, localMem[129], 0);
              ip = 285;
      end

        285 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[130] = heapMem[localMem[27]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 286;
      end

        286 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[130]*7 + 0] = localMem[82];
              updateArrayLength(1, localMem[130], 0);
              ip = 287;
      end

        287 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[131] = heapMem[localMem[27]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 288;
      end

        288 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[131]*7 + 1] = localMem[85];
              updateArrayLength(1, localMem[131], 1);
              ip = 289;
      end

        289 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[27]*7 + 0] = 1;
              updateArrayLength(1, localMem[27], 0);
              ip = 290;
      end

        290 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[132] = heapMem[localMem[27]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 291;
      end

        291 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[132]] = 1;
              ip = 292;
      end

        292 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[133] = heapMem[localMem[27]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 293;
      end

        293 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[133]] = 1;
              ip = 294;
      end

        294 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[134] = heapMem[localMem[27]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 295;
      end

        295 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[134]] = 2;
              ip = 296;
      end

        296 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 298;
      end

        297 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 303;
      end

        298 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 299;
      end

        299 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[28] = 1;
              updateArrayLength(2, 0, 0);
              ip = 300;
      end

        300 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 303;
      end

        301 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 302;
      end

        302 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[28] = 0;
              updateArrayLength(2, 0, 0);
              ip = 303;
      end

        303 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 304;
      end

        304 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 305;
      end

        305 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 306;
      end

        306 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[135] = 0;
              updateArrayLength(2, 0, 0);
              ip = 307;
      end

        307 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 308;
      end

        308 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[135] >= 99 ? 806 : 309;
      end

        309 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[136] = heapMem[localMem[27]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 310;
      end

        310 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[137] = localMem[136] - 1;
              updateArrayLength(2, 0, 0);
              ip = 311;
      end

        311 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[138] = heapMem[localMem[27]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 312;
      end

        312 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[139] = heapMem[localMem[138]*7 + localMem[137]];
              updateArrayLength(2, 0, 0);
              ip = 313;
      end

        313 :
      begin                                                                     // jLe
if (0) begin
  $display("AAAA %4d %4d jLe", steps, ip);
end
              ip = localMem[2] <= localMem[139] ? 554 : 314;
      end

        314 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[140] = !heapMem[localMem[27]*7 + 6];
              ip = 315;
      end

        315 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[140] == 0 ? 320 : 316;
      end

        316 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[4]*7 + 0] = localMem[27];
              updateArrayLength(1, localMem[4], 0);
              ip = 317;
      end

        317 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[4]*7 + 1] = 2;
              updateArrayLength(1, localMem[4], 1);
              ip = 318;
      end

        318 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              heapMem[localMem[4]*7 + 2] = localMem[136] - 1;
              updateArrayLength(1, localMem[4], 2);
              ip = 319;
      end

        319 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 810;
      end

        320 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 321;
      end

        321 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[141] = heapMem[localMem[27]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 322;
      end

        322 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[142] = heapMem[localMem[141]*7 + localMem[136]];
              updateArrayLength(2, 0, 0);
              ip = 323;
      end

        323 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 324;
      end

        324 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[144] = heapMem[localMem[142]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 325;
      end

        325 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[145] = heapMem[localMem[142]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 326;
      end

        326 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[146] = heapMem[localMem[145]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 327;
      end

        327 :
      begin                                                                     // jLt
if (0) begin
  $display("AAAA %4d %4d jLt", steps, ip);
end
              ip = localMem[144] <  localMem[146] ? 547 : 328;
      end

        328 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[147] = localMem[146];
              updateArrayLength(2, 0, 0);
              ip = 329;
      end

        329 :
      begin                                                                     // shiftRight
if (0) begin
  $display("AAAA %4d %4d shiftRight", steps, ip);
end
              localMem[147] = localMem[147] >> 1;
              ip = 330;
      end

        330 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[148] = localMem[147] + 1;
              updateArrayLength(2, 0, 0);
              ip = 331;
      end

        331 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[149] = heapMem[localMem[142]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 332;
      end

        332 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[149] == 0 ? 429 : 333;
      end

        333 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[150]*7 + 0] = localMem[147];
              updateArrayLength(1, localMem[150], 0);
              ip = 335;
      end

        335 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[150]*7 + 2] = 0;
              updateArrayLength(1, localMem[150], 2);
              ip = 336;
      end

        336 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[150]*7 + 4] = localMem[151];
              updateArrayLength(1, localMem[150], 4);
              ip = 338;
      end

        338 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[150]*7 + 5] = localMem[152];
              updateArrayLength(1, localMem[150], 5);
              ip = 340;
      end

        340 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[150]*7 + 6] = 0;
              updateArrayLength(1, localMem[150], 6);
              ip = 341;
      end

        341 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[150]*7 + 3] = localMem[145];
              updateArrayLength(1, localMem[150], 3);
              ip = 342;
      end

        342 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[145]*7 + 1] = heapMem[localMem[145]*7 + 1] + 1;
              updateArrayLength(1, localMem[145], 1);
              ip = 343;
      end

        343 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[150]*7 + 1] = heapMem[localMem[145]*7 + 1];
              updateArrayLength(1, localMem[150], 1);
              ip = 344;
      end

        344 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[153] = !heapMem[localMem[142]*7 + 6];
              ip = 345;
      end

        345 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[153] != 0 ? 374 : 346;
      end

        346 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[150]*7 + 6] = localMem[154];
              updateArrayLength(1, localMem[150], 6);
              ip = 348;
      end

        348 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[155] = heapMem[localMem[142]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 349;
      end

        349 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[156] = heapMem[localMem[150]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 350;
      end

        350 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[157] = heapMem[localMem[142]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 352;
      end

        352 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[158] = heapMem[localMem[150]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 353;
      end

        353 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[159] = heapMem[localMem[142]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 355;
      end

        355 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[160] = heapMem[localMem[150]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 356;
      end

        356 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[161] = localMem[147] + 1;
              updateArrayLength(2, 0, 0);
              ip = 357;
      end

        357 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[162] = heapMem[localMem[150]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 359;
      end

        359 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[163] = localMem[162] + 1;
              updateArrayLength(2, 0, 0);
              ip = 360;
      end

        360 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[164] = heapMem[localMem[150]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 361;
      end

        361 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 362;
      end

        362 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[165] = 0;
              updateArrayLength(2, 0, 0);
              ip = 363;
      end

        363 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 364;
      end

        364 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[165] >= localMem[163] ? 370 : 365;
      end

        365 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[166] = heapMem[localMem[164]*7 + localMem[165]];
              updateArrayLength(2, 0, 0);
              ip = 366;
      end

        366 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[166]*7 + 2] = localMem[150];
              updateArrayLength(1, localMem[166], 2);
              ip = 367;
      end

        367 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 368;
      end

        368 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[165] = localMem[165] + 1;
              updateArrayLength(2, 0, 0);
              ip = 369;
      end

        369 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 363;
      end

        370 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 371;
      end

        371 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[167] = heapMem[localMem[142]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 372;
      end

        372 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[167]] = localMem[148];
              ip = 373;
      end

        373 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 381;
      end

        374 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 375;
      end

        375 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[168] = heapMem[localMem[142]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 376;
      end

        376 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[169] = heapMem[localMem[150]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 377;
      end

        377 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[170] = heapMem[localMem[142]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 379;
      end

        379 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[171] = heapMem[localMem[150]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 380;
      end

        380 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 382;
      end

        382 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[142]*7 + 0] = localMem[147];
              updateArrayLength(1, localMem[142], 0);
              ip = 383;
      end

        383 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[150]*7 + 2] = localMem[149];
              updateArrayLength(1, localMem[150], 2);
              ip = 384;
      end

        384 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[172] = heapMem[localMem[149]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 385;
      end

        385 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[173] = heapMem[localMem[149]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 386;
      end

        386 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[174] = heapMem[localMem[173]*7 + localMem[172]];
              updateArrayLength(2, 0, 0);
              ip = 387;
      end

        387 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[174] != localMem[142] ? 406 : 388;
      end

        388 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[175] = heapMem[localMem[142]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 389;
      end

        389 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[176] = heapMem[localMem[175]*7 + localMem[147]];
              updateArrayLength(2, 0, 0);
              ip = 390;
      end

        390 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[177] = heapMem[localMem[149]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 391;
      end

        391 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[177]*7 + localMem[172]] = localMem[176];
              updateArrayLength(1, localMem[177], localMem[172]);
              ip = 392;
      end

        392 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[178] = heapMem[localMem[142]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 393;
      end

        393 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[179] = heapMem[localMem[178]*7 + localMem[147]];
              updateArrayLength(2, 0, 0);
              ip = 394;
      end

        394 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[180] = heapMem[localMem[149]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 395;
      end

        395 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[180]*7 + localMem[172]] = localMem[179];
              updateArrayLength(1, localMem[180], localMem[172]);
              ip = 396;
      end

        396 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[181] = heapMem[localMem[142]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 397;
      end

        397 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[181]] = localMem[147];
              ip = 398;
      end

        398 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[182] = heapMem[localMem[142]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 399;
      end

        399 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[182]] = localMem[147];
              ip = 400;
      end

        400 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[183] = localMem[172] + 1;
              updateArrayLength(2, 0, 0);
              ip = 401;
      end

        401 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[149]*7 + 0] = localMem[183];
              updateArrayLength(1, localMem[149], 0);
              ip = 402;
      end

        402 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[184] = heapMem[localMem[149]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 403;
      end

        403 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[184]*7 + localMem[183]] = localMem[150];
              updateArrayLength(1, localMem[184], localMem[183]);
              ip = 404;
      end

        404 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 544;
      end

        405 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 428;
      end

        406 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 407;
      end

        407 :
      begin                                                                     // assertNe
if (0) begin
  $display("AAAA %4d %4d assertNe", steps, ip);
end
            ip = 408;
      end

        408 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[185] = heapMem[localMem[149]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 409;
      end

        409 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[186] = 0; k = arraySizes[localMem[185]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[185] * NArea + i] == localMem[142]) localMem[186] = i + 1;
              end
              ip = 410;
      end

        410 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[186] = localMem[186] - 1;
              updateArrayLength(2, 0, 0);
              ip = 411;
      end

        411 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[187] = heapMem[localMem[142]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 412;
      end

        412 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[188] = heapMem[localMem[187]*7 + localMem[147]];
              updateArrayLength(2, 0, 0);
              ip = 413;
      end

        413 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[189] = heapMem[localMem[142]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 414;
      end

        414 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[190] = heapMem[localMem[189]*7 + localMem[147]];
              updateArrayLength(2, 0, 0);
              ip = 415;
      end

        415 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[191] = heapMem[localMem[142]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 416;
      end

        416 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[191]] = localMem[147];
              ip = 417;
      end

        417 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[192] = heapMem[localMem[142]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 418;
      end

        418 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[192]] = localMem[147];
              ip = 419;
      end

        419 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[193] = heapMem[localMem[149]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 420;
      end

        420 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[194] = heapMem[localMem[149]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 422;
      end

        422 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[195] = heapMem[localMem[149]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 424;
      end

        424 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[196] = localMem[186] + 1;
              updateArrayLength(2, 0, 0);
              ip = 425;
      end

        425 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[149]*7 + 0] = heapMem[localMem[149]*7 + 0] + 1;
              updateArrayLength(1, localMem[149], 0);
              ip = 427;
      end

        427 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 544;
      end

        428 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 429;
      end

        429 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 430;
      end

        430 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[197]*7 + 0] = localMem[147];
              updateArrayLength(1, localMem[197], 0);
              ip = 432;
      end

        432 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[197]*7 + 2] = 0;
              updateArrayLength(1, localMem[197], 2);
              ip = 433;
      end

        433 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[197]*7 + 4] = localMem[198];
              updateArrayLength(1, localMem[197], 4);
              ip = 435;
      end

        435 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[197]*7 + 5] = localMem[199];
              updateArrayLength(1, localMem[197], 5);
              ip = 437;
      end

        437 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[197]*7 + 6] = 0;
              updateArrayLength(1, localMem[197], 6);
              ip = 438;
      end

        438 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[197]*7 + 3] = localMem[145];
              updateArrayLength(1, localMem[197], 3);
              ip = 439;
      end

        439 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[145]*7 + 1] = heapMem[localMem[145]*7 + 1] + 1;
              updateArrayLength(1, localMem[145], 1);
              ip = 440;
      end

        440 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[197]*7 + 1] = heapMem[localMem[145]*7 + 1];
              updateArrayLength(1, localMem[197], 1);
              ip = 441;
      end

        441 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[200]*7 + 0] = localMem[147];
              updateArrayLength(1, localMem[200], 0);
              ip = 443;
      end

        443 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[200]*7 + 2] = 0;
              updateArrayLength(1, localMem[200], 2);
              ip = 444;
      end

        444 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[200]*7 + 4] = localMem[201];
              updateArrayLength(1, localMem[200], 4);
              ip = 446;
      end

        446 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[200]*7 + 5] = localMem[202];
              updateArrayLength(1, localMem[200], 5);
              ip = 448;
      end

        448 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[200]*7 + 6] = 0;
              updateArrayLength(1, localMem[200], 6);
              ip = 449;
      end

        449 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[200]*7 + 3] = localMem[145];
              updateArrayLength(1, localMem[200], 3);
              ip = 450;
      end

        450 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[145]*7 + 1] = heapMem[localMem[145]*7 + 1] + 1;
              updateArrayLength(1, localMem[145], 1);
              ip = 451;
      end

        451 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[200]*7 + 1] = heapMem[localMem[145]*7 + 1];
              updateArrayLength(1, localMem[200], 1);
              ip = 452;
      end

        452 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[203] = !heapMem[localMem[142]*7 + 6];
              ip = 453;
      end

        453 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[203] != 0 ? 505 : 454;
      end

        454 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[197]*7 + 6] = localMem[204];
              updateArrayLength(1, localMem[197], 6);
              ip = 456;
      end

        456 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[200]*7 + 6] = localMem[205];
              updateArrayLength(1, localMem[200], 6);
              ip = 458;
      end

        458 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[206] = heapMem[localMem[142]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 459;
      end

        459 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[207] = heapMem[localMem[197]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 460;
      end

        460 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[208] = heapMem[localMem[142]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 462;
      end

        462 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[209] = heapMem[localMem[197]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 463;
      end

        463 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[210] = heapMem[localMem[142]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 465;
      end

        465 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[211] = heapMem[localMem[197]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 466;
      end

        466 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[212] = localMem[147] + 1;
              updateArrayLength(2, 0, 0);
              ip = 467;
      end

        467 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[213] = heapMem[localMem[142]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 469;
      end

        469 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[214] = heapMem[localMem[200]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 470;
      end

        470 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[215] = heapMem[localMem[142]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 472;
      end

        472 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[216] = heapMem[localMem[200]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 473;
      end

        473 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[217] = heapMem[localMem[142]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 475;
      end

        475 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[218] = heapMem[localMem[200]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 476;
      end

        476 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[219] = localMem[147] + 1;
              updateArrayLength(2, 0, 0);
              ip = 477;
      end

        477 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[220] = heapMem[localMem[197]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 479;
      end

        479 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[221] = localMem[220] + 1;
              updateArrayLength(2, 0, 0);
              ip = 480;
      end

        480 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[222] = heapMem[localMem[197]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 481;
      end

        481 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 482;
      end

        482 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[223] = 0;
              updateArrayLength(2, 0, 0);
              ip = 483;
      end

        483 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 484;
      end

        484 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[223] >= localMem[221] ? 490 : 485;
      end

        485 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[224] = heapMem[localMem[222]*7 + localMem[223]];
              updateArrayLength(2, 0, 0);
              ip = 486;
      end

        486 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[224]*7 + 2] = localMem[197];
              updateArrayLength(1, localMem[224], 2);
              ip = 487;
      end

        487 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 488;
      end

        488 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[223] = localMem[223] + 1;
              updateArrayLength(2, 0, 0);
              ip = 489;
      end

        489 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 483;
      end

        490 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 491;
      end

        491 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[225] = heapMem[localMem[200]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 492;
      end

        492 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[226] = localMem[225] + 1;
              updateArrayLength(2, 0, 0);
              ip = 493;
      end

        493 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[227] = heapMem[localMem[200]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 494;
      end

        494 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 495;
      end

        495 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[228] = 0;
              updateArrayLength(2, 0, 0);
              ip = 496;
      end

        496 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 497;
      end

        497 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[228] >= localMem[226] ? 503 : 498;
      end

        498 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[229] = heapMem[localMem[227]*7 + localMem[228]];
              updateArrayLength(2, 0, 0);
              ip = 499;
      end

        499 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[229]*7 + 2] = localMem[200];
              updateArrayLength(1, localMem[229], 2);
              ip = 500;
      end

        500 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 501;
      end

        501 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[228] = localMem[228] + 1;
              updateArrayLength(2, 0, 0);
              ip = 502;
      end

        502 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 496;
      end

        503 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 504;
      end

        504 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 520;
      end

        505 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 506;
      end

        506 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[142]*7 + 6] = localMem[230];
              updateArrayLength(1, localMem[142], 6);
              ip = 508;
      end

        508 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[231] = heapMem[localMem[142]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 509;
      end

        509 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[232] = heapMem[localMem[197]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 510;
      end

        510 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[233] = heapMem[localMem[142]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 512;
      end

        512 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[234] = heapMem[localMem[197]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 513;
      end

        513 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[235] = heapMem[localMem[142]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 515;
      end

        515 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[236] = heapMem[localMem[200]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 516;
      end

        516 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[237] = heapMem[localMem[142]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 518;
      end

        518 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[238] = heapMem[localMem[200]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 519;
      end

        519 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 521;
      end

        521 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[197]*7 + 2] = localMem[142];
              updateArrayLength(1, localMem[197], 2);
              ip = 522;
      end

        522 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[200]*7 + 2] = localMem[142];
              updateArrayLength(1, localMem[200], 2);
              ip = 523;
      end

        523 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[239] = heapMem[localMem[142]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 524;
      end

        524 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[240] = heapMem[localMem[239]*7 + localMem[147]];
              updateArrayLength(2, 0, 0);
              ip = 525;
      end

        525 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[241] = heapMem[localMem[142]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 526;
      end

        526 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[242] = heapMem[localMem[241]*7 + localMem[147]];
              updateArrayLength(2, 0, 0);
              ip = 527;
      end

        527 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[243] = heapMem[localMem[142]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 528;
      end

        528 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[243]*7 + 0] = localMem[240];
              updateArrayLength(1, localMem[243], 0);
              ip = 529;
      end

        529 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[244] = heapMem[localMem[142]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 530;
      end

        530 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[244]*7 + 0] = localMem[242];
              updateArrayLength(1, localMem[244], 0);
              ip = 531;
      end

        531 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[245] = heapMem[localMem[142]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 532;
      end

        532 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[245]*7 + 0] = localMem[197];
              updateArrayLength(1, localMem[245], 0);
              ip = 533;
      end

        533 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[246] = heapMem[localMem[142]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 534;
      end

        534 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[246]*7 + 1] = localMem[200];
              updateArrayLength(1, localMem[246], 1);
              ip = 535;
      end

        535 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[142]*7 + 0] = 1;
              updateArrayLength(1, localMem[142], 0);
              ip = 536;
      end

        536 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[247] = heapMem[localMem[142]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 537;
      end

        537 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[247]] = 1;
              ip = 538;
      end

        538 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[248] = heapMem[localMem[142]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 539;
      end

        539 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[248]] = 1;
              ip = 540;
      end

        540 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[249] = heapMem[localMem[142]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 541;
      end

        541 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[249]] = 2;
              ip = 542;
      end

        542 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 544;
      end

        543 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 549;
      end

        544 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 545;
      end

        545 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[143] = 1;
              updateArrayLength(2, 0, 0);
              ip = 546;
      end

        546 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 549;
      end

        547 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 548;
      end

        548 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[143] = 0;
              updateArrayLength(2, 0, 0);
              ip = 549;
      end

        549 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 550;
      end

        550 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[143] != 0 ? 552 : 551;
      end

        551 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[27] = localMem[142];
              updateArrayLength(2, 0, 0);
              ip = 552;
      end

        552 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 553;
      end

        553 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 803;
      end

        554 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 555;
      end

        555 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[250] = heapMem[localMem[27]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 556;
      end

        556 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[251] = 0; k = arraySizes[localMem[250]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[250] * NArea + i] == localMem[2]) localMem[251] = i + 1;
              end
              ip = 557;
      end

        557 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[251] == 0 ? 562 : 558;
      end

        558 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[4]*7 + 0] = localMem[27];
              updateArrayLength(1, localMem[4], 0);
              ip = 559;
      end

        559 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[4]*7 + 1] = 1;
              updateArrayLength(1, localMem[4], 1);
              ip = 560;
      end

        560 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              heapMem[localMem[4]*7 + 2] = localMem[251] - 1;
              updateArrayLength(1, localMem[4], 2);
              ip = 561;
      end

        561 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 810;
      end

        562 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 563;
      end

        563 :
      begin                                                                     // arrayCountLess
if (0) begin
  $display("AAAA %4d %4d arrayCountLess", steps, ip);
end
              j = 0; k = arraySizes[localMem[250]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[250] * NArea + i] < localMem[2]) j = j + 1;
              end
              localMem[252] = j;
              ip = 564;
      end

        564 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[253] = !heapMem[localMem[27]*7 + 6];
              ip = 565;
      end

        565 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[253] == 0 ? 570 : 566;
      end

        566 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[4]*7 + 0] = localMem[27];
              updateArrayLength(1, localMem[4], 0);
              ip = 567;
      end

        567 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[4]*7 + 1] = 0;
              updateArrayLength(1, localMem[4], 1);
              ip = 568;
      end

        568 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[4]*7 + 2] = localMem[252];
              updateArrayLength(1, localMem[4], 2);
              ip = 569;
      end

        569 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 810;
      end

        570 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 571;
      end

        571 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[254] = heapMem[localMem[27]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 572;
      end

        572 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[255] = heapMem[localMem[254]*7 + localMem[252]];
              updateArrayLength(2, 0, 0);
              ip = 573;
      end

        573 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 574;
      end

        574 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[257] = heapMem[localMem[255]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 575;
      end

        575 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[258] = heapMem[localMem[255]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 576;
      end

        576 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[259] = heapMem[localMem[258]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 577;
      end

        577 :
      begin                                                                     // jLt
if (0) begin
  $display("AAAA %4d %4d jLt", steps, ip);
end
              ip = localMem[257] <  localMem[259] ? 797 : 578;
      end

        578 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[260] = localMem[259];
              updateArrayLength(2, 0, 0);
              ip = 579;
      end

        579 :
      begin                                                                     // shiftRight
if (0) begin
  $display("AAAA %4d %4d shiftRight", steps, ip);
end
              localMem[260] = localMem[260] >> 1;
              ip = 580;
      end

        580 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[261] = localMem[260] + 1;
              updateArrayLength(2, 0, 0);
              ip = 581;
      end

        581 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[262] = heapMem[localMem[255]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 582;
      end

        582 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[262] == 0 ? 679 : 583;
      end

        583 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[263]*7 + 0] = localMem[260];
              updateArrayLength(1, localMem[263], 0);
              ip = 585;
      end

        585 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[263]*7 + 2] = 0;
              updateArrayLength(1, localMem[263], 2);
              ip = 586;
      end

        586 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[263]*7 + 4] = localMem[264];
              updateArrayLength(1, localMem[263], 4);
              ip = 588;
      end

        588 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[263]*7 + 5] = localMem[265];
              updateArrayLength(1, localMem[263], 5);
              ip = 590;
      end

        590 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[263]*7 + 6] = 0;
              updateArrayLength(1, localMem[263], 6);
              ip = 591;
      end

        591 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[263]*7 + 3] = localMem[258];
              updateArrayLength(1, localMem[263], 3);
              ip = 592;
      end

        592 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[258]*7 + 1] = heapMem[localMem[258]*7 + 1] + 1;
              updateArrayLength(1, localMem[258], 1);
              ip = 593;
      end

        593 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[263]*7 + 1] = heapMem[localMem[258]*7 + 1];
              updateArrayLength(1, localMem[263], 1);
              ip = 594;
      end

        594 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[266] = !heapMem[localMem[255]*7 + 6];
              ip = 595;
      end

        595 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[266] != 0 ? 624 : 596;
      end

        596 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[263]*7 + 6] = localMem[267];
              updateArrayLength(1, localMem[263], 6);
              ip = 598;
      end

        598 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[268] = heapMem[localMem[255]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 599;
      end

        599 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[269] = heapMem[localMem[263]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 600;
      end

        600 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[270] = heapMem[localMem[255]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 602;
      end

        602 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[271] = heapMem[localMem[263]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 603;
      end

        603 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[272] = heapMem[localMem[255]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 605;
      end

        605 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[273] = heapMem[localMem[263]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 606;
      end

        606 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[274] = localMem[260] + 1;
              updateArrayLength(2, 0, 0);
              ip = 607;
      end

        607 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[275] = heapMem[localMem[263]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 609;
      end

        609 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[276] = localMem[275] + 1;
              updateArrayLength(2, 0, 0);
              ip = 610;
      end

        610 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[277] = heapMem[localMem[263]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 611;
      end

        611 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 612;
      end

        612 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[278] = 0;
              updateArrayLength(2, 0, 0);
              ip = 613;
      end

        613 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 614;
      end

        614 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[278] >= localMem[276] ? 620 : 615;
      end

        615 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[279] = heapMem[localMem[277]*7 + localMem[278]];
              updateArrayLength(2, 0, 0);
              ip = 616;
      end

        616 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[279]*7 + 2] = localMem[263];
              updateArrayLength(1, localMem[279], 2);
              ip = 617;
      end

        617 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 618;
      end

        618 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[278] = localMem[278] + 1;
              updateArrayLength(2, 0, 0);
              ip = 619;
      end

        619 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 613;
      end

        620 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 621;
      end

        621 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[280] = heapMem[localMem[255]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 622;
      end

        622 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[280]] = localMem[261];
              ip = 623;
      end

        623 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 631;
      end

        624 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 625;
      end

        625 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[281] = heapMem[localMem[255]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 626;
      end

        626 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[282] = heapMem[localMem[263]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 627;
      end

        627 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[283] = heapMem[localMem[255]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 629;
      end

        629 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[284] = heapMem[localMem[263]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 630;
      end

        630 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 632;
      end

        632 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[255]*7 + 0] = localMem[260];
              updateArrayLength(1, localMem[255], 0);
              ip = 633;
      end

        633 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[263]*7 + 2] = localMem[262];
              updateArrayLength(1, localMem[263], 2);
              ip = 634;
      end

        634 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[285] = heapMem[localMem[262]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 635;
      end

        635 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[286] = heapMem[localMem[262]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 636;
      end

        636 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[287] = heapMem[localMem[286]*7 + localMem[285]];
              updateArrayLength(2, 0, 0);
              ip = 637;
      end

        637 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[287] != localMem[255] ? 656 : 638;
      end

        638 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[288] = heapMem[localMem[255]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 639;
      end

        639 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[289] = heapMem[localMem[288]*7 + localMem[260]];
              updateArrayLength(2, 0, 0);
              ip = 640;
      end

        640 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[290] = heapMem[localMem[262]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 641;
      end

        641 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[290]*7 + localMem[285]] = localMem[289];
              updateArrayLength(1, localMem[290], localMem[285]);
              ip = 642;
      end

        642 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[291] = heapMem[localMem[255]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 643;
      end

        643 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[292] = heapMem[localMem[291]*7 + localMem[260]];
              updateArrayLength(2, 0, 0);
              ip = 644;
      end

        644 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[293] = heapMem[localMem[262]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 645;
      end

        645 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[293]*7 + localMem[285]] = localMem[292];
              updateArrayLength(1, localMem[293], localMem[285]);
              ip = 646;
      end

        646 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[294] = heapMem[localMem[255]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 647;
      end

        647 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[294]] = localMem[260];
              ip = 648;
      end

        648 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[295] = heapMem[localMem[255]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 649;
      end

        649 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[295]] = localMem[260];
              ip = 650;
      end

        650 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[296] = localMem[285] + 1;
              updateArrayLength(2, 0, 0);
              ip = 651;
      end

        651 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[262]*7 + 0] = localMem[296];
              updateArrayLength(1, localMem[262], 0);
              ip = 652;
      end

        652 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[297] = heapMem[localMem[262]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 653;
      end

        653 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[297]*7 + localMem[296]] = localMem[263];
              updateArrayLength(1, localMem[297], localMem[296]);
              ip = 654;
      end

        654 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 794;
      end

        655 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 678;
      end

        656 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 657;
      end

        657 :
      begin                                                                     // assertNe
if (0) begin
  $display("AAAA %4d %4d assertNe", steps, ip);
end
            ip = 658;
      end

        658 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[298] = heapMem[localMem[262]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 659;
      end

        659 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[299] = 0; k = arraySizes[localMem[298]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[298] * NArea + i] == localMem[255]) localMem[299] = i + 1;
              end
              ip = 660;
      end

        660 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[299] = localMem[299] - 1;
              updateArrayLength(2, 0, 0);
              ip = 661;
      end

        661 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[300] = heapMem[localMem[255]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 662;
      end

        662 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[301] = heapMem[localMem[300]*7 + localMem[260]];
              updateArrayLength(2, 0, 0);
              ip = 663;
      end

        663 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[302] = heapMem[localMem[255]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 664;
      end

        664 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[303] = heapMem[localMem[302]*7 + localMem[260]];
              updateArrayLength(2, 0, 0);
              ip = 665;
      end

        665 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[304] = heapMem[localMem[255]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 666;
      end

        666 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[304]] = localMem[260];
              ip = 667;
      end

        667 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[305] = heapMem[localMem[255]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 668;
      end

        668 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[305]] = localMem[260];
              ip = 669;
      end

        669 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[306] = heapMem[localMem[262]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 670;
      end

        670 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[307] = heapMem[localMem[262]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 672;
      end

        672 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[308] = heapMem[localMem[262]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 674;
      end

        674 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[309] = localMem[299] + 1;
              updateArrayLength(2, 0, 0);
              ip = 675;
      end

        675 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[262]*7 + 0] = heapMem[localMem[262]*7 + 0] + 1;
              updateArrayLength(1, localMem[262], 0);
              ip = 677;
      end

        677 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 794;
      end

        678 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 679;
      end

        679 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 680;
      end

        680 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[310]*7 + 0] = localMem[260];
              updateArrayLength(1, localMem[310], 0);
              ip = 682;
      end

        682 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[310]*7 + 2] = 0;
              updateArrayLength(1, localMem[310], 2);
              ip = 683;
      end

        683 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[310]*7 + 4] = localMem[311];
              updateArrayLength(1, localMem[310], 4);
              ip = 685;
      end

        685 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[310]*7 + 5] = localMem[312];
              updateArrayLength(1, localMem[310], 5);
              ip = 687;
      end

        687 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[310]*7 + 6] = 0;
              updateArrayLength(1, localMem[310], 6);
              ip = 688;
      end

        688 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[310]*7 + 3] = localMem[258];
              updateArrayLength(1, localMem[310], 3);
              ip = 689;
      end

        689 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[258]*7 + 1] = heapMem[localMem[258]*7 + 1] + 1;
              updateArrayLength(1, localMem[258], 1);
              ip = 690;
      end

        690 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[310]*7 + 1] = heapMem[localMem[258]*7 + 1];
              updateArrayLength(1, localMem[310], 1);
              ip = 691;
      end

        691 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[313]*7 + 0] = localMem[260];
              updateArrayLength(1, localMem[313], 0);
              ip = 693;
      end

        693 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[313]*7 + 2] = 0;
              updateArrayLength(1, localMem[313], 2);
              ip = 694;
      end

        694 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[313]*7 + 4] = localMem[314];
              updateArrayLength(1, localMem[313], 4);
              ip = 696;
      end

        696 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[313]*7 + 5] = localMem[315];
              updateArrayLength(1, localMem[313], 5);
              ip = 698;
      end

        698 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[313]*7 + 6] = 0;
              updateArrayLength(1, localMem[313], 6);
              ip = 699;
      end

        699 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[313]*7 + 3] = localMem[258];
              updateArrayLength(1, localMem[313], 3);
              ip = 700;
      end

        700 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[258]*7 + 1] = heapMem[localMem[258]*7 + 1] + 1;
              updateArrayLength(1, localMem[258], 1);
              ip = 701;
      end

        701 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[313]*7 + 1] = heapMem[localMem[258]*7 + 1];
              updateArrayLength(1, localMem[313], 1);
              ip = 702;
      end

        702 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[316] = !heapMem[localMem[255]*7 + 6];
              ip = 703;
      end

        703 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[316] != 0 ? 755 : 704;
      end

        704 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[310]*7 + 6] = localMem[317];
              updateArrayLength(1, localMem[310], 6);
              ip = 706;
      end

        706 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[313]*7 + 6] = localMem[318];
              updateArrayLength(1, localMem[313], 6);
              ip = 708;
      end

        708 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[319] = heapMem[localMem[255]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 709;
      end

        709 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[320] = heapMem[localMem[310]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 710;
      end

        710 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[321] = heapMem[localMem[255]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 712;
      end

        712 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[322] = heapMem[localMem[310]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 713;
      end

        713 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[323] = heapMem[localMem[255]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 715;
      end

        715 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[324] = heapMem[localMem[310]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 716;
      end

        716 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[325] = localMem[260] + 1;
              updateArrayLength(2, 0, 0);
              ip = 717;
      end

        717 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[326] = heapMem[localMem[255]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 719;
      end

        719 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[327] = heapMem[localMem[313]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 720;
      end

        720 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[328] = heapMem[localMem[255]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 722;
      end

        722 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[329] = heapMem[localMem[313]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 723;
      end

        723 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[330] = heapMem[localMem[255]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 725;
      end

        725 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[331] = heapMem[localMem[313]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 726;
      end

        726 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[332] = localMem[260] + 1;
              updateArrayLength(2, 0, 0);
              ip = 727;
      end

        727 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[333] = heapMem[localMem[310]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 729;
      end

        729 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[334] = localMem[333] + 1;
              updateArrayLength(2, 0, 0);
              ip = 730;
      end

        730 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[335] = heapMem[localMem[310]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 731;
      end

        731 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 732;
      end

        732 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[336] = 0;
              updateArrayLength(2, 0, 0);
              ip = 733;
      end

        733 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 734;
      end

        734 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[336] >= localMem[334] ? 740 : 735;
      end

        735 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[337] = heapMem[localMem[335]*7 + localMem[336]];
              updateArrayLength(2, 0, 0);
              ip = 736;
      end

        736 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[337]*7 + 2] = localMem[310];
              updateArrayLength(1, localMem[337], 2);
              ip = 737;
      end

        737 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 738;
      end

        738 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[336] = localMem[336] + 1;
              updateArrayLength(2, 0, 0);
              ip = 739;
      end

        739 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 733;
      end

        740 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 741;
      end

        741 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[338] = heapMem[localMem[313]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 742;
      end

        742 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[339] = localMem[338] + 1;
              updateArrayLength(2, 0, 0);
              ip = 743;
      end

        743 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[340] = heapMem[localMem[313]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 744;
      end

        744 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 745;
      end

        745 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[341] = 0;
              updateArrayLength(2, 0, 0);
              ip = 746;
      end

        746 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 747;
      end

        747 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[341] >= localMem[339] ? 753 : 748;
      end

        748 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[342] = heapMem[localMem[340]*7 + localMem[341]];
              updateArrayLength(2, 0, 0);
              ip = 749;
      end

        749 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[342]*7 + 2] = localMem[313];
              updateArrayLength(1, localMem[342], 2);
              ip = 750;
      end

        750 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 751;
      end

        751 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[341] = localMem[341] + 1;
              updateArrayLength(2, 0, 0);
              ip = 752;
      end

        752 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 746;
      end

        753 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 754;
      end

        754 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 770;
      end

        755 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 756;
      end

        756 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[255]*7 + 6] = localMem[343];
              updateArrayLength(1, localMem[255], 6);
              ip = 758;
      end

        758 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[344] = heapMem[localMem[255]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 759;
      end

        759 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[345] = heapMem[localMem[310]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 760;
      end

        760 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[346] = heapMem[localMem[255]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 762;
      end

        762 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[347] = heapMem[localMem[310]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 763;
      end

        763 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[348] = heapMem[localMem[255]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 765;
      end

        765 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[349] = heapMem[localMem[313]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 766;
      end

        766 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[350] = heapMem[localMem[255]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 768;
      end

        768 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[351] = heapMem[localMem[313]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 769;
      end

        769 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 771;
      end

        771 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[310]*7 + 2] = localMem[255];
              updateArrayLength(1, localMem[310], 2);
              ip = 772;
      end

        772 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[313]*7 + 2] = localMem[255];
              updateArrayLength(1, localMem[313], 2);
              ip = 773;
      end

        773 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[352] = heapMem[localMem[255]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 774;
      end

        774 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[353] = heapMem[localMem[352]*7 + localMem[260]];
              updateArrayLength(2, 0, 0);
              ip = 775;
      end

        775 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[354] = heapMem[localMem[255]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 776;
      end

        776 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[355] = heapMem[localMem[354]*7 + localMem[260]];
              updateArrayLength(2, 0, 0);
              ip = 777;
      end

        777 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[356] = heapMem[localMem[255]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 778;
      end

        778 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[356]*7 + 0] = localMem[353];
              updateArrayLength(1, localMem[356], 0);
              ip = 779;
      end

        779 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[357] = heapMem[localMem[255]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 780;
      end

        780 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[357]*7 + 0] = localMem[355];
              updateArrayLength(1, localMem[357], 0);
              ip = 781;
      end

        781 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[358] = heapMem[localMem[255]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 782;
      end

        782 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[358]*7 + 0] = localMem[310];
              updateArrayLength(1, localMem[358], 0);
              ip = 783;
      end

        783 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[359] = heapMem[localMem[255]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 784;
      end

        784 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[359]*7 + 1] = localMem[313];
              updateArrayLength(1, localMem[359], 1);
              ip = 785;
      end

        785 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[255]*7 + 0] = 1;
              updateArrayLength(1, localMem[255], 0);
              ip = 786;
      end

        786 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[360] = heapMem[localMem[255]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 787;
      end

        787 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[360]] = 1;
              ip = 788;
      end

        788 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[361] = heapMem[localMem[255]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 789;
      end

        789 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[361]] = 1;
              ip = 790;
      end

        790 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[362] = heapMem[localMem[255]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 791;
      end

        791 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[362]] = 2;
              ip = 792;
      end

        792 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 794;
      end

        793 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 799;
      end

        794 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 795;
      end

        795 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[256] = 1;
              updateArrayLength(2, 0, 0);
              ip = 796;
      end

        796 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 799;
      end

        797 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 798;
      end

        798 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[256] = 0;
              updateArrayLength(2, 0, 0);
              ip = 799;
      end

        799 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 800;
      end

        800 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[256] != 0 ? 802 : 801;
      end

        801 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[27] = localMem[255];
              updateArrayLength(2, 0, 0);
              ip = 802;
      end

        802 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 803;
      end

        803 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 804;
      end

        804 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[135] = localMem[135] + 1;
              updateArrayLength(2, 0, 0);
              ip = 805;
      end

        805 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 307;
      end

        806 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 807;
      end

        807 :
      begin                                                                     // assert
if (0) begin
  $display("AAAA %4d %4d assert", steps, ip);
end
            ip = 808;
      end

        808 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 809;
      end

        809 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 810;
      end

        810 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 811;
      end

        811 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[363] = heapMem[localMem[4]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 812;
      end

        812 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[364] = heapMem[localMem[4]*7 + 1];
              updateArrayLength(2, 0, 0);
              ip = 813;
      end

        813 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[365] = heapMem[localMem[4]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 814;
      end

        814 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[364] != 1 ? 818 : 815;
      end

        815 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[366] = heapMem[localMem[363]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 816;
      end

        816 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[366]*7 + localMem[365]] = localMem[3];
              updateArrayLength(1, localMem[366], localMem[365]);
              ip = 817;
      end

        817 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1064;
      end

        818 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 819;
      end

        819 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[364] != 2 ? 827 : 820;
      end

        820 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[367] = localMem[365] + 1;
              updateArrayLength(2, 0, 0);
              ip = 821;
      end

        821 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[368] = heapMem[localMem[363]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 822;
      end

        822 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[369] = heapMem[localMem[363]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 824;
      end

        824 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[363]*7 + 0] = heapMem[localMem[363]*7 + 0] + 1;
              updateArrayLength(1, localMem[363], 0);
              ip = 826;
      end

        826 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 833;
      end

        827 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 828;
      end

        828 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[370] = heapMem[localMem[363]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 829;
      end

        829 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[371] = heapMem[localMem[363]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 831;
      end

        831 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[363]*7 + 0] = heapMem[localMem[363]*7 + 0] + 1;
              updateArrayLength(1, localMem[363], 0);
              ip = 833;
      end

        833 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 834;
      end

        834 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[0]*7 + 0] = heapMem[localMem[0]*7 + 0] + 1;
              updateArrayLength(1, localMem[0], 0);
              ip = 835;
      end

        835 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 836;
      end

        836 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[373] = heapMem[localMem[363]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 837;
      end

        837 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[374] = heapMem[localMem[363]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 838;
      end

        838 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[375] = heapMem[localMem[374]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 839;
      end

        839 :
      begin                                                                     // jLt
if (0) begin
  $display("AAAA %4d %4d jLt", steps, ip);
end
              ip = localMem[373] <  localMem[375] ? 1059 : 840;
      end

        840 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[376] = localMem[375];
              updateArrayLength(2, 0, 0);
              ip = 841;
      end

        841 :
      begin                                                                     // shiftRight
if (0) begin
  $display("AAAA %4d %4d shiftRight", steps, ip);
end
              localMem[376] = localMem[376] >> 1;
              ip = 842;
      end

        842 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[377] = localMem[376] + 1;
              updateArrayLength(2, 0, 0);
              ip = 843;
      end

        843 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[378] = heapMem[localMem[363]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 844;
      end

        844 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[378] == 0 ? 941 : 845;
      end

        845 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[379]*7 + 0] = localMem[376];
              updateArrayLength(1, localMem[379], 0);
              ip = 847;
      end

        847 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[379]*7 + 2] = 0;
              updateArrayLength(1, localMem[379], 2);
              ip = 848;
      end

        848 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[379]*7 + 4] = localMem[380];
              updateArrayLength(1, localMem[379], 4);
              ip = 850;
      end

        850 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[379]*7 + 5] = localMem[381];
              updateArrayLength(1, localMem[379], 5);
              ip = 852;
      end

        852 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[379]*7 + 6] = 0;
              updateArrayLength(1, localMem[379], 6);
              ip = 853;
      end

        853 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[379]*7 + 3] = localMem[374];
              updateArrayLength(1, localMem[379], 3);
              ip = 854;
      end

        854 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[374]*7 + 1] = heapMem[localMem[374]*7 + 1] + 1;
              updateArrayLength(1, localMem[374], 1);
              ip = 855;
      end

        855 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[379]*7 + 1] = heapMem[localMem[374]*7 + 1];
              updateArrayLength(1, localMem[379], 1);
              ip = 856;
      end

        856 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[382] = !heapMem[localMem[363]*7 + 6];
              ip = 857;
      end

        857 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[382] != 0 ? 886 : 858;
      end

        858 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[379]*7 + 6] = localMem[383];
              updateArrayLength(1, localMem[379], 6);
              ip = 860;
      end

        860 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[384] = heapMem[localMem[363]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 861;
      end

        861 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[385] = heapMem[localMem[379]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 862;
      end

        862 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[386] = heapMem[localMem[363]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 864;
      end

        864 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[387] = heapMem[localMem[379]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 865;
      end

        865 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[388] = heapMem[localMem[363]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 867;
      end

        867 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[389] = heapMem[localMem[379]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 868;
      end

        868 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[390] = localMem[376] + 1;
              updateArrayLength(2, 0, 0);
              ip = 869;
      end

        869 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[391] = heapMem[localMem[379]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 871;
      end

        871 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[392] = localMem[391] + 1;
              updateArrayLength(2, 0, 0);
              ip = 872;
      end

        872 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[393] = heapMem[localMem[379]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 873;
      end

        873 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 874;
      end

        874 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[394] = 0;
              updateArrayLength(2, 0, 0);
              ip = 875;
      end

        875 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 876;
      end

        876 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[394] >= localMem[392] ? 882 : 877;
      end

        877 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[395] = heapMem[localMem[393]*7 + localMem[394]];
              updateArrayLength(2, 0, 0);
              ip = 878;
      end

        878 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[395]*7 + 2] = localMem[379];
              updateArrayLength(1, localMem[395], 2);
              ip = 879;
      end

        879 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 880;
      end

        880 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[394] = localMem[394] + 1;
              updateArrayLength(2, 0, 0);
              ip = 881;
      end

        881 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 875;
      end

        882 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 883;
      end

        883 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[396] = heapMem[localMem[363]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 884;
      end

        884 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[396]] = localMem[377];
              ip = 885;
      end

        885 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 893;
      end

        886 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 887;
      end

        887 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[397] = heapMem[localMem[363]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 888;
      end

        888 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[398] = heapMem[localMem[379]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 889;
      end

        889 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[399] = heapMem[localMem[363]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 891;
      end

        891 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[400] = heapMem[localMem[379]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 892;
      end

        892 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 894;
      end

        894 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[363]*7 + 0] = localMem[376];
              updateArrayLength(1, localMem[363], 0);
              ip = 895;
      end

        895 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[379]*7 + 2] = localMem[378];
              updateArrayLength(1, localMem[379], 2);
              ip = 896;
      end

        896 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[401] = heapMem[localMem[378]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 897;
      end

        897 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[402] = heapMem[localMem[378]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 898;
      end

        898 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[403] = heapMem[localMem[402]*7 + localMem[401]];
              updateArrayLength(2, 0, 0);
              ip = 899;
      end

        899 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[403] != localMem[363] ? 918 : 900;
      end

        900 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[404] = heapMem[localMem[363]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 901;
      end

        901 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[405] = heapMem[localMem[404]*7 + localMem[376]];
              updateArrayLength(2, 0, 0);
              ip = 902;
      end

        902 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[406] = heapMem[localMem[378]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 903;
      end

        903 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[406]*7 + localMem[401]] = localMem[405];
              updateArrayLength(1, localMem[406], localMem[401]);
              ip = 904;
      end

        904 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[407] = heapMem[localMem[363]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 905;
      end

        905 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[408] = heapMem[localMem[407]*7 + localMem[376]];
              updateArrayLength(2, 0, 0);
              ip = 906;
      end

        906 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[409] = heapMem[localMem[378]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 907;
      end

        907 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[409]*7 + localMem[401]] = localMem[408];
              updateArrayLength(1, localMem[409], localMem[401]);
              ip = 908;
      end

        908 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[410] = heapMem[localMem[363]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 909;
      end

        909 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[410]] = localMem[376];
              ip = 910;
      end

        910 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[411] = heapMem[localMem[363]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 911;
      end

        911 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[411]] = localMem[376];
              ip = 912;
      end

        912 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[412] = localMem[401] + 1;
              updateArrayLength(2, 0, 0);
              ip = 913;
      end

        913 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[378]*7 + 0] = localMem[412];
              updateArrayLength(1, localMem[378], 0);
              ip = 914;
      end

        914 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[413] = heapMem[localMem[378]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 915;
      end

        915 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[413]*7 + localMem[412]] = localMem[379];
              updateArrayLength(1, localMem[413], localMem[412]);
              ip = 916;
      end

        916 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1056;
      end

        917 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 940;
      end

        918 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 919;
      end

        919 :
      begin                                                                     // assertNe
if (0) begin
  $display("AAAA %4d %4d assertNe", steps, ip);
end
            ip = 920;
      end

        920 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[414] = heapMem[localMem[378]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 921;
      end

        921 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[415] = 0; k = arraySizes[localMem[414]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[414] * NArea + i] == localMem[363]) localMem[415] = i + 1;
              end
              ip = 922;
      end

        922 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[415] = localMem[415] - 1;
              updateArrayLength(2, 0, 0);
              ip = 923;
      end

        923 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[416] = heapMem[localMem[363]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 924;
      end

        924 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[417] = heapMem[localMem[416]*7 + localMem[376]];
              updateArrayLength(2, 0, 0);
              ip = 925;
      end

        925 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[418] = heapMem[localMem[363]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 926;
      end

        926 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[419] = heapMem[localMem[418]*7 + localMem[376]];
              updateArrayLength(2, 0, 0);
              ip = 927;
      end

        927 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[420] = heapMem[localMem[363]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 928;
      end

        928 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[420]] = localMem[376];
              ip = 929;
      end

        929 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[421] = heapMem[localMem[363]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 930;
      end

        930 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[421]] = localMem[376];
              ip = 931;
      end

        931 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[422] = heapMem[localMem[378]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 932;
      end

        932 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[423] = heapMem[localMem[378]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 934;
      end

        934 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[424] = heapMem[localMem[378]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 936;
      end

        936 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[425] = localMem[415] + 1;
              updateArrayLength(2, 0, 0);
              ip = 937;
      end

        937 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[378]*7 + 0] = heapMem[localMem[378]*7 + 0] + 1;
              updateArrayLength(1, localMem[378], 0);
              ip = 939;
      end

        939 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1056;
      end

        940 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 941;
      end

        941 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 942;
      end

        942 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[426]*7 + 0] = localMem[376];
              updateArrayLength(1, localMem[426], 0);
              ip = 944;
      end

        944 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[426]*7 + 2] = 0;
              updateArrayLength(1, localMem[426], 2);
              ip = 945;
      end

        945 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[426]*7 + 4] = localMem[427];
              updateArrayLength(1, localMem[426], 4);
              ip = 947;
      end

        947 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[426]*7 + 5] = localMem[428];
              updateArrayLength(1, localMem[426], 5);
              ip = 949;
      end

        949 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[426]*7 + 6] = 0;
              updateArrayLength(1, localMem[426], 6);
              ip = 950;
      end

        950 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[426]*7 + 3] = localMem[374];
              updateArrayLength(1, localMem[426], 3);
              ip = 951;
      end

        951 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[374]*7 + 1] = heapMem[localMem[374]*7 + 1] + 1;
              updateArrayLength(1, localMem[374], 1);
              ip = 952;
      end

        952 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[426]*7 + 1] = heapMem[localMem[374]*7 + 1];
              updateArrayLength(1, localMem[426], 1);
              ip = 953;
      end

        953 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[429]*7 + 0] = localMem[376];
              updateArrayLength(1, localMem[429], 0);
              ip = 955;
      end

        955 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[429]*7 + 2] = 0;
              updateArrayLength(1, localMem[429], 2);
              ip = 956;
      end

        956 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[429]*7 + 4] = localMem[430];
              updateArrayLength(1, localMem[429], 4);
              ip = 958;
      end

        958 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[429]*7 + 5] = localMem[431];
              updateArrayLength(1, localMem[429], 5);
              ip = 960;
      end

        960 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[429]*7 + 6] = 0;
              updateArrayLength(1, localMem[429], 6);
              ip = 961;
      end

        961 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[429]*7 + 3] = localMem[374];
              updateArrayLength(1, localMem[429], 3);
              ip = 962;
      end

        962 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[374]*7 + 1] = heapMem[localMem[374]*7 + 1] + 1;
              updateArrayLength(1, localMem[374], 1);
              ip = 963;
      end

        963 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[429]*7 + 1] = heapMem[localMem[374]*7 + 1];
              updateArrayLength(1, localMem[429], 1);
              ip = 964;
      end

        964 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[432] = !heapMem[localMem[363]*7 + 6];
              ip = 965;
      end

        965 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[432] != 0 ? 1017 : 966;
      end

        966 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[426]*7 + 6] = localMem[433];
              updateArrayLength(1, localMem[426], 6);
              ip = 968;
      end

        968 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[429]*7 + 6] = localMem[434];
              updateArrayLength(1, localMem[429], 6);
              ip = 970;
      end

        970 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[435] = heapMem[localMem[363]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 971;
      end

        971 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[436] = heapMem[localMem[426]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 972;
      end

        972 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[437] = heapMem[localMem[363]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 974;
      end

        974 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[438] = heapMem[localMem[426]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 975;
      end

        975 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[439] = heapMem[localMem[363]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 977;
      end

        977 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[440] = heapMem[localMem[426]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 978;
      end

        978 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[441] = localMem[376] + 1;
              updateArrayLength(2, 0, 0);
              ip = 979;
      end

        979 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[442] = heapMem[localMem[363]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 981;
      end

        981 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[443] = heapMem[localMem[429]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 982;
      end

        982 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[444] = heapMem[localMem[363]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 984;
      end

        984 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[445] = heapMem[localMem[429]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 985;
      end

        985 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[446] = heapMem[localMem[363]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 987;
      end

        987 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[447] = heapMem[localMem[429]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 988;
      end

        988 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[448] = localMem[376] + 1;
              updateArrayLength(2, 0, 0);
              ip = 989;
      end

        989 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[449] = heapMem[localMem[426]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 991;
      end

        991 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[450] = localMem[449] + 1;
              updateArrayLength(2, 0, 0);
              ip = 992;
      end

        992 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[451] = heapMem[localMem[426]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 993;
      end

        993 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 994;
      end

        994 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[452] = 0;
              updateArrayLength(2, 0, 0);
              ip = 995;
      end

        995 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 996;
      end

        996 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[452] >= localMem[450] ? 1002 : 997;
      end

        997 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[453] = heapMem[localMem[451]*7 + localMem[452]];
              updateArrayLength(2, 0, 0);
              ip = 998;
      end

        998 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[453]*7 + 2] = localMem[426];
              updateArrayLength(1, localMem[453], 2);
              ip = 999;
      end

        999 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1000;
      end

       1000 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[452] = localMem[452] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1001;
      end

       1001 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 995;
      end

       1002 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1003;
      end

       1003 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[454] = heapMem[localMem[429]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1004;
      end

       1004 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[455] = localMem[454] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1005;
      end

       1005 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[456] = heapMem[localMem[429]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1006;
      end

       1006 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1007;
      end

       1007 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[457] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1008;
      end

       1008 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1009;
      end

       1009 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[457] >= localMem[455] ? 1015 : 1010;
      end

       1010 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[458] = heapMem[localMem[456]*7 + localMem[457]];
              updateArrayLength(2, 0, 0);
              ip = 1011;
      end

       1011 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[458]*7 + 2] = localMem[429];
              updateArrayLength(1, localMem[458], 2);
              ip = 1012;
      end

       1012 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1013;
      end

       1013 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[457] = localMem[457] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1014;
      end

       1014 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1008;
      end

       1015 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1016;
      end

       1016 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1032;
      end

       1017 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1018;
      end

       1018 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[363]*7 + 6] = localMem[459];
              updateArrayLength(1, localMem[363], 6);
              ip = 1020;
      end

       1020 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[460] = heapMem[localMem[363]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1021;
      end

       1021 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[461] = heapMem[localMem[426]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1022;
      end

       1022 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[462] = heapMem[localMem[363]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1024;
      end

       1024 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[463] = heapMem[localMem[426]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1025;
      end

       1025 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[464] = heapMem[localMem[363]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1027;
      end

       1027 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[465] = heapMem[localMem[429]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1028;
      end

       1028 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[466] = heapMem[localMem[363]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1030;
      end

       1030 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[467] = heapMem[localMem[429]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1031;
      end

       1031 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1033;
      end

       1033 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[426]*7 + 2] = localMem[363];
              updateArrayLength(1, localMem[426], 2);
              ip = 1034;
      end

       1034 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[429]*7 + 2] = localMem[363];
              updateArrayLength(1, localMem[429], 2);
              ip = 1035;
      end

       1035 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[468] = heapMem[localMem[363]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1036;
      end

       1036 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[469] = heapMem[localMem[468]*7 + localMem[376]];
              updateArrayLength(2, 0, 0);
              ip = 1037;
      end

       1037 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[470] = heapMem[localMem[363]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1038;
      end

       1038 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[471] = heapMem[localMem[470]*7 + localMem[376]];
              updateArrayLength(2, 0, 0);
              ip = 1039;
      end

       1039 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[472] = heapMem[localMem[363]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1040;
      end

       1040 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[472]*7 + 0] = localMem[469];
              updateArrayLength(1, localMem[472], 0);
              ip = 1041;
      end

       1041 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[473] = heapMem[localMem[363]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1042;
      end

       1042 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[473]*7 + 0] = localMem[471];
              updateArrayLength(1, localMem[473], 0);
              ip = 1043;
      end

       1043 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[474] = heapMem[localMem[363]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1044;
      end

       1044 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[474]*7 + 0] = localMem[426];
              updateArrayLength(1, localMem[474], 0);
              ip = 1045;
      end

       1045 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[475] = heapMem[localMem[363]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1046;
      end

       1046 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[475]*7 + 1] = localMem[429];
              updateArrayLength(1, localMem[475], 1);
              ip = 1047;
      end

       1047 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[363]*7 + 0] = 1;
              updateArrayLength(1, localMem[363], 0);
              ip = 1048;
      end

       1048 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[476] = heapMem[localMem[363]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1049;
      end

       1049 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[476]] = 1;
              ip = 1050;
      end

       1050 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[477] = heapMem[localMem[363]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1051;
      end

       1051 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[477]] = 1;
              ip = 1052;
      end

       1052 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[478] = heapMem[localMem[363]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1053;
      end

       1053 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[478]] = 2;
              ip = 1054;
      end

       1054 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1056;
      end

       1055 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1061;
      end

       1056 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1057;
      end

       1057 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[372] = 1;
              updateArrayLength(2, 0, 0);
              ip = 1058;
      end

       1058 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1061;
      end

       1059 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1060;
      end

       1060 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[372] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1061;
      end

       1061 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1062;
      end

       1062 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1063;
      end

       1063 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1064;
      end

       1064 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1065;
      end

       1065 :
      begin                                                                     // free
if (0) begin
  $display("AAAA %4d %4d free", steps, ip);
end
                                 arraySizes[localMem[4]] = 0;
              freedArrays[freedArraysTop] = localMem[4];
              freedArraysTop = freedArraysTop + 1;
              ip = 1066;
      end

       1066 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1067;
      end

       1067 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 5;
      end

       1068 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1069;
      end

       1069 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[479] = 1;
              updateArrayLength(2, 0, 0);
              ip = 1070;
      end

       1070 :
      begin                                                                     // shiftLeft
if (0) begin
  $display("AAAA %4d %4d shiftLeft", steps, ip);
end
              localMem[479] = localMem[479] << 31;
              ip = 1071;
      end

       1071 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[480] = heapMem[localMem[0]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 1072;
      end

       1072 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[480] != 0 ? 1079 : 1075;
      end

       1075 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[481]*7 + 0] = localMem[480];
              updateArrayLength(1, localMem[481], 0);
              ip = 1076;
      end

       1076 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[481]*7 + 1] = 3;
              updateArrayLength(1, localMem[481], 1);
              ip = 1077;
      end

       1077 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[481]*7 + 2] = 0;
              updateArrayLength(1, localMem[481], 2);
              ip = 1078;
      end

       1078 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1096;
      end

       1079 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1080;
      end

       1080 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1081;
      end

       1081 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[483] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1082;
      end

       1082 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1083;
      end

       1083 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[483] >= 99 ? 1092 : 1084;
      end

       1084 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[484] = !heapMem[localMem[480]*7 + 6];
              ip = 1085;
      end

       1085 :
      begin                                                                     // jTrue
if (0) begin
  $display("AAAA %4d %4d jTrue", steps, ip);
end
              ip = localMem[484] != 0 ? 1092 : 1086;
      end

       1086 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[485] = heapMem[localMem[480]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1087;
      end

       1087 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[486] = heapMem[localMem[485]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1088;
      end

       1088 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[480] = localMem[486];
              updateArrayLength(2, 0, 0);
              ip = 1089;
      end

       1089 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1090;
      end

       1090 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[483] = localMem[483] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1091;
      end

       1091 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1082;
      end

       1092 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1093;
      end

       1093 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[481]*7 + 0] = localMem[480];
              updateArrayLength(1, localMem[481], 0);
              ip = 1094;
      end

       1094 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[481]*7 + 1] = 1;
              updateArrayLength(1, localMem[481], 1);
              ip = 1095;
      end

       1095 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[481]*7 + 2] = 0;
              updateArrayLength(1, localMem[481], 2);
              ip = 1096;
      end

       1096 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1097;
      end

       1097 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1098;
      end

       1098 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[487] = heapMem[localMem[481]*7 + 1];
              updateArrayLength(2, 0, 0);
              ip = 1099;
      end

       1099 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[487] == 3 ? 1182 : 1100;
      end

       1100 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[488] = heapMem[localMem[482]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1102;
      end

       1102 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[489] = heapMem[localMem[482]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1103;
      end

       1103 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[490] = heapMem[localMem[488]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1104;
      end

       1104 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[491] = heapMem[localMem[490]*7 + localMem[489]];
              updateArrayLength(2, 0, 0);
              ip = 1105;
      end

       1105 :
      begin                                                                     // out
if (0) begin
  $display("AAAA %4d %4d out", steps, ip);
end
              outMem[outMemPos] = localMem[491];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 1106;
      end

       1106 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1107;
      end

       1107 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[492] = heapMem[localMem[481]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1108;
      end

       1108 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[493] = !heapMem[localMem[492]*7 + 6];
              ip = 1109;
      end

       1109 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[493] == 0 ? 1149 : 1110;
      end

       1110 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[494] = heapMem[localMem[481]*7 + 2] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1111;
      end

       1111 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[495] = heapMem[localMem[492]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1112;
      end

       1112 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[494] >= localMem[495] ? 1117 : 1113;
      end

       1113 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[481]*7 + 0] = localMem[492];
              updateArrayLength(1, localMem[481], 0);
              ip = 1114;
      end

       1114 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[481]*7 + 1] = 1;
              updateArrayLength(1, localMem[481], 1);
              ip = 1115;
      end

       1115 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[481]*7 + 2] = localMem[494];
              updateArrayLength(1, localMem[481], 2);
              ip = 1116;
      end

       1116 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1178;
      end

       1117 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1118;
      end

       1118 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[496] = heapMem[localMem[492]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1119;
      end

       1119 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[496] == 0 ? 1144 : 1120;
      end

       1120 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1121;
      end

       1121 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[497] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1122;
      end

       1122 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1123;
      end

       1123 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[497] >= 99 ? 1143 : 1124;
      end

       1124 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[498] = heapMem[localMem[496]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1125;
      end

       1125 :
      begin                                                                     // assertNe
if (0) begin
  $display("AAAA %4d %4d assertNe", steps, ip);
end
            ip = 1126;
      end

       1126 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[499] = heapMem[localMem[496]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1127;
      end

       1127 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[500] = 0; k = arraySizes[localMem[499]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[499] * NArea + i] == localMem[492]) localMem[500] = i + 1;
              end
              ip = 1128;
      end

       1128 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[500] = localMem[500] - 1;
              updateArrayLength(2, 0, 0);
              ip = 1129;
      end

       1129 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[500] != localMem[498] ? 1134 : 1130;
      end

       1130 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[492] = localMem[496];
              updateArrayLength(2, 0, 0);
              ip = 1131;
      end

       1131 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[496] = heapMem[localMem[492]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1132;
      end

       1132 :
      begin                                                                     // jFalse
if (0) begin
  $display("AAAA %4d %4d jFalse", steps, ip);
end
              ip = localMem[496] == 0 ? 1143 : 1133;
      end

       1133 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1139;
      end

       1134 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1135;
      end

       1135 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[481]*7 + 0] = localMem[496];
              updateArrayLength(1, localMem[481], 0);
              ip = 1136;
      end

       1136 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[481]*7 + 1] = 1;
              updateArrayLength(1, localMem[481], 1);
              ip = 1137;
      end

       1137 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[481]*7 + 2] = localMem[500];
              updateArrayLength(1, localMem[481], 2);
              ip = 1138;
      end

       1138 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1178;
      end

       1139 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1140;
      end

       1140 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1141;
      end

       1141 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[497] = localMem[497] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1142;
      end

       1142 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1122;
      end

       1143 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1144;
      end

       1144 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1145;
      end

       1145 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[481]*7 + 0] = localMem[492];
              updateArrayLength(1, localMem[481], 0);
              ip = 1146;
      end

       1146 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[481]*7 + 1] = 3;
              updateArrayLength(1, localMem[481], 1);
              ip = 1147;
      end

       1147 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[481]*7 + 2] = 0;
              updateArrayLength(1, localMem[481], 2);
              ip = 1148;
      end

       1148 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1178;
      end

       1149 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1150;
      end

       1150 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[501] = heapMem[localMem[481]*7 + 2] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1151;
      end

       1151 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[502] = heapMem[localMem[492]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1152;
      end

       1152 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[503] = heapMem[localMem[502]*7 + localMem[501]];
              updateArrayLength(2, 0, 0);
              ip = 1153;
      end

       1153 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[503] != 0 ? 1158 : 1154;
      end

       1154 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[481]*7 + 0] = localMem[503];
              updateArrayLength(1, localMem[481], 0);
              ip = 1155;
      end

       1155 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[481]*7 + 1] = 3;
              updateArrayLength(1, localMem[481], 1);
              ip = 1156;
      end

       1156 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[481]*7 + 2] = 0;
              updateArrayLength(1, localMem[481], 2);
              ip = 1157;
      end

       1157 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1175;
      end

       1158 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1159;
      end

       1159 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1160;
      end

       1160 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[504] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1161;
      end

       1161 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1162;
      end

       1162 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[504] >= 99 ? 1171 : 1163;
      end

       1163 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[505] = !heapMem[localMem[503]*7 + 6];
              ip = 1164;
      end

       1164 :
      begin                                                                     // jTrue
if (0) begin
  $display("AAAA %4d %4d jTrue", steps, ip);
end
              ip = localMem[505] != 0 ? 1171 : 1165;
      end

       1165 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[506] = heapMem[localMem[503]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1166;
      end

       1166 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[507] = heapMem[localMem[506]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1167;
      end

       1167 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[503] = localMem[507];
              updateArrayLength(2, 0, 0);
              ip = 1168;
      end

       1168 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1169;
      end

       1169 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[504] = localMem[504] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1170;
      end

       1170 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1161;
      end

       1171 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1172;
      end

       1172 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[481]*7 + 0] = localMem[503];
              updateArrayLength(1, localMem[481], 0);
              ip = 1173;
      end

       1173 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[481]*7 + 1] = 1;
              updateArrayLength(1, localMem[481], 1);
              ip = 1174;
      end

       1174 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[481]*7 + 2] = 0;
              updateArrayLength(1, localMem[481], 2);
              ip = 1175;
      end

       1175 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1176;
      end

       1176 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1177;
      end

       1177 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1178;
      end

       1178 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1179;
      end

       1179 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1097;
      end

       1180 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1181;
      end

       1181 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1182;
      end

       1182 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1183;
      end

       1183 :
      begin                                                                     // free
if (0) begin
  $display("AAAA %4d %4d free", steps, ip);
end
                                 arraySizes[localMem[481]] = 0;
              freedArrays[freedArraysTop] = localMem[481];
              freedArraysTop = freedArraysTop + 1;
              ip = 1184;
      end

       1184 :
      begin                                                                     // free
if (0) begin
  $display("AAAA %4d %4d free", steps, ip);
end
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
    if (0) begin
      for(i = 0; i < 200; ++i) $write("%2d",   localMem[i]); $display("");
      for(i = 0; i < 200; ++i) $write("%2d",    heapMem[i]); $display("");
      for(i = 0; i < 200; ++i) $write("%2d", arraySizes[i]); $display("");
    end
  end
endmodule
