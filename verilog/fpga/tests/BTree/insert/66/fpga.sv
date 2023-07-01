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
  parameter integer NArrays =      284;                                         // Maximum number of arrays
  parameter integer NHeap   =     1988;                                         // Amount of heap memory
  parameter integer NLocal  =      528;                                         // Size of local memory
  parameter integer NOut    =        0;                                         // Size of output area
  parameter integer NIn     =         0;                                        // Size of input area
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
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[1] = 0;
              updateArrayLength(2, 0, 0);
              ip = 7;
      end

          7 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 8;
      end

          8 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[1] >= 66 ? 1069 : 9;
      end

          9 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[2] = localMem[1] + localMem[1];
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
                localMem[3] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[3] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[3]] = 0;
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
              localMem[4] = heapMem[localMem[0]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 13;
      end

         13 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[4] != 0 ? 36 : 14;
      end

         14 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[5] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[5] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[5]] = 0;
              ip = 15;
      end

         15 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[5]*7 + 0] = 1;
              updateArrayLength(1, localMem[5], 0);
              ip = 16;
      end

         16 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[5]*7 + 2] = 0;
              updateArrayLength(1, localMem[5], 2);
              ip = 17;
      end

         17 :
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
              ip = 18;
      end

         18 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[5]*7 + 4] = localMem[6];
              updateArrayLength(1, localMem[5], 4);
              ip = 19;
      end

         19 :
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
              ip = 20;
      end

         20 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[5]*7 + 5] = localMem[7];
              updateArrayLength(1, localMem[5], 5);
              ip = 21;
      end

         21 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[5]*7 + 6] = 0;
              updateArrayLength(1, localMem[5], 6);
              ip = 22;
      end

         22 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[5]*7 + 3] = localMem[0];
              updateArrayLength(1, localMem[5], 3);
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
              heapMem[localMem[5]*7 + 1] = heapMem[localMem[0]*7 + 1];
              updateArrayLength(1, localMem[5], 1);
              ip = 25;
      end

         25 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[8] = heapMem[localMem[5]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 26;
      end

         26 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[8]*7 + 0] = localMem[1];
              updateArrayLength(1, localMem[8], 0);
              ip = 27;
      end

         27 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[9] = heapMem[localMem[5]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 28;
      end

         28 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[9]*7 + 0] = localMem[2];
              updateArrayLength(1, localMem[9], 0);
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
              heapMem[localMem[0]*7 + 3] = localMem[5];
              updateArrayLength(1, localMem[0], 3);
              ip = 31;
      end

         31 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[10] = heapMem[localMem[5]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 32;
      end

         32 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[10]] = 1;
              ip = 33;
      end

         33 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[11] = heapMem[localMem[5]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 34;
      end

         34 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[11]] = 1;
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
              localMem[12] = heapMem[localMem[4]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 38;
      end

         38 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[13] = heapMem[localMem[0]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 39;
      end

         39 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[12] >= localMem[13] ? 75 : 40;
      end

         40 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[14] = heapMem[localMem[4]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 41;
      end

         41 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[14] != 0 ? 74 : 42;
      end

         42 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[15] = !heapMem[localMem[4]*7 + 6];
              ip = 43;
      end

         43 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[15] == 0 ? 73 : 44;
      end

         44 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[16] = heapMem[localMem[4]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 45;
      end

         45 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[17] = 0; k = arraySizes[localMem[16]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[16] * NArea + i] == localMem[1]) localMem[17] = i + 1;
              end
              ip = 46;
      end

         46 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[17] == 0 ? 51 : 47;
      end

         47 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[17] = localMem[17] - 1;
              updateArrayLength(2, 0, 0);
              ip = 48;
      end

         48 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[18] = heapMem[localMem[4]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 49;
      end

         49 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[18]*7 + localMem[17]] = localMem[2];
              updateArrayLength(1, localMem[18], localMem[17]);
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
              arraySizes[localMem[16]] = localMem[12];
              ip = 53;
      end

         53 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[19] = heapMem[localMem[4]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 54;
      end

         54 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[19]] = localMem[12];
              ip = 55;
      end

         55 :
      begin                                                                     // arrayCountGreater
if (0) begin
  $display("AAAA %4d %4d arrayCountGreater", steps, ip);
end
              j = 0; k = arraySizes[localMem[16]];
//$display("AAAAA k=%d  source2=%d", k, localMem[1]);
              for(i = 0; i < NArea; i = i + 1) begin
//$display("AAAAA i=%d  value=%d", i, heapMem[localMem[16] * NArea + i]);
                if (i < k && heapMem[localMem[16] * NArea + i] > localMem[1]) j = j + 1;
              end
              localMem[20] = j;
              ip = 56;
      end

         56 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[20] != 0 ? 64 : 57;
      end

         57 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[21] = heapMem[localMem[4]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 58;
      end

         58 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[21]*7 + localMem[12]] = localMem[1];
              updateArrayLength(1, localMem[21], localMem[12]);
              ip = 59;
      end

         59 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[22] = heapMem[localMem[4]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 60;
      end

         60 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[22]*7 + localMem[12]] = localMem[2];
              updateArrayLength(1, localMem[22], localMem[12]);
              ip = 61;
      end

         61 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[4]*7 + 0] = localMem[12] + 1;
              updateArrayLength(1, localMem[4], 0);
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
              j = 0; k = arraySizes[localMem[16]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[16] * NArea + i] < localMem[1]) j = j + 1;
              end
              localMem[23] = j;
              ip = 66;
      end

         66 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[24] = heapMem[localMem[4]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 67;
      end

         67 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[24] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[23], localMem[24], arraySizes[localMem[24]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[23] && i <= arraySizes[localMem[24]]) begin
                  heapMem[NArea * localMem[24] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[24] + localMem[23]] = localMem[1];                                    // Insert new value
              arraySizes[localMem[24]] = arraySizes[localMem[24]] + 1;                              // Increase array size
              ip = 68;
      end

         68 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[25] = heapMem[localMem[4]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 69;
      end

         69 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[25] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[23], localMem[25], arraySizes[localMem[25]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[23] && i <= arraySizes[localMem[25]]) begin
                  heapMem[NArea * localMem[25] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[25] + localMem[23]] = localMem[2];                                    // Insert new value
              arraySizes[localMem[25]] = arraySizes[localMem[25]] + 1;                              // Increase array size
              ip = 70;
      end

         70 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[4]*7 + 0] = heapMem[localMem[4]*7 + 0] + 1;
              updateArrayLength(1, localMem[4], 0);
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
              localMem[26] = heapMem[localMem[0]*7 + 3];
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
              localMem[28] = heapMem[localMem[26]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 79;
      end

         79 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[29] = heapMem[localMem[26]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 80;
      end

         80 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[30] = heapMem[localMem[29]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 81;
      end

         81 :
      begin                                                                     // jLt
if (0) begin
  $display("AAAA %4d %4d jLt", steps, ip);
end
              ip = localMem[28] <  localMem[30] ? 301 : 82;
      end

         82 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[31] = localMem[30];
              updateArrayLength(2, 0, 0);
              ip = 83;
      end

         83 :
      begin                                                                     // shiftRight
if (0) begin
  $display("AAAA %4d %4d shiftRight", steps, ip);
end
              localMem[31] = localMem[31] >> 1;
              ip = 84;
      end

         84 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[32] = localMem[31] + 1;
              updateArrayLength(2, 0, 0);
              ip = 85;
      end

         85 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[33] = heapMem[localMem[26]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 86;
      end

         86 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[33] == 0 ? 183 : 87;
      end

         87 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[34] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[34] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[34]] = 0;
              ip = 88;
      end

         88 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[34]*7 + 0] = localMem[31];
              updateArrayLength(1, localMem[34], 0);
              ip = 89;
      end

         89 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[34]*7 + 2] = 0;
              updateArrayLength(1, localMem[34], 2);
              ip = 90;
      end

         90 :
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
              ip = 91;
      end

         91 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[34]*7 + 4] = localMem[35];
              updateArrayLength(1, localMem[34], 4);
              ip = 92;
      end

         92 :
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
              ip = 93;
      end

         93 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[34]*7 + 5] = localMem[36];
              updateArrayLength(1, localMem[34], 5);
              ip = 94;
      end

         94 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[34]*7 + 6] = 0;
              updateArrayLength(1, localMem[34], 6);
              ip = 95;
      end

         95 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[34]*7 + 3] = localMem[29];
              updateArrayLength(1, localMem[34], 3);
              ip = 96;
      end

         96 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[29]*7 + 1] = heapMem[localMem[29]*7 + 1] + 1;
              updateArrayLength(1, localMem[29], 1);
              ip = 97;
      end

         97 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[34]*7 + 1] = heapMem[localMem[29]*7 + 1];
              updateArrayLength(1, localMem[34], 1);
              ip = 98;
      end

         98 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[37] = !heapMem[localMem[26]*7 + 6];
              ip = 99;
      end

         99 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[37] != 0 ? 128 : 100;
      end

        100 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[38] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[38] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[38]] = 0;
              ip = 101;
      end

        101 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[34]*7 + 6] = localMem[38];
              updateArrayLength(1, localMem[34], 6);
              ip = 102;
      end

        102 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[39] = heapMem[localMem[26]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 103;
      end

        103 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[40] = heapMem[localMem[34]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 104;
      end

        104 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[31]) begin
                  heapMem[NArea * localMem[40] + 0 + i] = heapMem[NArea * localMem[39] + localMem[32] + i];
                  updateArrayLength(1, localMem[40], 0 + i);
                end
              end
              ip = 105;
      end

        105 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[41] = heapMem[localMem[26]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 106;
      end

        106 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[42] = heapMem[localMem[34]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 107;
      end

        107 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[31]) begin
                  heapMem[NArea * localMem[42] + 0 + i] = heapMem[NArea * localMem[41] + localMem[32] + i];
                  updateArrayLength(1, localMem[42], 0 + i);
                end
              end
              ip = 108;
      end

        108 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[43] = heapMem[localMem[26]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 109;
      end

        109 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[44] = heapMem[localMem[34]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 110;
      end

        110 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[45] = localMem[31] + 1;
              updateArrayLength(2, 0, 0);
              ip = 111;
      end

        111 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[45]) begin
                  heapMem[NArea * localMem[44] + 0 + i] = heapMem[NArea * localMem[43] + localMem[32] + i];
                  updateArrayLength(1, localMem[44], 0 + i);
                end
              end
              ip = 112;
      end

        112 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[46] = heapMem[localMem[34]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 113;
      end

        113 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[47] = localMem[46] + 1;
              updateArrayLength(2, 0, 0);
              ip = 114;
      end

        114 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[48] = heapMem[localMem[34]*7 + 6];
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
              localMem[49] = 0;
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
              ip = localMem[49] >= localMem[47] ? 124 : 119;
      end

        119 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[50] = heapMem[localMem[48]*7 + localMem[49]];
              updateArrayLength(2, 0, 0);
              ip = 120;
      end

        120 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[50]*7 + 2] = localMem[34];
              updateArrayLength(1, localMem[50], 2);
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
              localMem[49] = localMem[49] + 1;
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
              localMem[51] = heapMem[localMem[26]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 126;
      end

        126 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[51]] = localMem[32];
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
              localMem[52] = heapMem[localMem[26]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 130;
      end

        130 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[53] = heapMem[localMem[34]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 131;
      end

        131 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[31]) begin
                  heapMem[NArea * localMem[53] + 0 + i] = heapMem[NArea * localMem[52] + localMem[32] + i];
                  updateArrayLength(1, localMem[53], 0 + i);
                end
              end
              ip = 132;
      end

        132 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[54] = heapMem[localMem[26]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 133;
      end

        133 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[55] = heapMem[localMem[34]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 134;
      end

        134 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[31]) begin
                  heapMem[NArea * localMem[55] + 0 + i] = heapMem[NArea * localMem[54] + localMem[32] + i];
                  updateArrayLength(1, localMem[55], 0 + i);
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
              heapMem[localMem[26]*7 + 0] = localMem[31];
              updateArrayLength(1, localMem[26], 0);
              ip = 137;
      end

        137 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[34]*7 + 2] = localMem[33];
              updateArrayLength(1, localMem[34], 2);
              ip = 138;
      end

        138 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[56] = heapMem[localMem[33]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 139;
      end

        139 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[57] = heapMem[localMem[33]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 140;
      end

        140 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[58] = heapMem[localMem[57]*7 + localMem[56]];
              updateArrayLength(2, 0, 0);
              ip = 141;
      end

        141 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[58] != localMem[26] ? 160 : 142;
      end

        142 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[59] = heapMem[localMem[26]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 143;
      end

        143 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[60] = heapMem[localMem[59]*7 + localMem[31]];
              updateArrayLength(2, 0, 0);
              ip = 144;
      end

        144 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[61] = heapMem[localMem[33]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 145;
      end

        145 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[61]*7 + localMem[56]] = localMem[60];
              updateArrayLength(1, localMem[61], localMem[56]);
              ip = 146;
      end

        146 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[62] = heapMem[localMem[26]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 147;
      end

        147 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[63] = heapMem[localMem[62]*7 + localMem[31]];
              updateArrayLength(2, 0, 0);
              ip = 148;
      end

        148 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[64] = heapMem[localMem[33]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 149;
      end

        149 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[64]*7 + localMem[56]] = localMem[63];
              updateArrayLength(1, localMem[64], localMem[56]);
              ip = 150;
      end

        150 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[65] = heapMem[localMem[26]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 151;
      end

        151 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[65]] = localMem[31];
              ip = 152;
      end

        152 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[66] = heapMem[localMem[26]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 153;
      end

        153 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[66]] = localMem[31];
              ip = 154;
      end

        154 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[67] = localMem[56] + 1;
              updateArrayLength(2, 0, 0);
              ip = 155;
      end

        155 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[33]*7 + 0] = localMem[67];
              updateArrayLength(1, localMem[33], 0);
              ip = 156;
      end

        156 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[68] = heapMem[localMem[33]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 157;
      end

        157 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[68]*7 + localMem[67]] = localMem[34];
              updateArrayLength(1, localMem[68], localMem[67]);
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
              localMem[69] = heapMem[localMem[33]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 163;
      end

        163 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[70] = 0; k = arraySizes[localMem[69]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[69] * NArea + i] == localMem[26]) localMem[70] = i + 1;
              end
              ip = 164;
      end

        164 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[70] = localMem[70] - 1;
              updateArrayLength(2, 0, 0);
              ip = 165;
      end

        165 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[71] = heapMem[localMem[26]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 166;
      end

        166 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[72] = heapMem[localMem[71]*7 + localMem[31]];
              updateArrayLength(2, 0, 0);
              ip = 167;
      end

        167 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[73] = heapMem[localMem[26]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 168;
      end

        168 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[74] = heapMem[localMem[73]*7 + localMem[31]];
              updateArrayLength(2, 0, 0);
              ip = 169;
      end

        169 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[75] = heapMem[localMem[26]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 170;
      end

        170 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[75]] = localMem[31];
              ip = 171;
      end

        171 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[76] = heapMem[localMem[26]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 172;
      end

        172 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[76]] = localMem[31];
              ip = 173;
      end

        173 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[77] = heapMem[localMem[33]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 174;
      end

        174 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[77] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[70], localMem[77], arraySizes[localMem[77]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[70] && i <= arraySizes[localMem[77]]) begin
                  heapMem[NArea * localMem[77] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[77] + localMem[70]] = localMem[72];                                    // Insert new value
              arraySizes[localMem[77]] = arraySizes[localMem[77]] + 1;                              // Increase array size
              ip = 175;
      end

        175 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[78] = heapMem[localMem[33]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 176;
      end

        176 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[78] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[70], localMem[78], arraySizes[localMem[78]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[70] && i <= arraySizes[localMem[78]]) begin
                  heapMem[NArea * localMem[78] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[78] + localMem[70]] = localMem[74];                                    // Insert new value
              arraySizes[localMem[78]] = arraySizes[localMem[78]] + 1;                              // Increase array size
              ip = 177;
      end

        177 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[79] = heapMem[localMem[33]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 178;
      end

        178 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[80] = localMem[70] + 1;
              updateArrayLength(2, 0, 0);
              ip = 179;
      end

        179 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[79] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[80], localMem[79], arraySizes[localMem[79]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[80] && i <= arraySizes[localMem[79]]) begin
                  heapMem[NArea * localMem[79] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[79] + localMem[80]] = localMem[34];                                    // Insert new value
              arraySizes[localMem[79]] = arraySizes[localMem[79]] + 1;                              // Increase array size
              ip = 180;
      end

        180 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[33]*7 + 0] = heapMem[localMem[33]*7 + 0] + 1;
              updateArrayLength(1, localMem[33], 0);
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
                localMem[81] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[81] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[81]] = 0;
              ip = 185;
      end

        185 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[81]*7 + 0] = localMem[31];
              updateArrayLength(1, localMem[81], 0);
              ip = 186;
      end

        186 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[81]*7 + 2] = 0;
              updateArrayLength(1, localMem[81], 2);
              ip = 187;
      end

        187 :
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
              ip = 188;
      end

        188 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[81]*7 + 4] = localMem[82];
              updateArrayLength(1, localMem[81], 4);
              ip = 189;
      end

        189 :
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
              ip = 190;
      end

        190 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[81]*7 + 5] = localMem[83];
              updateArrayLength(1, localMem[81], 5);
              ip = 191;
      end

        191 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[81]*7 + 6] = 0;
              updateArrayLength(1, localMem[81], 6);
              ip = 192;
      end

        192 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[81]*7 + 3] = localMem[29];
              updateArrayLength(1, localMem[81], 3);
              ip = 193;
      end

        193 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[29]*7 + 1] = heapMem[localMem[29]*7 + 1] + 1;
              updateArrayLength(1, localMem[29], 1);
              ip = 194;
      end

        194 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[81]*7 + 1] = heapMem[localMem[29]*7 + 1];
              updateArrayLength(1, localMem[81], 1);
              ip = 195;
      end

        195 :
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
              ip = 196;
      end

        196 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[84]*7 + 0] = localMem[31];
              updateArrayLength(1, localMem[84], 0);
              ip = 197;
      end

        197 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[84]*7 + 2] = 0;
              updateArrayLength(1, localMem[84], 2);
              ip = 198;
      end

        198 :
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
              ip = 199;
      end

        199 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[84]*7 + 4] = localMem[85];
              updateArrayLength(1, localMem[84], 4);
              ip = 200;
      end

        200 :
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
              ip = 201;
      end

        201 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[84]*7 + 5] = localMem[86];
              updateArrayLength(1, localMem[84], 5);
              ip = 202;
      end

        202 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[84]*7 + 6] = 0;
              updateArrayLength(1, localMem[84], 6);
              ip = 203;
      end

        203 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[84]*7 + 3] = localMem[29];
              updateArrayLength(1, localMem[84], 3);
              ip = 204;
      end

        204 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[29]*7 + 1] = heapMem[localMem[29]*7 + 1] + 1;
              updateArrayLength(1, localMem[29], 1);
              ip = 205;
      end

        205 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[84]*7 + 1] = heapMem[localMem[29]*7 + 1];
              updateArrayLength(1, localMem[84], 1);
              ip = 206;
      end

        206 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[87] = !heapMem[localMem[26]*7 + 6];
              ip = 207;
      end

        207 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[87] != 0 ? 259 : 208;
      end

        208 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[88] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[88] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[88]] = 0;
              ip = 209;
      end

        209 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[81]*7 + 6] = localMem[88];
              updateArrayLength(1, localMem[81], 6);
              ip = 210;
      end

        210 :
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
              ip = 211;
      end

        211 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[84]*7 + 6] = localMem[89];
              updateArrayLength(1, localMem[84], 6);
              ip = 212;
      end

        212 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[90] = heapMem[localMem[26]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 213;
      end

        213 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[91] = heapMem[localMem[81]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 214;
      end

        214 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[31]) begin
                  heapMem[NArea * localMem[91] + 0 + i] = heapMem[NArea * localMem[90] + 0 + i];
                  updateArrayLength(1, localMem[91], 0 + i);
                end
              end
              ip = 215;
      end

        215 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[92] = heapMem[localMem[26]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 216;
      end

        216 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[93] = heapMem[localMem[81]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 217;
      end

        217 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[31]) begin
                  heapMem[NArea * localMem[93] + 0 + i] = heapMem[NArea * localMem[92] + 0 + i];
                  updateArrayLength(1, localMem[93], 0 + i);
                end
              end
              ip = 218;
      end

        218 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[94] = heapMem[localMem[26]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 219;
      end

        219 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[95] = heapMem[localMem[81]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 220;
      end

        220 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[96] = localMem[31] + 1;
              updateArrayLength(2, 0, 0);
              ip = 221;
      end

        221 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[96]) begin
                  heapMem[NArea * localMem[95] + 0 + i] = heapMem[NArea * localMem[94] + 0 + i];
                  updateArrayLength(1, localMem[95], 0 + i);
                end
              end
              ip = 222;
      end

        222 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[97] = heapMem[localMem[26]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 223;
      end

        223 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[98] = heapMem[localMem[84]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 224;
      end

        224 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[31]) begin
                  heapMem[NArea * localMem[98] + 0 + i] = heapMem[NArea * localMem[97] + localMem[32] + i];
                  updateArrayLength(1, localMem[98], 0 + i);
                end
              end
              ip = 225;
      end

        225 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[99] = heapMem[localMem[26]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 226;
      end

        226 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[100] = heapMem[localMem[84]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 227;
      end

        227 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[31]) begin
                  heapMem[NArea * localMem[100] + 0 + i] = heapMem[NArea * localMem[99] + localMem[32] + i];
                  updateArrayLength(1, localMem[100], 0 + i);
                end
              end
              ip = 228;
      end

        228 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[101] = heapMem[localMem[26]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 229;
      end

        229 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[102] = heapMem[localMem[84]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 230;
      end

        230 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[103] = localMem[31] + 1;
              updateArrayLength(2, 0, 0);
              ip = 231;
      end

        231 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[103]) begin
                  heapMem[NArea * localMem[102] + 0 + i] = heapMem[NArea * localMem[101] + localMem[32] + i];
                  updateArrayLength(1, localMem[102], 0 + i);
                end
              end
              ip = 232;
      end

        232 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[104] = heapMem[localMem[81]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 233;
      end

        233 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[105] = localMem[104] + 1;
              updateArrayLength(2, 0, 0);
              ip = 234;
      end

        234 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[106] = heapMem[localMem[81]*7 + 6];
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
              localMem[107] = 0;
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
              ip = localMem[107] >= localMem[105] ? 244 : 239;
      end

        239 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[108] = heapMem[localMem[106]*7 + localMem[107]];
              updateArrayLength(2, 0, 0);
              ip = 240;
      end

        240 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[108]*7 + 2] = localMem[81];
              updateArrayLength(1, localMem[108], 2);
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
              localMem[107] = localMem[107] + 1;
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
              localMem[109] = heapMem[localMem[84]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 246;
      end

        246 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[110] = localMem[109] + 1;
              updateArrayLength(2, 0, 0);
              ip = 247;
      end

        247 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[111] = heapMem[localMem[84]*7 + 6];
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
              localMem[112] = 0;
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
              ip = localMem[112] >= localMem[110] ? 257 : 252;
      end

        252 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[113] = heapMem[localMem[111]*7 + localMem[112]];
              updateArrayLength(2, 0, 0);
              ip = 253;
      end

        253 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[113]*7 + 2] = localMem[84];
              updateArrayLength(1, localMem[113], 2);
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
              localMem[112] = localMem[112] + 1;
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
                localMem[114] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[114] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[114]] = 0;
              ip = 261;
      end

        261 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[26]*7 + 6] = localMem[114];
              updateArrayLength(1, localMem[26], 6);
              ip = 262;
      end

        262 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[115] = heapMem[localMem[26]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 263;
      end

        263 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[116] = heapMem[localMem[81]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 264;
      end

        264 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[31]) begin
                  heapMem[NArea * localMem[116] + 0 + i] = heapMem[NArea * localMem[115] + 0 + i];
                  updateArrayLength(1, localMem[116], 0 + i);
                end
              end
              ip = 265;
      end

        265 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[117] = heapMem[localMem[26]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 266;
      end

        266 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[118] = heapMem[localMem[81]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 267;
      end

        267 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[31]) begin
                  heapMem[NArea * localMem[118] + 0 + i] = heapMem[NArea * localMem[117] + 0 + i];
                  updateArrayLength(1, localMem[118], 0 + i);
                end
              end
              ip = 268;
      end

        268 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[119] = heapMem[localMem[26]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 269;
      end

        269 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[120] = heapMem[localMem[84]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 270;
      end

        270 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[31]) begin
                  heapMem[NArea * localMem[120] + 0 + i] = heapMem[NArea * localMem[119] + localMem[32] + i];
                  updateArrayLength(1, localMem[120], 0 + i);
                end
              end
              ip = 271;
      end

        271 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[121] = heapMem[localMem[26]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 272;
      end

        272 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[122] = heapMem[localMem[84]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 273;
      end

        273 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[31]) begin
                  heapMem[NArea * localMem[122] + 0 + i] = heapMem[NArea * localMem[121] + localMem[32] + i];
                  updateArrayLength(1, localMem[122], 0 + i);
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
              heapMem[localMem[81]*7 + 2] = localMem[26];
              updateArrayLength(1, localMem[81], 2);
              ip = 276;
      end

        276 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[84]*7 + 2] = localMem[26];
              updateArrayLength(1, localMem[84], 2);
              ip = 277;
      end

        277 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[123] = heapMem[localMem[26]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 278;
      end

        278 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[124] = heapMem[localMem[123]*7 + localMem[31]];
              updateArrayLength(2, 0, 0);
              ip = 279;
      end

        279 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[125] = heapMem[localMem[26]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 280;
      end

        280 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[126] = heapMem[localMem[125]*7 + localMem[31]];
              updateArrayLength(2, 0, 0);
              ip = 281;
      end

        281 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[127] = heapMem[localMem[26]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 282;
      end

        282 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[127]*7 + 0] = localMem[124];
              updateArrayLength(1, localMem[127], 0);
              ip = 283;
      end

        283 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[128] = heapMem[localMem[26]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 284;
      end

        284 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[128]*7 + 0] = localMem[126];
              updateArrayLength(1, localMem[128], 0);
              ip = 285;
      end

        285 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[129] = heapMem[localMem[26]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 286;
      end

        286 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[129]*7 + 0] = localMem[81];
              updateArrayLength(1, localMem[129], 0);
              ip = 287;
      end

        287 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[130] = heapMem[localMem[26]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 288;
      end

        288 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[130]*7 + 1] = localMem[84];
              updateArrayLength(1, localMem[130], 1);
              ip = 289;
      end

        289 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[26]*7 + 0] = 1;
              updateArrayLength(1, localMem[26], 0);
              ip = 290;
      end

        290 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[131] = heapMem[localMem[26]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 291;
      end

        291 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[131]] = 1;
              ip = 292;
      end

        292 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[132] = heapMem[localMem[26]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 293;
      end

        293 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[132]] = 1;
              ip = 294;
      end

        294 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[133] = heapMem[localMem[26]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 295;
      end

        295 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[133]] = 2;
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
              localMem[27] = 1;
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
              localMem[27] = 0;
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
              localMem[134] = 0;
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
              ip = localMem[134] >= 99 ? 806 : 309;
      end

        309 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[135] = heapMem[localMem[26]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 310;
      end

        310 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[136] = localMem[135] - 1;
              updateArrayLength(2, 0, 0);
              ip = 311;
      end

        311 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[137] = heapMem[localMem[26]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 312;
      end

        312 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[138] = heapMem[localMem[137]*7 + localMem[136]];
              updateArrayLength(2, 0, 0);
              ip = 313;
      end

        313 :
      begin                                                                     // jLe
if (0) begin
  $display("AAAA %4d %4d jLe", steps, ip);
end
              ip = localMem[1] <= localMem[138] ? 554 : 314;
      end

        314 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[139] = !heapMem[localMem[26]*7 + 6];
              ip = 315;
      end

        315 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[139] == 0 ? 320 : 316;
      end

        316 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[3]*7 + 0] = localMem[26];
              updateArrayLength(1, localMem[3], 0);
              ip = 317;
      end

        317 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[3]*7 + 1] = 2;
              updateArrayLength(1, localMem[3], 1);
              ip = 318;
      end

        318 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              heapMem[localMem[3]*7 + 2] = localMem[135] - 1;
              updateArrayLength(1, localMem[3], 2);
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
              localMem[140] = heapMem[localMem[26]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 322;
      end

        322 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[141] = heapMem[localMem[140]*7 + localMem[135]];
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
              localMem[143] = heapMem[localMem[141]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 325;
      end

        325 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[144] = heapMem[localMem[141]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 326;
      end

        326 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[145] = heapMem[localMem[144]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 327;
      end

        327 :
      begin                                                                     // jLt
if (0) begin
  $display("AAAA %4d %4d jLt", steps, ip);
end
              ip = localMem[143] <  localMem[145] ? 547 : 328;
      end

        328 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[146] = localMem[145];
              updateArrayLength(2, 0, 0);
              ip = 329;
      end

        329 :
      begin                                                                     // shiftRight
if (0) begin
  $display("AAAA %4d %4d shiftRight", steps, ip);
end
              localMem[146] = localMem[146] >> 1;
              ip = 330;
      end

        330 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[147] = localMem[146] + 1;
              updateArrayLength(2, 0, 0);
              ip = 331;
      end

        331 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[148] = heapMem[localMem[141]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 332;
      end

        332 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[148] == 0 ? 429 : 333;
      end

        333 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[149] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[149] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[149]] = 0;
              ip = 334;
      end

        334 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[149]*7 + 0] = localMem[146];
              updateArrayLength(1, localMem[149], 0);
              ip = 335;
      end

        335 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[149]*7 + 2] = 0;
              updateArrayLength(1, localMem[149], 2);
              ip = 336;
      end

        336 :
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
              ip = 337;
      end

        337 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[149]*7 + 4] = localMem[150];
              updateArrayLength(1, localMem[149], 4);
              ip = 338;
      end

        338 :
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
              ip = 339;
      end

        339 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[149]*7 + 5] = localMem[151];
              updateArrayLength(1, localMem[149], 5);
              ip = 340;
      end

        340 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[149]*7 + 6] = 0;
              updateArrayLength(1, localMem[149], 6);
              ip = 341;
      end

        341 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[149]*7 + 3] = localMem[144];
              updateArrayLength(1, localMem[149], 3);
              ip = 342;
      end

        342 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[144]*7 + 1] = heapMem[localMem[144]*7 + 1] + 1;
              updateArrayLength(1, localMem[144], 1);
              ip = 343;
      end

        343 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[149]*7 + 1] = heapMem[localMem[144]*7 + 1];
              updateArrayLength(1, localMem[149], 1);
              ip = 344;
      end

        344 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[152] = !heapMem[localMem[141]*7 + 6];
              ip = 345;
      end

        345 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[152] != 0 ? 374 : 346;
      end

        346 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[153] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[153] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[153]] = 0;
              ip = 347;
      end

        347 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[149]*7 + 6] = localMem[153];
              updateArrayLength(1, localMem[149], 6);
              ip = 348;
      end

        348 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[154] = heapMem[localMem[141]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 349;
      end

        349 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[155] = heapMem[localMem[149]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 350;
      end

        350 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[146]) begin
                  heapMem[NArea * localMem[155] + 0 + i] = heapMem[NArea * localMem[154] + localMem[147] + i];
                  updateArrayLength(1, localMem[155], 0 + i);
                end
              end
              ip = 351;
      end

        351 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[156] = heapMem[localMem[141]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 352;
      end

        352 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[157] = heapMem[localMem[149]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 353;
      end

        353 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[146]) begin
                  heapMem[NArea * localMem[157] + 0 + i] = heapMem[NArea * localMem[156] + localMem[147] + i];
                  updateArrayLength(1, localMem[157], 0 + i);
                end
              end
              ip = 354;
      end

        354 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[158] = heapMem[localMem[141]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 355;
      end

        355 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[159] = heapMem[localMem[149]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 356;
      end

        356 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[160] = localMem[146] + 1;
              updateArrayLength(2, 0, 0);
              ip = 357;
      end

        357 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[160]) begin
                  heapMem[NArea * localMem[159] + 0 + i] = heapMem[NArea * localMem[158] + localMem[147] + i];
                  updateArrayLength(1, localMem[159], 0 + i);
                end
              end
              ip = 358;
      end

        358 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[161] = heapMem[localMem[149]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 359;
      end

        359 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[162] = localMem[161] + 1;
              updateArrayLength(2, 0, 0);
              ip = 360;
      end

        360 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[163] = heapMem[localMem[149]*7 + 6];
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
              localMem[164] = 0;
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
              ip = localMem[164] >= localMem[162] ? 370 : 365;
      end

        365 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[165] = heapMem[localMem[163]*7 + localMem[164]];
              updateArrayLength(2, 0, 0);
              ip = 366;
      end

        366 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[165]*7 + 2] = localMem[149];
              updateArrayLength(1, localMem[165], 2);
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
              localMem[164] = localMem[164] + 1;
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
              localMem[166] = heapMem[localMem[141]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 372;
      end

        372 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[166]] = localMem[147];
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
              localMem[167] = heapMem[localMem[141]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 376;
      end

        376 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[168] = heapMem[localMem[149]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 377;
      end

        377 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[146]) begin
                  heapMem[NArea * localMem[168] + 0 + i] = heapMem[NArea * localMem[167] + localMem[147] + i];
                  updateArrayLength(1, localMem[168], 0 + i);
                end
              end
              ip = 378;
      end

        378 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[169] = heapMem[localMem[141]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 379;
      end

        379 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[170] = heapMem[localMem[149]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 380;
      end

        380 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[146]) begin
                  heapMem[NArea * localMem[170] + 0 + i] = heapMem[NArea * localMem[169] + localMem[147] + i];
                  updateArrayLength(1, localMem[170], 0 + i);
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
              heapMem[localMem[141]*7 + 0] = localMem[146];
              updateArrayLength(1, localMem[141], 0);
              ip = 383;
      end

        383 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[149]*7 + 2] = localMem[148];
              updateArrayLength(1, localMem[149], 2);
              ip = 384;
      end

        384 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[171] = heapMem[localMem[148]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 385;
      end

        385 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[172] = heapMem[localMem[148]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 386;
      end

        386 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[173] = heapMem[localMem[172]*7 + localMem[171]];
              updateArrayLength(2, 0, 0);
              ip = 387;
      end

        387 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[173] != localMem[141] ? 406 : 388;
      end

        388 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[174] = heapMem[localMem[141]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 389;
      end

        389 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[175] = heapMem[localMem[174]*7 + localMem[146]];
              updateArrayLength(2, 0, 0);
              ip = 390;
      end

        390 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[176] = heapMem[localMem[148]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 391;
      end

        391 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[176]*7 + localMem[171]] = localMem[175];
              updateArrayLength(1, localMem[176], localMem[171]);
              ip = 392;
      end

        392 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[177] = heapMem[localMem[141]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 393;
      end

        393 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[178] = heapMem[localMem[177]*7 + localMem[146]];
              updateArrayLength(2, 0, 0);
              ip = 394;
      end

        394 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[179] = heapMem[localMem[148]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 395;
      end

        395 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[179]*7 + localMem[171]] = localMem[178];
              updateArrayLength(1, localMem[179], localMem[171]);
              ip = 396;
      end

        396 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[180] = heapMem[localMem[141]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 397;
      end

        397 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[180]] = localMem[146];
              ip = 398;
      end

        398 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[181] = heapMem[localMem[141]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 399;
      end

        399 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[181]] = localMem[146];
              ip = 400;
      end

        400 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[182] = localMem[171] + 1;
              updateArrayLength(2, 0, 0);
              ip = 401;
      end

        401 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[148]*7 + 0] = localMem[182];
              updateArrayLength(1, localMem[148], 0);
              ip = 402;
      end

        402 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[183] = heapMem[localMem[148]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 403;
      end

        403 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[183]*7 + localMem[182]] = localMem[149];
              updateArrayLength(1, localMem[183], localMem[182]);
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
              localMem[184] = heapMem[localMem[148]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 409;
      end

        409 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[185] = 0; k = arraySizes[localMem[184]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[184] * NArea + i] == localMem[141]) localMem[185] = i + 1;
              end
              ip = 410;
      end

        410 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[185] = localMem[185] - 1;
              updateArrayLength(2, 0, 0);
              ip = 411;
      end

        411 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[186] = heapMem[localMem[141]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 412;
      end

        412 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[187] = heapMem[localMem[186]*7 + localMem[146]];
              updateArrayLength(2, 0, 0);
              ip = 413;
      end

        413 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[188] = heapMem[localMem[141]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 414;
      end

        414 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[189] = heapMem[localMem[188]*7 + localMem[146]];
              updateArrayLength(2, 0, 0);
              ip = 415;
      end

        415 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[190] = heapMem[localMem[141]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 416;
      end

        416 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[190]] = localMem[146];
              ip = 417;
      end

        417 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[191] = heapMem[localMem[141]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 418;
      end

        418 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[191]] = localMem[146];
              ip = 419;
      end

        419 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[192] = heapMem[localMem[148]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 420;
      end

        420 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[192] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[185], localMem[192], arraySizes[localMem[192]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[185] && i <= arraySizes[localMem[192]]) begin
                  heapMem[NArea * localMem[192] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[192] + localMem[185]] = localMem[187];                                    // Insert new value
              arraySizes[localMem[192]] = arraySizes[localMem[192]] + 1;                              // Increase array size
              ip = 421;
      end

        421 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[193] = heapMem[localMem[148]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 422;
      end

        422 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[193] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[185], localMem[193], arraySizes[localMem[193]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[185] && i <= arraySizes[localMem[193]]) begin
                  heapMem[NArea * localMem[193] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[193] + localMem[185]] = localMem[189];                                    // Insert new value
              arraySizes[localMem[193]] = arraySizes[localMem[193]] + 1;                              // Increase array size
              ip = 423;
      end

        423 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[194] = heapMem[localMem[148]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 424;
      end

        424 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[195] = localMem[185] + 1;
              updateArrayLength(2, 0, 0);
              ip = 425;
      end

        425 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[194] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[195], localMem[194], arraySizes[localMem[194]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[195] && i <= arraySizes[localMem[194]]) begin
                  heapMem[NArea * localMem[194] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[194] + localMem[195]] = localMem[149];                                    // Insert new value
              arraySizes[localMem[194]] = arraySizes[localMem[194]] + 1;                              // Increase array size
              ip = 426;
      end

        426 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[148]*7 + 0] = heapMem[localMem[148]*7 + 0] + 1;
              updateArrayLength(1, localMem[148], 0);
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
                localMem[196] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[196] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[196]] = 0;
              ip = 431;
      end

        431 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[196]*7 + 0] = localMem[146];
              updateArrayLength(1, localMem[196], 0);
              ip = 432;
      end

        432 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[196]*7 + 2] = 0;
              updateArrayLength(1, localMem[196], 2);
              ip = 433;
      end

        433 :
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
              ip = 434;
      end

        434 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[196]*7 + 4] = localMem[197];
              updateArrayLength(1, localMem[196], 4);
              ip = 435;
      end

        435 :
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
              ip = 436;
      end

        436 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[196]*7 + 5] = localMem[198];
              updateArrayLength(1, localMem[196], 5);
              ip = 437;
      end

        437 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[196]*7 + 6] = 0;
              updateArrayLength(1, localMem[196], 6);
              ip = 438;
      end

        438 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[196]*7 + 3] = localMem[144];
              updateArrayLength(1, localMem[196], 3);
              ip = 439;
      end

        439 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[144]*7 + 1] = heapMem[localMem[144]*7 + 1] + 1;
              updateArrayLength(1, localMem[144], 1);
              ip = 440;
      end

        440 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[196]*7 + 1] = heapMem[localMem[144]*7 + 1];
              updateArrayLength(1, localMem[196], 1);
              ip = 441;
      end

        441 :
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
              ip = 442;
      end

        442 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[199]*7 + 0] = localMem[146];
              updateArrayLength(1, localMem[199], 0);
              ip = 443;
      end

        443 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[199]*7 + 2] = 0;
              updateArrayLength(1, localMem[199], 2);
              ip = 444;
      end

        444 :
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
              ip = 445;
      end

        445 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[199]*7 + 4] = localMem[200];
              updateArrayLength(1, localMem[199], 4);
              ip = 446;
      end

        446 :
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
              ip = 447;
      end

        447 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[199]*7 + 5] = localMem[201];
              updateArrayLength(1, localMem[199], 5);
              ip = 448;
      end

        448 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[199]*7 + 6] = 0;
              updateArrayLength(1, localMem[199], 6);
              ip = 449;
      end

        449 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[199]*7 + 3] = localMem[144];
              updateArrayLength(1, localMem[199], 3);
              ip = 450;
      end

        450 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[144]*7 + 1] = heapMem[localMem[144]*7 + 1] + 1;
              updateArrayLength(1, localMem[144], 1);
              ip = 451;
      end

        451 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[199]*7 + 1] = heapMem[localMem[144]*7 + 1];
              updateArrayLength(1, localMem[199], 1);
              ip = 452;
      end

        452 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[202] = !heapMem[localMem[141]*7 + 6];
              ip = 453;
      end

        453 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[202] != 0 ? 505 : 454;
      end

        454 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[203] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[203] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[203]] = 0;
              ip = 455;
      end

        455 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[196]*7 + 6] = localMem[203];
              updateArrayLength(1, localMem[196], 6);
              ip = 456;
      end

        456 :
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
              ip = 457;
      end

        457 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[199]*7 + 6] = localMem[204];
              updateArrayLength(1, localMem[199], 6);
              ip = 458;
      end

        458 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[205] = heapMem[localMem[141]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 459;
      end

        459 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[206] = heapMem[localMem[196]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 460;
      end

        460 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[146]) begin
                  heapMem[NArea * localMem[206] + 0 + i] = heapMem[NArea * localMem[205] + 0 + i];
                  updateArrayLength(1, localMem[206], 0 + i);
                end
              end
              ip = 461;
      end

        461 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[207] = heapMem[localMem[141]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 462;
      end

        462 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[208] = heapMem[localMem[196]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 463;
      end

        463 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[146]) begin
                  heapMem[NArea * localMem[208] + 0 + i] = heapMem[NArea * localMem[207] + 0 + i];
                  updateArrayLength(1, localMem[208], 0 + i);
                end
              end
              ip = 464;
      end

        464 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[209] = heapMem[localMem[141]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 465;
      end

        465 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[210] = heapMem[localMem[196]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 466;
      end

        466 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[211] = localMem[146] + 1;
              updateArrayLength(2, 0, 0);
              ip = 467;
      end

        467 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[211]) begin
                  heapMem[NArea * localMem[210] + 0 + i] = heapMem[NArea * localMem[209] + 0 + i];
                  updateArrayLength(1, localMem[210], 0 + i);
                end
              end
              ip = 468;
      end

        468 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[212] = heapMem[localMem[141]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 469;
      end

        469 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[213] = heapMem[localMem[199]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 470;
      end

        470 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[146]) begin
                  heapMem[NArea * localMem[213] + 0 + i] = heapMem[NArea * localMem[212] + localMem[147] + i];
                  updateArrayLength(1, localMem[213], 0 + i);
                end
              end
              ip = 471;
      end

        471 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[214] = heapMem[localMem[141]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 472;
      end

        472 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[215] = heapMem[localMem[199]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 473;
      end

        473 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[146]) begin
                  heapMem[NArea * localMem[215] + 0 + i] = heapMem[NArea * localMem[214] + localMem[147] + i];
                  updateArrayLength(1, localMem[215], 0 + i);
                end
              end
              ip = 474;
      end

        474 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[216] = heapMem[localMem[141]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 475;
      end

        475 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[217] = heapMem[localMem[199]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 476;
      end

        476 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[218] = localMem[146] + 1;
              updateArrayLength(2, 0, 0);
              ip = 477;
      end

        477 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[218]) begin
                  heapMem[NArea * localMem[217] + 0 + i] = heapMem[NArea * localMem[216] + localMem[147] + i];
                  updateArrayLength(1, localMem[217], 0 + i);
                end
              end
              ip = 478;
      end

        478 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[219] = heapMem[localMem[196]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 479;
      end

        479 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[220] = localMem[219] + 1;
              updateArrayLength(2, 0, 0);
              ip = 480;
      end

        480 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[221] = heapMem[localMem[196]*7 + 6];
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
              localMem[222] = 0;
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
              ip = localMem[222] >= localMem[220] ? 490 : 485;
      end

        485 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[223] = heapMem[localMem[221]*7 + localMem[222]];
              updateArrayLength(2, 0, 0);
              ip = 486;
      end

        486 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[223]*7 + 2] = localMem[196];
              updateArrayLength(1, localMem[223], 2);
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
              localMem[222] = localMem[222] + 1;
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
              localMem[224] = heapMem[localMem[199]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 492;
      end

        492 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[225] = localMem[224] + 1;
              updateArrayLength(2, 0, 0);
              ip = 493;
      end

        493 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[226] = heapMem[localMem[199]*7 + 6];
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
              localMem[227] = 0;
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
              ip = localMem[227] >= localMem[225] ? 503 : 498;
      end

        498 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[228] = heapMem[localMem[226]*7 + localMem[227]];
              updateArrayLength(2, 0, 0);
              ip = 499;
      end

        499 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[228]*7 + 2] = localMem[199];
              updateArrayLength(1, localMem[228], 2);
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
              localMem[227] = localMem[227] + 1;
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
                localMem[229] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[229] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[229]] = 0;
              ip = 507;
      end

        507 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[141]*7 + 6] = localMem[229];
              updateArrayLength(1, localMem[141], 6);
              ip = 508;
      end

        508 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[230] = heapMem[localMem[141]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 509;
      end

        509 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[231] = heapMem[localMem[196]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 510;
      end

        510 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[146]) begin
                  heapMem[NArea * localMem[231] + 0 + i] = heapMem[NArea * localMem[230] + 0 + i];
                  updateArrayLength(1, localMem[231], 0 + i);
                end
              end
              ip = 511;
      end

        511 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[232] = heapMem[localMem[141]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 512;
      end

        512 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[233] = heapMem[localMem[196]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 513;
      end

        513 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[146]) begin
                  heapMem[NArea * localMem[233] + 0 + i] = heapMem[NArea * localMem[232] + 0 + i];
                  updateArrayLength(1, localMem[233], 0 + i);
                end
              end
              ip = 514;
      end

        514 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[234] = heapMem[localMem[141]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 515;
      end

        515 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[235] = heapMem[localMem[199]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 516;
      end

        516 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[146]) begin
                  heapMem[NArea * localMem[235] + 0 + i] = heapMem[NArea * localMem[234] + localMem[147] + i];
                  updateArrayLength(1, localMem[235], 0 + i);
                end
              end
              ip = 517;
      end

        517 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[236] = heapMem[localMem[141]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 518;
      end

        518 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[237] = heapMem[localMem[199]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 519;
      end

        519 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[146]) begin
                  heapMem[NArea * localMem[237] + 0 + i] = heapMem[NArea * localMem[236] + localMem[147] + i];
                  updateArrayLength(1, localMem[237], 0 + i);
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
              heapMem[localMem[196]*7 + 2] = localMem[141];
              updateArrayLength(1, localMem[196], 2);
              ip = 522;
      end

        522 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[199]*7 + 2] = localMem[141];
              updateArrayLength(1, localMem[199], 2);
              ip = 523;
      end

        523 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[238] = heapMem[localMem[141]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 524;
      end

        524 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[239] = heapMem[localMem[238]*7 + localMem[146]];
              updateArrayLength(2, 0, 0);
              ip = 525;
      end

        525 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[240] = heapMem[localMem[141]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 526;
      end

        526 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[241] = heapMem[localMem[240]*7 + localMem[146]];
              updateArrayLength(2, 0, 0);
              ip = 527;
      end

        527 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[242] = heapMem[localMem[141]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 528;
      end

        528 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[242]*7 + 0] = localMem[239];
              updateArrayLength(1, localMem[242], 0);
              ip = 529;
      end

        529 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[243] = heapMem[localMem[141]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 530;
      end

        530 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[243]*7 + 0] = localMem[241];
              updateArrayLength(1, localMem[243], 0);
              ip = 531;
      end

        531 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[244] = heapMem[localMem[141]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 532;
      end

        532 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[244]*7 + 0] = localMem[196];
              updateArrayLength(1, localMem[244], 0);
              ip = 533;
      end

        533 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[245] = heapMem[localMem[141]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 534;
      end

        534 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[245]*7 + 1] = localMem[199];
              updateArrayLength(1, localMem[245], 1);
              ip = 535;
      end

        535 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[141]*7 + 0] = 1;
              updateArrayLength(1, localMem[141], 0);
              ip = 536;
      end

        536 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[246] = heapMem[localMem[141]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 537;
      end

        537 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[246]] = 1;
              ip = 538;
      end

        538 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[247] = heapMem[localMem[141]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 539;
      end

        539 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[247]] = 1;
              ip = 540;
      end

        540 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[248] = heapMem[localMem[141]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 541;
      end

        541 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[248]] = 2;
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
              localMem[142] = 1;
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
              localMem[142] = 0;
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
              ip = localMem[142] != 0 ? 552 : 551;
      end

        551 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[26] = localMem[141];
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
              localMem[249] = heapMem[localMem[26]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 556;
      end

        556 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[250] = 0; k = arraySizes[localMem[249]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[249] * NArea + i] == localMem[1]) localMem[250] = i + 1;
              end
              ip = 557;
      end

        557 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[250] == 0 ? 562 : 558;
      end

        558 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[3]*7 + 0] = localMem[26];
              updateArrayLength(1, localMem[3], 0);
              ip = 559;
      end

        559 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[3]*7 + 1] = 1;
              updateArrayLength(1, localMem[3], 1);
              ip = 560;
      end

        560 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              heapMem[localMem[3]*7 + 2] = localMem[250] - 1;
              updateArrayLength(1, localMem[3], 2);
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
              j = 0; k = arraySizes[localMem[249]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[249] * NArea + i] < localMem[1]) j = j + 1;
              end
              localMem[251] = j;
              ip = 564;
      end

        564 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[252] = !heapMem[localMem[26]*7 + 6];
              ip = 565;
      end

        565 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[252] == 0 ? 570 : 566;
      end

        566 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[3]*7 + 0] = localMem[26];
              updateArrayLength(1, localMem[3], 0);
              ip = 567;
      end

        567 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[3]*7 + 1] = 0;
              updateArrayLength(1, localMem[3], 1);
              ip = 568;
      end

        568 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[3]*7 + 2] = localMem[251];
              updateArrayLength(1, localMem[3], 2);
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
              localMem[253] = heapMem[localMem[26]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 572;
      end

        572 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[254] = heapMem[localMem[253]*7 + localMem[251]];
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
              localMem[256] = heapMem[localMem[254]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 575;
      end

        575 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[257] = heapMem[localMem[254]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 576;
      end

        576 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[258] = heapMem[localMem[257]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 577;
      end

        577 :
      begin                                                                     // jLt
if (0) begin
  $display("AAAA %4d %4d jLt", steps, ip);
end
              ip = localMem[256] <  localMem[258] ? 797 : 578;
      end

        578 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[259] = localMem[258];
              updateArrayLength(2, 0, 0);
              ip = 579;
      end

        579 :
      begin                                                                     // shiftRight
if (0) begin
  $display("AAAA %4d %4d shiftRight", steps, ip);
end
              localMem[259] = localMem[259] >> 1;
              ip = 580;
      end

        580 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[260] = localMem[259] + 1;
              updateArrayLength(2, 0, 0);
              ip = 581;
      end

        581 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[261] = heapMem[localMem[254]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 582;
      end

        582 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[261] == 0 ? 679 : 583;
      end

        583 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[262] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[262] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[262]] = 0;
              ip = 584;
      end

        584 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[262]*7 + 0] = localMem[259];
              updateArrayLength(1, localMem[262], 0);
              ip = 585;
      end

        585 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[262]*7 + 2] = 0;
              updateArrayLength(1, localMem[262], 2);
              ip = 586;
      end

        586 :
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
              ip = 587;
      end

        587 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[262]*7 + 4] = localMem[263];
              updateArrayLength(1, localMem[262], 4);
              ip = 588;
      end

        588 :
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
              ip = 589;
      end

        589 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[262]*7 + 5] = localMem[264];
              updateArrayLength(1, localMem[262], 5);
              ip = 590;
      end

        590 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[262]*7 + 6] = 0;
              updateArrayLength(1, localMem[262], 6);
              ip = 591;
      end

        591 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[262]*7 + 3] = localMem[257];
              updateArrayLength(1, localMem[262], 3);
              ip = 592;
      end

        592 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[257]*7 + 1] = heapMem[localMem[257]*7 + 1] + 1;
              updateArrayLength(1, localMem[257], 1);
              ip = 593;
      end

        593 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[262]*7 + 1] = heapMem[localMem[257]*7 + 1];
              updateArrayLength(1, localMem[262], 1);
              ip = 594;
      end

        594 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[265] = !heapMem[localMem[254]*7 + 6];
              ip = 595;
      end

        595 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[265] != 0 ? 624 : 596;
      end

        596 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[266] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[266] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[266]] = 0;
              ip = 597;
      end

        597 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[262]*7 + 6] = localMem[266];
              updateArrayLength(1, localMem[262], 6);
              ip = 598;
      end

        598 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[267] = heapMem[localMem[254]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 599;
      end

        599 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[268] = heapMem[localMem[262]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 600;
      end

        600 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[259]) begin
                  heapMem[NArea * localMem[268] + 0 + i] = heapMem[NArea * localMem[267] + localMem[260] + i];
                  updateArrayLength(1, localMem[268], 0 + i);
                end
              end
              ip = 601;
      end

        601 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[269] = heapMem[localMem[254]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 602;
      end

        602 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[270] = heapMem[localMem[262]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 603;
      end

        603 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[259]) begin
                  heapMem[NArea * localMem[270] + 0 + i] = heapMem[NArea * localMem[269] + localMem[260] + i];
                  updateArrayLength(1, localMem[270], 0 + i);
                end
              end
              ip = 604;
      end

        604 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[271] = heapMem[localMem[254]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 605;
      end

        605 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[272] = heapMem[localMem[262]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 606;
      end

        606 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[273] = localMem[259] + 1;
              updateArrayLength(2, 0, 0);
              ip = 607;
      end

        607 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[273]) begin
                  heapMem[NArea * localMem[272] + 0 + i] = heapMem[NArea * localMem[271] + localMem[260] + i];
                  updateArrayLength(1, localMem[272], 0 + i);
                end
              end
              ip = 608;
      end

        608 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[274] = heapMem[localMem[262]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 609;
      end

        609 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[275] = localMem[274] + 1;
              updateArrayLength(2, 0, 0);
              ip = 610;
      end

        610 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[276] = heapMem[localMem[262]*7 + 6];
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
              localMem[277] = 0;
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
              ip = localMem[277] >= localMem[275] ? 620 : 615;
      end

        615 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[278] = heapMem[localMem[276]*7 + localMem[277]];
              updateArrayLength(2, 0, 0);
              ip = 616;
      end

        616 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[278]*7 + 2] = localMem[262];
              updateArrayLength(1, localMem[278], 2);
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
              localMem[277] = localMem[277] + 1;
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
              localMem[279] = heapMem[localMem[254]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 622;
      end

        622 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[279]] = localMem[260];
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
              localMem[280] = heapMem[localMem[254]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 626;
      end

        626 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[281] = heapMem[localMem[262]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 627;
      end

        627 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[259]) begin
                  heapMem[NArea * localMem[281] + 0 + i] = heapMem[NArea * localMem[280] + localMem[260] + i];
                  updateArrayLength(1, localMem[281], 0 + i);
                end
              end
              ip = 628;
      end

        628 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[282] = heapMem[localMem[254]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 629;
      end

        629 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[283] = heapMem[localMem[262]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 630;
      end

        630 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[259]) begin
                  heapMem[NArea * localMem[283] + 0 + i] = heapMem[NArea * localMem[282] + localMem[260] + i];
                  updateArrayLength(1, localMem[283], 0 + i);
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
              heapMem[localMem[254]*7 + 0] = localMem[259];
              updateArrayLength(1, localMem[254], 0);
              ip = 633;
      end

        633 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[262]*7 + 2] = localMem[261];
              updateArrayLength(1, localMem[262], 2);
              ip = 634;
      end

        634 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[284] = heapMem[localMem[261]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 635;
      end

        635 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[285] = heapMem[localMem[261]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 636;
      end

        636 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[286] = heapMem[localMem[285]*7 + localMem[284]];
              updateArrayLength(2, 0, 0);
              ip = 637;
      end

        637 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[286] != localMem[254] ? 656 : 638;
      end

        638 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[287] = heapMem[localMem[254]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 639;
      end

        639 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[288] = heapMem[localMem[287]*7 + localMem[259]];
              updateArrayLength(2, 0, 0);
              ip = 640;
      end

        640 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[289] = heapMem[localMem[261]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 641;
      end

        641 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[289]*7 + localMem[284]] = localMem[288];
              updateArrayLength(1, localMem[289], localMem[284]);
              ip = 642;
      end

        642 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[290] = heapMem[localMem[254]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 643;
      end

        643 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[291] = heapMem[localMem[290]*7 + localMem[259]];
              updateArrayLength(2, 0, 0);
              ip = 644;
      end

        644 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[292] = heapMem[localMem[261]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 645;
      end

        645 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[292]*7 + localMem[284]] = localMem[291];
              updateArrayLength(1, localMem[292], localMem[284]);
              ip = 646;
      end

        646 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[293] = heapMem[localMem[254]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 647;
      end

        647 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[293]] = localMem[259];
              ip = 648;
      end

        648 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[294] = heapMem[localMem[254]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 649;
      end

        649 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[294]] = localMem[259];
              ip = 650;
      end

        650 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[295] = localMem[284] + 1;
              updateArrayLength(2, 0, 0);
              ip = 651;
      end

        651 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[261]*7 + 0] = localMem[295];
              updateArrayLength(1, localMem[261], 0);
              ip = 652;
      end

        652 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[296] = heapMem[localMem[261]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 653;
      end

        653 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[296]*7 + localMem[295]] = localMem[262];
              updateArrayLength(1, localMem[296], localMem[295]);
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
              localMem[297] = heapMem[localMem[261]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 659;
      end

        659 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[298] = 0; k = arraySizes[localMem[297]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[297] * NArea + i] == localMem[254]) localMem[298] = i + 1;
              end
              ip = 660;
      end

        660 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[298] = localMem[298] - 1;
              updateArrayLength(2, 0, 0);
              ip = 661;
      end

        661 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[299] = heapMem[localMem[254]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 662;
      end

        662 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[300] = heapMem[localMem[299]*7 + localMem[259]];
              updateArrayLength(2, 0, 0);
              ip = 663;
      end

        663 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[301] = heapMem[localMem[254]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 664;
      end

        664 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[302] = heapMem[localMem[301]*7 + localMem[259]];
              updateArrayLength(2, 0, 0);
              ip = 665;
      end

        665 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[303] = heapMem[localMem[254]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 666;
      end

        666 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[303]] = localMem[259];
              ip = 667;
      end

        667 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[304] = heapMem[localMem[254]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 668;
      end

        668 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[304]] = localMem[259];
              ip = 669;
      end

        669 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[305] = heapMem[localMem[261]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 670;
      end

        670 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[305] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[298], localMem[305], arraySizes[localMem[305]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[298] && i <= arraySizes[localMem[305]]) begin
                  heapMem[NArea * localMem[305] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[305] + localMem[298]] = localMem[300];                                    // Insert new value
              arraySizes[localMem[305]] = arraySizes[localMem[305]] + 1;                              // Increase array size
              ip = 671;
      end

        671 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[306] = heapMem[localMem[261]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 672;
      end

        672 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[306] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[298], localMem[306], arraySizes[localMem[306]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[298] && i <= arraySizes[localMem[306]]) begin
                  heapMem[NArea * localMem[306] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[306] + localMem[298]] = localMem[302];                                    // Insert new value
              arraySizes[localMem[306]] = arraySizes[localMem[306]] + 1;                              // Increase array size
              ip = 673;
      end

        673 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[307] = heapMem[localMem[261]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 674;
      end

        674 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[308] = localMem[298] + 1;
              updateArrayLength(2, 0, 0);
              ip = 675;
      end

        675 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[307] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[308], localMem[307], arraySizes[localMem[307]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[308] && i <= arraySizes[localMem[307]]) begin
                  heapMem[NArea * localMem[307] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[307] + localMem[308]] = localMem[262];                                    // Insert new value
              arraySizes[localMem[307]] = arraySizes[localMem[307]] + 1;                              // Increase array size
              ip = 676;
      end

        676 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[261]*7 + 0] = heapMem[localMem[261]*7 + 0] + 1;
              updateArrayLength(1, localMem[261], 0);
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
                localMem[309] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[309] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[309]] = 0;
              ip = 681;
      end

        681 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[309]*7 + 0] = localMem[259];
              updateArrayLength(1, localMem[309], 0);
              ip = 682;
      end

        682 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[309]*7 + 2] = 0;
              updateArrayLength(1, localMem[309], 2);
              ip = 683;
      end

        683 :
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
              ip = 684;
      end

        684 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[309]*7 + 4] = localMem[310];
              updateArrayLength(1, localMem[309], 4);
              ip = 685;
      end

        685 :
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
              ip = 686;
      end

        686 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[309]*7 + 5] = localMem[311];
              updateArrayLength(1, localMem[309], 5);
              ip = 687;
      end

        687 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[309]*7 + 6] = 0;
              updateArrayLength(1, localMem[309], 6);
              ip = 688;
      end

        688 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[309]*7 + 3] = localMem[257];
              updateArrayLength(1, localMem[309], 3);
              ip = 689;
      end

        689 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[257]*7 + 1] = heapMem[localMem[257]*7 + 1] + 1;
              updateArrayLength(1, localMem[257], 1);
              ip = 690;
      end

        690 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[309]*7 + 1] = heapMem[localMem[257]*7 + 1];
              updateArrayLength(1, localMem[309], 1);
              ip = 691;
      end

        691 :
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
              ip = 692;
      end

        692 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[312]*7 + 0] = localMem[259];
              updateArrayLength(1, localMem[312], 0);
              ip = 693;
      end

        693 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[312]*7 + 2] = 0;
              updateArrayLength(1, localMem[312], 2);
              ip = 694;
      end

        694 :
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
              ip = 695;
      end

        695 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[312]*7 + 4] = localMem[313];
              updateArrayLength(1, localMem[312], 4);
              ip = 696;
      end

        696 :
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
              ip = 697;
      end

        697 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[312]*7 + 5] = localMem[314];
              updateArrayLength(1, localMem[312], 5);
              ip = 698;
      end

        698 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[312]*7 + 6] = 0;
              updateArrayLength(1, localMem[312], 6);
              ip = 699;
      end

        699 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[312]*7 + 3] = localMem[257];
              updateArrayLength(1, localMem[312], 3);
              ip = 700;
      end

        700 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[257]*7 + 1] = heapMem[localMem[257]*7 + 1] + 1;
              updateArrayLength(1, localMem[257], 1);
              ip = 701;
      end

        701 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[312]*7 + 1] = heapMem[localMem[257]*7 + 1];
              updateArrayLength(1, localMem[312], 1);
              ip = 702;
      end

        702 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[315] = !heapMem[localMem[254]*7 + 6];
              ip = 703;
      end

        703 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[315] != 0 ? 755 : 704;
      end

        704 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[316] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[316] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[316]] = 0;
              ip = 705;
      end

        705 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[309]*7 + 6] = localMem[316];
              updateArrayLength(1, localMem[309], 6);
              ip = 706;
      end

        706 :
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
              ip = 707;
      end

        707 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[312]*7 + 6] = localMem[317];
              updateArrayLength(1, localMem[312], 6);
              ip = 708;
      end

        708 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[318] = heapMem[localMem[254]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 709;
      end

        709 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[319] = heapMem[localMem[309]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 710;
      end

        710 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[259]) begin
                  heapMem[NArea * localMem[319] + 0 + i] = heapMem[NArea * localMem[318] + 0 + i];
                  updateArrayLength(1, localMem[319], 0 + i);
                end
              end
              ip = 711;
      end

        711 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[320] = heapMem[localMem[254]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 712;
      end

        712 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[321] = heapMem[localMem[309]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 713;
      end

        713 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[259]) begin
                  heapMem[NArea * localMem[321] + 0 + i] = heapMem[NArea * localMem[320] + 0 + i];
                  updateArrayLength(1, localMem[321], 0 + i);
                end
              end
              ip = 714;
      end

        714 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[322] = heapMem[localMem[254]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 715;
      end

        715 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[323] = heapMem[localMem[309]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 716;
      end

        716 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[324] = localMem[259] + 1;
              updateArrayLength(2, 0, 0);
              ip = 717;
      end

        717 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[324]) begin
                  heapMem[NArea * localMem[323] + 0 + i] = heapMem[NArea * localMem[322] + 0 + i];
                  updateArrayLength(1, localMem[323], 0 + i);
                end
              end
              ip = 718;
      end

        718 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[325] = heapMem[localMem[254]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 719;
      end

        719 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[326] = heapMem[localMem[312]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 720;
      end

        720 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[259]) begin
                  heapMem[NArea * localMem[326] + 0 + i] = heapMem[NArea * localMem[325] + localMem[260] + i];
                  updateArrayLength(1, localMem[326], 0 + i);
                end
              end
              ip = 721;
      end

        721 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[327] = heapMem[localMem[254]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 722;
      end

        722 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[328] = heapMem[localMem[312]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 723;
      end

        723 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[259]) begin
                  heapMem[NArea * localMem[328] + 0 + i] = heapMem[NArea * localMem[327] + localMem[260] + i];
                  updateArrayLength(1, localMem[328], 0 + i);
                end
              end
              ip = 724;
      end

        724 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[329] = heapMem[localMem[254]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 725;
      end

        725 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[330] = heapMem[localMem[312]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 726;
      end

        726 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[331] = localMem[259] + 1;
              updateArrayLength(2, 0, 0);
              ip = 727;
      end

        727 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[331]) begin
                  heapMem[NArea * localMem[330] + 0 + i] = heapMem[NArea * localMem[329] + localMem[260] + i];
                  updateArrayLength(1, localMem[330], 0 + i);
                end
              end
              ip = 728;
      end

        728 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[332] = heapMem[localMem[309]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 729;
      end

        729 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[333] = localMem[332] + 1;
              updateArrayLength(2, 0, 0);
              ip = 730;
      end

        730 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[334] = heapMem[localMem[309]*7 + 6];
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
              localMem[335] = 0;
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
              ip = localMem[335] >= localMem[333] ? 740 : 735;
      end

        735 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[336] = heapMem[localMem[334]*7 + localMem[335]];
              updateArrayLength(2, 0, 0);
              ip = 736;
      end

        736 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[336]*7 + 2] = localMem[309];
              updateArrayLength(1, localMem[336], 2);
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
              localMem[335] = localMem[335] + 1;
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
              localMem[337] = heapMem[localMem[312]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 742;
      end

        742 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[338] = localMem[337] + 1;
              updateArrayLength(2, 0, 0);
              ip = 743;
      end

        743 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[339] = heapMem[localMem[312]*7 + 6];
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
              localMem[340] = 0;
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
              ip = localMem[340] >= localMem[338] ? 753 : 748;
      end

        748 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[341] = heapMem[localMem[339]*7 + localMem[340]];
              updateArrayLength(2, 0, 0);
              ip = 749;
      end

        749 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[341]*7 + 2] = localMem[312];
              updateArrayLength(1, localMem[341], 2);
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
              localMem[340] = localMem[340] + 1;
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
                localMem[342] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[342] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[342]] = 0;
              ip = 757;
      end

        757 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[254]*7 + 6] = localMem[342];
              updateArrayLength(1, localMem[254], 6);
              ip = 758;
      end

        758 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[343] = heapMem[localMem[254]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 759;
      end

        759 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[344] = heapMem[localMem[309]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 760;
      end

        760 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[259]) begin
                  heapMem[NArea * localMem[344] + 0 + i] = heapMem[NArea * localMem[343] + 0 + i];
                  updateArrayLength(1, localMem[344], 0 + i);
                end
              end
              ip = 761;
      end

        761 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[345] = heapMem[localMem[254]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 762;
      end

        762 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[346] = heapMem[localMem[309]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 763;
      end

        763 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[259]) begin
                  heapMem[NArea * localMem[346] + 0 + i] = heapMem[NArea * localMem[345] + 0 + i];
                  updateArrayLength(1, localMem[346], 0 + i);
                end
              end
              ip = 764;
      end

        764 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[347] = heapMem[localMem[254]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 765;
      end

        765 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[348] = heapMem[localMem[312]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 766;
      end

        766 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[259]) begin
                  heapMem[NArea * localMem[348] + 0 + i] = heapMem[NArea * localMem[347] + localMem[260] + i];
                  updateArrayLength(1, localMem[348], 0 + i);
                end
              end
              ip = 767;
      end

        767 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[349] = heapMem[localMem[254]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 768;
      end

        768 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[350] = heapMem[localMem[312]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 769;
      end

        769 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[259]) begin
                  heapMem[NArea * localMem[350] + 0 + i] = heapMem[NArea * localMem[349] + localMem[260] + i];
                  updateArrayLength(1, localMem[350], 0 + i);
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
              heapMem[localMem[309]*7 + 2] = localMem[254];
              updateArrayLength(1, localMem[309], 2);
              ip = 772;
      end

        772 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[312]*7 + 2] = localMem[254];
              updateArrayLength(1, localMem[312], 2);
              ip = 773;
      end

        773 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[351] = heapMem[localMem[254]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 774;
      end

        774 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[352] = heapMem[localMem[351]*7 + localMem[259]];
              updateArrayLength(2, 0, 0);
              ip = 775;
      end

        775 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[353] = heapMem[localMem[254]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 776;
      end

        776 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[354] = heapMem[localMem[353]*7 + localMem[259]];
              updateArrayLength(2, 0, 0);
              ip = 777;
      end

        777 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[355] = heapMem[localMem[254]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 778;
      end

        778 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[355]*7 + 0] = localMem[352];
              updateArrayLength(1, localMem[355], 0);
              ip = 779;
      end

        779 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[356] = heapMem[localMem[254]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 780;
      end

        780 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[356]*7 + 0] = localMem[354];
              updateArrayLength(1, localMem[356], 0);
              ip = 781;
      end

        781 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[357] = heapMem[localMem[254]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 782;
      end

        782 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[357]*7 + 0] = localMem[309];
              updateArrayLength(1, localMem[357], 0);
              ip = 783;
      end

        783 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[358] = heapMem[localMem[254]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 784;
      end

        784 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[358]*7 + 1] = localMem[312];
              updateArrayLength(1, localMem[358], 1);
              ip = 785;
      end

        785 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[254]*7 + 0] = 1;
              updateArrayLength(1, localMem[254], 0);
              ip = 786;
      end

        786 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[359] = heapMem[localMem[254]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 787;
      end

        787 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[359]] = 1;
              ip = 788;
      end

        788 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[360] = heapMem[localMem[254]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 789;
      end

        789 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[360]] = 1;
              ip = 790;
      end

        790 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[361] = heapMem[localMem[254]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 791;
      end

        791 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[361]] = 2;
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
              localMem[255] = 1;
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
              localMem[255] = 0;
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
              ip = localMem[255] != 0 ? 802 : 801;
      end

        801 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[26] = localMem[254];
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
              localMem[134] = localMem[134] + 1;
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
              localMem[362] = heapMem[localMem[3]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 812;
      end

        812 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[363] = heapMem[localMem[3]*7 + 1];
              updateArrayLength(2, 0, 0);
              ip = 813;
      end

        813 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[364] = heapMem[localMem[3]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 814;
      end

        814 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[363] != 1 ? 818 : 815;
      end

        815 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[365] = heapMem[localMem[362]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 816;
      end

        816 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[365]*7 + localMem[364]] = localMem[2];
              updateArrayLength(1, localMem[365], localMem[364]);
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
              ip = localMem[363] != 2 ? 827 : 820;
      end

        820 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[366] = localMem[364] + 1;
              updateArrayLength(2, 0, 0);
              ip = 821;
      end

        821 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[367] = heapMem[localMem[362]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 822;
      end

        822 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[367] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[366], localMem[367], arraySizes[localMem[367]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[366] && i <= arraySizes[localMem[367]]) begin
                  heapMem[NArea * localMem[367] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[367] + localMem[366]] = localMem[1];                                    // Insert new value
              arraySizes[localMem[367]] = arraySizes[localMem[367]] + 1;                              // Increase array size
              ip = 823;
      end

        823 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[368] = heapMem[localMem[362]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 824;
      end

        824 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[368] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[366], localMem[368], arraySizes[localMem[368]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[366] && i <= arraySizes[localMem[368]]) begin
                  heapMem[NArea * localMem[368] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[368] + localMem[366]] = localMem[2];                                    // Insert new value
              arraySizes[localMem[368]] = arraySizes[localMem[368]] + 1;                              // Increase array size
              ip = 825;
      end

        825 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[362]*7 + 0] = heapMem[localMem[362]*7 + 0] + 1;
              updateArrayLength(1, localMem[362], 0);
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
              localMem[369] = heapMem[localMem[362]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 829;
      end

        829 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[369] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[364], localMem[369], arraySizes[localMem[369]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[364] && i <= arraySizes[localMem[369]]) begin
                  heapMem[NArea * localMem[369] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[369] + localMem[364]] = localMem[1];                                    // Insert new value
              arraySizes[localMem[369]] = arraySizes[localMem[369]] + 1;                              // Increase array size
              ip = 830;
      end

        830 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[370] = heapMem[localMem[362]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 831;
      end

        831 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[370] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[364], localMem[370], arraySizes[localMem[370]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[364] && i <= arraySizes[localMem[370]]) begin
                  heapMem[NArea * localMem[370] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[370] + localMem[364]] = localMem[2];                                    // Insert new value
              arraySizes[localMem[370]] = arraySizes[localMem[370]] + 1;                              // Increase array size
              ip = 832;
      end

        832 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[362]*7 + 0] = heapMem[localMem[362]*7 + 0] + 1;
              updateArrayLength(1, localMem[362], 0);
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
              localMem[372] = heapMem[localMem[362]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 837;
      end

        837 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[373] = heapMem[localMem[362]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 838;
      end

        838 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[374] = heapMem[localMem[373]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 839;
      end

        839 :
      begin                                                                     // jLt
if (0) begin
  $display("AAAA %4d %4d jLt", steps, ip);
end
              ip = localMem[372] <  localMem[374] ? 1059 : 840;
      end

        840 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[375] = localMem[374];
              updateArrayLength(2, 0, 0);
              ip = 841;
      end

        841 :
      begin                                                                     // shiftRight
if (0) begin
  $display("AAAA %4d %4d shiftRight", steps, ip);
end
              localMem[375] = localMem[375] >> 1;
              ip = 842;
      end

        842 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[376] = localMem[375] + 1;
              updateArrayLength(2, 0, 0);
              ip = 843;
      end

        843 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[377] = heapMem[localMem[362]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 844;
      end

        844 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[377] == 0 ? 941 : 845;
      end

        845 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[378] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[378] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[378]] = 0;
              ip = 846;
      end

        846 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[378]*7 + 0] = localMem[375];
              updateArrayLength(1, localMem[378], 0);
              ip = 847;
      end

        847 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[378]*7 + 2] = 0;
              updateArrayLength(1, localMem[378], 2);
              ip = 848;
      end

        848 :
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
              ip = 849;
      end

        849 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[378]*7 + 4] = localMem[379];
              updateArrayLength(1, localMem[378], 4);
              ip = 850;
      end

        850 :
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
              ip = 851;
      end

        851 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[378]*7 + 5] = localMem[380];
              updateArrayLength(1, localMem[378], 5);
              ip = 852;
      end

        852 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[378]*7 + 6] = 0;
              updateArrayLength(1, localMem[378], 6);
              ip = 853;
      end

        853 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[378]*7 + 3] = localMem[373];
              updateArrayLength(1, localMem[378], 3);
              ip = 854;
      end

        854 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[373]*7 + 1] = heapMem[localMem[373]*7 + 1] + 1;
              updateArrayLength(1, localMem[373], 1);
              ip = 855;
      end

        855 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[378]*7 + 1] = heapMem[localMem[373]*7 + 1];
              updateArrayLength(1, localMem[378], 1);
              ip = 856;
      end

        856 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[381] = !heapMem[localMem[362]*7 + 6];
              ip = 857;
      end

        857 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[381] != 0 ? 886 : 858;
      end

        858 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[382] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[382] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[382]] = 0;
              ip = 859;
      end

        859 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[378]*7 + 6] = localMem[382];
              updateArrayLength(1, localMem[378], 6);
              ip = 860;
      end

        860 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[383] = heapMem[localMem[362]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 861;
      end

        861 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[384] = heapMem[localMem[378]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 862;
      end

        862 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[375]) begin
                  heapMem[NArea * localMem[384] + 0 + i] = heapMem[NArea * localMem[383] + localMem[376] + i];
                  updateArrayLength(1, localMem[384], 0 + i);
                end
              end
              ip = 863;
      end

        863 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[385] = heapMem[localMem[362]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 864;
      end

        864 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[386] = heapMem[localMem[378]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 865;
      end

        865 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[375]) begin
                  heapMem[NArea * localMem[386] + 0 + i] = heapMem[NArea * localMem[385] + localMem[376] + i];
                  updateArrayLength(1, localMem[386], 0 + i);
                end
              end
              ip = 866;
      end

        866 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[387] = heapMem[localMem[362]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 867;
      end

        867 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[388] = heapMem[localMem[378]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 868;
      end

        868 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[389] = localMem[375] + 1;
              updateArrayLength(2, 0, 0);
              ip = 869;
      end

        869 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[389]) begin
                  heapMem[NArea * localMem[388] + 0 + i] = heapMem[NArea * localMem[387] + localMem[376] + i];
                  updateArrayLength(1, localMem[388], 0 + i);
                end
              end
              ip = 870;
      end

        870 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[390] = heapMem[localMem[378]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 871;
      end

        871 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[391] = localMem[390] + 1;
              updateArrayLength(2, 0, 0);
              ip = 872;
      end

        872 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[392] = heapMem[localMem[378]*7 + 6];
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
              localMem[393] = 0;
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
              ip = localMem[393] >= localMem[391] ? 882 : 877;
      end

        877 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[394] = heapMem[localMem[392]*7 + localMem[393]];
              updateArrayLength(2, 0, 0);
              ip = 878;
      end

        878 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[394]*7 + 2] = localMem[378];
              updateArrayLength(1, localMem[394], 2);
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
              localMem[393] = localMem[393] + 1;
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
              localMem[395] = heapMem[localMem[362]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 884;
      end

        884 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[395]] = localMem[376];
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
              localMem[396] = heapMem[localMem[362]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 888;
      end

        888 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[397] = heapMem[localMem[378]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 889;
      end

        889 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[375]) begin
                  heapMem[NArea * localMem[397] + 0 + i] = heapMem[NArea * localMem[396] + localMem[376] + i];
                  updateArrayLength(1, localMem[397], 0 + i);
                end
              end
              ip = 890;
      end

        890 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[398] = heapMem[localMem[362]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 891;
      end

        891 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[399] = heapMem[localMem[378]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 892;
      end

        892 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[375]) begin
                  heapMem[NArea * localMem[399] + 0 + i] = heapMem[NArea * localMem[398] + localMem[376] + i];
                  updateArrayLength(1, localMem[399], 0 + i);
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
              heapMem[localMem[362]*7 + 0] = localMem[375];
              updateArrayLength(1, localMem[362], 0);
              ip = 895;
      end

        895 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[378]*7 + 2] = localMem[377];
              updateArrayLength(1, localMem[378], 2);
              ip = 896;
      end

        896 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[400] = heapMem[localMem[377]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 897;
      end

        897 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[401] = heapMem[localMem[377]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 898;
      end

        898 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[402] = heapMem[localMem[401]*7 + localMem[400]];
              updateArrayLength(2, 0, 0);
              ip = 899;
      end

        899 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[402] != localMem[362] ? 918 : 900;
      end

        900 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[403] = heapMem[localMem[362]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 901;
      end

        901 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[404] = heapMem[localMem[403]*7 + localMem[375]];
              updateArrayLength(2, 0, 0);
              ip = 902;
      end

        902 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[405] = heapMem[localMem[377]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 903;
      end

        903 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[405]*7 + localMem[400]] = localMem[404];
              updateArrayLength(1, localMem[405], localMem[400]);
              ip = 904;
      end

        904 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[406] = heapMem[localMem[362]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 905;
      end

        905 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[407] = heapMem[localMem[406]*7 + localMem[375]];
              updateArrayLength(2, 0, 0);
              ip = 906;
      end

        906 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[408] = heapMem[localMem[377]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 907;
      end

        907 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[408]*7 + localMem[400]] = localMem[407];
              updateArrayLength(1, localMem[408], localMem[400]);
              ip = 908;
      end

        908 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[409] = heapMem[localMem[362]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 909;
      end

        909 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[409]] = localMem[375];
              ip = 910;
      end

        910 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[410] = heapMem[localMem[362]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 911;
      end

        911 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[410]] = localMem[375];
              ip = 912;
      end

        912 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[411] = localMem[400] + 1;
              updateArrayLength(2, 0, 0);
              ip = 913;
      end

        913 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[377]*7 + 0] = localMem[411];
              updateArrayLength(1, localMem[377], 0);
              ip = 914;
      end

        914 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[412] = heapMem[localMem[377]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 915;
      end

        915 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[412]*7 + localMem[411]] = localMem[378];
              updateArrayLength(1, localMem[412], localMem[411]);
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
              localMem[413] = heapMem[localMem[377]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 921;
      end

        921 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[414] = 0; k = arraySizes[localMem[413]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[413] * NArea + i] == localMem[362]) localMem[414] = i + 1;
              end
              ip = 922;
      end

        922 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[414] = localMem[414] - 1;
              updateArrayLength(2, 0, 0);
              ip = 923;
      end

        923 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[415] = heapMem[localMem[362]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 924;
      end

        924 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[416] = heapMem[localMem[415]*7 + localMem[375]];
              updateArrayLength(2, 0, 0);
              ip = 925;
      end

        925 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[417] = heapMem[localMem[362]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 926;
      end

        926 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[418] = heapMem[localMem[417]*7 + localMem[375]];
              updateArrayLength(2, 0, 0);
              ip = 927;
      end

        927 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[419] = heapMem[localMem[362]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 928;
      end

        928 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[419]] = localMem[375];
              ip = 929;
      end

        929 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[420] = heapMem[localMem[362]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 930;
      end

        930 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[420]] = localMem[375];
              ip = 931;
      end

        931 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[421] = heapMem[localMem[377]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 932;
      end

        932 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[421] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[414], localMem[421], arraySizes[localMem[421]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[414] && i <= arraySizes[localMem[421]]) begin
                  heapMem[NArea * localMem[421] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[421] + localMem[414]] = localMem[416];                                    // Insert new value
              arraySizes[localMem[421]] = arraySizes[localMem[421]] + 1;                              // Increase array size
              ip = 933;
      end

        933 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[422] = heapMem[localMem[377]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 934;
      end

        934 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[422] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[414], localMem[422], arraySizes[localMem[422]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[414] && i <= arraySizes[localMem[422]]) begin
                  heapMem[NArea * localMem[422] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[422] + localMem[414]] = localMem[418];                                    // Insert new value
              arraySizes[localMem[422]] = arraySizes[localMem[422]] + 1;                              // Increase array size
              ip = 935;
      end

        935 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[423] = heapMem[localMem[377]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 936;
      end

        936 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[424] = localMem[414] + 1;
              updateArrayLength(2, 0, 0);
              ip = 937;
      end

        937 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[423] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[424], localMem[423], arraySizes[localMem[423]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[424] && i <= arraySizes[localMem[423]]) begin
                  heapMem[NArea * localMem[423] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[423] + localMem[424]] = localMem[378];                                    // Insert new value
              arraySizes[localMem[423]] = arraySizes[localMem[423]] + 1;                              // Increase array size
              ip = 938;
      end

        938 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[377]*7 + 0] = heapMem[localMem[377]*7 + 0] + 1;
              updateArrayLength(1, localMem[377], 0);
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
                localMem[425] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[425] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[425]] = 0;
              ip = 943;
      end

        943 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[425]*7 + 0] = localMem[375];
              updateArrayLength(1, localMem[425], 0);
              ip = 944;
      end

        944 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[425]*7 + 2] = 0;
              updateArrayLength(1, localMem[425], 2);
              ip = 945;
      end

        945 :
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
              ip = 946;
      end

        946 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[425]*7 + 4] = localMem[426];
              updateArrayLength(1, localMem[425], 4);
              ip = 947;
      end

        947 :
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
              ip = 948;
      end

        948 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[425]*7 + 5] = localMem[427];
              updateArrayLength(1, localMem[425], 5);
              ip = 949;
      end

        949 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[425]*7 + 6] = 0;
              updateArrayLength(1, localMem[425], 6);
              ip = 950;
      end

        950 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[425]*7 + 3] = localMem[373];
              updateArrayLength(1, localMem[425], 3);
              ip = 951;
      end

        951 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[373]*7 + 1] = heapMem[localMem[373]*7 + 1] + 1;
              updateArrayLength(1, localMem[373], 1);
              ip = 952;
      end

        952 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[425]*7 + 1] = heapMem[localMem[373]*7 + 1];
              updateArrayLength(1, localMem[425], 1);
              ip = 953;
      end

        953 :
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
              ip = 954;
      end

        954 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[428]*7 + 0] = localMem[375];
              updateArrayLength(1, localMem[428], 0);
              ip = 955;
      end

        955 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[428]*7 + 2] = 0;
              updateArrayLength(1, localMem[428], 2);
              ip = 956;
      end

        956 :
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
              ip = 957;
      end

        957 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[428]*7 + 4] = localMem[429];
              updateArrayLength(1, localMem[428], 4);
              ip = 958;
      end

        958 :
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
              ip = 959;
      end

        959 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[428]*7 + 5] = localMem[430];
              updateArrayLength(1, localMem[428], 5);
              ip = 960;
      end

        960 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[428]*7 + 6] = 0;
              updateArrayLength(1, localMem[428], 6);
              ip = 961;
      end

        961 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[428]*7 + 3] = localMem[373];
              updateArrayLength(1, localMem[428], 3);
              ip = 962;
      end

        962 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[373]*7 + 1] = heapMem[localMem[373]*7 + 1] + 1;
              updateArrayLength(1, localMem[373], 1);
              ip = 963;
      end

        963 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[428]*7 + 1] = heapMem[localMem[373]*7 + 1];
              updateArrayLength(1, localMem[428], 1);
              ip = 964;
      end

        964 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[431] = !heapMem[localMem[362]*7 + 6];
              ip = 965;
      end

        965 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[431] != 0 ? 1017 : 966;
      end

        966 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[432] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[432] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[432]] = 0;
              ip = 967;
      end

        967 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[425]*7 + 6] = localMem[432];
              updateArrayLength(1, localMem[425], 6);
              ip = 968;
      end

        968 :
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
              ip = 969;
      end

        969 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[428]*7 + 6] = localMem[433];
              updateArrayLength(1, localMem[428], 6);
              ip = 970;
      end

        970 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[434] = heapMem[localMem[362]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 971;
      end

        971 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[435] = heapMem[localMem[425]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 972;
      end

        972 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[375]) begin
                  heapMem[NArea * localMem[435] + 0 + i] = heapMem[NArea * localMem[434] + 0 + i];
                  updateArrayLength(1, localMem[435], 0 + i);
                end
              end
              ip = 973;
      end

        973 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[436] = heapMem[localMem[362]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 974;
      end

        974 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[437] = heapMem[localMem[425]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 975;
      end

        975 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[375]) begin
                  heapMem[NArea * localMem[437] + 0 + i] = heapMem[NArea * localMem[436] + 0 + i];
                  updateArrayLength(1, localMem[437], 0 + i);
                end
              end
              ip = 976;
      end

        976 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[438] = heapMem[localMem[362]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 977;
      end

        977 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[439] = heapMem[localMem[425]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 978;
      end

        978 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[440] = localMem[375] + 1;
              updateArrayLength(2, 0, 0);
              ip = 979;
      end

        979 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[440]) begin
                  heapMem[NArea * localMem[439] + 0 + i] = heapMem[NArea * localMem[438] + 0 + i];
                  updateArrayLength(1, localMem[439], 0 + i);
                end
              end
              ip = 980;
      end

        980 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[441] = heapMem[localMem[362]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 981;
      end

        981 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[442] = heapMem[localMem[428]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 982;
      end

        982 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[375]) begin
                  heapMem[NArea * localMem[442] + 0 + i] = heapMem[NArea * localMem[441] + localMem[376] + i];
                  updateArrayLength(1, localMem[442], 0 + i);
                end
              end
              ip = 983;
      end

        983 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[443] = heapMem[localMem[362]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 984;
      end

        984 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[444] = heapMem[localMem[428]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 985;
      end

        985 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[375]) begin
                  heapMem[NArea * localMem[444] + 0 + i] = heapMem[NArea * localMem[443] + localMem[376] + i];
                  updateArrayLength(1, localMem[444], 0 + i);
                end
              end
              ip = 986;
      end

        986 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[445] = heapMem[localMem[362]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 987;
      end

        987 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[446] = heapMem[localMem[428]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 988;
      end

        988 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[447] = localMem[375] + 1;
              updateArrayLength(2, 0, 0);
              ip = 989;
      end

        989 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[447]) begin
                  heapMem[NArea * localMem[446] + 0 + i] = heapMem[NArea * localMem[445] + localMem[376] + i];
                  updateArrayLength(1, localMem[446], 0 + i);
                end
              end
              ip = 990;
      end

        990 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[448] = heapMem[localMem[425]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 991;
      end

        991 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[449] = localMem[448] + 1;
              updateArrayLength(2, 0, 0);
              ip = 992;
      end

        992 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[450] = heapMem[localMem[425]*7 + 6];
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
              localMem[451] = 0;
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
              ip = localMem[451] >= localMem[449] ? 1002 : 997;
      end

        997 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[452] = heapMem[localMem[450]*7 + localMem[451]];
              updateArrayLength(2, 0, 0);
              ip = 998;
      end

        998 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[452]*7 + 2] = localMem[425];
              updateArrayLength(1, localMem[452], 2);
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
              localMem[451] = localMem[451] + 1;
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
              localMem[453] = heapMem[localMem[428]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1004;
      end

       1004 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[454] = localMem[453] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1005;
      end

       1005 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[455] = heapMem[localMem[428]*7 + 6];
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
              localMem[456] = 0;
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
              ip = localMem[456] >= localMem[454] ? 1015 : 1010;
      end

       1010 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[457] = heapMem[localMem[455]*7 + localMem[456]];
              updateArrayLength(2, 0, 0);
              ip = 1011;
      end

       1011 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[457]*7 + 2] = localMem[428];
              updateArrayLength(1, localMem[457], 2);
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
              localMem[456] = localMem[456] + 1;
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
                localMem[458] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[458] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[458]] = 0;
              ip = 1019;
      end

       1019 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[362]*7 + 6] = localMem[458];
              updateArrayLength(1, localMem[362], 6);
              ip = 1020;
      end

       1020 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[459] = heapMem[localMem[362]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1021;
      end

       1021 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[460] = heapMem[localMem[425]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1022;
      end

       1022 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[375]) begin
                  heapMem[NArea * localMem[460] + 0 + i] = heapMem[NArea * localMem[459] + 0 + i];
                  updateArrayLength(1, localMem[460], 0 + i);
                end
              end
              ip = 1023;
      end

       1023 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[461] = heapMem[localMem[362]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1024;
      end

       1024 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[462] = heapMem[localMem[425]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1025;
      end

       1025 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[375]) begin
                  heapMem[NArea * localMem[462] + 0 + i] = heapMem[NArea * localMem[461] + 0 + i];
                  updateArrayLength(1, localMem[462], 0 + i);
                end
              end
              ip = 1026;
      end

       1026 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[463] = heapMem[localMem[362]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1027;
      end

       1027 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[464] = heapMem[localMem[428]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1028;
      end

       1028 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[375]) begin
                  heapMem[NArea * localMem[464] + 0 + i] = heapMem[NArea * localMem[463] + localMem[376] + i];
                  updateArrayLength(1, localMem[464], 0 + i);
                end
              end
              ip = 1029;
      end

       1029 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[465] = heapMem[localMem[362]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1030;
      end

       1030 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[466] = heapMem[localMem[428]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1031;
      end

       1031 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[375]) begin
                  heapMem[NArea * localMem[466] + 0 + i] = heapMem[NArea * localMem[465] + localMem[376] + i];
                  updateArrayLength(1, localMem[466], 0 + i);
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
              heapMem[localMem[425]*7 + 2] = localMem[362];
              updateArrayLength(1, localMem[425], 2);
              ip = 1034;
      end

       1034 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[428]*7 + 2] = localMem[362];
              updateArrayLength(1, localMem[428], 2);
              ip = 1035;
      end

       1035 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[467] = heapMem[localMem[362]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1036;
      end

       1036 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[468] = heapMem[localMem[467]*7 + localMem[375]];
              updateArrayLength(2, 0, 0);
              ip = 1037;
      end

       1037 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[469] = heapMem[localMem[362]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1038;
      end

       1038 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[470] = heapMem[localMem[469]*7 + localMem[375]];
              updateArrayLength(2, 0, 0);
              ip = 1039;
      end

       1039 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[471] = heapMem[localMem[362]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1040;
      end

       1040 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[471]*7 + 0] = localMem[468];
              updateArrayLength(1, localMem[471], 0);
              ip = 1041;
      end

       1041 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[472] = heapMem[localMem[362]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1042;
      end

       1042 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[472]*7 + 0] = localMem[470];
              updateArrayLength(1, localMem[472], 0);
              ip = 1043;
      end

       1043 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[473] = heapMem[localMem[362]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1044;
      end

       1044 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[473]*7 + 0] = localMem[425];
              updateArrayLength(1, localMem[473], 0);
              ip = 1045;
      end

       1045 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[474] = heapMem[localMem[362]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1046;
      end

       1046 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[474]*7 + 1] = localMem[428];
              updateArrayLength(1, localMem[474], 1);
              ip = 1047;
      end

       1047 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[362]*7 + 0] = 1;
              updateArrayLength(1, localMem[362], 0);
              ip = 1048;
      end

       1048 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[475] = heapMem[localMem[362]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1049;
      end

       1049 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[475]] = 1;
              ip = 1050;
      end

       1050 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[476] = heapMem[localMem[362]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1051;
      end

       1051 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[476]] = 1;
              ip = 1052;
      end

       1052 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[477] = heapMem[localMem[362]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1053;
      end

       1053 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[477]] = 2;
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
              localMem[371] = 1;
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
              localMem[371] = 0;
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
                                 arraySizes[localMem[3]] = 0;
              freedArrays[freedArraysTop] = localMem[3];
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
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[1] = localMem[1] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1068;
      end

       1068 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 7;
      end

       1069 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1070;
      end

       1070 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1071;
      end

       1071 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[478] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1072;
      end

       1072 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1073;
      end

       1073 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[478] >= 66 ? 1138 : 1074;
      end

       1074 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[479] = localMem[478] + localMem[478];
              updateArrayLength(2, 0, 0);
              ip = 1075;
      end

       1075 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[480] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[480] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[480]] = 0;
              ip = 1076;
      end

       1076 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1077;
      end

       1077 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[481] = heapMem[localMem[0]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 1078;
      end

       1078 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[481] != 0 ? 1083 : 1079;
      end

       1079 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[480]*7 + 0] = localMem[481];
              updateArrayLength(1, localMem[480], 0);
              ip = 1080;
      end

       1080 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[480]*7 + 1] = 3;
              updateArrayLength(1, localMem[480], 1);
              ip = 1081;
      end

       1081 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[480]*7 + 2] = 0;
              updateArrayLength(1, localMem[480], 2);
              ip = 1082;
      end

       1082 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1129;
      end

       1083 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1084;
      end

       1084 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1085;
      end

       1085 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[482] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1086;
      end

       1086 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1087;
      end

       1087 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[482] >= 99 ? 1125 : 1088;
      end

       1088 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[483] = heapMem[localMem[481]*7 + 0] - 1;
              updateArrayLength(2, 0, 0);
              ip = 1089;
      end

       1089 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[484] = heapMem[localMem[481]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1090;
      end

       1090 :
      begin                                                                     // jLe
if (0) begin
  $display("AAAA %4d %4d jLe", steps, ip);
end
              ip = localMem[478] <= heapMem[localMem[484]*7 + localMem[483]] ? 1103 : 1091;
      end

       1091 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[485] = localMem[483] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1092;
      end

       1092 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[486] = !heapMem[localMem[481]*7 + 6];
              ip = 1093;
      end

       1093 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[486] == 0 ? 1098 : 1094;
      end

       1094 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[480]*7 + 0] = localMem[481];
              updateArrayLength(1, localMem[480], 0);
              ip = 1095;
      end

       1095 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[480]*7 + 1] = 2;
              updateArrayLength(1, localMem[480], 1);
              ip = 1096;
      end

       1096 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[480]*7 + 2] = localMem[485];
              updateArrayLength(1, localMem[480], 2);
              ip = 1097;
      end

       1097 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1129;
      end

       1098 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1099;
      end

       1099 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[487] = heapMem[localMem[481]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1100;
      end

       1100 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[488] = heapMem[localMem[487]*7 + localMem[485]];
              updateArrayLength(2, 0, 0);
              ip = 1101;
      end

       1101 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[481] = localMem[488];
              updateArrayLength(2, 0, 0);
              ip = 1102;
      end

       1102 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1122;
      end

       1103 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1104;
      end

       1104 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[489] = 0; k = arraySizes[localMem[484]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[484] * NArea + i] == localMem[478]) localMem[489] = i + 1;
              end
              ip = 1105;
      end

       1105 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[489] == 0 ? 1110 : 1106;
      end

       1106 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[480]*7 + 0] = localMem[481];
              updateArrayLength(1, localMem[480], 0);
              ip = 1107;
      end

       1107 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[480]*7 + 1] = 1;
              updateArrayLength(1, localMem[480], 1);
              ip = 1108;
      end

       1108 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              heapMem[localMem[480]*7 + 2] = localMem[489] - 1;
              updateArrayLength(1, localMem[480], 2);
              ip = 1109;
      end

       1109 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1129;
      end

       1110 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1111;
      end

       1111 :
      begin                                                                     // arrayCountLess
if (0) begin
  $display("AAAA %4d %4d arrayCountLess", steps, ip);
end
              j = 0; k = arraySizes[localMem[484]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[484] * NArea + i] < localMem[478]) j = j + 1;
              end
              localMem[490] = j;
              ip = 1112;
      end

       1112 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[491] = !heapMem[localMem[481]*7 + 6];
              ip = 1113;
      end

       1113 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[491] == 0 ? 1118 : 1114;
      end

       1114 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[480]*7 + 0] = localMem[481];
              updateArrayLength(1, localMem[480], 0);
              ip = 1115;
      end

       1115 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[480]*7 + 1] = 0;
              updateArrayLength(1, localMem[480], 1);
              ip = 1116;
      end

       1116 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[480]*7 + 2] = localMem[490];
              updateArrayLength(1, localMem[480], 2);
              ip = 1117;
      end

       1117 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1129;
      end

       1118 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1119;
      end

       1119 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[492] = heapMem[localMem[481]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1120;
      end

       1120 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[493] = heapMem[localMem[492]*7 + localMem[490]];
              updateArrayLength(2, 0, 0);
              ip = 1121;
      end

       1121 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[481] = localMem[493];
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
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[482] = localMem[482] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1124;
      end

       1124 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1086;
      end

       1125 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1126;
      end

       1126 :
      begin                                                                     // assert
if (0) begin
  $display("AAAA %4d %4d assert", steps, ip);
end
            ip = 1127;
      end

       1127 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1128;
      end

       1128 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1129;
      end

       1129 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1130;
      end

       1130 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[494] = heapMem[localMem[480]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1131;
      end

       1131 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[495] = heapMem[localMem[480]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1132;
      end

       1132 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[496] = heapMem[localMem[494]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1133;
      end

       1133 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[497] = heapMem[localMem[496]*7 + localMem[495]];
              updateArrayLength(2, 0, 0);
              ip = 1134;
      end

       1134 :
      begin                                                                     // assertEq
if (0) begin
  $display("AAAA %4d %4d assertEq", steps, ip);
end
            ip = 1135;
      end

       1135 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1136;
      end

       1136 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[478] = localMem[478] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1137;
      end

       1137 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1072;
      end

       1138 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1139;
      end

       1139 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[498] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[498] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[498]] = 0;
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
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[499] = heapMem[localMem[0]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 1142;
      end

       1142 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[499] != 0 ? 1147 : 1143;
      end

       1143 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[498]*7 + 0] = localMem[499];
              updateArrayLength(1, localMem[498], 0);
              ip = 1144;
      end

       1144 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[498]*7 + 1] = 3;
              updateArrayLength(1, localMem[498], 1);
              ip = 1145;
      end

       1145 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[498]*7 + 2] = 0;
              updateArrayLength(1, localMem[498], 2);
              ip = 1146;
      end

       1146 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1193;
      end

       1147 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1148;
      end

       1148 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1149;
      end

       1149 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[500] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1150;
      end

       1150 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1151;
      end

       1151 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[500] >= 99 ? 1189 : 1152;
      end

       1152 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[501] = heapMem[localMem[499]*7 + 0] - 1;
              updateArrayLength(2, 0, 0);
              ip = 1153;
      end

       1153 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[502] = heapMem[localMem[499]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1154;
      end

       1154 :
      begin                                                                     // jLe
if (0) begin
  $display("AAAA %4d %4d jLe", steps, ip);
end
              ip = -1 <= heapMem[localMem[502]*7 + localMem[501]] ? 1167 : 1155;
      end

       1155 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[503] = localMem[501] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1156;
      end

       1156 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[504] = !heapMem[localMem[499]*7 + 6];
              ip = 1157;
      end

       1157 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[504] == 0 ? 1162 : 1158;
      end

       1158 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[498]*7 + 0] = localMem[499];
              updateArrayLength(1, localMem[498], 0);
              ip = 1159;
      end

       1159 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[498]*7 + 1] = 2;
              updateArrayLength(1, localMem[498], 1);
              ip = 1160;
      end

       1160 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[498]*7 + 2] = localMem[503];
              updateArrayLength(1, localMem[498], 2);
              ip = 1161;
      end

       1161 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1193;
      end

       1162 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1163;
      end

       1163 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[505] = heapMem[localMem[499]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1164;
      end

       1164 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[506] = heapMem[localMem[505]*7 + localMem[503]];
              updateArrayLength(2, 0, 0);
              ip = 1165;
      end

       1165 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[499] = localMem[506];
              updateArrayLength(2, 0, 0);
              ip = 1166;
      end

       1166 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1186;
      end

       1167 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1168;
      end

       1168 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[507] = 0; k = arraySizes[localMem[502]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[502] * NArea + i] == -1) localMem[507] = i + 1;
              end
              ip = 1169;
      end

       1169 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[507] == 0 ? 1174 : 1170;
      end

       1170 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[498]*7 + 0] = localMem[499];
              updateArrayLength(1, localMem[498], 0);
              ip = 1171;
      end

       1171 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[498]*7 + 1] = 1;
              updateArrayLength(1, localMem[498], 1);
              ip = 1172;
      end

       1172 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              heapMem[localMem[498]*7 + 2] = localMem[507] - 1;
              updateArrayLength(1, localMem[498], 2);
              ip = 1173;
      end

       1173 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1193;
      end

       1174 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1175;
      end

       1175 :
      begin                                                                     // arrayCountLess
if (0) begin
  $display("AAAA %4d %4d arrayCountLess", steps, ip);
end
              j = 0; k = arraySizes[localMem[502]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[502] * NArea + i] < -1) j = j + 1;
              end
              localMem[508] = j;
              ip = 1176;
      end

       1176 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[509] = !heapMem[localMem[499]*7 + 6];
              ip = 1177;
      end

       1177 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[509] == 0 ? 1182 : 1178;
      end

       1178 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[498]*7 + 0] = localMem[499];
              updateArrayLength(1, localMem[498], 0);
              ip = 1179;
      end

       1179 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[498]*7 + 1] = 0;
              updateArrayLength(1, localMem[498], 1);
              ip = 1180;
      end

       1180 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[498]*7 + 2] = localMem[508];
              updateArrayLength(1, localMem[498], 2);
              ip = 1181;
      end

       1181 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1193;
      end

       1182 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1183;
      end

       1183 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[510] = heapMem[localMem[499]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1184;
      end

       1184 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[511] = heapMem[localMem[510]*7 + localMem[508]];
              updateArrayLength(2, 0, 0);
              ip = 1185;
      end

       1185 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[499] = localMem[511];
              updateArrayLength(2, 0, 0);
              ip = 1186;
      end

       1186 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1187;
      end

       1187 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[500] = localMem[500] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1188;
      end

       1188 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1150;
      end

       1189 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1190;
      end

       1190 :
      begin                                                                     // assert
if (0) begin
  $display("AAAA %4d %4d assert", steps, ip);
end
            ip = 1191;
      end

       1191 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1192;
      end

       1192 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1193;
      end

       1193 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1194;
      end

       1194 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[512] = heapMem[localMem[498]*7 + 1];
              updateArrayLength(2, 0, 0);
              ip = 1195;
      end

       1195 :
      begin                                                                     // assertNe
if (0) begin
  $display("AAAA %4d %4d assertNe", steps, ip);
end
            ip = 1196;
      end

       1196 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[513] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[513] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[513]] = 0;
              ip = 1197;
      end

       1197 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1198;
      end

       1198 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[514] = heapMem[localMem[0]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 1199;
      end

       1199 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[514] != 0 ? 1204 : 1200;
      end

       1200 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[513]*7 + 0] = localMem[514];
              updateArrayLength(1, localMem[513], 0);
              ip = 1201;
      end

       1201 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[513]*7 + 1] = 3;
              updateArrayLength(1, localMem[513], 1);
              ip = 1202;
      end

       1202 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[513]*7 + 2] = 0;
              updateArrayLength(1, localMem[513], 2);
              ip = 1203;
      end

       1203 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1250;
      end

       1204 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1205;
      end

       1205 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1206;
      end

       1206 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[515] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1207;
      end

       1207 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1208;
      end

       1208 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[515] >= 99 ? 1246 : 1209;
      end

       1209 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[516] = heapMem[localMem[514]*7 + 0] - 1;
              updateArrayLength(2, 0, 0);
              ip = 1210;
      end

       1210 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[517] = heapMem[localMem[514]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1211;
      end

       1211 :
      begin                                                                     // jLe
if (0) begin
  $display("AAAA %4d %4d jLe", steps, ip);
end
              ip = 66 <= heapMem[localMem[517]*7 + localMem[516]] ? 1224 : 1212;
      end

       1212 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[518] = localMem[516] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1213;
      end

       1213 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[519] = !heapMem[localMem[514]*7 + 6];
              ip = 1214;
      end

       1214 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[519] == 0 ? 1219 : 1215;
      end

       1215 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[513]*7 + 0] = localMem[514];
              updateArrayLength(1, localMem[513], 0);
              ip = 1216;
      end

       1216 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[513]*7 + 1] = 2;
              updateArrayLength(1, localMem[513], 1);
              ip = 1217;
      end

       1217 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[513]*7 + 2] = localMem[518];
              updateArrayLength(1, localMem[513], 2);
              ip = 1218;
      end

       1218 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1250;
      end

       1219 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1220;
      end

       1220 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[520] = heapMem[localMem[514]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1221;
      end

       1221 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[521] = heapMem[localMem[520]*7 + localMem[518]];
              updateArrayLength(2, 0, 0);
              ip = 1222;
      end

       1222 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[514] = localMem[521];
              updateArrayLength(2, 0, 0);
              ip = 1223;
      end

       1223 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1243;
      end

       1224 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1225;
      end

       1225 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[522] = 0; k = arraySizes[localMem[517]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[517] * NArea + i] == 66) localMem[522] = i + 1;
              end
              ip = 1226;
      end

       1226 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[522] == 0 ? 1231 : 1227;
      end

       1227 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[513]*7 + 0] = localMem[514];
              updateArrayLength(1, localMem[513], 0);
              ip = 1228;
      end

       1228 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[513]*7 + 1] = 1;
              updateArrayLength(1, localMem[513], 1);
              ip = 1229;
      end

       1229 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              heapMem[localMem[513]*7 + 2] = localMem[522] - 1;
              updateArrayLength(1, localMem[513], 2);
              ip = 1230;
      end

       1230 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1250;
      end

       1231 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1232;
      end

       1232 :
      begin                                                                     // arrayCountLess
if (0) begin
  $display("AAAA %4d %4d arrayCountLess", steps, ip);
end
              j = 0; k = arraySizes[localMem[517]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[517] * NArea + i] < 66) j = j + 1;
              end
              localMem[523] = j;
              ip = 1233;
      end

       1233 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[524] = !heapMem[localMem[514]*7 + 6];
              ip = 1234;
      end

       1234 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[524] == 0 ? 1239 : 1235;
      end

       1235 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[513]*7 + 0] = localMem[514];
              updateArrayLength(1, localMem[513], 0);
              ip = 1236;
      end

       1236 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[513]*7 + 1] = 0;
              updateArrayLength(1, localMem[513], 1);
              ip = 1237;
      end

       1237 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[513]*7 + 2] = localMem[523];
              updateArrayLength(1, localMem[513], 2);
              ip = 1238;
      end

       1238 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1250;
      end

       1239 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1240;
      end

       1240 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[525] = heapMem[localMem[514]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1241;
      end

       1241 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[526] = heapMem[localMem[525]*7 + localMem[523]];
              updateArrayLength(2, 0, 0);
              ip = 1242;
      end

       1242 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[514] = localMem[526];
              updateArrayLength(2, 0, 0);
              ip = 1243;
      end

       1243 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1244;
      end

       1244 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[515] = localMem[515] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1245;
      end

       1245 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1207;
      end

       1246 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1247;
      end

       1247 :
      begin                                                                     // assert
if (0) begin
  $display("AAAA %4d %4d assert", steps, ip);
end
            ip = 1248;
      end

       1248 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1249;
      end

       1249 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1250;
      end

       1250 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1251;
      end

       1251 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[527] = heapMem[localMem[513]*7 + 1];
              updateArrayLength(2, 0, 0);
              ip = 1252;
      end

       1252 :
      begin                                                                     // assertNe
if (0) begin
  $display("AAAA %4d %4d assertNe", steps, ip);
end
            ip = 1253;
      end
      default: begin
        success  = 1;
        finished = 1;
      end
    endcase
    if (steps <=  20503) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
    if (0) begin
      for(i = 0; i < 200; ++i) $write("%2d",   localMem[i]); $display("");
      for(i = 0; i < 200; ++i) $write("%2d",    heapMem[i]); $display("");
      for(i = 0; i < 200; ++i) $write("%2d", arraySizes[i]); $display("");
    end
  end
endmodule
