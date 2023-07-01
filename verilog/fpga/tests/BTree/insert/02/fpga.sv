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
  parameter integer NArrays =        5;                                         // Maximum number of arrays
  parameter integer NHeap   =       35;                                         // Amount of heap memory
  parameter integer NLocal  =      496;                                         // Size of local memory
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
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
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
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 7;
      end

          7 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[2] = heapMem[localMem[0]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 8;
      end

          8 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[2] != 0 ? 31 : 9;
      end

          9 :
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
              ip = 10;
      end

         10 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[3]*7 + 0] = 1;
              updateArrayLength(1, localMem[3], 0);
              ip = 11;
      end

         11 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[3]*7 + 2] = 0;
              updateArrayLength(1, localMem[3], 2);
              ip = 12;
      end

         12 :
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
              ip = 13;
      end

         13 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[3]*7 + 4] = localMem[4];
              updateArrayLength(1, localMem[3], 4);
              ip = 14;
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
              heapMem[localMem[3]*7 + 5] = localMem[5];
              updateArrayLength(1, localMem[3], 5);
              ip = 16;
      end

         16 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[3]*7 + 6] = 0;
              updateArrayLength(1, localMem[3], 6);
              ip = 17;
      end

         17 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[3]*7 + 3] = localMem[0];
              updateArrayLength(1, localMem[3], 3);
              ip = 18;
      end

         18 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[0]*7 + 1] = heapMem[localMem[0]*7 + 1] + 1;
              updateArrayLength(1, localMem[0], 1);
              ip = 19;
      end

         19 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[3]*7 + 1] = heapMem[localMem[0]*7 + 1];
              updateArrayLength(1, localMem[3], 1);
              ip = 20;
      end

         20 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[6] = heapMem[localMem[3]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 21;
      end

         21 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[6]*7 + 0] = 1;
              updateArrayLength(1, localMem[6], 0);
              ip = 22;
      end

         22 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[7] = heapMem[localMem[3]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 23;
      end

         23 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[7]*7 + 0] = 11;
              updateArrayLength(1, localMem[7], 0);
              ip = 24;
      end

         24 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[0]*7 + 0] = heapMem[localMem[0]*7 + 0] + 1;
              updateArrayLength(1, localMem[0], 0);
              ip = 25;
      end

         25 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[0]*7 + 3] = localMem[3];
              updateArrayLength(1, localMem[0], 3);
              ip = 26;
      end

         26 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[8] = heapMem[localMem[3]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 27;
      end

         27 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[8]] = 1;
              ip = 28;
      end

         28 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[9] = heapMem[localMem[3]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 29;
      end

         29 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[9]] = 1;
              ip = 30;
      end

         30 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1059;
      end

         31 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 32;
      end

         32 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[10] = heapMem[localMem[2]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 33;
      end

         33 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[11] = heapMem[localMem[0]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 34;
      end

         34 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[10] >= localMem[11] ? 70 : 35;
      end

         35 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[12] = heapMem[localMem[2]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 36;
      end

         36 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[12] != 0 ? 69 : 37;
      end

         37 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[13] = !heapMem[localMem[2]*7 + 6];
              ip = 38;
      end

         38 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[13] == 0 ? 68 : 39;
      end

         39 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[14] = heapMem[localMem[2]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 40;
      end

         40 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[15] = 0; k = arraySizes[localMem[14]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[14] * NArea + i] == 1) localMem[15] = i + 1;
              end
              ip = 41;
      end

         41 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[15] == 0 ? 46 : 42;
      end

         42 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[15] = localMem[15] - 1;
              updateArrayLength(2, 0, 0);
              ip = 43;
      end

         43 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[16] = heapMem[localMem[2]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 44;
      end

         44 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[16]*7 + localMem[15]] = 11;
              updateArrayLength(1, localMem[16], localMem[15]);
              ip = 45;
      end

         45 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1059;
      end

         46 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 47;
      end

         47 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[14]] = localMem[10];
              ip = 48;
      end

         48 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[17] = heapMem[localMem[2]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 49;
      end

         49 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[17]] = localMem[10];
              ip = 50;
      end

         50 :
      begin                                                                     // arrayCountGreater
if (0) begin
  $display("AAAA %4d %4d arrayCountGreater", steps, ip);
end
              j = 0; k = arraySizes[localMem[14]];
//$display("AAAAA k=%d  source2=%d", k, 1);
              for(i = 0; i < NArea; i = i + 1) begin
//$display("AAAAA i=%d  value=%d", i, heapMem[localMem[14] * NArea + i]);
                if (i < k && heapMem[localMem[14] * NArea + i] > 1) j = j + 1;
              end
              localMem[18] = j;
              ip = 51;
      end

         51 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[18] != 0 ? 59 : 52;
      end

         52 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[19] = heapMem[localMem[2]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 53;
      end

         53 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[19]*7 + localMem[10]] = 1;
              updateArrayLength(1, localMem[19], localMem[10]);
              ip = 54;
      end

         54 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[20] = heapMem[localMem[2]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 55;
      end

         55 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[20]*7 + localMem[10]] = 11;
              updateArrayLength(1, localMem[20], localMem[10]);
              ip = 56;
      end

         56 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[2]*7 + 0] = localMem[10] + 1;
              updateArrayLength(1, localMem[2], 0);
              ip = 57;
      end

         57 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[0]*7 + 0] = heapMem[localMem[0]*7 + 0] + 1;
              updateArrayLength(1, localMem[0], 0);
              ip = 58;
      end

         58 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1059;
      end

         59 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 60;
      end

         60 :
      begin                                                                     // arrayCountLess
if (0) begin
  $display("AAAA %4d %4d arrayCountLess", steps, ip);
end
              j = 0; k = arraySizes[localMem[14]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[14] * NArea + i] < 1) j = j + 1;
              end
              localMem[21] = j;
              ip = 61;
      end

         61 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[22] = heapMem[localMem[2]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 62;
      end

         62 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[22] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[21], localMem[22], arraySizes[localMem[22]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[21] && i <= arraySizes[localMem[22]]) begin
                  heapMem[NArea * localMem[22] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[22] + localMem[21]] = 1;                                    // Insert new value
              arraySizes[localMem[22]] = arraySizes[localMem[22]] + 1;                              // Increase array size
              ip = 63;
      end

         63 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[23] = heapMem[localMem[2]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 64;
      end

         64 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[23] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[21], localMem[23], arraySizes[localMem[23]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[21] && i <= arraySizes[localMem[23]]) begin
                  heapMem[NArea * localMem[23] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[23] + localMem[21]] = 11;                                    // Insert new value
              arraySizes[localMem[23]] = arraySizes[localMem[23]] + 1;                              // Increase array size
              ip = 65;
      end

         65 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[2]*7 + 0] = heapMem[localMem[2]*7 + 0] + 1;
              updateArrayLength(1, localMem[2], 0);
              ip = 66;
      end

         66 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[0]*7 + 0] = heapMem[localMem[0]*7 + 0] + 1;
              updateArrayLength(1, localMem[0], 0);
              ip = 67;
      end

         67 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1059;
      end

         68 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 69;
      end

         69 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 70;
      end

         70 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 71;
      end

         71 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[24] = heapMem[localMem[0]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 72;
      end

         72 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 73;
      end

         73 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[26] = heapMem[localMem[24]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 74;
      end

         74 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[27] = heapMem[localMem[24]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 75;
      end

         75 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[28] = heapMem[localMem[27]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 76;
      end

         76 :
      begin                                                                     // jLt
if (0) begin
  $display("AAAA %4d %4d jLt", steps, ip);
end
              ip = localMem[26] <  localMem[28] ? 296 : 77;
      end

         77 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[29] = localMem[28];
              updateArrayLength(2, 0, 0);
              ip = 78;
      end

         78 :
      begin                                                                     // shiftRight
if (0) begin
  $display("AAAA %4d %4d shiftRight", steps, ip);
end
              localMem[29] = localMem[29] >> 1;
              ip = 79;
      end

         79 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[30] = localMem[29] + 1;
              updateArrayLength(2, 0, 0);
              ip = 80;
      end

         80 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[31] = heapMem[localMem[24]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 81;
      end

         81 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[31] == 0 ? 178 : 82;
      end

         82 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[32] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[32] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[32]] = 0;
              ip = 83;
      end

         83 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[32]*7 + 0] = localMem[29];
              updateArrayLength(1, localMem[32], 0);
              ip = 84;
      end

         84 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[32]*7 + 2] = 0;
              updateArrayLength(1, localMem[32], 2);
              ip = 85;
      end

         85 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[33] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[33] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[33]] = 0;
              ip = 86;
      end

         86 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[32]*7 + 4] = localMem[33];
              updateArrayLength(1, localMem[32], 4);
              ip = 87;
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
              heapMem[localMem[32]*7 + 5] = localMem[34];
              updateArrayLength(1, localMem[32], 5);
              ip = 89;
      end

         89 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[32]*7 + 6] = 0;
              updateArrayLength(1, localMem[32], 6);
              ip = 90;
      end

         90 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[32]*7 + 3] = localMem[27];
              updateArrayLength(1, localMem[32], 3);
              ip = 91;
      end

         91 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[27]*7 + 1] = heapMem[localMem[27]*7 + 1] + 1;
              updateArrayLength(1, localMem[27], 1);
              ip = 92;
      end

         92 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[32]*7 + 1] = heapMem[localMem[27]*7 + 1];
              updateArrayLength(1, localMem[32], 1);
              ip = 93;
      end

         93 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[35] = !heapMem[localMem[24]*7 + 6];
              ip = 94;
      end

         94 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[35] != 0 ? 123 : 95;
      end

         95 :
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
              ip = 96;
      end

         96 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[32]*7 + 6] = localMem[36];
              updateArrayLength(1, localMem[32], 6);
              ip = 97;
      end

         97 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[37] = heapMem[localMem[24]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 98;
      end

         98 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[38] = heapMem[localMem[32]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 99;
      end

         99 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[29]) begin
                  heapMem[NArea * localMem[38] + 0 + i] = heapMem[NArea * localMem[37] + localMem[30] + i];
                  updateArrayLength(1, localMem[38], 0 + i);
                end
              end
              ip = 100;
      end

        100 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[39] = heapMem[localMem[24]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 101;
      end

        101 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[40] = heapMem[localMem[32]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 102;
      end

        102 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[29]) begin
                  heapMem[NArea * localMem[40] + 0 + i] = heapMem[NArea * localMem[39] + localMem[30] + i];
                  updateArrayLength(1, localMem[40], 0 + i);
                end
              end
              ip = 103;
      end

        103 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[41] = heapMem[localMem[24]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 104;
      end

        104 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[42] = heapMem[localMem[32]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 105;
      end

        105 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[43] = localMem[29] + 1;
              updateArrayLength(2, 0, 0);
              ip = 106;
      end

        106 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[43]) begin
                  heapMem[NArea * localMem[42] + 0 + i] = heapMem[NArea * localMem[41] + localMem[30] + i];
                  updateArrayLength(1, localMem[42], 0 + i);
                end
              end
              ip = 107;
      end

        107 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[44] = heapMem[localMem[32]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 108;
      end

        108 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[45] = localMem[44] + 1;
              updateArrayLength(2, 0, 0);
              ip = 109;
      end

        109 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[46] = heapMem[localMem[32]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 110;
      end

        110 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 111;
      end

        111 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[47] = 0;
              updateArrayLength(2, 0, 0);
              ip = 112;
      end

        112 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 113;
      end

        113 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[47] >= localMem[45] ? 119 : 114;
      end

        114 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[48] = heapMem[localMem[46]*7 + localMem[47]];
              updateArrayLength(2, 0, 0);
              ip = 115;
      end

        115 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[48]*7 + 2] = localMem[32];
              updateArrayLength(1, localMem[48], 2);
              ip = 116;
      end

        116 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 117;
      end

        117 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[47] = localMem[47] + 1;
              updateArrayLength(2, 0, 0);
              ip = 118;
      end

        118 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 112;
      end

        119 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 120;
      end

        120 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[49] = heapMem[localMem[24]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 121;
      end

        121 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[49]] = localMem[30];
              ip = 122;
      end

        122 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 130;
      end

        123 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 124;
      end

        124 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[50] = heapMem[localMem[24]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 125;
      end

        125 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[51] = heapMem[localMem[32]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 126;
      end

        126 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[29]) begin
                  heapMem[NArea * localMem[51] + 0 + i] = heapMem[NArea * localMem[50] + localMem[30] + i];
                  updateArrayLength(1, localMem[51], 0 + i);
                end
              end
              ip = 127;
      end

        127 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[52] = heapMem[localMem[24]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 128;
      end

        128 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[53] = heapMem[localMem[32]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 129;
      end

        129 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[29]) begin
                  heapMem[NArea * localMem[53] + 0 + i] = heapMem[NArea * localMem[52] + localMem[30] + i];
                  updateArrayLength(1, localMem[53], 0 + i);
                end
              end
              ip = 130;
      end

        130 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 131;
      end

        131 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[24]*7 + 0] = localMem[29];
              updateArrayLength(1, localMem[24], 0);
              ip = 132;
      end

        132 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[32]*7 + 2] = localMem[31];
              updateArrayLength(1, localMem[32], 2);
              ip = 133;
      end

        133 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[54] = heapMem[localMem[31]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 134;
      end

        134 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[55] = heapMem[localMem[31]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 135;
      end

        135 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[56] = heapMem[localMem[55]*7 + localMem[54]];
              updateArrayLength(2, 0, 0);
              ip = 136;
      end

        136 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[56] != localMem[24] ? 155 : 137;
      end

        137 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[57] = heapMem[localMem[24]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 138;
      end

        138 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[58] = heapMem[localMem[57]*7 + localMem[29]];
              updateArrayLength(2, 0, 0);
              ip = 139;
      end

        139 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[59] = heapMem[localMem[31]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 140;
      end

        140 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[59]*7 + localMem[54]] = localMem[58];
              updateArrayLength(1, localMem[59], localMem[54]);
              ip = 141;
      end

        141 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[60] = heapMem[localMem[24]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 142;
      end

        142 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[61] = heapMem[localMem[60]*7 + localMem[29]];
              updateArrayLength(2, 0, 0);
              ip = 143;
      end

        143 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[62] = heapMem[localMem[31]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 144;
      end

        144 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[62]*7 + localMem[54]] = localMem[61];
              updateArrayLength(1, localMem[62], localMem[54]);
              ip = 145;
      end

        145 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[63] = heapMem[localMem[24]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 146;
      end

        146 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[63]] = localMem[29];
              ip = 147;
      end

        147 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[64] = heapMem[localMem[24]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 148;
      end

        148 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[64]] = localMem[29];
              ip = 149;
      end

        149 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[65] = localMem[54] + 1;
              updateArrayLength(2, 0, 0);
              ip = 150;
      end

        150 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[31]*7 + 0] = localMem[65];
              updateArrayLength(1, localMem[31], 0);
              ip = 151;
      end

        151 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[66] = heapMem[localMem[31]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 152;
      end

        152 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[66]*7 + localMem[65]] = localMem[32];
              updateArrayLength(1, localMem[66], localMem[65]);
              ip = 153;
      end

        153 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 293;
      end

        154 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 177;
      end

        155 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 156;
      end

        156 :
      begin                                                                     // assertNe
if (0) begin
  $display("AAAA %4d %4d assertNe", steps, ip);
end
            ip = 157;
      end

        157 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[67] = heapMem[localMem[31]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 158;
      end

        158 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[68] = 0; k = arraySizes[localMem[67]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[67] * NArea + i] == localMem[24]) localMem[68] = i + 1;
              end
              ip = 159;
      end

        159 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[68] = localMem[68] - 1;
              updateArrayLength(2, 0, 0);
              ip = 160;
      end

        160 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[69] = heapMem[localMem[24]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 161;
      end

        161 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[70] = heapMem[localMem[69]*7 + localMem[29]];
              updateArrayLength(2, 0, 0);
              ip = 162;
      end

        162 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[71] = heapMem[localMem[24]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 163;
      end

        163 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[72] = heapMem[localMem[71]*7 + localMem[29]];
              updateArrayLength(2, 0, 0);
              ip = 164;
      end

        164 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[73] = heapMem[localMem[24]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 165;
      end

        165 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[73]] = localMem[29];
              ip = 166;
      end

        166 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[74] = heapMem[localMem[24]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 167;
      end

        167 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[74]] = localMem[29];
              ip = 168;
      end

        168 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[75] = heapMem[localMem[31]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 169;
      end

        169 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[75] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[68], localMem[75], arraySizes[localMem[75]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[68] && i <= arraySizes[localMem[75]]) begin
                  heapMem[NArea * localMem[75] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[75] + localMem[68]] = localMem[70];                                    // Insert new value
              arraySizes[localMem[75]] = arraySizes[localMem[75]] + 1;                              // Increase array size
              ip = 170;
      end

        170 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[76] = heapMem[localMem[31]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 171;
      end

        171 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[76] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[68], localMem[76], arraySizes[localMem[76]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[68] && i <= arraySizes[localMem[76]]) begin
                  heapMem[NArea * localMem[76] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[76] + localMem[68]] = localMem[72];                                    // Insert new value
              arraySizes[localMem[76]] = arraySizes[localMem[76]] + 1;                              // Increase array size
              ip = 172;
      end

        172 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[77] = heapMem[localMem[31]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 173;
      end

        173 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[78] = localMem[68] + 1;
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
//$display("BBBB pos=%d array=%d length=%d", localMem[78], localMem[77], arraySizes[localMem[77]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[78] && i <= arraySizes[localMem[77]]) begin
                  heapMem[NArea * localMem[77] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[77] + localMem[78]] = localMem[32];                                    // Insert new value
              arraySizes[localMem[77]] = arraySizes[localMem[77]] + 1;                              // Increase array size
              ip = 175;
      end

        175 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[31]*7 + 0] = heapMem[localMem[31]*7 + 0] + 1;
              updateArrayLength(1, localMem[31], 0);
              ip = 176;
      end

        176 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 293;
      end

        177 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 178;
      end

        178 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 179;
      end

        179 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[79] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[79] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[79]] = 0;
              ip = 180;
      end

        180 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[79]*7 + 0] = localMem[29];
              updateArrayLength(1, localMem[79], 0);
              ip = 181;
      end

        181 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[79]*7 + 2] = 0;
              updateArrayLength(1, localMem[79], 2);
              ip = 182;
      end

        182 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[80] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[80] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[80]] = 0;
              ip = 183;
      end

        183 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[79]*7 + 4] = localMem[80];
              updateArrayLength(1, localMem[79], 4);
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
              heapMem[localMem[79]*7 + 5] = localMem[81];
              updateArrayLength(1, localMem[79], 5);
              ip = 186;
      end

        186 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[79]*7 + 6] = 0;
              updateArrayLength(1, localMem[79], 6);
              ip = 187;
      end

        187 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[79]*7 + 3] = localMem[27];
              updateArrayLength(1, localMem[79], 3);
              ip = 188;
      end

        188 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[27]*7 + 1] = heapMem[localMem[27]*7 + 1] + 1;
              updateArrayLength(1, localMem[27], 1);
              ip = 189;
      end

        189 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[79]*7 + 1] = heapMem[localMem[27]*7 + 1];
              updateArrayLength(1, localMem[79], 1);
              ip = 190;
      end

        190 :
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
              ip = 191;
      end

        191 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[82]*7 + 0] = localMem[29];
              updateArrayLength(1, localMem[82], 0);
              ip = 192;
      end

        192 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[82]*7 + 2] = 0;
              updateArrayLength(1, localMem[82], 2);
              ip = 193;
      end

        193 :
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
              ip = 194;
      end

        194 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[82]*7 + 4] = localMem[83];
              updateArrayLength(1, localMem[82], 4);
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
              heapMem[localMem[82]*7 + 5] = localMem[84];
              updateArrayLength(1, localMem[82], 5);
              ip = 197;
      end

        197 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[82]*7 + 6] = 0;
              updateArrayLength(1, localMem[82], 6);
              ip = 198;
      end

        198 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[82]*7 + 3] = localMem[27];
              updateArrayLength(1, localMem[82], 3);
              ip = 199;
      end

        199 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[27]*7 + 1] = heapMem[localMem[27]*7 + 1] + 1;
              updateArrayLength(1, localMem[27], 1);
              ip = 200;
      end

        200 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[82]*7 + 1] = heapMem[localMem[27]*7 + 1];
              updateArrayLength(1, localMem[82], 1);
              ip = 201;
      end

        201 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[85] = !heapMem[localMem[24]*7 + 6];
              ip = 202;
      end

        202 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[85] != 0 ? 254 : 203;
      end

        203 :
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
              ip = 204;
      end

        204 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[79]*7 + 6] = localMem[86];
              updateArrayLength(1, localMem[79], 6);
              ip = 205;
      end

        205 :
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
              ip = 206;
      end

        206 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[82]*7 + 6] = localMem[87];
              updateArrayLength(1, localMem[82], 6);
              ip = 207;
      end

        207 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[88] = heapMem[localMem[24]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 208;
      end

        208 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[89] = heapMem[localMem[79]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 209;
      end

        209 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[29]) begin
                  heapMem[NArea * localMem[89] + 0 + i] = heapMem[NArea * localMem[88] + 0 + i];
                  updateArrayLength(1, localMem[89], 0 + i);
                end
              end
              ip = 210;
      end

        210 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[90] = heapMem[localMem[24]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 211;
      end

        211 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[91] = heapMem[localMem[79]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 212;
      end

        212 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[29]) begin
                  heapMem[NArea * localMem[91] + 0 + i] = heapMem[NArea * localMem[90] + 0 + i];
                  updateArrayLength(1, localMem[91], 0 + i);
                end
              end
              ip = 213;
      end

        213 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[92] = heapMem[localMem[24]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 214;
      end

        214 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[93] = heapMem[localMem[79]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 215;
      end

        215 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[94] = localMem[29] + 1;
              updateArrayLength(2, 0, 0);
              ip = 216;
      end

        216 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[94]) begin
                  heapMem[NArea * localMem[93] + 0 + i] = heapMem[NArea * localMem[92] + 0 + i];
                  updateArrayLength(1, localMem[93], 0 + i);
                end
              end
              ip = 217;
      end

        217 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[95] = heapMem[localMem[24]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 218;
      end

        218 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[96] = heapMem[localMem[82]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 219;
      end

        219 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[29]) begin
                  heapMem[NArea * localMem[96] + 0 + i] = heapMem[NArea * localMem[95] + localMem[30] + i];
                  updateArrayLength(1, localMem[96], 0 + i);
                end
              end
              ip = 220;
      end

        220 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[97] = heapMem[localMem[24]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 221;
      end

        221 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[98] = heapMem[localMem[82]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 222;
      end

        222 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[29]) begin
                  heapMem[NArea * localMem[98] + 0 + i] = heapMem[NArea * localMem[97] + localMem[30] + i];
                  updateArrayLength(1, localMem[98], 0 + i);
                end
              end
              ip = 223;
      end

        223 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[99] = heapMem[localMem[24]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 224;
      end

        224 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[100] = heapMem[localMem[82]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 225;
      end

        225 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[101] = localMem[29] + 1;
              updateArrayLength(2, 0, 0);
              ip = 226;
      end

        226 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[101]) begin
                  heapMem[NArea * localMem[100] + 0 + i] = heapMem[NArea * localMem[99] + localMem[30] + i];
                  updateArrayLength(1, localMem[100], 0 + i);
                end
              end
              ip = 227;
      end

        227 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[102] = heapMem[localMem[79]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 228;
      end

        228 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[103] = localMem[102] + 1;
              updateArrayLength(2, 0, 0);
              ip = 229;
      end

        229 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[104] = heapMem[localMem[79]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 230;
      end

        230 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 231;
      end

        231 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[105] = 0;
              updateArrayLength(2, 0, 0);
              ip = 232;
      end

        232 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 233;
      end

        233 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[105] >= localMem[103] ? 239 : 234;
      end

        234 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[106] = heapMem[localMem[104]*7 + localMem[105]];
              updateArrayLength(2, 0, 0);
              ip = 235;
      end

        235 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[106]*7 + 2] = localMem[79];
              updateArrayLength(1, localMem[106], 2);
              ip = 236;
      end

        236 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 237;
      end

        237 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[105] = localMem[105] + 1;
              updateArrayLength(2, 0, 0);
              ip = 238;
      end

        238 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 232;
      end

        239 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 240;
      end

        240 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[107] = heapMem[localMem[82]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 241;
      end

        241 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[108] = localMem[107] + 1;
              updateArrayLength(2, 0, 0);
              ip = 242;
      end

        242 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[109] = heapMem[localMem[82]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 243;
      end

        243 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 244;
      end

        244 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[110] = 0;
              updateArrayLength(2, 0, 0);
              ip = 245;
      end

        245 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 246;
      end

        246 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[110] >= localMem[108] ? 252 : 247;
      end

        247 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[111] = heapMem[localMem[109]*7 + localMem[110]];
              updateArrayLength(2, 0, 0);
              ip = 248;
      end

        248 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[111]*7 + 2] = localMem[82];
              updateArrayLength(1, localMem[111], 2);
              ip = 249;
      end

        249 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 250;
      end

        250 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[110] = localMem[110] + 1;
              updateArrayLength(2, 0, 0);
              ip = 251;
      end

        251 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 245;
      end

        252 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 253;
      end

        253 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 269;
      end

        254 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 255;
      end

        255 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[112] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[112] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[112]] = 0;
              ip = 256;
      end

        256 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[24]*7 + 6] = localMem[112];
              updateArrayLength(1, localMem[24], 6);
              ip = 257;
      end

        257 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[113] = heapMem[localMem[24]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 258;
      end

        258 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[114] = heapMem[localMem[79]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 259;
      end

        259 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[29]) begin
                  heapMem[NArea * localMem[114] + 0 + i] = heapMem[NArea * localMem[113] + 0 + i];
                  updateArrayLength(1, localMem[114], 0 + i);
                end
              end
              ip = 260;
      end

        260 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[115] = heapMem[localMem[24]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 261;
      end

        261 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[116] = heapMem[localMem[79]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 262;
      end

        262 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[29]) begin
                  heapMem[NArea * localMem[116] + 0 + i] = heapMem[NArea * localMem[115] + 0 + i];
                  updateArrayLength(1, localMem[116], 0 + i);
                end
              end
              ip = 263;
      end

        263 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[117] = heapMem[localMem[24]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 264;
      end

        264 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[118] = heapMem[localMem[82]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 265;
      end

        265 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[29]) begin
                  heapMem[NArea * localMem[118] + 0 + i] = heapMem[NArea * localMem[117] + localMem[30] + i];
                  updateArrayLength(1, localMem[118], 0 + i);
                end
              end
              ip = 266;
      end

        266 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[119] = heapMem[localMem[24]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 267;
      end

        267 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[120] = heapMem[localMem[82]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 268;
      end

        268 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[29]) begin
                  heapMem[NArea * localMem[120] + 0 + i] = heapMem[NArea * localMem[119] + localMem[30] + i];
                  updateArrayLength(1, localMem[120], 0 + i);
                end
              end
              ip = 269;
      end

        269 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 270;
      end

        270 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[79]*7 + 2] = localMem[24];
              updateArrayLength(1, localMem[79], 2);
              ip = 271;
      end

        271 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[82]*7 + 2] = localMem[24];
              updateArrayLength(1, localMem[82], 2);
              ip = 272;
      end

        272 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[121] = heapMem[localMem[24]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 273;
      end

        273 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[122] = heapMem[localMem[121]*7 + localMem[29]];
              updateArrayLength(2, 0, 0);
              ip = 274;
      end

        274 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[123] = heapMem[localMem[24]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 275;
      end

        275 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[124] = heapMem[localMem[123]*7 + localMem[29]];
              updateArrayLength(2, 0, 0);
              ip = 276;
      end

        276 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[125] = heapMem[localMem[24]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 277;
      end

        277 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[125]*7 + 0] = localMem[122];
              updateArrayLength(1, localMem[125], 0);
              ip = 278;
      end

        278 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[126] = heapMem[localMem[24]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 279;
      end

        279 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[126]*7 + 0] = localMem[124];
              updateArrayLength(1, localMem[126], 0);
              ip = 280;
      end

        280 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[127] = heapMem[localMem[24]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 281;
      end

        281 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[127]*7 + 0] = localMem[79];
              updateArrayLength(1, localMem[127], 0);
              ip = 282;
      end

        282 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[128] = heapMem[localMem[24]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 283;
      end

        283 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[128]*7 + 1] = localMem[82];
              updateArrayLength(1, localMem[128], 1);
              ip = 284;
      end

        284 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[24]*7 + 0] = 1;
              updateArrayLength(1, localMem[24], 0);
              ip = 285;
      end

        285 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[129] = heapMem[localMem[24]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 286;
      end

        286 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[129]] = 1;
              ip = 287;
      end

        287 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[130] = heapMem[localMem[24]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 288;
      end

        288 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[130]] = 1;
              ip = 289;
      end

        289 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[131] = heapMem[localMem[24]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 290;
      end

        290 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[131]] = 2;
              ip = 291;
      end

        291 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 293;
      end

        292 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 298;
      end

        293 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 294;
      end

        294 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[25] = 1;
              updateArrayLength(2, 0, 0);
              ip = 295;
      end

        295 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 298;
      end

        296 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 297;
      end

        297 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[25] = 0;
              updateArrayLength(2, 0, 0);
              ip = 298;
      end

        298 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 299;
      end

        299 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 300;
      end

        300 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 301;
      end

        301 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[132] = 0;
              updateArrayLength(2, 0, 0);
              ip = 302;
      end

        302 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 303;
      end

        303 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[132] >= 99 ? 801 : 304;
      end

        304 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[133] = heapMem[localMem[24]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 305;
      end

        305 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[134] = localMem[133] - 1;
              updateArrayLength(2, 0, 0);
              ip = 306;
      end

        306 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[135] = heapMem[localMem[24]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 307;
      end

        307 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[136] = heapMem[localMem[135]*7 + localMem[134]];
              updateArrayLength(2, 0, 0);
              ip = 308;
      end

        308 :
      begin                                                                     // jLe
if (0) begin
  $display("AAAA %4d %4d jLe", steps, ip);
end
              ip = 1 <= localMem[136] ? 549 : 309;
      end

        309 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[137] = !heapMem[localMem[24]*7 + 6];
              ip = 310;
      end

        310 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[137] == 0 ? 315 : 311;
      end

        311 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[1]*7 + 0] = localMem[24];
              updateArrayLength(1, localMem[1], 0);
              ip = 312;
      end

        312 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[1]*7 + 1] = 2;
              updateArrayLength(1, localMem[1], 1);
              ip = 313;
      end

        313 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              heapMem[localMem[1]*7 + 2] = localMem[133] - 1;
              updateArrayLength(1, localMem[1], 2);
              ip = 314;
      end

        314 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 805;
      end

        315 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 316;
      end

        316 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[138] = heapMem[localMem[24]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 317;
      end

        317 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[139] = heapMem[localMem[138]*7 + localMem[133]];
              updateArrayLength(2, 0, 0);
              ip = 318;
      end

        318 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 319;
      end

        319 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[141] = heapMem[localMem[139]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 320;
      end

        320 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[142] = heapMem[localMem[139]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 321;
      end

        321 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[143] = heapMem[localMem[142]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 322;
      end

        322 :
      begin                                                                     // jLt
if (0) begin
  $display("AAAA %4d %4d jLt", steps, ip);
end
              ip = localMem[141] <  localMem[143] ? 542 : 323;
      end

        323 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[144] = localMem[143];
              updateArrayLength(2, 0, 0);
              ip = 324;
      end

        324 :
      begin                                                                     // shiftRight
if (0) begin
  $display("AAAA %4d %4d shiftRight", steps, ip);
end
              localMem[144] = localMem[144] >> 1;
              ip = 325;
      end

        325 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[145] = localMem[144] + 1;
              updateArrayLength(2, 0, 0);
              ip = 326;
      end

        326 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[146] = heapMem[localMem[139]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 327;
      end

        327 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[146] == 0 ? 424 : 328;
      end

        328 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[147] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[147] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[147]] = 0;
              ip = 329;
      end

        329 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[147]*7 + 0] = localMem[144];
              updateArrayLength(1, localMem[147], 0);
              ip = 330;
      end

        330 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[147]*7 + 2] = 0;
              updateArrayLength(1, localMem[147], 2);
              ip = 331;
      end

        331 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[148] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[148] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[148]] = 0;
              ip = 332;
      end

        332 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[147]*7 + 4] = localMem[148];
              updateArrayLength(1, localMem[147], 4);
              ip = 333;
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
              heapMem[localMem[147]*7 + 5] = localMem[149];
              updateArrayLength(1, localMem[147], 5);
              ip = 335;
      end

        335 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[147]*7 + 6] = 0;
              updateArrayLength(1, localMem[147], 6);
              ip = 336;
      end

        336 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[147]*7 + 3] = localMem[142];
              updateArrayLength(1, localMem[147], 3);
              ip = 337;
      end

        337 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[142]*7 + 1] = heapMem[localMem[142]*7 + 1] + 1;
              updateArrayLength(1, localMem[142], 1);
              ip = 338;
      end

        338 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[147]*7 + 1] = heapMem[localMem[142]*7 + 1];
              updateArrayLength(1, localMem[147], 1);
              ip = 339;
      end

        339 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[150] = !heapMem[localMem[139]*7 + 6];
              ip = 340;
      end

        340 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[150] != 0 ? 369 : 341;
      end

        341 :
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
              ip = 342;
      end

        342 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[147]*7 + 6] = localMem[151];
              updateArrayLength(1, localMem[147], 6);
              ip = 343;
      end

        343 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[152] = heapMem[localMem[139]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 344;
      end

        344 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[153] = heapMem[localMem[147]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 345;
      end

        345 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[144]) begin
                  heapMem[NArea * localMem[153] + 0 + i] = heapMem[NArea * localMem[152] + localMem[145] + i];
                  updateArrayLength(1, localMem[153], 0 + i);
                end
              end
              ip = 346;
      end

        346 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[154] = heapMem[localMem[139]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 347;
      end

        347 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[155] = heapMem[localMem[147]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 348;
      end

        348 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[144]) begin
                  heapMem[NArea * localMem[155] + 0 + i] = heapMem[NArea * localMem[154] + localMem[145] + i];
                  updateArrayLength(1, localMem[155], 0 + i);
                end
              end
              ip = 349;
      end

        349 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[156] = heapMem[localMem[139]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 350;
      end

        350 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[157] = heapMem[localMem[147]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 351;
      end

        351 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[158] = localMem[144] + 1;
              updateArrayLength(2, 0, 0);
              ip = 352;
      end

        352 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[158]) begin
                  heapMem[NArea * localMem[157] + 0 + i] = heapMem[NArea * localMem[156] + localMem[145] + i];
                  updateArrayLength(1, localMem[157], 0 + i);
                end
              end
              ip = 353;
      end

        353 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[159] = heapMem[localMem[147]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 354;
      end

        354 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[160] = localMem[159] + 1;
              updateArrayLength(2, 0, 0);
              ip = 355;
      end

        355 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[161] = heapMem[localMem[147]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 356;
      end

        356 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 357;
      end

        357 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[162] = 0;
              updateArrayLength(2, 0, 0);
              ip = 358;
      end

        358 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 359;
      end

        359 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[162] >= localMem[160] ? 365 : 360;
      end

        360 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[163] = heapMem[localMem[161]*7 + localMem[162]];
              updateArrayLength(2, 0, 0);
              ip = 361;
      end

        361 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[163]*7 + 2] = localMem[147];
              updateArrayLength(1, localMem[163], 2);
              ip = 362;
      end

        362 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 363;
      end

        363 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[162] = localMem[162] + 1;
              updateArrayLength(2, 0, 0);
              ip = 364;
      end

        364 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 358;
      end

        365 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 366;
      end

        366 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[164] = heapMem[localMem[139]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 367;
      end

        367 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[164]] = localMem[145];
              ip = 368;
      end

        368 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 376;
      end

        369 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 370;
      end

        370 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[165] = heapMem[localMem[139]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 371;
      end

        371 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[166] = heapMem[localMem[147]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 372;
      end

        372 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[144]) begin
                  heapMem[NArea * localMem[166] + 0 + i] = heapMem[NArea * localMem[165] + localMem[145] + i];
                  updateArrayLength(1, localMem[166], 0 + i);
                end
              end
              ip = 373;
      end

        373 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[167] = heapMem[localMem[139]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 374;
      end

        374 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[168] = heapMem[localMem[147]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 375;
      end

        375 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[144]) begin
                  heapMem[NArea * localMem[168] + 0 + i] = heapMem[NArea * localMem[167] + localMem[145] + i];
                  updateArrayLength(1, localMem[168], 0 + i);
                end
              end
              ip = 376;
      end

        376 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 377;
      end

        377 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[139]*7 + 0] = localMem[144];
              updateArrayLength(1, localMem[139], 0);
              ip = 378;
      end

        378 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[147]*7 + 2] = localMem[146];
              updateArrayLength(1, localMem[147], 2);
              ip = 379;
      end

        379 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[169] = heapMem[localMem[146]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 380;
      end

        380 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[170] = heapMem[localMem[146]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 381;
      end

        381 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[171] = heapMem[localMem[170]*7 + localMem[169]];
              updateArrayLength(2, 0, 0);
              ip = 382;
      end

        382 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[171] != localMem[139] ? 401 : 383;
      end

        383 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[172] = heapMem[localMem[139]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 384;
      end

        384 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[173] = heapMem[localMem[172]*7 + localMem[144]];
              updateArrayLength(2, 0, 0);
              ip = 385;
      end

        385 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[174] = heapMem[localMem[146]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 386;
      end

        386 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[174]*7 + localMem[169]] = localMem[173];
              updateArrayLength(1, localMem[174], localMem[169]);
              ip = 387;
      end

        387 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[175] = heapMem[localMem[139]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 388;
      end

        388 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[176] = heapMem[localMem[175]*7 + localMem[144]];
              updateArrayLength(2, 0, 0);
              ip = 389;
      end

        389 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[177] = heapMem[localMem[146]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 390;
      end

        390 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[177]*7 + localMem[169]] = localMem[176];
              updateArrayLength(1, localMem[177], localMem[169]);
              ip = 391;
      end

        391 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[178] = heapMem[localMem[139]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 392;
      end

        392 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[178]] = localMem[144];
              ip = 393;
      end

        393 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[179] = heapMem[localMem[139]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 394;
      end

        394 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[179]] = localMem[144];
              ip = 395;
      end

        395 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[180] = localMem[169] + 1;
              updateArrayLength(2, 0, 0);
              ip = 396;
      end

        396 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[146]*7 + 0] = localMem[180];
              updateArrayLength(1, localMem[146], 0);
              ip = 397;
      end

        397 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[181] = heapMem[localMem[146]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 398;
      end

        398 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[181]*7 + localMem[180]] = localMem[147];
              updateArrayLength(1, localMem[181], localMem[180]);
              ip = 399;
      end

        399 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 539;
      end

        400 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 423;
      end

        401 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 402;
      end

        402 :
      begin                                                                     // assertNe
if (0) begin
  $display("AAAA %4d %4d assertNe", steps, ip);
end
            ip = 403;
      end

        403 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[182] = heapMem[localMem[146]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 404;
      end

        404 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[183] = 0; k = arraySizes[localMem[182]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[182] * NArea + i] == localMem[139]) localMem[183] = i + 1;
              end
              ip = 405;
      end

        405 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[183] = localMem[183] - 1;
              updateArrayLength(2, 0, 0);
              ip = 406;
      end

        406 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[184] = heapMem[localMem[139]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 407;
      end

        407 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[185] = heapMem[localMem[184]*7 + localMem[144]];
              updateArrayLength(2, 0, 0);
              ip = 408;
      end

        408 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[186] = heapMem[localMem[139]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 409;
      end

        409 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[187] = heapMem[localMem[186]*7 + localMem[144]];
              updateArrayLength(2, 0, 0);
              ip = 410;
      end

        410 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[188] = heapMem[localMem[139]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 411;
      end

        411 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[188]] = localMem[144];
              ip = 412;
      end

        412 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[189] = heapMem[localMem[139]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 413;
      end

        413 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[189]] = localMem[144];
              ip = 414;
      end

        414 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[190] = heapMem[localMem[146]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 415;
      end

        415 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[190] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[183], localMem[190], arraySizes[localMem[190]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[183] && i <= arraySizes[localMem[190]]) begin
                  heapMem[NArea * localMem[190] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[190] + localMem[183]] = localMem[185];                                    // Insert new value
              arraySizes[localMem[190]] = arraySizes[localMem[190]] + 1;                              // Increase array size
              ip = 416;
      end

        416 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[191] = heapMem[localMem[146]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 417;
      end

        417 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[191] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[183], localMem[191], arraySizes[localMem[191]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[183] && i <= arraySizes[localMem[191]]) begin
                  heapMem[NArea * localMem[191] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[191] + localMem[183]] = localMem[187];                                    // Insert new value
              arraySizes[localMem[191]] = arraySizes[localMem[191]] + 1;                              // Increase array size
              ip = 418;
      end

        418 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[192] = heapMem[localMem[146]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 419;
      end

        419 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[193] = localMem[183] + 1;
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
//$display("BBBB pos=%d array=%d length=%d", localMem[193], localMem[192], arraySizes[localMem[192]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[193] && i <= arraySizes[localMem[192]]) begin
                  heapMem[NArea * localMem[192] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[192] + localMem[193]] = localMem[147];                                    // Insert new value
              arraySizes[localMem[192]] = arraySizes[localMem[192]] + 1;                              // Increase array size
              ip = 421;
      end

        421 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[146]*7 + 0] = heapMem[localMem[146]*7 + 0] + 1;
              updateArrayLength(1, localMem[146], 0);
              ip = 422;
      end

        422 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 539;
      end

        423 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 424;
      end

        424 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 425;
      end

        425 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[194] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[194] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[194]] = 0;
              ip = 426;
      end

        426 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[194]*7 + 0] = localMem[144];
              updateArrayLength(1, localMem[194], 0);
              ip = 427;
      end

        427 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[194]*7 + 2] = 0;
              updateArrayLength(1, localMem[194], 2);
              ip = 428;
      end

        428 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[195] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[195] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[195]] = 0;
              ip = 429;
      end

        429 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[194]*7 + 4] = localMem[195];
              updateArrayLength(1, localMem[194], 4);
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
              heapMem[localMem[194]*7 + 5] = localMem[196];
              updateArrayLength(1, localMem[194], 5);
              ip = 432;
      end

        432 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[194]*7 + 6] = 0;
              updateArrayLength(1, localMem[194], 6);
              ip = 433;
      end

        433 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[194]*7 + 3] = localMem[142];
              updateArrayLength(1, localMem[194], 3);
              ip = 434;
      end

        434 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[142]*7 + 1] = heapMem[localMem[142]*7 + 1] + 1;
              updateArrayLength(1, localMem[142], 1);
              ip = 435;
      end

        435 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[194]*7 + 1] = heapMem[localMem[142]*7 + 1];
              updateArrayLength(1, localMem[194], 1);
              ip = 436;
      end

        436 :
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
              ip = 437;
      end

        437 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[197]*7 + 0] = localMem[144];
              updateArrayLength(1, localMem[197], 0);
              ip = 438;
      end

        438 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[197]*7 + 2] = 0;
              updateArrayLength(1, localMem[197], 2);
              ip = 439;
      end

        439 :
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
              ip = 440;
      end

        440 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[197]*7 + 4] = localMem[198];
              updateArrayLength(1, localMem[197], 4);
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
              heapMem[localMem[197]*7 + 5] = localMem[199];
              updateArrayLength(1, localMem[197], 5);
              ip = 443;
      end

        443 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[197]*7 + 6] = 0;
              updateArrayLength(1, localMem[197], 6);
              ip = 444;
      end

        444 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[197]*7 + 3] = localMem[142];
              updateArrayLength(1, localMem[197], 3);
              ip = 445;
      end

        445 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[142]*7 + 1] = heapMem[localMem[142]*7 + 1] + 1;
              updateArrayLength(1, localMem[142], 1);
              ip = 446;
      end

        446 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[197]*7 + 1] = heapMem[localMem[142]*7 + 1];
              updateArrayLength(1, localMem[197], 1);
              ip = 447;
      end

        447 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[200] = !heapMem[localMem[139]*7 + 6];
              ip = 448;
      end

        448 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[200] != 0 ? 500 : 449;
      end

        449 :
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
              ip = 450;
      end

        450 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[194]*7 + 6] = localMem[201];
              updateArrayLength(1, localMem[194], 6);
              ip = 451;
      end

        451 :
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
              ip = 452;
      end

        452 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[197]*7 + 6] = localMem[202];
              updateArrayLength(1, localMem[197], 6);
              ip = 453;
      end

        453 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[203] = heapMem[localMem[139]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 454;
      end

        454 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[204] = heapMem[localMem[194]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 455;
      end

        455 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[144]) begin
                  heapMem[NArea * localMem[204] + 0 + i] = heapMem[NArea * localMem[203] + 0 + i];
                  updateArrayLength(1, localMem[204], 0 + i);
                end
              end
              ip = 456;
      end

        456 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[205] = heapMem[localMem[139]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 457;
      end

        457 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[206] = heapMem[localMem[194]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 458;
      end

        458 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[144]) begin
                  heapMem[NArea * localMem[206] + 0 + i] = heapMem[NArea * localMem[205] + 0 + i];
                  updateArrayLength(1, localMem[206], 0 + i);
                end
              end
              ip = 459;
      end

        459 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[207] = heapMem[localMem[139]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 460;
      end

        460 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[208] = heapMem[localMem[194]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 461;
      end

        461 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[209] = localMem[144] + 1;
              updateArrayLength(2, 0, 0);
              ip = 462;
      end

        462 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[209]) begin
                  heapMem[NArea * localMem[208] + 0 + i] = heapMem[NArea * localMem[207] + 0 + i];
                  updateArrayLength(1, localMem[208], 0 + i);
                end
              end
              ip = 463;
      end

        463 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[210] = heapMem[localMem[139]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 464;
      end

        464 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[211] = heapMem[localMem[197]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 465;
      end

        465 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[144]) begin
                  heapMem[NArea * localMem[211] + 0 + i] = heapMem[NArea * localMem[210] + localMem[145] + i];
                  updateArrayLength(1, localMem[211], 0 + i);
                end
              end
              ip = 466;
      end

        466 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[212] = heapMem[localMem[139]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 467;
      end

        467 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[213] = heapMem[localMem[197]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 468;
      end

        468 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[144]) begin
                  heapMem[NArea * localMem[213] + 0 + i] = heapMem[NArea * localMem[212] + localMem[145] + i];
                  updateArrayLength(1, localMem[213], 0 + i);
                end
              end
              ip = 469;
      end

        469 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[214] = heapMem[localMem[139]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 470;
      end

        470 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[215] = heapMem[localMem[197]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 471;
      end

        471 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[216] = localMem[144] + 1;
              updateArrayLength(2, 0, 0);
              ip = 472;
      end

        472 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[216]) begin
                  heapMem[NArea * localMem[215] + 0 + i] = heapMem[NArea * localMem[214] + localMem[145] + i];
                  updateArrayLength(1, localMem[215], 0 + i);
                end
              end
              ip = 473;
      end

        473 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[217] = heapMem[localMem[194]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 474;
      end

        474 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[218] = localMem[217] + 1;
              updateArrayLength(2, 0, 0);
              ip = 475;
      end

        475 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[219] = heapMem[localMem[194]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 476;
      end

        476 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 477;
      end

        477 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[220] = 0;
              updateArrayLength(2, 0, 0);
              ip = 478;
      end

        478 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 479;
      end

        479 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[220] >= localMem[218] ? 485 : 480;
      end

        480 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[221] = heapMem[localMem[219]*7 + localMem[220]];
              updateArrayLength(2, 0, 0);
              ip = 481;
      end

        481 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[221]*7 + 2] = localMem[194];
              updateArrayLength(1, localMem[221], 2);
              ip = 482;
      end

        482 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 483;
      end

        483 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[220] = localMem[220] + 1;
              updateArrayLength(2, 0, 0);
              ip = 484;
      end

        484 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 478;
      end

        485 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 486;
      end

        486 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[222] = heapMem[localMem[197]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 487;
      end

        487 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[223] = localMem[222] + 1;
              updateArrayLength(2, 0, 0);
              ip = 488;
      end

        488 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[224] = heapMem[localMem[197]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 489;
      end

        489 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 490;
      end

        490 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[225] = 0;
              updateArrayLength(2, 0, 0);
              ip = 491;
      end

        491 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 492;
      end

        492 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[225] >= localMem[223] ? 498 : 493;
      end

        493 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[226] = heapMem[localMem[224]*7 + localMem[225]];
              updateArrayLength(2, 0, 0);
              ip = 494;
      end

        494 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[226]*7 + 2] = localMem[197];
              updateArrayLength(1, localMem[226], 2);
              ip = 495;
      end

        495 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 496;
      end

        496 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[225] = localMem[225] + 1;
              updateArrayLength(2, 0, 0);
              ip = 497;
      end

        497 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 491;
      end

        498 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 499;
      end

        499 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 515;
      end

        500 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 501;
      end

        501 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[227] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[227] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[227]] = 0;
              ip = 502;
      end

        502 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[139]*7 + 6] = localMem[227];
              updateArrayLength(1, localMem[139], 6);
              ip = 503;
      end

        503 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[228] = heapMem[localMem[139]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 504;
      end

        504 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[229] = heapMem[localMem[194]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 505;
      end

        505 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[144]) begin
                  heapMem[NArea * localMem[229] + 0 + i] = heapMem[NArea * localMem[228] + 0 + i];
                  updateArrayLength(1, localMem[229], 0 + i);
                end
              end
              ip = 506;
      end

        506 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[230] = heapMem[localMem[139]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 507;
      end

        507 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[231] = heapMem[localMem[194]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 508;
      end

        508 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[144]) begin
                  heapMem[NArea * localMem[231] + 0 + i] = heapMem[NArea * localMem[230] + 0 + i];
                  updateArrayLength(1, localMem[231], 0 + i);
                end
              end
              ip = 509;
      end

        509 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[232] = heapMem[localMem[139]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 510;
      end

        510 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[233] = heapMem[localMem[197]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 511;
      end

        511 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[144]) begin
                  heapMem[NArea * localMem[233] + 0 + i] = heapMem[NArea * localMem[232] + localMem[145] + i];
                  updateArrayLength(1, localMem[233], 0 + i);
                end
              end
              ip = 512;
      end

        512 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[234] = heapMem[localMem[139]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 513;
      end

        513 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[235] = heapMem[localMem[197]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 514;
      end

        514 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[144]) begin
                  heapMem[NArea * localMem[235] + 0 + i] = heapMem[NArea * localMem[234] + localMem[145] + i];
                  updateArrayLength(1, localMem[235], 0 + i);
                end
              end
              ip = 515;
      end

        515 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 516;
      end

        516 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[194]*7 + 2] = localMem[139];
              updateArrayLength(1, localMem[194], 2);
              ip = 517;
      end

        517 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[197]*7 + 2] = localMem[139];
              updateArrayLength(1, localMem[197], 2);
              ip = 518;
      end

        518 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[236] = heapMem[localMem[139]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 519;
      end

        519 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[237] = heapMem[localMem[236]*7 + localMem[144]];
              updateArrayLength(2, 0, 0);
              ip = 520;
      end

        520 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[238] = heapMem[localMem[139]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 521;
      end

        521 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[239] = heapMem[localMem[238]*7 + localMem[144]];
              updateArrayLength(2, 0, 0);
              ip = 522;
      end

        522 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[240] = heapMem[localMem[139]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 523;
      end

        523 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[240]*7 + 0] = localMem[237];
              updateArrayLength(1, localMem[240], 0);
              ip = 524;
      end

        524 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[241] = heapMem[localMem[139]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 525;
      end

        525 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[241]*7 + 0] = localMem[239];
              updateArrayLength(1, localMem[241], 0);
              ip = 526;
      end

        526 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[242] = heapMem[localMem[139]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 527;
      end

        527 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[242]*7 + 0] = localMem[194];
              updateArrayLength(1, localMem[242], 0);
              ip = 528;
      end

        528 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[243] = heapMem[localMem[139]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 529;
      end

        529 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[243]*7 + 1] = localMem[197];
              updateArrayLength(1, localMem[243], 1);
              ip = 530;
      end

        530 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[139]*7 + 0] = 1;
              updateArrayLength(1, localMem[139], 0);
              ip = 531;
      end

        531 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[244] = heapMem[localMem[139]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 532;
      end

        532 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[244]] = 1;
              ip = 533;
      end

        533 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[245] = heapMem[localMem[139]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 534;
      end

        534 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[245]] = 1;
              ip = 535;
      end

        535 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[246] = heapMem[localMem[139]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 536;
      end

        536 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[246]] = 2;
              ip = 537;
      end

        537 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 539;
      end

        538 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 544;
      end

        539 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 540;
      end

        540 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[140] = 1;
              updateArrayLength(2, 0, 0);
              ip = 541;
      end

        541 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 544;
      end

        542 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 543;
      end

        543 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[140] = 0;
              updateArrayLength(2, 0, 0);
              ip = 544;
      end

        544 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 545;
      end

        545 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[140] != 0 ? 547 : 546;
      end

        546 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[24] = localMem[139];
              updateArrayLength(2, 0, 0);
              ip = 547;
      end

        547 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 548;
      end

        548 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 798;
      end

        549 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 550;
      end

        550 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[247] = heapMem[localMem[24]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 551;
      end

        551 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[248] = 0; k = arraySizes[localMem[247]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[247] * NArea + i] == 1) localMem[248] = i + 1;
              end
              ip = 552;
      end

        552 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[248] == 0 ? 557 : 553;
      end

        553 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[1]*7 + 0] = localMem[24];
              updateArrayLength(1, localMem[1], 0);
              ip = 554;
      end

        554 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[1]*7 + 1] = 1;
              updateArrayLength(1, localMem[1], 1);
              ip = 555;
      end

        555 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              heapMem[localMem[1]*7 + 2] = localMem[248] - 1;
              updateArrayLength(1, localMem[1], 2);
              ip = 556;
      end

        556 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 805;
      end

        557 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 558;
      end

        558 :
      begin                                                                     // arrayCountLess
if (0) begin
  $display("AAAA %4d %4d arrayCountLess", steps, ip);
end
              j = 0; k = arraySizes[localMem[247]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[247] * NArea + i] < 1) j = j + 1;
              end
              localMem[249] = j;
              ip = 559;
      end

        559 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[250] = !heapMem[localMem[24]*7 + 6];
              ip = 560;
      end

        560 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[250] == 0 ? 565 : 561;
      end

        561 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[1]*7 + 0] = localMem[24];
              updateArrayLength(1, localMem[1], 0);
              ip = 562;
      end

        562 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[1]*7 + 1] = 0;
              updateArrayLength(1, localMem[1], 1);
              ip = 563;
      end

        563 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[1]*7 + 2] = localMem[249];
              updateArrayLength(1, localMem[1], 2);
              ip = 564;
      end

        564 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 805;
      end

        565 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 566;
      end

        566 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[251] = heapMem[localMem[24]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 567;
      end

        567 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[252] = heapMem[localMem[251]*7 + localMem[249]];
              updateArrayLength(2, 0, 0);
              ip = 568;
      end

        568 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 569;
      end

        569 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[254] = heapMem[localMem[252]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 570;
      end

        570 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[255] = heapMem[localMem[252]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 571;
      end

        571 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[256] = heapMem[localMem[255]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 572;
      end

        572 :
      begin                                                                     // jLt
if (0) begin
  $display("AAAA %4d %4d jLt", steps, ip);
end
              ip = localMem[254] <  localMem[256] ? 792 : 573;
      end

        573 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[257] = localMem[256];
              updateArrayLength(2, 0, 0);
              ip = 574;
      end

        574 :
      begin                                                                     // shiftRight
if (0) begin
  $display("AAAA %4d %4d shiftRight", steps, ip);
end
              localMem[257] = localMem[257] >> 1;
              ip = 575;
      end

        575 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[258] = localMem[257] + 1;
              updateArrayLength(2, 0, 0);
              ip = 576;
      end

        576 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[259] = heapMem[localMem[252]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 577;
      end

        577 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[259] == 0 ? 674 : 578;
      end

        578 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[260] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[260] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[260]] = 0;
              ip = 579;
      end

        579 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[260]*7 + 0] = localMem[257];
              updateArrayLength(1, localMem[260], 0);
              ip = 580;
      end

        580 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[260]*7 + 2] = 0;
              updateArrayLength(1, localMem[260], 2);
              ip = 581;
      end

        581 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[261] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[261] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[261]] = 0;
              ip = 582;
      end

        582 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[260]*7 + 4] = localMem[261];
              updateArrayLength(1, localMem[260], 4);
              ip = 583;
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
              heapMem[localMem[260]*7 + 5] = localMem[262];
              updateArrayLength(1, localMem[260], 5);
              ip = 585;
      end

        585 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[260]*7 + 6] = 0;
              updateArrayLength(1, localMem[260], 6);
              ip = 586;
      end

        586 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[260]*7 + 3] = localMem[255];
              updateArrayLength(1, localMem[260], 3);
              ip = 587;
      end

        587 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[255]*7 + 1] = heapMem[localMem[255]*7 + 1] + 1;
              updateArrayLength(1, localMem[255], 1);
              ip = 588;
      end

        588 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[260]*7 + 1] = heapMem[localMem[255]*7 + 1];
              updateArrayLength(1, localMem[260], 1);
              ip = 589;
      end

        589 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[263] = !heapMem[localMem[252]*7 + 6];
              ip = 590;
      end

        590 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[263] != 0 ? 619 : 591;
      end

        591 :
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
              ip = 592;
      end

        592 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[260]*7 + 6] = localMem[264];
              updateArrayLength(1, localMem[260], 6);
              ip = 593;
      end

        593 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[265] = heapMem[localMem[252]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 594;
      end

        594 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[266] = heapMem[localMem[260]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 595;
      end

        595 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[257]) begin
                  heapMem[NArea * localMem[266] + 0 + i] = heapMem[NArea * localMem[265] + localMem[258] + i];
                  updateArrayLength(1, localMem[266], 0 + i);
                end
              end
              ip = 596;
      end

        596 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[267] = heapMem[localMem[252]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 597;
      end

        597 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[268] = heapMem[localMem[260]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 598;
      end

        598 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[257]) begin
                  heapMem[NArea * localMem[268] + 0 + i] = heapMem[NArea * localMem[267] + localMem[258] + i];
                  updateArrayLength(1, localMem[268], 0 + i);
                end
              end
              ip = 599;
      end

        599 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[269] = heapMem[localMem[252]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 600;
      end

        600 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[270] = heapMem[localMem[260]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 601;
      end

        601 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[271] = localMem[257] + 1;
              updateArrayLength(2, 0, 0);
              ip = 602;
      end

        602 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[271]) begin
                  heapMem[NArea * localMem[270] + 0 + i] = heapMem[NArea * localMem[269] + localMem[258] + i];
                  updateArrayLength(1, localMem[270], 0 + i);
                end
              end
              ip = 603;
      end

        603 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[272] = heapMem[localMem[260]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 604;
      end

        604 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[273] = localMem[272] + 1;
              updateArrayLength(2, 0, 0);
              ip = 605;
      end

        605 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[274] = heapMem[localMem[260]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 606;
      end

        606 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 607;
      end

        607 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[275] = 0;
              updateArrayLength(2, 0, 0);
              ip = 608;
      end

        608 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 609;
      end

        609 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[275] >= localMem[273] ? 615 : 610;
      end

        610 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[276] = heapMem[localMem[274]*7 + localMem[275]];
              updateArrayLength(2, 0, 0);
              ip = 611;
      end

        611 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[276]*7 + 2] = localMem[260];
              updateArrayLength(1, localMem[276], 2);
              ip = 612;
      end

        612 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 613;
      end

        613 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[275] = localMem[275] + 1;
              updateArrayLength(2, 0, 0);
              ip = 614;
      end

        614 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 608;
      end

        615 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 616;
      end

        616 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[277] = heapMem[localMem[252]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 617;
      end

        617 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[277]] = localMem[258];
              ip = 618;
      end

        618 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 626;
      end

        619 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 620;
      end

        620 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[278] = heapMem[localMem[252]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 621;
      end

        621 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[279] = heapMem[localMem[260]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 622;
      end

        622 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[257]) begin
                  heapMem[NArea * localMem[279] + 0 + i] = heapMem[NArea * localMem[278] + localMem[258] + i];
                  updateArrayLength(1, localMem[279], 0 + i);
                end
              end
              ip = 623;
      end

        623 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[280] = heapMem[localMem[252]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 624;
      end

        624 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[281] = heapMem[localMem[260]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 625;
      end

        625 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[257]) begin
                  heapMem[NArea * localMem[281] + 0 + i] = heapMem[NArea * localMem[280] + localMem[258] + i];
                  updateArrayLength(1, localMem[281], 0 + i);
                end
              end
              ip = 626;
      end

        626 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 627;
      end

        627 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[252]*7 + 0] = localMem[257];
              updateArrayLength(1, localMem[252], 0);
              ip = 628;
      end

        628 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[260]*7 + 2] = localMem[259];
              updateArrayLength(1, localMem[260], 2);
              ip = 629;
      end

        629 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[282] = heapMem[localMem[259]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 630;
      end

        630 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[283] = heapMem[localMem[259]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 631;
      end

        631 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[284] = heapMem[localMem[283]*7 + localMem[282]];
              updateArrayLength(2, 0, 0);
              ip = 632;
      end

        632 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[284] != localMem[252] ? 651 : 633;
      end

        633 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[285] = heapMem[localMem[252]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 634;
      end

        634 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[286] = heapMem[localMem[285]*7 + localMem[257]];
              updateArrayLength(2, 0, 0);
              ip = 635;
      end

        635 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[287] = heapMem[localMem[259]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 636;
      end

        636 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[287]*7 + localMem[282]] = localMem[286];
              updateArrayLength(1, localMem[287], localMem[282]);
              ip = 637;
      end

        637 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[288] = heapMem[localMem[252]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 638;
      end

        638 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[289] = heapMem[localMem[288]*7 + localMem[257]];
              updateArrayLength(2, 0, 0);
              ip = 639;
      end

        639 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[290] = heapMem[localMem[259]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 640;
      end

        640 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[290]*7 + localMem[282]] = localMem[289];
              updateArrayLength(1, localMem[290], localMem[282]);
              ip = 641;
      end

        641 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[291] = heapMem[localMem[252]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 642;
      end

        642 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[291]] = localMem[257];
              ip = 643;
      end

        643 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[292] = heapMem[localMem[252]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 644;
      end

        644 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[292]] = localMem[257];
              ip = 645;
      end

        645 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[293] = localMem[282] + 1;
              updateArrayLength(2, 0, 0);
              ip = 646;
      end

        646 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[259]*7 + 0] = localMem[293];
              updateArrayLength(1, localMem[259], 0);
              ip = 647;
      end

        647 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[294] = heapMem[localMem[259]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 648;
      end

        648 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[294]*7 + localMem[293]] = localMem[260];
              updateArrayLength(1, localMem[294], localMem[293]);
              ip = 649;
      end

        649 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 789;
      end

        650 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 673;
      end

        651 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 652;
      end

        652 :
      begin                                                                     // assertNe
if (0) begin
  $display("AAAA %4d %4d assertNe", steps, ip);
end
            ip = 653;
      end

        653 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[295] = heapMem[localMem[259]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 654;
      end

        654 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[296] = 0; k = arraySizes[localMem[295]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[295] * NArea + i] == localMem[252]) localMem[296] = i + 1;
              end
              ip = 655;
      end

        655 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[296] = localMem[296] - 1;
              updateArrayLength(2, 0, 0);
              ip = 656;
      end

        656 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[297] = heapMem[localMem[252]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 657;
      end

        657 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[298] = heapMem[localMem[297]*7 + localMem[257]];
              updateArrayLength(2, 0, 0);
              ip = 658;
      end

        658 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[299] = heapMem[localMem[252]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 659;
      end

        659 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[300] = heapMem[localMem[299]*7 + localMem[257]];
              updateArrayLength(2, 0, 0);
              ip = 660;
      end

        660 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[301] = heapMem[localMem[252]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 661;
      end

        661 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[301]] = localMem[257];
              ip = 662;
      end

        662 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[302] = heapMem[localMem[252]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 663;
      end

        663 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[302]] = localMem[257];
              ip = 664;
      end

        664 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[303] = heapMem[localMem[259]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 665;
      end

        665 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[303] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[296], localMem[303], arraySizes[localMem[303]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[296] && i <= arraySizes[localMem[303]]) begin
                  heapMem[NArea * localMem[303] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[303] + localMem[296]] = localMem[298];                                    // Insert new value
              arraySizes[localMem[303]] = arraySizes[localMem[303]] + 1;                              // Increase array size
              ip = 666;
      end

        666 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[304] = heapMem[localMem[259]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 667;
      end

        667 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[304] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[296], localMem[304], arraySizes[localMem[304]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[296] && i <= arraySizes[localMem[304]]) begin
                  heapMem[NArea * localMem[304] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[304] + localMem[296]] = localMem[300];                                    // Insert new value
              arraySizes[localMem[304]] = arraySizes[localMem[304]] + 1;                              // Increase array size
              ip = 668;
      end

        668 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[305] = heapMem[localMem[259]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 669;
      end

        669 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[306] = localMem[296] + 1;
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
//$display("BBBB pos=%d array=%d length=%d", localMem[306], localMem[305], arraySizes[localMem[305]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[306] && i <= arraySizes[localMem[305]]) begin
                  heapMem[NArea * localMem[305] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[305] + localMem[306]] = localMem[260];                                    // Insert new value
              arraySizes[localMem[305]] = arraySizes[localMem[305]] + 1;                              // Increase array size
              ip = 671;
      end

        671 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[259]*7 + 0] = heapMem[localMem[259]*7 + 0] + 1;
              updateArrayLength(1, localMem[259], 0);
              ip = 672;
      end

        672 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 789;
      end

        673 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 674;
      end

        674 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 675;
      end

        675 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[307] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[307] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[307]] = 0;
              ip = 676;
      end

        676 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[307]*7 + 0] = localMem[257];
              updateArrayLength(1, localMem[307], 0);
              ip = 677;
      end

        677 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[307]*7 + 2] = 0;
              updateArrayLength(1, localMem[307], 2);
              ip = 678;
      end

        678 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[308] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[308] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[308]] = 0;
              ip = 679;
      end

        679 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[307]*7 + 4] = localMem[308];
              updateArrayLength(1, localMem[307], 4);
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
              heapMem[localMem[307]*7 + 5] = localMem[309];
              updateArrayLength(1, localMem[307], 5);
              ip = 682;
      end

        682 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[307]*7 + 6] = 0;
              updateArrayLength(1, localMem[307], 6);
              ip = 683;
      end

        683 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[307]*7 + 3] = localMem[255];
              updateArrayLength(1, localMem[307], 3);
              ip = 684;
      end

        684 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[255]*7 + 1] = heapMem[localMem[255]*7 + 1] + 1;
              updateArrayLength(1, localMem[255], 1);
              ip = 685;
      end

        685 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[307]*7 + 1] = heapMem[localMem[255]*7 + 1];
              updateArrayLength(1, localMem[307], 1);
              ip = 686;
      end

        686 :
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
              ip = 687;
      end

        687 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[310]*7 + 0] = localMem[257];
              updateArrayLength(1, localMem[310], 0);
              ip = 688;
      end

        688 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[310]*7 + 2] = 0;
              updateArrayLength(1, localMem[310], 2);
              ip = 689;
      end

        689 :
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
              ip = 690;
      end

        690 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[310]*7 + 4] = localMem[311];
              updateArrayLength(1, localMem[310], 4);
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
              heapMem[localMem[310]*7 + 5] = localMem[312];
              updateArrayLength(1, localMem[310], 5);
              ip = 693;
      end

        693 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[310]*7 + 6] = 0;
              updateArrayLength(1, localMem[310], 6);
              ip = 694;
      end

        694 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[310]*7 + 3] = localMem[255];
              updateArrayLength(1, localMem[310], 3);
              ip = 695;
      end

        695 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[255]*7 + 1] = heapMem[localMem[255]*7 + 1] + 1;
              updateArrayLength(1, localMem[255], 1);
              ip = 696;
      end

        696 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[310]*7 + 1] = heapMem[localMem[255]*7 + 1];
              updateArrayLength(1, localMem[310], 1);
              ip = 697;
      end

        697 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[313] = !heapMem[localMem[252]*7 + 6];
              ip = 698;
      end

        698 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[313] != 0 ? 750 : 699;
      end

        699 :
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
              ip = 700;
      end

        700 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[307]*7 + 6] = localMem[314];
              updateArrayLength(1, localMem[307], 6);
              ip = 701;
      end

        701 :
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
              ip = 702;
      end

        702 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[310]*7 + 6] = localMem[315];
              updateArrayLength(1, localMem[310], 6);
              ip = 703;
      end

        703 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[316] = heapMem[localMem[252]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 704;
      end

        704 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[317] = heapMem[localMem[307]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 705;
      end

        705 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[257]) begin
                  heapMem[NArea * localMem[317] + 0 + i] = heapMem[NArea * localMem[316] + 0 + i];
                  updateArrayLength(1, localMem[317], 0 + i);
                end
              end
              ip = 706;
      end

        706 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[318] = heapMem[localMem[252]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 707;
      end

        707 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[319] = heapMem[localMem[307]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 708;
      end

        708 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[257]) begin
                  heapMem[NArea * localMem[319] + 0 + i] = heapMem[NArea * localMem[318] + 0 + i];
                  updateArrayLength(1, localMem[319], 0 + i);
                end
              end
              ip = 709;
      end

        709 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[320] = heapMem[localMem[252]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 710;
      end

        710 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[321] = heapMem[localMem[307]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 711;
      end

        711 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[322] = localMem[257] + 1;
              updateArrayLength(2, 0, 0);
              ip = 712;
      end

        712 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[322]) begin
                  heapMem[NArea * localMem[321] + 0 + i] = heapMem[NArea * localMem[320] + 0 + i];
                  updateArrayLength(1, localMem[321], 0 + i);
                end
              end
              ip = 713;
      end

        713 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[323] = heapMem[localMem[252]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 714;
      end

        714 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[324] = heapMem[localMem[310]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 715;
      end

        715 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[257]) begin
                  heapMem[NArea * localMem[324] + 0 + i] = heapMem[NArea * localMem[323] + localMem[258] + i];
                  updateArrayLength(1, localMem[324], 0 + i);
                end
              end
              ip = 716;
      end

        716 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[325] = heapMem[localMem[252]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 717;
      end

        717 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[326] = heapMem[localMem[310]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 718;
      end

        718 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[257]) begin
                  heapMem[NArea * localMem[326] + 0 + i] = heapMem[NArea * localMem[325] + localMem[258] + i];
                  updateArrayLength(1, localMem[326], 0 + i);
                end
              end
              ip = 719;
      end

        719 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[327] = heapMem[localMem[252]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 720;
      end

        720 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[328] = heapMem[localMem[310]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 721;
      end

        721 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[329] = localMem[257] + 1;
              updateArrayLength(2, 0, 0);
              ip = 722;
      end

        722 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[329]) begin
                  heapMem[NArea * localMem[328] + 0 + i] = heapMem[NArea * localMem[327] + localMem[258] + i];
                  updateArrayLength(1, localMem[328], 0 + i);
                end
              end
              ip = 723;
      end

        723 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[330] = heapMem[localMem[307]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 724;
      end

        724 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[331] = localMem[330] + 1;
              updateArrayLength(2, 0, 0);
              ip = 725;
      end

        725 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[332] = heapMem[localMem[307]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 726;
      end

        726 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 727;
      end

        727 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[333] = 0;
              updateArrayLength(2, 0, 0);
              ip = 728;
      end

        728 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 729;
      end

        729 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[333] >= localMem[331] ? 735 : 730;
      end

        730 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[334] = heapMem[localMem[332]*7 + localMem[333]];
              updateArrayLength(2, 0, 0);
              ip = 731;
      end

        731 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[334]*7 + 2] = localMem[307];
              updateArrayLength(1, localMem[334], 2);
              ip = 732;
      end

        732 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 733;
      end

        733 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[333] = localMem[333] + 1;
              updateArrayLength(2, 0, 0);
              ip = 734;
      end

        734 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 728;
      end

        735 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 736;
      end

        736 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[335] = heapMem[localMem[310]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 737;
      end

        737 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[336] = localMem[335] + 1;
              updateArrayLength(2, 0, 0);
              ip = 738;
      end

        738 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[337] = heapMem[localMem[310]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 739;
      end

        739 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 740;
      end

        740 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[338] = 0;
              updateArrayLength(2, 0, 0);
              ip = 741;
      end

        741 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 742;
      end

        742 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[338] >= localMem[336] ? 748 : 743;
      end

        743 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[339] = heapMem[localMem[337]*7 + localMem[338]];
              updateArrayLength(2, 0, 0);
              ip = 744;
      end

        744 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[339]*7 + 2] = localMem[310];
              updateArrayLength(1, localMem[339], 2);
              ip = 745;
      end

        745 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 746;
      end

        746 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[338] = localMem[338] + 1;
              updateArrayLength(2, 0, 0);
              ip = 747;
      end

        747 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 741;
      end

        748 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 749;
      end

        749 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 765;
      end

        750 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 751;
      end

        751 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[340] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[340] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[340]] = 0;
              ip = 752;
      end

        752 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[252]*7 + 6] = localMem[340];
              updateArrayLength(1, localMem[252], 6);
              ip = 753;
      end

        753 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[341] = heapMem[localMem[252]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 754;
      end

        754 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[342] = heapMem[localMem[307]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 755;
      end

        755 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[257]) begin
                  heapMem[NArea * localMem[342] + 0 + i] = heapMem[NArea * localMem[341] + 0 + i];
                  updateArrayLength(1, localMem[342], 0 + i);
                end
              end
              ip = 756;
      end

        756 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[343] = heapMem[localMem[252]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 757;
      end

        757 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[344] = heapMem[localMem[307]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 758;
      end

        758 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[257]) begin
                  heapMem[NArea * localMem[344] + 0 + i] = heapMem[NArea * localMem[343] + 0 + i];
                  updateArrayLength(1, localMem[344], 0 + i);
                end
              end
              ip = 759;
      end

        759 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[345] = heapMem[localMem[252]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 760;
      end

        760 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[346] = heapMem[localMem[310]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 761;
      end

        761 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[257]) begin
                  heapMem[NArea * localMem[346] + 0 + i] = heapMem[NArea * localMem[345] + localMem[258] + i];
                  updateArrayLength(1, localMem[346], 0 + i);
                end
              end
              ip = 762;
      end

        762 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[347] = heapMem[localMem[252]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 763;
      end

        763 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[348] = heapMem[localMem[310]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 764;
      end

        764 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[257]) begin
                  heapMem[NArea * localMem[348] + 0 + i] = heapMem[NArea * localMem[347] + localMem[258] + i];
                  updateArrayLength(1, localMem[348], 0 + i);
                end
              end
              ip = 765;
      end

        765 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 766;
      end

        766 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[307]*7 + 2] = localMem[252];
              updateArrayLength(1, localMem[307], 2);
              ip = 767;
      end

        767 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[310]*7 + 2] = localMem[252];
              updateArrayLength(1, localMem[310], 2);
              ip = 768;
      end

        768 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[349] = heapMem[localMem[252]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 769;
      end

        769 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[350] = heapMem[localMem[349]*7 + localMem[257]];
              updateArrayLength(2, 0, 0);
              ip = 770;
      end

        770 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[351] = heapMem[localMem[252]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 771;
      end

        771 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[352] = heapMem[localMem[351]*7 + localMem[257]];
              updateArrayLength(2, 0, 0);
              ip = 772;
      end

        772 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[353] = heapMem[localMem[252]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 773;
      end

        773 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[353]*7 + 0] = localMem[350];
              updateArrayLength(1, localMem[353], 0);
              ip = 774;
      end

        774 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[354] = heapMem[localMem[252]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 775;
      end

        775 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[354]*7 + 0] = localMem[352];
              updateArrayLength(1, localMem[354], 0);
              ip = 776;
      end

        776 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[355] = heapMem[localMem[252]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 777;
      end

        777 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[355]*7 + 0] = localMem[307];
              updateArrayLength(1, localMem[355], 0);
              ip = 778;
      end

        778 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[356] = heapMem[localMem[252]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 779;
      end

        779 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[356]*7 + 1] = localMem[310];
              updateArrayLength(1, localMem[356], 1);
              ip = 780;
      end

        780 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[252]*7 + 0] = 1;
              updateArrayLength(1, localMem[252], 0);
              ip = 781;
      end

        781 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[357] = heapMem[localMem[252]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 782;
      end

        782 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[357]] = 1;
              ip = 783;
      end

        783 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[358] = heapMem[localMem[252]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 784;
      end

        784 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[358]] = 1;
              ip = 785;
      end

        785 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[359] = heapMem[localMem[252]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 786;
      end

        786 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[359]] = 2;
              ip = 787;
      end

        787 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 789;
      end

        788 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 794;
      end

        789 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 790;
      end

        790 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[253] = 1;
              updateArrayLength(2, 0, 0);
              ip = 791;
      end

        791 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 794;
      end

        792 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 793;
      end

        793 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[253] = 0;
              updateArrayLength(2, 0, 0);
              ip = 794;
      end

        794 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 795;
      end

        795 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[253] != 0 ? 797 : 796;
      end

        796 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[24] = localMem[252];
              updateArrayLength(2, 0, 0);
              ip = 797;
      end

        797 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 798;
      end

        798 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 799;
      end

        799 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[132] = localMem[132] + 1;
              updateArrayLength(2, 0, 0);
              ip = 800;
      end

        800 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 302;
      end

        801 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 802;
      end

        802 :
      begin                                                                     // assert
if (0) begin
  $display("AAAA %4d %4d assert", steps, ip);
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
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 805;
      end

        805 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 806;
      end

        806 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[360] = heapMem[localMem[1]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 807;
      end

        807 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[361] = heapMem[localMem[1]*7 + 1];
              updateArrayLength(2, 0, 0);
              ip = 808;
      end

        808 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[362] = heapMem[localMem[1]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 809;
      end

        809 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[361] != 1 ? 813 : 810;
      end

        810 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[363] = heapMem[localMem[360]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 811;
      end

        811 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[363]*7 + localMem[362]] = 11;
              updateArrayLength(1, localMem[363], localMem[362]);
              ip = 812;
      end

        812 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1059;
      end

        813 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 814;
      end

        814 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[361] != 2 ? 822 : 815;
      end

        815 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[364] = localMem[362] + 1;
              updateArrayLength(2, 0, 0);
              ip = 816;
      end

        816 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[365] = heapMem[localMem[360]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 817;
      end

        817 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[365] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[364], localMem[365], arraySizes[localMem[365]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[364] && i <= arraySizes[localMem[365]]) begin
                  heapMem[NArea * localMem[365] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[365] + localMem[364]] = 1;                                    // Insert new value
              arraySizes[localMem[365]] = arraySizes[localMem[365]] + 1;                              // Increase array size
              ip = 818;
      end

        818 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[366] = heapMem[localMem[360]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 819;
      end

        819 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[366] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[364], localMem[366], arraySizes[localMem[366]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[364] && i <= arraySizes[localMem[366]]) begin
                  heapMem[NArea * localMem[366] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[366] + localMem[364]] = 11;                                    // Insert new value
              arraySizes[localMem[366]] = arraySizes[localMem[366]] + 1;                              // Increase array size
              ip = 820;
      end

        820 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[360]*7 + 0] = heapMem[localMem[360]*7 + 0] + 1;
              updateArrayLength(1, localMem[360], 0);
              ip = 821;
      end

        821 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 828;
      end

        822 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 823;
      end

        823 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[367] = heapMem[localMem[360]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 824;
      end

        824 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[367] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[362], localMem[367], arraySizes[localMem[367]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[362] && i <= arraySizes[localMem[367]]) begin
                  heapMem[NArea * localMem[367] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[367] + localMem[362]] = 1;                                    // Insert new value
              arraySizes[localMem[367]] = arraySizes[localMem[367]] + 1;                              // Increase array size
              ip = 825;
      end

        825 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[368] = heapMem[localMem[360]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 826;
      end

        826 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[368] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[362], localMem[368], arraySizes[localMem[368]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[362] && i <= arraySizes[localMem[368]]) begin
                  heapMem[NArea * localMem[368] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[368] + localMem[362]] = 11;                                    // Insert new value
              arraySizes[localMem[368]] = arraySizes[localMem[368]] + 1;                              // Increase array size
              ip = 827;
      end

        827 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[360]*7 + 0] = heapMem[localMem[360]*7 + 0] + 1;
              updateArrayLength(1, localMem[360], 0);
              ip = 828;
      end

        828 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 829;
      end

        829 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[0]*7 + 0] = heapMem[localMem[0]*7 + 0] + 1;
              updateArrayLength(1, localMem[0], 0);
              ip = 830;
      end

        830 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 831;
      end

        831 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[370] = heapMem[localMem[360]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 832;
      end

        832 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[371] = heapMem[localMem[360]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 833;
      end

        833 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[372] = heapMem[localMem[371]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 834;
      end

        834 :
      begin                                                                     // jLt
if (0) begin
  $display("AAAA %4d %4d jLt", steps, ip);
end
              ip = localMem[370] <  localMem[372] ? 1054 : 835;
      end

        835 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[373] = localMem[372];
              updateArrayLength(2, 0, 0);
              ip = 836;
      end

        836 :
      begin                                                                     // shiftRight
if (0) begin
  $display("AAAA %4d %4d shiftRight", steps, ip);
end
              localMem[373] = localMem[373] >> 1;
              ip = 837;
      end

        837 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[374] = localMem[373] + 1;
              updateArrayLength(2, 0, 0);
              ip = 838;
      end

        838 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[375] = heapMem[localMem[360]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 839;
      end

        839 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[375] == 0 ? 936 : 840;
      end

        840 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[376] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[376] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[376]] = 0;
              ip = 841;
      end

        841 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[376]*7 + 0] = localMem[373];
              updateArrayLength(1, localMem[376], 0);
              ip = 842;
      end

        842 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[376]*7 + 2] = 0;
              updateArrayLength(1, localMem[376], 2);
              ip = 843;
      end

        843 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[377] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[377] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[377]] = 0;
              ip = 844;
      end

        844 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[376]*7 + 4] = localMem[377];
              updateArrayLength(1, localMem[376], 4);
              ip = 845;
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
              heapMem[localMem[376]*7 + 5] = localMem[378];
              updateArrayLength(1, localMem[376], 5);
              ip = 847;
      end

        847 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[376]*7 + 6] = 0;
              updateArrayLength(1, localMem[376], 6);
              ip = 848;
      end

        848 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[376]*7 + 3] = localMem[371];
              updateArrayLength(1, localMem[376], 3);
              ip = 849;
      end

        849 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[371]*7 + 1] = heapMem[localMem[371]*7 + 1] + 1;
              updateArrayLength(1, localMem[371], 1);
              ip = 850;
      end

        850 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[376]*7 + 1] = heapMem[localMem[371]*7 + 1];
              updateArrayLength(1, localMem[376], 1);
              ip = 851;
      end

        851 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[379] = !heapMem[localMem[360]*7 + 6];
              ip = 852;
      end

        852 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[379] != 0 ? 881 : 853;
      end

        853 :
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
              ip = 854;
      end

        854 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[376]*7 + 6] = localMem[380];
              updateArrayLength(1, localMem[376], 6);
              ip = 855;
      end

        855 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[381] = heapMem[localMem[360]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 856;
      end

        856 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[382] = heapMem[localMem[376]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 857;
      end

        857 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[373]) begin
                  heapMem[NArea * localMem[382] + 0 + i] = heapMem[NArea * localMem[381] + localMem[374] + i];
                  updateArrayLength(1, localMem[382], 0 + i);
                end
              end
              ip = 858;
      end

        858 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[383] = heapMem[localMem[360]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 859;
      end

        859 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[384] = heapMem[localMem[376]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 860;
      end

        860 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[373]) begin
                  heapMem[NArea * localMem[384] + 0 + i] = heapMem[NArea * localMem[383] + localMem[374] + i];
                  updateArrayLength(1, localMem[384], 0 + i);
                end
              end
              ip = 861;
      end

        861 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[385] = heapMem[localMem[360]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 862;
      end

        862 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[386] = heapMem[localMem[376]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 863;
      end

        863 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[387] = localMem[373] + 1;
              updateArrayLength(2, 0, 0);
              ip = 864;
      end

        864 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[387]) begin
                  heapMem[NArea * localMem[386] + 0 + i] = heapMem[NArea * localMem[385] + localMem[374] + i];
                  updateArrayLength(1, localMem[386], 0 + i);
                end
              end
              ip = 865;
      end

        865 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[388] = heapMem[localMem[376]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 866;
      end

        866 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[389] = localMem[388] + 1;
              updateArrayLength(2, 0, 0);
              ip = 867;
      end

        867 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[390] = heapMem[localMem[376]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 868;
      end

        868 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 869;
      end

        869 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[391] = 0;
              updateArrayLength(2, 0, 0);
              ip = 870;
      end

        870 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 871;
      end

        871 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[391] >= localMem[389] ? 877 : 872;
      end

        872 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[392] = heapMem[localMem[390]*7 + localMem[391]];
              updateArrayLength(2, 0, 0);
              ip = 873;
      end

        873 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[392]*7 + 2] = localMem[376];
              updateArrayLength(1, localMem[392], 2);
              ip = 874;
      end

        874 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 875;
      end

        875 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[391] = localMem[391] + 1;
              updateArrayLength(2, 0, 0);
              ip = 876;
      end

        876 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 870;
      end

        877 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 878;
      end

        878 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[393] = heapMem[localMem[360]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 879;
      end

        879 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[393]] = localMem[374];
              ip = 880;
      end

        880 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 888;
      end

        881 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 882;
      end

        882 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[394] = heapMem[localMem[360]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 883;
      end

        883 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[395] = heapMem[localMem[376]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 884;
      end

        884 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[373]) begin
                  heapMem[NArea * localMem[395] + 0 + i] = heapMem[NArea * localMem[394] + localMem[374] + i];
                  updateArrayLength(1, localMem[395], 0 + i);
                end
              end
              ip = 885;
      end

        885 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[396] = heapMem[localMem[360]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 886;
      end

        886 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[397] = heapMem[localMem[376]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 887;
      end

        887 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[373]) begin
                  heapMem[NArea * localMem[397] + 0 + i] = heapMem[NArea * localMem[396] + localMem[374] + i];
                  updateArrayLength(1, localMem[397], 0 + i);
                end
              end
              ip = 888;
      end

        888 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 889;
      end

        889 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[360]*7 + 0] = localMem[373];
              updateArrayLength(1, localMem[360], 0);
              ip = 890;
      end

        890 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[376]*7 + 2] = localMem[375];
              updateArrayLength(1, localMem[376], 2);
              ip = 891;
      end

        891 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[398] = heapMem[localMem[375]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 892;
      end

        892 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[399] = heapMem[localMem[375]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 893;
      end

        893 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[400] = heapMem[localMem[399]*7 + localMem[398]];
              updateArrayLength(2, 0, 0);
              ip = 894;
      end

        894 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[400] != localMem[360] ? 913 : 895;
      end

        895 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[401] = heapMem[localMem[360]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 896;
      end

        896 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[402] = heapMem[localMem[401]*7 + localMem[373]];
              updateArrayLength(2, 0, 0);
              ip = 897;
      end

        897 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[403] = heapMem[localMem[375]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 898;
      end

        898 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[403]*7 + localMem[398]] = localMem[402];
              updateArrayLength(1, localMem[403], localMem[398]);
              ip = 899;
      end

        899 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[404] = heapMem[localMem[360]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 900;
      end

        900 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[405] = heapMem[localMem[404]*7 + localMem[373]];
              updateArrayLength(2, 0, 0);
              ip = 901;
      end

        901 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[406] = heapMem[localMem[375]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 902;
      end

        902 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[406]*7 + localMem[398]] = localMem[405];
              updateArrayLength(1, localMem[406], localMem[398]);
              ip = 903;
      end

        903 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[407] = heapMem[localMem[360]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 904;
      end

        904 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[407]] = localMem[373];
              ip = 905;
      end

        905 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[408] = heapMem[localMem[360]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 906;
      end

        906 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[408]] = localMem[373];
              ip = 907;
      end

        907 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[409] = localMem[398] + 1;
              updateArrayLength(2, 0, 0);
              ip = 908;
      end

        908 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[375]*7 + 0] = localMem[409];
              updateArrayLength(1, localMem[375], 0);
              ip = 909;
      end

        909 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[410] = heapMem[localMem[375]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 910;
      end

        910 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[410]*7 + localMem[409]] = localMem[376];
              updateArrayLength(1, localMem[410], localMem[409]);
              ip = 911;
      end

        911 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1051;
      end

        912 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 935;
      end

        913 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 914;
      end

        914 :
      begin                                                                     // assertNe
if (0) begin
  $display("AAAA %4d %4d assertNe", steps, ip);
end
            ip = 915;
      end

        915 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[411] = heapMem[localMem[375]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 916;
      end

        916 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[412] = 0; k = arraySizes[localMem[411]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[411] * NArea + i] == localMem[360]) localMem[412] = i + 1;
              end
              ip = 917;
      end

        917 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[412] = localMem[412] - 1;
              updateArrayLength(2, 0, 0);
              ip = 918;
      end

        918 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[413] = heapMem[localMem[360]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 919;
      end

        919 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[414] = heapMem[localMem[413]*7 + localMem[373]];
              updateArrayLength(2, 0, 0);
              ip = 920;
      end

        920 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[415] = heapMem[localMem[360]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 921;
      end

        921 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[416] = heapMem[localMem[415]*7 + localMem[373]];
              updateArrayLength(2, 0, 0);
              ip = 922;
      end

        922 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[417] = heapMem[localMem[360]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 923;
      end

        923 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[417]] = localMem[373];
              ip = 924;
      end

        924 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[418] = heapMem[localMem[360]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 925;
      end

        925 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[418]] = localMem[373];
              ip = 926;
      end

        926 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[419] = heapMem[localMem[375]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 927;
      end

        927 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[419] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[412], localMem[419], arraySizes[localMem[419]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[412] && i <= arraySizes[localMem[419]]) begin
                  heapMem[NArea * localMem[419] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[419] + localMem[412]] = localMem[414];                                    // Insert new value
              arraySizes[localMem[419]] = arraySizes[localMem[419]] + 1;                              // Increase array size
              ip = 928;
      end

        928 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[420] = heapMem[localMem[375]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 929;
      end

        929 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[420] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[412], localMem[420], arraySizes[localMem[420]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[412] && i <= arraySizes[localMem[420]]) begin
                  heapMem[NArea * localMem[420] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[420] + localMem[412]] = localMem[416];                                    // Insert new value
              arraySizes[localMem[420]] = arraySizes[localMem[420]] + 1;                              // Increase array size
              ip = 930;
      end

        930 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[421] = heapMem[localMem[375]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 931;
      end

        931 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[422] = localMem[412] + 1;
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
//$display("BBBB pos=%d array=%d length=%d", localMem[422], localMem[421], arraySizes[localMem[421]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[422] && i <= arraySizes[localMem[421]]) begin
                  heapMem[NArea * localMem[421] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[421] + localMem[422]] = localMem[376];                                    // Insert new value
              arraySizes[localMem[421]] = arraySizes[localMem[421]] + 1;                              // Increase array size
              ip = 933;
      end

        933 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[375]*7 + 0] = heapMem[localMem[375]*7 + 0] + 1;
              updateArrayLength(1, localMem[375], 0);
              ip = 934;
      end

        934 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1051;
      end

        935 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 936;
      end

        936 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 937;
      end

        937 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[423] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[423] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[423]] = 0;
              ip = 938;
      end

        938 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[423]*7 + 0] = localMem[373];
              updateArrayLength(1, localMem[423], 0);
              ip = 939;
      end

        939 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[423]*7 + 2] = 0;
              updateArrayLength(1, localMem[423], 2);
              ip = 940;
      end

        940 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[424] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[424] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[424]] = 0;
              ip = 941;
      end

        941 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[423]*7 + 4] = localMem[424];
              updateArrayLength(1, localMem[423], 4);
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
              heapMem[localMem[423]*7 + 5] = localMem[425];
              updateArrayLength(1, localMem[423], 5);
              ip = 944;
      end

        944 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[423]*7 + 6] = 0;
              updateArrayLength(1, localMem[423], 6);
              ip = 945;
      end

        945 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[423]*7 + 3] = localMem[371];
              updateArrayLength(1, localMem[423], 3);
              ip = 946;
      end

        946 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[371]*7 + 1] = heapMem[localMem[371]*7 + 1] + 1;
              updateArrayLength(1, localMem[371], 1);
              ip = 947;
      end

        947 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[423]*7 + 1] = heapMem[localMem[371]*7 + 1];
              updateArrayLength(1, localMem[423], 1);
              ip = 948;
      end

        948 :
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
              ip = 949;
      end

        949 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[426]*7 + 0] = localMem[373];
              updateArrayLength(1, localMem[426], 0);
              ip = 950;
      end

        950 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[426]*7 + 2] = 0;
              updateArrayLength(1, localMem[426], 2);
              ip = 951;
      end

        951 :
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
              ip = 952;
      end

        952 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[426]*7 + 4] = localMem[427];
              updateArrayLength(1, localMem[426], 4);
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
              heapMem[localMem[426]*7 + 5] = localMem[428];
              updateArrayLength(1, localMem[426], 5);
              ip = 955;
      end

        955 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[426]*7 + 6] = 0;
              updateArrayLength(1, localMem[426], 6);
              ip = 956;
      end

        956 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[426]*7 + 3] = localMem[371];
              updateArrayLength(1, localMem[426], 3);
              ip = 957;
      end

        957 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[371]*7 + 1] = heapMem[localMem[371]*7 + 1] + 1;
              updateArrayLength(1, localMem[371], 1);
              ip = 958;
      end

        958 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[426]*7 + 1] = heapMem[localMem[371]*7 + 1];
              updateArrayLength(1, localMem[426], 1);
              ip = 959;
      end

        959 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[429] = !heapMem[localMem[360]*7 + 6];
              ip = 960;
      end

        960 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[429] != 0 ? 1012 : 961;
      end

        961 :
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
              ip = 962;
      end

        962 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[423]*7 + 6] = localMem[430];
              updateArrayLength(1, localMem[423], 6);
              ip = 963;
      end

        963 :
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
              ip = 964;
      end

        964 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[426]*7 + 6] = localMem[431];
              updateArrayLength(1, localMem[426], 6);
              ip = 965;
      end

        965 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[432] = heapMem[localMem[360]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 966;
      end

        966 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[433] = heapMem[localMem[423]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 967;
      end

        967 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[373]) begin
                  heapMem[NArea * localMem[433] + 0 + i] = heapMem[NArea * localMem[432] + 0 + i];
                  updateArrayLength(1, localMem[433], 0 + i);
                end
              end
              ip = 968;
      end

        968 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[434] = heapMem[localMem[360]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 969;
      end

        969 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[435] = heapMem[localMem[423]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 970;
      end

        970 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[373]) begin
                  heapMem[NArea * localMem[435] + 0 + i] = heapMem[NArea * localMem[434] + 0 + i];
                  updateArrayLength(1, localMem[435], 0 + i);
                end
              end
              ip = 971;
      end

        971 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[436] = heapMem[localMem[360]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 972;
      end

        972 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[437] = heapMem[localMem[423]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 973;
      end

        973 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[438] = localMem[373] + 1;
              updateArrayLength(2, 0, 0);
              ip = 974;
      end

        974 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[438]) begin
                  heapMem[NArea * localMem[437] + 0 + i] = heapMem[NArea * localMem[436] + 0 + i];
                  updateArrayLength(1, localMem[437], 0 + i);
                end
              end
              ip = 975;
      end

        975 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[439] = heapMem[localMem[360]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 976;
      end

        976 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[440] = heapMem[localMem[426]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 977;
      end

        977 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[373]) begin
                  heapMem[NArea * localMem[440] + 0 + i] = heapMem[NArea * localMem[439] + localMem[374] + i];
                  updateArrayLength(1, localMem[440], 0 + i);
                end
              end
              ip = 978;
      end

        978 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[441] = heapMem[localMem[360]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 979;
      end

        979 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[442] = heapMem[localMem[426]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 980;
      end

        980 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[373]) begin
                  heapMem[NArea * localMem[442] + 0 + i] = heapMem[NArea * localMem[441] + localMem[374] + i];
                  updateArrayLength(1, localMem[442], 0 + i);
                end
              end
              ip = 981;
      end

        981 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[443] = heapMem[localMem[360]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 982;
      end

        982 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[444] = heapMem[localMem[426]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 983;
      end

        983 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[445] = localMem[373] + 1;
              updateArrayLength(2, 0, 0);
              ip = 984;
      end

        984 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[445]) begin
                  heapMem[NArea * localMem[444] + 0 + i] = heapMem[NArea * localMem[443] + localMem[374] + i];
                  updateArrayLength(1, localMem[444], 0 + i);
                end
              end
              ip = 985;
      end

        985 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[446] = heapMem[localMem[423]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 986;
      end

        986 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[447] = localMem[446] + 1;
              updateArrayLength(2, 0, 0);
              ip = 987;
      end

        987 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[448] = heapMem[localMem[423]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 988;
      end

        988 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 989;
      end

        989 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[449] = 0;
              updateArrayLength(2, 0, 0);
              ip = 990;
      end

        990 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 991;
      end

        991 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[449] >= localMem[447] ? 997 : 992;
      end

        992 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[450] = heapMem[localMem[448]*7 + localMem[449]];
              updateArrayLength(2, 0, 0);
              ip = 993;
      end

        993 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[450]*7 + 2] = localMem[423];
              updateArrayLength(1, localMem[450], 2);
              ip = 994;
      end

        994 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 995;
      end

        995 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[449] = localMem[449] + 1;
              updateArrayLength(2, 0, 0);
              ip = 996;
      end

        996 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 990;
      end

        997 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 998;
      end

        998 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[451] = heapMem[localMem[426]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 999;
      end

        999 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[452] = localMem[451] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1000;
      end

       1000 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[453] = heapMem[localMem[426]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1001;
      end

       1001 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1002;
      end

       1002 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[454] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1003;
      end

       1003 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1004;
      end

       1004 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[454] >= localMem[452] ? 1010 : 1005;
      end

       1005 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[455] = heapMem[localMem[453]*7 + localMem[454]];
              updateArrayLength(2, 0, 0);
              ip = 1006;
      end

       1006 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[455]*7 + 2] = localMem[426];
              updateArrayLength(1, localMem[455], 2);
              ip = 1007;
      end

       1007 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1008;
      end

       1008 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[454] = localMem[454] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1009;
      end

       1009 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1003;
      end

       1010 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1011;
      end

       1011 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1027;
      end

       1012 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1013;
      end

       1013 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[456] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[456] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[456]] = 0;
              ip = 1014;
      end

       1014 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[360]*7 + 6] = localMem[456];
              updateArrayLength(1, localMem[360], 6);
              ip = 1015;
      end

       1015 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[457] = heapMem[localMem[360]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1016;
      end

       1016 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[458] = heapMem[localMem[423]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1017;
      end

       1017 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[373]) begin
                  heapMem[NArea * localMem[458] + 0 + i] = heapMem[NArea * localMem[457] + 0 + i];
                  updateArrayLength(1, localMem[458], 0 + i);
                end
              end
              ip = 1018;
      end

       1018 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[459] = heapMem[localMem[360]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1019;
      end

       1019 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[460] = heapMem[localMem[423]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1020;
      end

       1020 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[373]) begin
                  heapMem[NArea * localMem[460] + 0 + i] = heapMem[NArea * localMem[459] + 0 + i];
                  updateArrayLength(1, localMem[460], 0 + i);
                end
              end
              ip = 1021;
      end

       1021 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[461] = heapMem[localMem[360]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1022;
      end

       1022 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[462] = heapMem[localMem[426]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1023;
      end

       1023 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[373]) begin
                  heapMem[NArea * localMem[462] + 0 + i] = heapMem[NArea * localMem[461] + localMem[374] + i];
                  updateArrayLength(1, localMem[462], 0 + i);
                end
              end
              ip = 1024;
      end

       1024 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[463] = heapMem[localMem[360]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1025;
      end

       1025 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[464] = heapMem[localMem[426]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1026;
      end

       1026 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[373]) begin
                  heapMem[NArea * localMem[464] + 0 + i] = heapMem[NArea * localMem[463] + localMem[374] + i];
                  updateArrayLength(1, localMem[464], 0 + i);
                end
              end
              ip = 1027;
      end

       1027 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1028;
      end

       1028 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[423]*7 + 2] = localMem[360];
              updateArrayLength(1, localMem[423], 2);
              ip = 1029;
      end

       1029 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[426]*7 + 2] = localMem[360];
              updateArrayLength(1, localMem[426], 2);
              ip = 1030;
      end

       1030 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[465] = heapMem[localMem[360]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1031;
      end

       1031 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[466] = heapMem[localMem[465]*7 + localMem[373]];
              updateArrayLength(2, 0, 0);
              ip = 1032;
      end

       1032 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[467] = heapMem[localMem[360]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1033;
      end

       1033 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[468] = heapMem[localMem[467]*7 + localMem[373]];
              updateArrayLength(2, 0, 0);
              ip = 1034;
      end

       1034 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[469] = heapMem[localMem[360]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1035;
      end

       1035 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[469]*7 + 0] = localMem[466];
              updateArrayLength(1, localMem[469], 0);
              ip = 1036;
      end

       1036 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[470] = heapMem[localMem[360]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1037;
      end

       1037 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[470]*7 + 0] = localMem[468];
              updateArrayLength(1, localMem[470], 0);
              ip = 1038;
      end

       1038 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[471] = heapMem[localMem[360]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1039;
      end

       1039 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[471]*7 + 0] = localMem[423];
              updateArrayLength(1, localMem[471], 0);
              ip = 1040;
      end

       1040 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[472] = heapMem[localMem[360]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1041;
      end

       1041 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[472]*7 + 1] = localMem[426];
              updateArrayLength(1, localMem[472], 1);
              ip = 1042;
      end

       1042 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[360]*7 + 0] = 1;
              updateArrayLength(1, localMem[360], 0);
              ip = 1043;
      end

       1043 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[473] = heapMem[localMem[360]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1044;
      end

       1044 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[473]] = 1;
              ip = 1045;
      end

       1045 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[474] = heapMem[localMem[360]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1046;
      end

       1046 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[474]] = 1;
              ip = 1047;
      end

       1047 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[475] = heapMem[localMem[360]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1048;
      end

       1048 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[475]] = 2;
              ip = 1049;
      end

       1049 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1051;
      end

       1050 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1056;
      end

       1051 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1052;
      end

       1052 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[369] = 1;
              updateArrayLength(2, 0, 0);
              ip = 1053;
      end

       1053 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1056;
      end

       1054 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1055;
      end

       1055 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[369] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1056;
      end

       1056 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1057;
      end

       1057 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1058;
      end

       1058 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1059;
      end

       1059 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1060;
      end

       1060 :
      begin                                                                     // free
if (0) begin
  $display("AAAA %4d %4d free", steps, ip);
end
                                 arraySizes[localMem[1]] = 0;
              freedArrays[freedArraysTop] = localMem[1];
              freedArraysTop = freedArraysTop + 1;
              ip = 1061;
      end

       1061 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[476] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[476] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[476]] = 0;
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
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[477] = heapMem[localMem[0]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 1064;
      end

       1064 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[477] != 0 ? 1087 : 1065;
      end

       1065 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[478] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[478] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[478]] = 0;
              ip = 1066;
      end

       1066 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[478]*7 + 0] = 1;
              updateArrayLength(1, localMem[478], 0);
              ip = 1067;
      end

       1067 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[478]*7 + 2] = 0;
              updateArrayLength(1, localMem[478], 2);
              ip = 1068;
      end

       1068 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[479] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[479] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[479]] = 0;
              ip = 1069;
      end

       1069 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[478]*7 + 4] = localMem[479];
              updateArrayLength(1, localMem[478], 4);
              ip = 1070;
      end

       1070 :
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
              ip = 1071;
      end

       1071 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[478]*7 + 5] = localMem[480];
              updateArrayLength(1, localMem[478], 5);
              ip = 1072;
      end

       1072 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[478]*7 + 6] = 0;
              updateArrayLength(1, localMem[478], 6);
              ip = 1073;
      end

       1073 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[478]*7 + 3] = localMem[0];
              updateArrayLength(1, localMem[478], 3);
              ip = 1074;
      end

       1074 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[0]*7 + 1] = heapMem[localMem[0]*7 + 1] + 1;
              updateArrayLength(1, localMem[0], 1);
              ip = 1075;
      end

       1075 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[478]*7 + 1] = heapMem[localMem[0]*7 + 1];
              updateArrayLength(1, localMem[478], 1);
              ip = 1076;
      end

       1076 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[481] = heapMem[localMem[478]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1077;
      end

       1077 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[481]*7 + 0] = 2;
              updateArrayLength(1, localMem[481], 0);
              ip = 1078;
      end

       1078 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[482] = heapMem[localMem[478]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1079;
      end

       1079 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[482]*7 + 0] = 22;
              updateArrayLength(1, localMem[482], 0);
              ip = 1080;
      end

       1080 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[0]*7 + 0] = heapMem[localMem[0]*7 + 0] + 1;
              updateArrayLength(1, localMem[0], 0);
              ip = 1081;
      end

       1081 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[0]*7 + 3] = localMem[478];
              updateArrayLength(1, localMem[0], 3);
              ip = 1082;
      end

       1082 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[483] = heapMem[localMem[478]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1083;
      end

       1083 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[483]] = 1;
              ip = 1084;
      end

       1084 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[484] = heapMem[localMem[478]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1085;
      end

       1085 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[484]] = 1;
              ip = 1086;
      end

       1086 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 2115;
      end

       1087 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1088;
      end

       1088 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[485] = heapMem[localMem[477]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1089;
      end

       1089 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[486] = heapMem[localMem[0]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1090;
      end

       1090 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[485] >= localMem[486] ? 1126 : 1091;
      end

       1091 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[487] = heapMem[localMem[477]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1092;
      end

       1092 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[487] != 0 ? 1125 : 1093;
      end

       1093 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[488] = !heapMem[localMem[477]*7 + 6];
              ip = 1094;
      end

       1094 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[488] == 0 ? 1124 : 1095;
      end

       1095 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[489] = heapMem[localMem[477]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1096;
      end

       1096 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[490] = 0; k = arraySizes[localMem[489]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[489] * NArea + i] == 2) localMem[490] = i + 1;
              end
              ip = 1097;
      end

       1097 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[490] == 0 ? 1102 : 1098;
      end

       1098 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[490] = localMem[490] - 1;
              updateArrayLength(2, 0, 0);
              ip = 1099;
      end

       1099 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[491] = heapMem[localMem[477]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1100;
      end

       1100 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[491]*7 + localMem[490]] = 22;
              updateArrayLength(1, localMem[491], localMem[490]);
              ip = 1101;
      end

       1101 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 2115;
      end

       1102 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1103;
      end

       1103 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[489]] = localMem[485];
              ip = 1104;
      end

       1104 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[492] = heapMem[localMem[477]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1105;
      end

       1105 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[492]] = localMem[485];
              ip = 1106;
      end

       1106 :
      begin                                                                     // arrayCountGreater
if (0) begin
  $display("AAAA %4d %4d arrayCountGreater", steps, ip);
end
              j = 0; k = arraySizes[localMem[489]];
//$display("AAAAA k=%d  source2=%d", k, 2);
              for(i = 0; i < NArea; i = i + 1) begin
//$display("AAAAA i=%d  value=%d", i, heapMem[localMem[489] * NArea + i]);
                if (i < k && heapMem[localMem[489] * NArea + i] > 2) j = j + 1;
              end
              localMem[493] = j;
              ip = 1107;
      end

       1107 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[493] != 0 ? 1115 : 1108;
      end

       1108 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[494] = heapMem[localMem[477]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1109;
      end

       1109 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[494]*7 + localMem[485]] = 2;
              updateArrayLength(1, localMem[494], localMem[485]);
              ip = 1110;
      end

       1110 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[495] = heapMem[localMem[477]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1111;
      end

       1111 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[495]*7 + localMem[485]] = 22;
              updateArrayLength(1, localMem[495], localMem[485]);
              ip = 1112;
      end

       1112 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[477]*7 + 0] = localMem[485] + 1;
              updateArrayLength(1, localMem[477], 0);
              ip = 1113;
      end

       1113 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[0]*7 + 0] = heapMem[localMem[0]*7 + 0] + 1;
              updateArrayLength(1, localMem[0], 0);
              ip = 1114;
      end

       1114 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 2115;
      end

       1115 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1116;
      end

       1116 :
      begin                                                                     // arrayCountLess
if (0) begin
  $display("AAAA %4d %4d arrayCountLess", steps, ip);
end
              j = 0; k = arraySizes[localMem[489]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[489] * NArea + i] < 2) j = j + 1;
              end
              localMem[496] = j;
              ip = 1117;
      end

       1117 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[497] = heapMem[localMem[477]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1118;
      end

       1118 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[497] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[496], localMem[497], arraySizes[localMem[497]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[496] && i <= arraySizes[localMem[497]]) begin
                  heapMem[NArea * localMem[497] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[497] + localMem[496]] = 2;                                    // Insert new value
              arraySizes[localMem[497]] = arraySizes[localMem[497]] + 1;                              // Increase array size
              ip = 1119;
      end

       1119 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[498] = heapMem[localMem[477]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1120;
      end

       1120 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[498] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[496], localMem[498], arraySizes[localMem[498]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[496] && i <= arraySizes[localMem[498]]) begin
                  heapMem[NArea * localMem[498] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[498] + localMem[496]] = 22;                                    // Insert new value
              arraySizes[localMem[498]] = arraySizes[localMem[498]] + 1;                              // Increase array size
              ip = 1121;
      end

       1121 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[477]*7 + 0] = heapMem[localMem[477]*7 + 0] + 1;
              updateArrayLength(1, localMem[477], 0);
              ip = 1122;
      end

       1122 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[0]*7 + 0] = heapMem[localMem[0]*7 + 0] + 1;
              updateArrayLength(1, localMem[0], 0);
              ip = 1123;
      end

       1123 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 2115;
      end

       1124 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1125;
      end

       1125 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1126;
      end

       1126 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1127;
      end

       1127 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[499] = heapMem[localMem[0]*7 + 3];
              updateArrayLength(2, 0, 0);
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
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[501] = heapMem[localMem[499]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1130;
      end

       1130 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[502] = heapMem[localMem[499]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 1131;
      end

       1131 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[503] = heapMem[localMem[502]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1132;
      end

       1132 :
      begin                                                                     // jLt
if (0) begin
  $display("AAAA %4d %4d jLt", steps, ip);
end
              ip = localMem[501] <  localMem[503] ? 1352 : 1133;
      end

       1133 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[504] = localMem[503];
              updateArrayLength(2, 0, 0);
              ip = 1134;
      end

       1134 :
      begin                                                                     // shiftRight
if (0) begin
  $display("AAAA %4d %4d shiftRight", steps, ip);
end
              localMem[504] = localMem[504] >> 1;
              ip = 1135;
      end

       1135 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[505] = localMem[504] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1136;
      end

       1136 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[506] = heapMem[localMem[499]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1137;
      end

       1137 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[506] == 0 ? 1234 : 1138;
      end

       1138 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[507] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[507] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[507]] = 0;
              ip = 1139;
      end

       1139 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[507]*7 + 0] = localMem[504];
              updateArrayLength(1, localMem[507], 0);
              ip = 1140;
      end

       1140 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[507]*7 + 2] = 0;
              updateArrayLength(1, localMem[507], 2);
              ip = 1141;
      end

       1141 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[508] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[508] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[508]] = 0;
              ip = 1142;
      end

       1142 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[507]*7 + 4] = localMem[508];
              updateArrayLength(1, localMem[507], 4);
              ip = 1143;
      end

       1143 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[509] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[509] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[509]] = 0;
              ip = 1144;
      end

       1144 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[507]*7 + 5] = localMem[509];
              updateArrayLength(1, localMem[507], 5);
              ip = 1145;
      end

       1145 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[507]*7 + 6] = 0;
              updateArrayLength(1, localMem[507], 6);
              ip = 1146;
      end

       1146 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[507]*7 + 3] = localMem[502];
              updateArrayLength(1, localMem[507], 3);
              ip = 1147;
      end

       1147 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[502]*7 + 1] = heapMem[localMem[502]*7 + 1] + 1;
              updateArrayLength(1, localMem[502], 1);
              ip = 1148;
      end

       1148 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[507]*7 + 1] = heapMem[localMem[502]*7 + 1];
              updateArrayLength(1, localMem[507], 1);
              ip = 1149;
      end

       1149 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[510] = !heapMem[localMem[499]*7 + 6];
              ip = 1150;
      end

       1150 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[510] != 0 ? 1179 : 1151;
      end

       1151 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[511] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[511] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[511]] = 0;
              ip = 1152;
      end

       1152 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[507]*7 + 6] = localMem[511];
              updateArrayLength(1, localMem[507], 6);
              ip = 1153;
      end

       1153 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[512] = heapMem[localMem[499]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1154;
      end

       1154 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[513] = heapMem[localMem[507]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1155;
      end

       1155 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[504]) begin
                  heapMem[NArea * localMem[513] + 0 + i] = heapMem[NArea * localMem[512] + localMem[505] + i];
                  updateArrayLength(1, localMem[513], 0 + i);
                end
              end
              ip = 1156;
      end

       1156 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[514] = heapMem[localMem[499]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1157;
      end

       1157 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[515] = heapMem[localMem[507]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1158;
      end

       1158 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[504]) begin
                  heapMem[NArea * localMem[515] + 0 + i] = heapMem[NArea * localMem[514] + localMem[505] + i];
                  updateArrayLength(1, localMem[515], 0 + i);
                end
              end
              ip = 1159;
      end

       1159 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[516] = heapMem[localMem[499]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1160;
      end

       1160 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[517] = heapMem[localMem[507]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1161;
      end

       1161 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[518] = localMem[504] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1162;
      end

       1162 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[518]) begin
                  heapMem[NArea * localMem[517] + 0 + i] = heapMem[NArea * localMem[516] + localMem[505] + i];
                  updateArrayLength(1, localMem[517], 0 + i);
                end
              end
              ip = 1163;
      end

       1163 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[519] = heapMem[localMem[507]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1164;
      end

       1164 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[520] = localMem[519] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1165;
      end

       1165 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[521] = heapMem[localMem[507]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1166;
      end

       1166 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1167;
      end

       1167 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[522] = 0;
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
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[522] >= localMem[520] ? 1175 : 1170;
      end

       1170 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[523] = heapMem[localMem[521]*7 + localMem[522]];
              updateArrayLength(2, 0, 0);
              ip = 1171;
      end

       1171 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[523]*7 + 2] = localMem[507];
              updateArrayLength(1, localMem[523], 2);
              ip = 1172;
      end

       1172 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1173;
      end

       1173 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[522] = localMem[522] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1174;
      end

       1174 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1168;
      end

       1175 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1176;
      end

       1176 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[524] = heapMem[localMem[499]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1177;
      end

       1177 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[524]] = localMem[505];
              ip = 1178;
      end

       1178 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1186;
      end

       1179 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1180;
      end

       1180 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[525] = heapMem[localMem[499]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1181;
      end

       1181 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[526] = heapMem[localMem[507]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1182;
      end

       1182 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[504]) begin
                  heapMem[NArea * localMem[526] + 0 + i] = heapMem[NArea * localMem[525] + localMem[505] + i];
                  updateArrayLength(1, localMem[526], 0 + i);
                end
              end
              ip = 1183;
      end

       1183 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[527] = heapMem[localMem[499]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1184;
      end

       1184 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[528] = heapMem[localMem[507]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1185;
      end

       1185 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[504]) begin
                  heapMem[NArea * localMem[528] + 0 + i] = heapMem[NArea * localMem[527] + localMem[505] + i];
                  updateArrayLength(1, localMem[528], 0 + i);
                end
              end
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
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[499]*7 + 0] = localMem[504];
              updateArrayLength(1, localMem[499], 0);
              ip = 1188;
      end

       1188 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[507]*7 + 2] = localMem[506];
              updateArrayLength(1, localMem[507], 2);
              ip = 1189;
      end

       1189 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[529] = heapMem[localMem[506]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1190;
      end

       1190 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[530] = heapMem[localMem[506]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1191;
      end

       1191 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[531] = heapMem[localMem[530]*7 + localMem[529]];
              updateArrayLength(2, 0, 0);
              ip = 1192;
      end

       1192 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[531] != localMem[499] ? 1211 : 1193;
      end

       1193 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[532] = heapMem[localMem[499]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1194;
      end

       1194 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[533] = heapMem[localMem[532]*7 + localMem[504]];
              updateArrayLength(2, 0, 0);
              ip = 1195;
      end

       1195 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[534] = heapMem[localMem[506]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1196;
      end

       1196 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[534]*7 + localMem[529]] = localMem[533];
              updateArrayLength(1, localMem[534], localMem[529]);
              ip = 1197;
      end

       1197 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[535] = heapMem[localMem[499]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1198;
      end

       1198 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[536] = heapMem[localMem[535]*7 + localMem[504]];
              updateArrayLength(2, 0, 0);
              ip = 1199;
      end

       1199 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[537] = heapMem[localMem[506]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1200;
      end

       1200 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[537]*7 + localMem[529]] = localMem[536];
              updateArrayLength(1, localMem[537], localMem[529]);
              ip = 1201;
      end

       1201 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[538] = heapMem[localMem[499]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1202;
      end

       1202 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[538]] = localMem[504];
              ip = 1203;
      end

       1203 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[539] = heapMem[localMem[499]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1204;
      end

       1204 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[539]] = localMem[504];
              ip = 1205;
      end

       1205 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[540] = localMem[529] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1206;
      end

       1206 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[506]*7 + 0] = localMem[540];
              updateArrayLength(1, localMem[506], 0);
              ip = 1207;
      end

       1207 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[541] = heapMem[localMem[506]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1208;
      end

       1208 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[541]*7 + localMem[540]] = localMem[507];
              updateArrayLength(1, localMem[541], localMem[540]);
              ip = 1209;
      end

       1209 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1349;
      end

       1210 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1233;
      end

       1211 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1212;
      end

       1212 :
      begin                                                                     // assertNe
if (0) begin
  $display("AAAA %4d %4d assertNe", steps, ip);
end
            ip = 1213;
      end

       1213 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[542] = heapMem[localMem[506]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1214;
      end

       1214 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[543] = 0; k = arraySizes[localMem[542]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[542] * NArea + i] == localMem[499]) localMem[543] = i + 1;
              end
              ip = 1215;
      end

       1215 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[543] = localMem[543] - 1;
              updateArrayLength(2, 0, 0);
              ip = 1216;
      end

       1216 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[544] = heapMem[localMem[499]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1217;
      end

       1217 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[545] = heapMem[localMem[544]*7 + localMem[504]];
              updateArrayLength(2, 0, 0);
              ip = 1218;
      end

       1218 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[546] = heapMem[localMem[499]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1219;
      end

       1219 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[547] = heapMem[localMem[546]*7 + localMem[504]];
              updateArrayLength(2, 0, 0);
              ip = 1220;
      end

       1220 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[548] = heapMem[localMem[499]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1221;
      end

       1221 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[548]] = localMem[504];
              ip = 1222;
      end

       1222 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[549] = heapMem[localMem[499]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1223;
      end

       1223 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[549]] = localMem[504];
              ip = 1224;
      end

       1224 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[550] = heapMem[localMem[506]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1225;
      end

       1225 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[550] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[543], localMem[550], arraySizes[localMem[550]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[543] && i <= arraySizes[localMem[550]]) begin
                  heapMem[NArea * localMem[550] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[550] + localMem[543]] = localMem[545];                                    // Insert new value
              arraySizes[localMem[550]] = arraySizes[localMem[550]] + 1;                              // Increase array size
              ip = 1226;
      end

       1226 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[551] = heapMem[localMem[506]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1227;
      end

       1227 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[551] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[543], localMem[551], arraySizes[localMem[551]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[543] && i <= arraySizes[localMem[551]]) begin
                  heapMem[NArea * localMem[551] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[551] + localMem[543]] = localMem[547];                                    // Insert new value
              arraySizes[localMem[551]] = arraySizes[localMem[551]] + 1;                              // Increase array size
              ip = 1228;
      end

       1228 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[552] = heapMem[localMem[506]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1229;
      end

       1229 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[553] = localMem[543] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1230;
      end

       1230 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[552] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[553], localMem[552], arraySizes[localMem[552]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[553] && i <= arraySizes[localMem[552]]) begin
                  heapMem[NArea * localMem[552] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[552] + localMem[553]] = localMem[507];                                    // Insert new value
              arraySizes[localMem[552]] = arraySizes[localMem[552]] + 1;                              // Increase array size
              ip = 1231;
      end

       1231 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[506]*7 + 0] = heapMem[localMem[506]*7 + 0] + 1;
              updateArrayLength(1, localMem[506], 0);
              ip = 1232;
      end

       1232 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1349;
      end

       1233 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1234;
      end

       1234 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1235;
      end

       1235 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[554] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[554] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[554]] = 0;
              ip = 1236;
      end

       1236 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[554]*7 + 0] = localMem[504];
              updateArrayLength(1, localMem[554], 0);
              ip = 1237;
      end

       1237 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[554]*7 + 2] = 0;
              updateArrayLength(1, localMem[554], 2);
              ip = 1238;
      end

       1238 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[555] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[555] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[555]] = 0;
              ip = 1239;
      end

       1239 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[554]*7 + 4] = localMem[555];
              updateArrayLength(1, localMem[554], 4);
              ip = 1240;
      end

       1240 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[556] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[556] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[556]] = 0;
              ip = 1241;
      end

       1241 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[554]*7 + 5] = localMem[556];
              updateArrayLength(1, localMem[554], 5);
              ip = 1242;
      end

       1242 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[554]*7 + 6] = 0;
              updateArrayLength(1, localMem[554], 6);
              ip = 1243;
      end

       1243 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[554]*7 + 3] = localMem[502];
              updateArrayLength(1, localMem[554], 3);
              ip = 1244;
      end

       1244 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[502]*7 + 1] = heapMem[localMem[502]*7 + 1] + 1;
              updateArrayLength(1, localMem[502], 1);
              ip = 1245;
      end

       1245 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[554]*7 + 1] = heapMem[localMem[502]*7 + 1];
              updateArrayLength(1, localMem[554], 1);
              ip = 1246;
      end

       1246 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[557] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[557] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[557]] = 0;
              ip = 1247;
      end

       1247 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[557]*7 + 0] = localMem[504];
              updateArrayLength(1, localMem[557], 0);
              ip = 1248;
      end

       1248 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[557]*7 + 2] = 0;
              updateArrayLength(1, localMem[557], 2);
              ip = 1249;
      end

       1249 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[558] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[558] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[558]] = 0;
              ip = 1250;
      end

       1250 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[557]*7 + 4] = localMem[558];
              updateArrayLength(1, localMem[557], 4);
              ip = 1251;
      end

       1251 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[559] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[559] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[559]] = 0;
              ip = 1252;
      end

       1252 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[557]*7 + 5] = localMem[559];
              updateArrayLength(1, localMem[557], 5);
              ip = 1253;
      end

       1253 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[557]*7 + 6] = 0;
              updateArrayLength(1, localMem[557], 6);
              ip = 1254;
      end

       1254 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[557]*7 + 3] = localMem[502];
              updateArrayLength(1, localMem[557], 3);
              ip = 1255;
      end

       1255 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[502]*7 + 1] = heapMem[localMem[502]*7 + 1] + 1;
              updateArrayLength(1, localMem[502], 1);
              ip = 1256;
      end

       1256 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[557]*7 + 1] = heapMem[localMem[502]*7 + 1];
              updateArrayLength(1, localMem[557], 1);
              ip = 1257;
      end

       1257 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[560] = !heapMem[localMem[499]*7 + 6];
              ip = 1258;
      end

       1258 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[560] != 0 ? 1310 : 1259;
      end

       1259 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[561] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[561] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[561]] = 0;
              ip = 1260;
      end

       1260 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[554]*7 + 6] = localMem[561];
              updateArrayLength(1, localMem[554], 6);
              ip = 1261;
      end

       1261 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[562] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[562] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[562]] = 0;
              ip = 1262;
      end

       1262 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[557]*7 + 6] = localMem[562];
              updateArrayLength(1, localMem[557], 6);
              ip = 1263;
      end

       1263 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[563] = heapMem[localMem[499]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1264;
      end

       1264 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[564] = heapMem[localMem[554]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1265;
      end

       1265 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[504]) begin
                  heapMem[NArea * localMem[564] + 0 + i] = heapMem[NArea * localMem[563] + 0 + i];
                  updateArrayLength(1, localMem[564], 0 + i);
                end
              end
              ip = 1266;
      end

       1266 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[565] = heapMem[localMem[499]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1267;
      end

       1267 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[566] = heapMem[localMem[554]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1268;
      end

       1268 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[504]) begin
                  heapMem[NArea * localMem[566] + 0 + i] = heapMem[NArea * localMem[565] + 0 + i];
                  updateArrayLength(1, localMem[566], 0 + i);
                end
              end
              ip = 1269;
      end

       1269 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[567] = heapMem[localMem[499]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1270;
      end

       1270 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[568] = heapMem[localMem[554]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1271;
      end

       1271 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[569] = localMem[504] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1272;
      end

       1272 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[569]) begin
                  heapMem[NArea * localMem[568] + 0 + i] = heapMem[NArea * localMem[567] + 0 + i];
                  updateArrayLength(1, localMem[568], 0 + i);
                end
              end
              ip = 1273;
      end

       1273 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[570] = heapMem[localMem[499]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1274;
      end

       1274 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[571] = heapMem[localMem[557]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1275;
      end

       1275 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[504]) begin
                  heapMem[NArea * localMem[571] + 0 + i] = heapMem[NArea * localMem[570] + localMem[505] + i];
                  updateArrayLength(1, localMem[571], 0 + i);
                end
              end
              ip = 1276;
      end

       1276 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[572] = heapMem[localMem[499]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1277;
      end

       1277 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[573] = heapMem[localMem[557]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1278;
      end

       1278 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[504]) begin
                  heapMem[NArea * localMem[573] + 0 + i] = heapMem[NArea * localMem[572] + localMem[505] + i];
                  updateArrayLength(1, localMem[573], 0 + i);
                end
              end
              ip = 1279;
      end

       1279 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[574] = heapMem[localMem[499]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1280;
      end

       1280 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[575] = heapMem[localMem[557]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1281;
      end

       1281 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[576] = localMem[504] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1282;
      end

       1282 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[576]) begin
                  heapMem[NArea * localMem[575] + 0 + i] = heapMem[NArea * localMem[574] + localMem[505] + i];
                  updateArrayLength(1, localMem[575], 0 + i);
                end
              end
              ip = 1283;
      end

       1283 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[577] = heapMem[localMem[554]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1284;
      end

       1284 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[578] = localMem[577] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1285;
      end

       1285 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[579] = heapMem[localMem[554]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1286;
      end

       1286 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1287;
      end

       1287 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[580] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1288;
      end

       1288 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1289;
      end

       1289 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[580] >= localMem[578] ? 1295 : 1290;
      end

       1290 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[581] = heapMem[localMem[579]*7 + localMem[580]];
              updateArrayLength(2, 0, 0);
              ip = 1291;
      end

       1291 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[581]*7 + 2] = localMem[554];
              updateArrayLength(1, localMem[581], 2);
              ip = 1292;
      end

       1292 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1293;
      end

       1293 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[580] = localMem[580] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1294;
      end

       1294 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1288;
      end

       1295 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1296;
      end

       1296 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[582] = heapMem[localMem[557]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1297;
      end

       1297 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[583] = localMem[582] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1298;
      end

       1298 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[584] = heapMem[localMem[557]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1299;
      end

       1299 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1300;
      end

       1300 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[585] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1301;
      end

       1301 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1302;
      end

       1302 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[585] >= localMem[583] ? 1308 : 1303;
      end

       1303 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[586] = heapMem[localMem[584]*7 + localMem[585]];
              updateArrayLength(2, 0, 0);
              ip = 1304;
      end

       1304 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[586]*7 + 2] = localMem[557];
              updateArrayLength(1, localMem[586], 2);
              ip = 1305;
      end

       1305 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1306;
      end

       1306 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[585] = localMem[585] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1307;
      end

       1307 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1301;
      end

       1308 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1309;
      end

       1309 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1325;
      end

       1310 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1311;
      end

       1311 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[587] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[587] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[587]] = 0;
              ip = 1312;
      end

       1312 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[499]*7 + 6] = localMem[587];
              updateArrayLength(1, localMem[499], 6);
              ip = 1313;
      end

       1313 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[588] = heapMem[localMem[499]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1314;
      end

       1314 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[589] = heapMem[localMem[554]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1315;
      end

       1315 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[504]) begin
                  heapMem[NArea * localMem[589] + 0 + i] = heapMem[NArea * localMem[588] + 0 + i];
                  updateArrayLength(1, localMem[589], 0 + i);
                end
              end
              ip = 1316;
      end

       1316 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[590] = heapMem[localMem[499]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1317;
      end

       1317 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[591] = heapMem[localMem[554]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1318;
      end

       1318 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[504]) begin
                  heapMem[NArea * localMem[591] + 0 + i] = heapMem[NArea * localMem[590] + 0 + i];
                  updateArrayLength(1, localMem[591], 0 + i);
                end
              end
              ip = 1319;
      end

       1319 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[592] = heapMem[localMem[499]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1320;
      end

       1320 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[593] = heapMem[localMem[557]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1321;
      end

       1321 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[504]) begin
                  heapMem[NArea * localMem[593] + 0 + i] = heapMem[NArea * localMem[592] + localMem[505] + i];
                  updateArrayLength(1, localMem[593], 0 + i);
                end
              end
              ip = 1322;
      end

       1322 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[594] = heapMem[localMem[499]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1323;
      end

       1323 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[595] = heapMem[localMem[557]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1324;
      end

       1324 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[504]) begin
                  heapMem[NArea * localMem[595] + 0 + i] = heapMem[NArea * localMem[594] + localMem[505] + i];
                  updateArrayLength(1, localMem[595], 0 + i);
                end
              end
              ip = 1325;
      end

       1325 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1326;
      end

       1326 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[554]*7 + 2] = localMem[499];
              updateArrayLength(1, localMem[554], 2);
              ip = 1327;
      end

       1327 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[557]*7 + 2] = localMem[499];
              updateArrayLength(1, localMem[557], 2);
              ip = 1328;
      end

       1328 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[596] = heapMem[localMem[499]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1329;
      end

       1329 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[597] = heapMem[localMem[596]*7 + localMem[504]];
              updateArrayLength(2, 0, 0);
              ip = 1330;
      end

       1330 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[598] = heapMem[localMem[499]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1331;
      end

       1331 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[599] = heapMem[localMem[598]*7 + localMem[504]];
              updateArrayLength(2, 0, 0);
              ip = 1332;
      end

       1332 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[600] = heapMem[localMem[499]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1333;
      end

       1333 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[600]*7 + 0] = localMem[597];
              updateArrayLength(1, localMem[600], 0);
              ip = 1334;
      end

       1334 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[601] = heapMem[localMem[499]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1335;
      end

       1335 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[601]*7 + 0] = localMem[599];
              updateArrayLength(1, localMem[601], 0);
              ip = 1336;
      end

       1336 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[602] = heapMem[localMem[499]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1337;
      end

       1337 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[602]*7 + 0] = localMem[554];
              updateArrayLength(1, localMem[602], 0);
              ip = 1338;
      end

       1338 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[603] = heapMem[localMem[499]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1339;
      end

       1339 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[603]*7 + 1] = localMem[557];
              updateArrayLength(1, localMem[603], 1);
              ip = 1340;
      end

       1340 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[499]*7 + 0] = 1;
              updateArrayLength(1, localMem[499], 0);
              ip = 1341;
      end

       1341 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[604] = heapMem[localMem[499]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1342;
      end

       1342 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[604]] = 1;
              ip = 1343;
      end

       1343 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[605] = heapMem[localMem[499]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1344;
      end

       1344 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[605]] = 1;
              ip = 1345;
      end

       1345 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[606] = heapMem[localMem[499]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1346;
      end

       1346 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[606]] = 2;
              ip = 1347;
      end

       1347 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1349;
      end

       1348 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1354;
      end

       1349 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1350;
      end

       1350 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[500] = 1;
              updateArrayLength(2, 0, 0);
              ip = 1351;
      end

       1351 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1354;
      end

       1352 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1353;
      end

       1353 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[500] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1354;
      end

       1354 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1355;
      end

       1355 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1356;
      end

       1356 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1357;
      end

       1357 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[607] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1358;
      end

       1358 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1359;
      end

       1359 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[607] >= 99 ? 1857 : 1360;
      end

       1360 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[608] = heapMem[localMem[499]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1361;
      end

       1361 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[609] = localMem[608] - 1;
              updateArrayLength(2, 0, 0);
              ip = 1362;
      end

       1362 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[610] = heapMem[localMem[499]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1363;
      end

       1363 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[611] = heapMem[localMem[610]*7 + localMem[609]];
              updateArrayLength(2, 0, 0);
              ip = 1364;
      end

       1364 :
      begin                                                                     // jLe
if (0) begin
  $display("AAAA %4d %4d jLe", steps, ip);
end
              ip = 2 <= localMem[611] ? 1605 : 1365;
      end

       1365 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[612] = !heapMem[localMem[499]*7 + 6];
              ip = 1366;
      end

       1366 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[612] == 0 ? 1371 : 1367;
      end

       1367 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[476]*7 + 0] = localMem[499];
              updateArrayLength(1, localMem[476], 0);
              ip = 1368;
      end

       1368 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[476]*7 + 1] = 2;
              updateArrayLength(1, localMem[476], 1);
              ip = 1369;
      end

       1369 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              heapMem[localMem[476]*7 + 2] = localMem[608] - 1;
              updateArrayLength(1, localMem[476], 2);
              ip = 1370;
      end

       1370 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1861;
      end

       1371 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1372;
      end

       1372 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[613] = heapMem[localMem[499]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1373;
      end

       1373 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[614] = heapMem[localMem[613]*7 + localMem[608]];
              updateArrayLength(2, 0, 0);
              ip = 1374;
      end

       1374 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1375;
      end

       1375 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[616] = heapMem[localMem[614]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1376;
      end

       1376 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[617] = heapMem[localMem[614]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 1377;
      end

       1377 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[618] = heapMem[localMem[617]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1378;
      end

       1378 :
      begin                                                                     // jLt
if (0) begin
  $display("AAAA %4d %4d jLt", steps, ip);
end
              ip = localMem[616] <  localMem[618] ? 1598 : 1379;
      end

       1379 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[619] = localMem[618];
              updateArrayLength(2, 0, 0);
              ip = 1380;
      end

       1380 :
      begin                                                                     // shiftRight
if (0) begin
  $display("AAAA %4d %4d shiftRight", steps, ip);
end
              localMem[619] = localMem[619] >> 1;
              ip = 1381;
      end

       1381 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[620] = localMem[619] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1382;
      end

       1382 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[621] = heapMem[localMem[614]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1383;
      end

       1383 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[621] == 0 ? 1480 : 1384;
      end

       1384 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[622] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[622] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[622]] = 0;
              ip = 1385;
      end

       1385 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[622]*7 + 0] = localMem[619];
              updateArrayLength(1, localMem[622], 0);
              ip = 1386;
      end

       1386 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[622]*7 + 2] = 0;
              updateArrayLength(1, localMem[622], 2);
              ip = 1387;
      end

       1387 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[623] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[623] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[623]] = 0;
              ip = 1388;
      end

       1388 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[622]*7 + 4] = localMem[623];
              updateArrayLength(1, localMem[622], 4);
              ip = 1389;
      end

       1389 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[624] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[624] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[624]] = 0;
              ip = 1390;
      end

       1390 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[622]*7 + 5] = localMem[624];
              updateArrayLength(1, localMem[622], 5);
              ip = 1391;
      end

       1391 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[622]*7 + 6] = 0;
              updateArrayLength(1, localMem[622], 6);
              ip = 1392;
      end

       1392 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[622]*7 + 3] = localMem[617];
              updateArrayLength(1, localMem[622], 3);
              ip = 1393;
      end

       1393 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[617]*7 + 1] = heapMem[localMem[617]*7 + 1] + 1;
              updateArrayLength(1, localMem[617], 1);
              ip = 1394;
      end

       1394 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[622]*7 + 1] = heapMem[localMem[617]*7 + 1];
              updateArrayLength(1, localMem[622], 1);
              ip = 1395;
      end

       1395 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[625] = !heapMem[localMem[614]*7 + 6];
              ip = 1396;
      end

       1396 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[625] != 0 ? 1425 : 1397;
      end

       1397 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[626] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[626] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[626]] = 0;
              ip = 1398;
      end

       1398 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[622]*7 + 6] = localMem[626];
              updateArrayLength(1, localMem[622], 6);
              ip = 1399;
      end

       1399 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[627] = heapMem[localMem[614]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1400;
      end

       1400 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[628] = heapMem[localMem[622]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1401;
      end

       1401 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[619]) begin
                  heapMem[NArea * localMem[628] + 0 + i] = heapMem[NArea * localMem[627] + localMem[620] + i];
                  updateArrayLength(1, localMem[628], 0 + i);
                end
              end
              ip = 1402;
      end

       1402 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[629] = heapMem[localMem[614]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1403;
      end

       1403 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[630] = heapMem[localMem[622]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1404;
      end

       1404 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[619]) begin
                  heapMem[NArea * localMem[630] + 0 + i] = heapMem[NArea * localMem[629] + localMem[620] + i];
                  updateArrayLength(1, localMem[630], 0 + i);
                end
              end
              ip = 1405;
      end

       1405 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[631] = heapMem[localMem[614]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1406;
      end

       1406 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[632] = heapMem[localMem[622]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1407;
      end

       1407 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[633] = localMem[619] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1408;
      end

       1408 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[633]) begin
                  heapMem[NArea * localMem[632] + 0 + i] = heapMem[NArea * localMem[631] + localMem[620] + i];
                  updateArrayLength(1, localMem[632], 0 + i);
                end
              end
              ip = 1409;
      end

       1409 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[634] = heapMem[localMem[622]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1410;
      end

       1410 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[635] = localMem[634] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1411;
      end

       1411 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[636] = heapMem[localMem[622]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1412;
      end

       1412 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1413;
      end

       1413 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[637] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1414;
      end

       1414 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1415;
      end

       1415 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[637] >= localMem[635] ? 1421 : 1416;
      end

       1416 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[638] = heapMem[localMem[636]*7 + localMem[637]];
              updateArrayLength(2, 0, 0);
              ip = 1417;
      end

       1417 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[638]*7 + 2] = localMem[622];
              updateArrayLength(1, localMem[638], 2);
              ip = 1418;
      end

       1418 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1419;
      end

       1419 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[637] = localMem[637] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1420;
      end

       1420 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1414;
      end

       1421 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1422;
      end

       1422 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[639] = heapMem[localMem[614]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1423;
      end

       1423 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[639]] = localMem[620];
              ip = 1424;
      end

       1424 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1432;
      end

       1425 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1426;
      end

       1426 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[640] = heapMem[localMem[614]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1427;
      end

       1427 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[641] = heapMem[localMem[622]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1428;
      end

       1428 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[619]) begin
                  heapMem[NArea * localMem[641] + 0 + i] = heapMem[NArea * localMem[640] + localMem[620] + i];
                  updateArrayLength(1, localMem[641], 0 + i);
                end
              end
              ip = 1429;
      end

       1429 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[642] = heapMem[localMem[614]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1430;
      end

       1430 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[643] = heapMem[localMem[622]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1431;
      end

       1431 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[619]) begin
                  heapMem[NArea * localMem[643] + 0 + i] = heapMem[NArea * localMem[642] + localMem[620] + i];
                  updateArrayLength(1, localMem[643], 0 + i);
                end
              end
              ip = 1432;
      end

       1432 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1433;
      end

       1433 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[614]*7 + 0] = localMem[619];
              updateArrayLength(1, localMem[614], 0);
              ip = 1434;
      end

       1434 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[622]*7 + 2] = localMem[621];
              updateArrayLength(1, localMem[622], 2);
              ip = 1435;
      end

       1435 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[644] = heapMem[localMem[621]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1436;
      end

       1436 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[645] = heapMem[localMem[621]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1437;
      end

       1437 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[646] = heapMem[localMem[645]*7 + localMem[644]];
              updateArrayLength(2, 0, 0);
              ip = 1438;
      end

       1438 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[646] != localMem[614] ? 1457 : 1439;
      end

       1439 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[647] = heapMem[localMem[614]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1440;
      end

       1440 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[648] = heapMem[localMem[647]*7 + localMem[619]];
              updateArrayLength(2, 0, 0);
              ip = 1441;
      end

       1441 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[649] = heapMem[localMem[621]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1442;
      end

       1442 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[649]*7 + localMem[644]] = localMem[648];
              updateArrayLength(1, localMem[649], localMem[644]);
              ip = 1443;
      end

       1443 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[650] = heapMem[localMem[614]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1444;
      end

       1444 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[651] = heapMem[localMem[650]*7 + localMem[619]];
              updateArrayLength(2, 0, 0);
              ip = 1445;
      end

       1445 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[652] = heapMem[localMem[621]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1446;
      end

       1446 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[652]*7 + localMem[644]] = localMem[651];
              updateArrayLength(1, localMem[652], localMem[644]);
              ip = 1447;
      end

       1447 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[653] = heapMem[localMem[614]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1448;
      end

       1448 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[653]] = localMem[619];
              ip = 1449;
      end

       1449 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[654] = heapMem[localMem[614]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1450;
      end

       1450 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[654]] = localMem[619];
              ip = 1451;
      end

       1451 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[655] = localMem[644] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1452;
      end

       1452 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[621]*7 + 0] = localMem[655];
              updateArrayLength(1, localMem[621], 0);
              ip = 1453;
      end

       1453 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[656] = heapMem[localMem[621]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1454;
      end

       1454 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[656]*7 + localMem[655]] = localMem[622];
              updateArrayLength(1, localMem[656], localMem[655]);
              ip = 1455;
      end

       1455 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1595;
      end

       1456 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1479;
      end

       1457 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1458;
      end

       1458 :
      begin                                                                     // assertNe
if (0) begin
  $display("AAAA %4d %4d assertNe", steps, ip);
end
            ip = 1459;
      end

       1459 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[657] = heapMem[localMem[621]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1460;
      end

       1460 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[658] = 0; k = arraySizes[localMem[657]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[657] * NArea + i] == localMem[614]) localMem[658] = i + 1;
              end
              ip = 1461;
      end

       1461 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[658] = localMem[658] - 1;
              updateArrayLength(2, 0, 0);
              ip = 1462;
      end

       1462 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[659] = heapMem[localMem[614]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1463;
      end

       1463 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[660] = heapMem[localMem[659]*7 + localMem[619]];
              updateArrayLength(2, 0, 0);
              ip = 1464;
      end

       1464 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[661] = heapMem[localMem[614]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1465;
      end

       1465 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[662] = heapMem[localMem[661]*7 + localMem[619]];
              updateArrayLength(2, 0, 0);
              ip = 1466;
      end

       1466 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[663] = heapMem[localMem[614]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1467;
      end

       1467 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[663]] = localMem[619];
              ip = 1468;
      end

       1468 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[664] = heapMem[localMem[614]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1469;
      end

       1469 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[664]] = localMem[619];
              ip = 1470;
      end

       1470 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[665] = heapMem[localMem[621]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1471;
      end

       1471 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[665] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[658], localMem[665], arraySizes[localMem[665]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[658] && i <= arraySizes[localMem[665]]) begin
                  heapMem[NArea * localMem[665] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[665] + localMem[658]] = localMem[660];                                    // Insert new value
              arraySizes[localMem[665]] = arraySizes[localMem[665]] + 1;                              // Increase array size
              ip = 1472;
      end

       1472 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[666] = heapMem[localMem[621]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1473;
      end

       1473 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[666] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[658], localMem[666], arraySizes[localMem[666]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[658] && i <= arraySizes[localMem[666]]) begin
                  heapMem[NArea * localMem[666] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[666] + localMem[658]] = localMem[662];                                    // Insert new value
              arraySizes[localMem[666]] = arraySizes[localMem[666]] + 1;                              // Increase array size
              ip = 1474;
      end

       1474 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[667] = heapMem[localMem[621]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1475;
      end

       1475 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[668] = localMem[658] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1476;
      end

       1476 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[667] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[668], localMem[667], arraySizes[localMem[667]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[668] && i <= arraySizes[localMem[667]]) begin
                  heapMem[NArea * localMem[667] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[667] + localMem[668]] = localMem[622];                                    // Insert new value
              arraySizes[localMem[667]] = arraySizes[localMem[667]] + 1;                              // Increase array size
              ip = 1477;
      end

       1477 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[621]*7 + 0] = heapMem[localMem[621]*7 + 0] + 1;
              updateArrayLength(1, localMem[621], 0);
              ip = 1478;
      end

       1478 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1595;
      end

       1479 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1480;
      end

       1480 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1481;
      end

       1481 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[669] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[669] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[669]] = 0;
              ip = 1482;
      end

       1482 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[669]*7 + 0] = localMem[619];
              updateArrayLength(1, localMem[669], 0);
              ip = 1483;
      end

       1483 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[669]*7 + 2] = 0;
              updateArrayLength(1, localMem[669], 2);
              ip = 1484;
      end

       1484 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[670] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[670] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[670]] = 0;
              ip = 1485;
      end

       1485 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[669]*7 + 4] = localMem[670];
              updateArrayLength(1, localMem[669], 4);
              ip = 1486;
      end

       1486 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[671] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[671] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[671]] = 0;
              ip = 1487;
      end

       1487 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[669]*7 + 5] = localMem[671];
              updateArrayLength(1, localMem[669], 5);
              ip = 1488;
      end

       1488 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[669]*7 + 6] = 0;
              updateArrayLength(1, localMem[669], 6);
              ip = 1489;
      end

       1489 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[669]*7 + 3] = localMem[617];
              updateArrayLength(1, localMem[669], 3);
              ip = 1490;
      end

       1490 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[617]*7 + 1] = heapMem[localMem[617]*7 + 1] + 1;
              updateArrayLength(1, localMem[617], 1);
              ip = 1491;
      end

       1491 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[669]*7 + 1] = heapMem[localMem[617]*7 + 1];
              updateArrayLength(1, localMem[669], 1);
              ip = 1492;
      end

       1492 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[672] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[672] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[672]] = 0;
              ip = 1493;
      end

       1493 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[672]*7 + 0] = localMem[619];
              updateArrayLength(1, localMem[672], 0);
              ip = 1494;
      end

       1494 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[672]*7 + 2] = 0;
              updateArrayLength(1, localMem[672], 2);
              ip = 1495;
      end

       1495 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[673] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[673] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[673]] = 0;
              ip = 1496;
      end

       1496 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[672]*7 + 4] = localMem[673];
              updateArrayLength(1, localMem[672], 4);
              ip = 1497;
      end

       1497 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[674] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[674] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[674]] = 0;
              ip = 1498;
      end

       1498 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[672]*7 + 5] = localMem[674];
              updateArrayLength(1, localMem[672], 5);
              ip = 1499;
      end

       1499 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[672]*7 + 6] = 0;
              updateArrayLength(1, localMem[672], 6);
              ip = 1500;
      end

       1500 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[672]*7 + 3] = localMem[617];
              updateArrayLength(1, localMem[672], 3);
              ip = 1501;
      end

       1501 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[617]*7 + 1] = heapMem[localMem[617]*7 + 1] + 1;
              updateArrayLength(1, localMem[617], 1);
              ip = 1502;
      end

       1502 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[672]*7 + 1] = heapMem[localMem[617]*7 + 1];
              updateArrayLength(1, localMem[672], 1);
              ip = 1503;
      end

       1503 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[675] = !heapMem[localMem[614]*7 + 6];
              ip = 1504;
      end

       1504 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[675] != 0 ? 1556 : 1505;
      end

       1505 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[676] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[676] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[676]] = 0;
              ip = 1506;
      end

       1506 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[669]*7 + 6] = localMem[676];
              updateArrayLength(1, localMem[669], 6);
              ip = 1507;
      end

       1507 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[677] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[677] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[677]] = 0;
              ip = 1508;
      end

       1508 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[672]*7 + 6] = localMem[677];
              updateArrayLength(1, localMem[672], 6);
              ip = 1509;
      end

       1509 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[678] = heapMem[localMem[614]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1510;
      end

       1510 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[679] = heapMem[localMem[669]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1511;
      end

       1511 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[619]) begin
                  heapMem[NArea * localMem[679] + 0 + i] = heapMem[NArea * localMem[678] + 0 + i];
                  updateArrayLength(1, localMem[679], 0 + i);
                end
              end
              ip = 1512;
      end

       1512 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[680] = heapMem[localMem[614]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1513;
      end

       1513 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[681] = heapMem[localMem[669]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1514;
      end

       1514 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[619]) begin
                  heapMem[NArea * localMem[681] + 0 + i] = heapMem[NArea * localMem[680] + 0 + i];
                  updateArrayLength(1, localMem[681], 0 + i);
                end
              end
              ip = 1515;
      end

       1515 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[682] = heapMem[localMem[614]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1516;
      end

       1516 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[683] = heapMem[localMem[669]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1517;
      end

       1517 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[684] = localMem[619] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1518;
      end

       1518 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[684]) begin
                  heapMem[NArea * localMem[683] + 0 + i] = heapMem[NArea * localMem[682] + 0 + i];
                  updateArrayLength(1, localMem[683], 0 + i);
                end
              end
              ip = 1519;
      end

       1519 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[685] = heapMem[localMem[614]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1520;
      end

       1520 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[686] = heapMem[localMem[672]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1521;
      end

       1521 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[619]) begin
                  heapMem[NArea * localMem[686] + 0 + i] = heapMem[NArea * localMem[685] + localMem[620] + i];
                  updateArrayLength(1, localMem[686], 0 + i);
                end
              end
              ip = 1522;
      end

       1522 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[687] = heapMem[localMem[614]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1523;
      end

       1523 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[688] = heapMem[localMem[672]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1524;
      end

       1524 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[619]) begin
                  heapMem[NArea * localMem[688] + 0 + i] = heapMem[NArea * localMem[687] + localMem[620] + i];
                  updateArrayLength(1, localMem[688], 0 + i);
                end
              end
              ip = 1525;
      end

       1525 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[689] = heapMem[localMem[614]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1526;
      end

       1526 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[690] = heapMem[localMem[672]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1527;
      end

       1527 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[691] = localMem[619] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1528;
      end

       1528 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[691]) begin
                  heapMem[NArea * localMem[690] + 0 + i] = heapMem[NArea * localMem[689] + localMem[620] + i];
                  updateArrayLength(1, localMem[690], 0 + i);
                end
              end
              ip = 1529;
      end

       1529 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[692] = heapMem[localMem[669]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1530;
      end

       1530 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[693] = localMem[692] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1531;
      end

       1531 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[694] = heapMem[localMem[669]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1532;
      end

       1532 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1533;
      end

       1533 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[695] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1534;
      end

       1534 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1535;
      end

       1535 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[695] >= localMem[693] ? 1541 : 1536;
      end

       1536 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[696] = heapMem[localMem[694]*7 + localMem[695]];
              updateArrayLength(2, 0, 0);
              ip = 1537;
      end

       1537 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[696]*7 + 2] = localMem[669];
              updateArrayLength(1, localMem[696], 2);
              ip = 1538;
      end

       1538 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1539;
      end

       1539 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[695] = localMem[695] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1540;
      end

       1540 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1534;
      end

       1541 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1542;
      end

       1542 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[697] = heapMem[localMem[672]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1543;
      end

       1543 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[698] = localMem[697] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1544;
      end

       1544 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[699] = heapMem[localMem[672]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1545;
      end

       1545 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1546;
      end

       1546 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[700] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1547;
      end

       1547 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1548;
      end

       1548 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[700] >= localMem[698] ? 1554 : 1549;
      end

       1549 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[701] = heapMem[localMem[699]*7 + localMem[700]];
              updateArrayLength(2, 0, 0);
              ip = 1550;
      end

       1550 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[701]*7 + 2] = localMem[672];
              updateArrayLength(1, localMem[701], 2);
              ip = 1551;
      end

       1551 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1552;
      end

       1552 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[700] = localMem[700] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1553;
      end

       1553 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1547;
      end

       1554 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1555;
      end

       1555 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1571;
      end

       1556 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1557;
      end

       1557 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[702] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[702] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[702]] = 0;
              ip = 1558;
      end

       1558 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[614]*7 + 6] = localMem[702];
              updateArrayLength(1, localMem[614], 6);
              ip = 1559;
      end

       1559 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[703] = heapMem[localMem[614]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1560;
      end

       1560 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[704] = heapMem[localMem[669]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1561;
      end

       1561 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[619]) begin
                  heapMem[NArea * localMem[704] + 0 + i] = heapMem[NArea * localMem[703] + 0 + i];
                  updateArrayLength(1, localMem[704], 0 + i);
                end
              end
              ip = 1562;
      end

       1562 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[705] = heapMem[localMem[614]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1563;
      end

       1563 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[706] = heapMem[localMem[669]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1564;
      end

       1564 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[619]) begin
                  heapMem[NArea * localMem[706] + 0 + i] = heapMem[NArea * localMem[705] + 0 + i];
                  updateArrayLength(1, localMem[706], 0 + i);
                end
              end
              ip = 1565;
      end

       1565 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[707] = heapMem[localMem[614]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1566;
      end

       1566 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[708] = heapMem[localMem[672]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1567;
      end

       1567 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[619]) begin
                  heapMem[NArea * localMem[708] + 0 + i] = heapMem[NArea * localMem[707] + localMem[620] + i];
                  updateArrayLength(1, localMem[708], 0 + i);
                end
              end
              ip = 1568;
      end

       1568 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[709] = heapMem[localMem[614]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1569;
      end

       1569 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[710] = heapMem[localMem[672]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1570;
      end

       1570 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[619]) begin
                  heapMem[NArea * localMem[710] + 0 + i] = heapMem[NArea * localMem[709] + localMem[620] + i];
                  updateArrayLength(1, localMem[710], 0 + i);
                end
              end
              ip = 1571;
      end

       1571 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1572;
      end

       1572 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[669]*7 + 2] = localMem[614];
              updateArrayLength(1, localMem[669], 2);
              ip = 1573;
      end

       1573 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[672]*7 + 2] = localMem[614];
              updateArrayLength(1, localMem[672], 2);
              ip = 1574;
      end

       1574 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[711] = heapMem[localMem[614]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1575;
      end

       1575 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[712] = heapMem[localMem[711]*7 + localMem[619]];
              updateArrayLength(2, 0, 0);
              ip = 1576;
      end

       1576 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[713] = heapMem[localMem[614]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1577;
      end

       1577 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[714] = heapMem[localMem[713]*7 + localMem[619]];
              updateArrayLength(2, 0, 0);
              ip = 1578;
      end

       1578 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[715] = heapMem[localMem[614]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1579;
      end

       1579 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[715]*7 + 0] = localMem[712];
              updateArrayLength(1, localMem[715], 0);
              ip = 1580;
      end

       1580 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[716] = heapMem[localMem[614]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1581;
      end

       1581 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[716]*7 + 0] = localMem[714];
              updateArrayLength(1, localMem[716], 0);
              ip = 1582;
      end

       1582 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[717] = heapMem[localMem[614]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1583;
      end

       1583 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[717]*7 + 0] = localMem[669];
              updateArrayLength(1, localMem[717], 0);
              ip = 1584;
      end

       1584 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[718] = heapMem[localMem[614]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1585;
      end

       1585 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[718]*7 + 1] = localMem[672];
              updateArrayLength(1, localMem[718], 1);
              ip = 1586;
      end

       1586 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[614]*7 + 0] = 1;
              updateArrayLength(1, localMem[614], 0);
              ip = 1587;
      end

       1587 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[719] = heapMem[localMem[614]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1588;
      end

       1588 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[719]] = 1;
              ip = 1589;
      end

       1589 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[720] = heapMem[localMem[614]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1590;
      end

       1590 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[720]] = 1;
              ip = 1591;
      end

       1591 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[721] = heapMem[localMem[614]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1592;
      end

       1592 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[721]] = 2;
              ip = 1593;
      end

       1593 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1595;
      end

       1594 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1600;
      end

       1595 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1596;
      end

       1596 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[615] = 1;
              updateArrayLength(2, 0, 0);
              ip = 1597;
      end

       1597 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1600;
      end

       1598 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1599;
      end

       1599 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[615] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1600;
      end

       1600 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1601;
      end

       1601 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[615] != 0 ? 1603 : 1602;
      end

       1602 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[499] = localMem[614];
              updateArrayLength(2, 0, 0);
              ip = 1603;
      end

       1603 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1604;
      end

       1604 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1854;
      end

       1605 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1606;
      end

       1606 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[722] = heapMem[localMem[499]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1607;
      end

       1607 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[723] = 0; k = arraySizes[localMem[722]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[722] * NArea + i] == 2) localMem[723] = i + 1;
              end
              ip = 1608;
      end

       1608 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[723] == 0 ? 1613 : 1609;
      end

       1609 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[476]*7 + 0] = localMem[499];
              updateArrayLength(1, localMem[476], 0);
              ip = 1610;
      end

       1610 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[476]*7 + 1] = 1;
              updateArrayLength(1, localMem[476], 1);
              ip = 1611;
      end

       1611 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              heapMem[localMem[476]*7 + 2] = localMem[723] - 1;
              updateArrayLength(1, localMem[476], 2);
              ip = 1612;
      end

       1612 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1861;
      end

       1613 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1614;
      end

       1614 :
      begin                                                                     // arrayCountLess
if (0) begin
  $display("AAAA %4d %4d arrayCountLess", steps, ip);
end
              j = 0; k = arraySizes[localMem[722]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[722] * NArea + i] < 2) j = j + 1;
              end
              localMem[724] = j;
              ip = 1615;
      end

       1615 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[725] = !heapMem[localMem[499]*7 + 6];
              ip = 1616;
      end

       1616 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[725] == 0 ? 1621 : 1617;
      end

       1617 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[476]*7 + 0] = localMem[499];
              updateArrayLength(1, localMem[476], 0);
              ip = 1618;
      end

       1618 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[476]*7 + 1] = 0;
              updateArrayLength(1, localMem[476], 1);
              ip = 1619;
      end

       1619 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[476]*7 + 2] = localMem[724];
              updateArrayLength(1, localMem[476], 2);
              ip = 1620;
      end

       1620 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1861;
      end

       1621 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1622;
      end

       1622 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[726] = heapMem[localMem[499]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1623;
      end

       1623 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[727] = heapMem[localMem[726]*7 + localMem[724]];
              updateArrayLength(2, 0, 0);
              ip = 1624;
      end

       1624 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1625;
      end

       1625 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[729] = heapMem[localMem[727]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1626;
      end

       1626 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[730] = heapMem[localMem[727]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 1627;
      end

       1627 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[731] = heapMem[localMem[730]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1628;
      end

       1628 :
      begin                                                                     // jLt
if (0) begin
  $display("AAAA %4d %4d jLt", steps, ip);
end
              ip = localMem[729] <  localMem[731] ? 1848 : 1629;
      end

       1629 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[732] = localMem[731];
              updateArrayLength(2, 0, 0);
              ip = 1630;
      end

       1630 :
      begin                                                                     // shiftRight
if (0) begin
  $display("AAAA %4d %4d shiftRight", steps, ip);
end
              localMem[732] = localMem[732] >> 1;
              ip = 1631;
      end

       1631 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[733] = localMem[732] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1632;
      end

       1632 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[734] = heapMem[localMem[727]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1633;
      end

       1633 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[734] == 0 ? 1730 : 1634;
      end

       1634 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[735] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[735] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[735]] = 0;
              ip = 1635;
      end

       1635 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[735]*7 + 0] = localMem[732];
              updateArrayLength(1, localMem[735], 0);
              ip = 1636;
      end

       1636 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[735]*7 + 2] = 0;
              updateArrayLength(1, localMem[735], 2);
              ip = 1637;
      end

       1637 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[736] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[736] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[736]] = 0;
              ip = 1638;
      end

       1638 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[735]*7 + 4] = localMem[736];
              updateArrayLength(1, localMem[735], 4);
              ip = 1639;
      end

       1639 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[737] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[737] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[737]] = 0;
              ip = 1640;
      end

       1640 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[735]*7 + 5] = localMem[737];
              updateArrayLength(1, localMem[735], 5);
              ip = 1641;
      end

       1641 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[735]*7 + 6] = 0;
              updateArrayLength(1, localMem[735], 6);
              ip = 1642;
      end

       1642 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[735]*7 + 3] = localMem[730];
              updateArrayLength(1, localMem[735], 3);
              ip = 1643;
      end

       1643 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[730]*7 + 1] = heapMem[localMem[730]*7 + 1] + 1;
              updateArrayLength(1, localMem[730], 1);
              ip = 1644;
      end

       1644 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[735]*7 + 1] = heapMem[localMem[730]*7 + 1];
              updateArrayLength(1, localMem[735], 1);
              ip = 1645;
      end

       1645 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[738] = !heapMem[localMem[727]*7 + 6];
              ip = 1646;
      end

       1646 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[738] != 0 ? 1675 : 1647;
      end

       1647 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[739] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[739] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[739]] = 0;
              ip = 1648;
      end

       1648 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[735]*7 + 6] = localMem[739];
              updateArrayLength(1, localMem[735], 6);
              ip = 1649;
      end

       1649 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[740] = heapMem[localMem[727]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1650;
      end

       1650 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[741] = heapMem[localMem[735]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1651;
      end

       1651 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[732]) begin
                  heapMem[NArea * localMem[741] + 0 + i] = heapMem[NArea * localMem[740] + localMem[733] + i];
                  updateArrayLength(1, localMem[741], 0 + i);
                end
              end
              ip = 1652;
      end

       1652 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[742] = heapMem[localMem[727]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1653;
      end

       1653 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[743] = heapMem[localMem[735]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1654;
      end

       1654 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[732]) begin
                  heapMem[NArea * localMem[743] + 0 + i] = heapMem[NArea * localMem[742] + localMem[733] + i];
                  updateArrayLength(1, localMem[743], 0 + i);
                end
              end
              ip = 1655;
      end

       1655 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[744] = heapMem[localMem[727]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1656;
      end

       1656 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[745] = heapMem[localMem[735]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1657;
      end

       1657 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[746] = localMem[732] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1658;
      end

       1658 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[746]) begin
                  heapMem[NArea * localMem[745] + 0 + i] = heapMem[NArea * localMem[744] + localMem[733] + i];
                  updateArrayLength(1, localMem[745], 0 + i);
                end
              end
              ip = 1659;
      end

       1659 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[747] = heapMem[localMem[735]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1660;
      end

       1660 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[748] = localMem[747] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1661;
      end

       1661 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[749] = heapMem[localMem[735]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1662;
      end

       1662 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1663;
      end

       1663 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[750] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1664;
      end

       1664 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1665;
      end

       1665 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[750] >= localMem[748] ? 1671 : 1666;
      end

       1666 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[751] = heapMem[localMem[749]*7 + localMem[750]];
              updateArrayLength(2, 0, 0);
              ip = 1667;
      end

       1667 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[751]*7 + 2] = localMem[735];
              updateArrayLength(1, localMem[751], 2);
              ip = 1668;
      end

       1668 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1669;
      end

       1669 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[750] = localMem[750] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1670;
      end

       1670 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1664;
      end

       1671 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1672;
      end

       1672 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[752] = heapMem[localMem[727]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1673;
      end

       1673 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[752]] = localMem[733];
              ip = 1674;
      end

       1674 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1682;
      end

       1675 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1676;
      end

       1676 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[753] = heapMem[localMem[727]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1677;
      end

       1677 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[754] = heapMem[localMem[735]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1678;
      end

       1678 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[732]) begin
                  heapMem[NArea * localMem[754] + 0 + i] = heapMem[NArea * localMem[753] + localMem[733] + i];
                  updateArrayLength(1, localMem[754], 0 + i);
                end
              end
              ip = 1679;
      end

       1679 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[755] = heapMem[localMem[727]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1680;
      end

       1680 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[756] = heapMem[localMem[735]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1681;
      end

       1681 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[732]) begin
                  heapMem[NArea * localMem[756] + 0 + i] = heapMem[NArea * localMem[755] + localMem[733] + i];
                  updateArrayLength(1, localMem[756], 0 + i);
                end
              end
              ip = 1682;
      end

       1682 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1683;
      end

       1683 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[727]*7 + 0] = localMem[732];
              updateArrayLength(1, localMem[727], 0);
              ip = 1684;
      end

       1684 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[735]*7 + 2] = localMem[734];
              updateArrayLength(1, localMem[735], 2);
              ip = 1685;
      end

       1685 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[757] = heapMem[localMem[734]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1686;
      end

       1686 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[758] = heapMem[localMem[734]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1687;
      end

       1687 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[759] = heapMem[localMem[758]*7 + localMem[757]];
              updateArrayLength(2, 0, 0);
              ip = 1688;
      end

       1688 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[759] != localMem[727] ? 1707 : 1689;
      end

       1689 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[760] = heapMem[localMem[727]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1690;
      end

       1690 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[761] = heapMem[localMem[760]*7 + localMem[732]];
              updateArrayLength(2, 0, 0);
              ip = 1691;
      end

       1691 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[762] = heapMem[localMem[734]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1692;
      end

       1692 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[762]*7 + localMem[757]] = localMem[761];
              updateArrayLength(1, localMem[762], localMem[757]);
              ip = 1693;
      end

       1693 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[763] = heapMem[localMem[727]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1694;
      end

       1694 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[764] = heapMem[localMem[763]*7 + localMem[732]];
              updateArrayLength(2, 0, 0);
              ip = 1695;
      end

       1695 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[765] = heapMem[localMem[734]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1696;
      end

       1696 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[765]*7 + localMem[757]] = localMem[764];
              updateArrayLength(1, localMem[765], localMem[757]);
              ip = 1697;
      end

       1697 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[766] = heapMem[localMem[727]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1698;
      end

       1698 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[766]] = localMem[732];
              ip = 1699;
      end

       1699 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[767] = heapMem[localMem[727]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1700;
      end

       1700 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[767]] = localMem[732];
              ip = 1701;
      end

       1701 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[768] = localMem[757] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1702;
      end

       1702 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[734]*7 + 0] = localMem[768];
              updateArrayLength(1, localMem[734], 0);
              ip = 1703;
      end

       1703 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[769] = heapMem[localMem[734]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1704;
      end

       1704 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[769]*7 + localMem[768]] = localMem[735];
              updateArrayLength(1, localMem[769], localMem[768]);
              ip = 1705;
      end

       1705 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1845;
      end

       1706 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1729;
      end

       1707 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1708;
      end

       1708 :
      begin                                                                     // assertNe
if (0) begin
  $display("AAAA %4d %4d assertNe", steps, ip);
end
            ip = 1709;
      end

       1709 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[770] = heapMem[localMem[734]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1710;
      end

       1710 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[771] = 0; k = arraySizes[localMem[770]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[770] * NArea + i] == localMem[727]) localMem[771] = i + 1;
              end
              ip = 1711;
      end

       1711 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[771] = localMem[771] - 1;
              updateArrayLength(2, 0, 0);
              ip = 1712;
      end

       1712 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[772] = heapMem[localMem[727]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1713;
      end

       1713 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[773] = heapMem[localMem[772]*7 + localMem[732]];
              updateArrayLength(2, 0, 0);
              ip = 1714;
      end

       1714 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[774] = heapMem[localMem[727]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1715;
      end

       1715 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[775] = heapMem[localMem[774]*7 + localMem[732]];
              updateArrayLength(2, 0, 0);
              ip = 1716;
      end

       1716 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[776] = heapMem[localMem[727]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1717;
      end

       1717 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[776]] = localMem[732];
              ip = 1718;
      end

       1718 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[777] = heapMem[localMem[727]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1719;
      end

       1719 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[777]] = localMem[732];
              ip = 1720;
      end

       1720 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[778] = heapMem[localMem[734]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1721;
      end

       1721 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[778] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[771], localMem[778], arraySizes[localMem[778]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[771] && i <= arraySizes[localMem[778]]) begin
                  heapMem[NArea * localMem[778] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[778] + localMem[771]] = localMem[773];                                    // Insert new value
              arraySizes[localMem[778]] = arraySizes[localMem[778]] + 1;                              // Increase array size
              ip = 1722;
      end

       1722 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[779] = heapMem[localMem[734]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1723;
      end

       1723 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[779] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[771], localMem[779], arraySizes[localMem[779]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[771] && i <= arraySizes[localMem[779]]) begin
                  heapMem[NArea * localMem[779] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[779] + localMem[771]] = localMem[775];                                    // Insert new value
              arraySizes[localMem[779]] = arraySizes[localMem[779]] + 1;                              // Increase array size
              ip = 1724;
      end

       1724 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[780] = heapMem[localMem[734]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1725;
      end

       1725 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[781] = localMem[771] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1726;
      end

       1726 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[780] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[781], localMem[780], arraySizes[localMem[780]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[781] && i <= arraySizes[localMem[780]]) begin
                  heapMem[NArea * localMem[780] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[780] + localMem[781]] = localMem[735];                                    // Insert new value
              arraySizes[localMem[780]] = arraySizes[localMem[780]] + 1;                              // Increase array size
              ip = 1727;
      end

       1727 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[734]*7 + 0] = heapMem[localMem[734]*7 + 0] + 1;
              updateArrayLength(1, localMem[734], 0);
              ip = 1728;
      end

       1728 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1845;
      end

       1729 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1730;
      end

       1730 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1731;
      end

       1731 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[782] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[782] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[782]] = 0;
              ip = 1732;
      end

       1732 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[782]*7 + 0] = localMem[732];
              updateArrayLength(1, localMem[782], 0);
              ip = 1733;
      end

       1733 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[782]*7 + 2] = 0;
              updateArrayLength(1, localMem[782], 2);
              ip = 1734;
      end

       1734 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[783] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[783] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[783]] = 0;
              ip = 1735;
      end

       1735 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[782]*7 + 4] = localMem[783];
              updateArrayLength(1, localMem[782], 4);
              ip = 1736;
      end

       1736 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[784] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[784] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[784]] = 0;
              ip = 1737;
      end

       1737 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[782]*7 + 5] = localMem[784];
              updateArrayLength(1, localMem[782], 5);
              ip = 1738;
      end

       1738 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[782]*7 + 6] = 0;
              updateArrayLength(1, localMem[782], 6);
              ip = 1739;
      end

       1739 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[782]*7 + 3] = localMem[730];
              updateArrayLength(1, localMem[782], 3);
              ip = 1740;
      end

       1740 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[730]*7 + 1] = heapMem[localMem[730]*7 + 1] + 1;
              updateArrayLength(1, localMem[730], 1);
              ip = 1741;
      end

       1741 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[782]*7 + 1] = heapMem[localMem[730]*7 + 1];
              updateArrayLength(1, localMem[782], 1);
              ip = 1742;
      end

       1742 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[785] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[785] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[785]] = 0;
              ip = 1743;
      end

       1743 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[785]*7 + 0] = localMem[732];
              updateArrayLength(1, localMem[785], 0);
              ip = 1744;
      end

       1744 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[785]*7 + 2] = 0;
              updateArrayLength(1, localMem[785], 2);
              ip = 1745;
      end

       1745 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[786] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[786] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[786]] = 0;
              ip = 1746;
      end

       1746 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[785]*7 + 4] = localMem[786];
              updateArrayLength(1, localMem[785], 4);
              ip = 1747;
      end

       1747 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[787] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[787] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[787]] = 0;
              ip = 1748;
      end

       1748 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[785]*7 + 5] = localMem[787];
              updateArrayLength(1, localMem[785], 5);
              ip = 1749;
      end

       1749 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[785]*7 + 6] = 0;
              updateArrayLength(1, localMem[785], 6);
              ip = 1750;
      end

       1750 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[785]*7 + 3] = localMem[730];
              updateArrayLength(1, localMem[785], 3);
              ip = 1751;
      end

       1751 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[730]*7 + 1] = heapMem[localMem[730]*7 + 1] + 1;
              updateArrayLength(1, localMem[730], 1);
              ip = 1752;
      end

       1752 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[785]*7 + 1] = heapMem[localMem[730]*7 + 1];
              updateArrayLength(1, localMem[785], 1);
              ip = 1753;
      end

       1753 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[788] = !heapMem[localMem[727]*7 + 6];
              ip = 1754;
      end

       1754 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[788] != 0 ? 1806 : 1755;
      end

       1755 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[789] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[789] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[789]] = 0;
              ip = 1756;
      end

       1756 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[782]*7 + 6] = localMem[789];
              updateArrayLength(1, localMem[782], 6);
              ip = 1757;
      end

       1757 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[790] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[790] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[790]] = 0;
              ip = 1758;
      end

       1758 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[785]*7 + 6] = localMem[790];
              updateArrayLength(1, localMem[785], 6);
              ip = 1759;
      end

       1759 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[791] = heapMem[localMem[727]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1760;
      end

       1760 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[792] = heapMem[localMem[782]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1761;
      end

       1761 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[732]) begin
                  heapMem[NArea * localMem[792] + 0 + i] = heapMem[NArea * localMem[791] + 0 + i];
                  updateArrayLength(1, localMem[792], 0 + i);
                end
              end
              ip = 1762;
      end

       1762 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[793] = heapMem[localMem[727]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1763;
      end

       1763 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[794] = heapMem[localMem[782]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1764;
      end

       1764 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[732]) begin
                  heapMem[NArea * localMem[794] + 0 + i] = heapMem[NArea * localMem[793] + 0 + i];
                  updateArrayLength(1, localMem[794], 0 + i);
                end
              end
              ip = 1765;
      end

       1765 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[795] = heapMem[localMem[727]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1766;
      end

       1766 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[796] = heapMem[localMem[782]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1767;
      end

       1767 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[797] = localMem[732] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1768;
      end

       1768 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[797]) begin
                  heapMem[NArea * localMem[796] + 0 + i] = heapMem[NArea * localMem[795] + 0 + i];
                  updateArrayLength(1, localMem[796], 0 + i);
                end
              end
              ip = 1769;
      end

       1769 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[798] = heapMem[localMem[727]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1770;
      end

       1770 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[799] = heapMem[localMem[785]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1771;
      end

       1771 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[732]) begin
                  heapMem[NArea * localMem[799] + 0 + i] = heapMem[NArea * localMem[798] + localMem[733] + i];
                  updateArrayLength(1, localMem[799], 0 + i);
                end
              end
              ip = 1772;
      end

       1772 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[800] = heapMem[localMem[727]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1773;
      end

       1773 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[801] = heapMem[localMem[785]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1774;
      end

       1774 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[732]) begin
                  heapMem[NArea * localMem[801] + 0 + i] = heapMem[NArea * localMem[800] + localMem[733] + i];
                  updateArrayLength(1, localMem[801], 0 + i);
                end
              end
              ip = 1775;
      end

       1775 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[802] = heapMem[localMem[727]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1776;
      end

       1776 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[803] = heapMem[localMem[785]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1777;
      end

       1777 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[804] = localMem[732] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1778;
      end

       1778 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[804]) begin
                  heapMem[NArea * localMem[803] + 0 + i] = heapMem[NArea * localMem[802] + localMem[733] + i];
                  updateArrayLength(1, localMem[803], 0 + i);
                end
              end
              ip = 1779;
      end

       1779 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[805] = heapMem[localMem[782]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1780;
      end

       1780 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[806] = localMem[805] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1781;
      end

       1781 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[807] = heapMem[localMem[782]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1782;
      end

       1782 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1783;
      end

       1783 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[808] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1784;
      end

       1784 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1785;
      end

       1785 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[808] >= localMem[806] ? 1791 : 1786;
      end

       1786 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[809] = heapMem[localMem[807]*7 + localMem[808]];
              updateArrayLength(2, 0, 0);
              ip = 1787;
      end

       1787 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[809]*7 + 2] = localMem[782];
              updateArrayLength(1, localMem[809], 2);
              ip = 1788;
      end

       1788 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1789;
      end

       1789 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[808] = localMem[808] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1790;
      end

       1790 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1784;
      end

       1791 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1792;
      end

       1792 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[810] = heapMem[localMem[785]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1793;
      end

       1793 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[811] = localMem[810] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1794;
      end

       1794 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[812] = heapMem[localMem[785]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1795;
      end

       1795 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1796;
      end

       1796 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[813] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1797;
      end

       1797 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1798;
      end

       1798 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[813] >= localMem[811] ? 1804 : 1799;
      end

       1799 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[814] = heapMem[localMem[812]*7 + localMem[813]];
              updateArrayLength(2, 0, 0);
              ip = 1800;
      end

       1800 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[814]*7 + 2] = localMem[785];
              updateArrayLength(1, localMem[814], 2);
              ip = 1801;
      end

       1801 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1802;
      end

       1802 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[813] = localMem[813] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1803;
      end

       1803 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1797;
      end

       1804 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1805;
      end

       1805 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1821;
      end

       1806 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1807;
      end

       1807 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[815] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[815] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[815]] = 0;
              ip = 1808;
      end

       1808 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[727]*7 + 6] = localMem[815];
              updateArrayLength(1, localMem[727], 6);
              ip = 1809;
      end

       1809 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[816] = heapMem[localMem[727]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1810;
      end

       1810 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[817] = heapMem[localMem[782]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1811;
      end

       1811 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[732]) begin
                  heapMem[NArea * localMem[817] + 0 + i] = heapMem[NArea * localMem[816] + 0 + i];
                  updateArrayLength(1, localMem[817], 0 + i);
                end
              end
              ip = 1812;
      end

       1812 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[818] = heapMem[localMem[727]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1813;
      end

       1813 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[819] = heapMem[localMem[782]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1814;
      end

       1814 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[732]) begin
                  heapMem[NArea * localMem[819] + 0 + i] = heapMem[NArea * localMem[818] + 0 + i];
                  updateArrayLength(1, localMem[819], 0 + i);
                end
              end
              ip = 1815;
      end

       1815 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[820] = heapMem[localMem[727]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1816;
      end

       1816 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[821] = heapMem[localMem[785]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1817;
      end

       1817 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[732]) begin
                  heapMem[NArea * localMem[821] + 0 + i] = heapMem[NArea * localMem[820] + localMem[733] + i];
                  updateArrayLength(1, localMem[821], 0 + i);
                end
              end
              ip = 1818;
      end

       1818 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[822] = heapMem[localMem[727]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1819;
      end

       1819 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[823] = heapMem[localMem[785]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1820;
      end

       1820 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[732]) begin
                  heapMem[NArea * localMem[823] + 0 + i] = heapMem[NArea * localMem[822] + localMem[733] + i];
                  updateArrayLength(1, localMem[823], 0 + i);
                end
              end
              ip = 1821;
      end

       1821 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1822;
      end

       1822 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[782]*7 + 2] = localMem[727];
              updateArrayLength(1, localMem[782], 2);
              ip = 1823;
      end

       1823 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[785]*7 + 2] = localMem[727];
              updateArrayLength(1, localMem[785], 2);
              ip = 1824;
      end

       1824 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[824] = heapMem[localMem[727]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1825;
      end

       1825 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[825] = heapMem[localMem[824]*7 + localMem[732]];
              updateArrayLength(2, 0, 0);
              ip = 1826;
      end

       1826 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[826] = heapMem[localMem[727]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1827;
      end

       1827 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[827] = heapMem[localMem[826]*7 + localMem[732]];
              updateArrayLength(2, 0, 0);
              ip = 1828;
      end

       1828 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[828] = heapMem[localMem[727]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1829;
      end

       1829 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[828]*7 + 0] = localMem[825];
              updateArrayLength(1, localMem[828], 0);
              ip = 1830;
      end

       1830 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[829] = heapMem[localMem[727]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1831;
      end

       1831 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[829]*7 + 0] = localMem[827];
              updateArrayLength(1, localMem[829], 0);
              ip = 1832;
      end

       1832 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[830] = heapMem[localMem[727]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1833;
      end

       1833 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[830]*7 + 0] = localMem[782];
              updateArrayLength(1, localMem[830], 0);
              ip = 1834;
      end

       1834 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[831] = heapMem[localMem[727]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1835;
      end

       1835 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[831]*7 + 1] = localMem[785];
              updateArrayLength(1, localMem[831], 1);
              ip = 1836;
      end

       1836 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[727]*7 + 0] = 1;
              updateArrayLength(1, localMem[727], 0);
              ip = 1837;
      end

       1837 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[832] = heapMem[localMem[727]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1838;
      end

       1838 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[832]] = 1;
              ip = 1839;
      end

       1839 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[833] = heapMem[localMem[727]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1840;
      end

       1840 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[833]] = 1;
              ip = 1841;
      end

       1841 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[834] = heapMem[localMem[727]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1842;
      end

       1842 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[834]] = 2;
              ip = 1843;
      end

       1843 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1845;
      end

       1844 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1850;
      end

       1845 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1846;
      end

       1846 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[728] = 1;
              updateArrayLength(2, 0, 0);
              ip = 1847;
      end

       1847 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1850;
      end

       1848 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1849;
      end

       1849 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[728] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1850;
      end

       1850 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1851;
      end

       1851 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[728] != 0 ? 1853 : 1852;
      end

       1852 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[499] = localMem[727];
              updateArrayLength(2, 0, 0);
              ip = 1853;
      end

       1853 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1854;
      end

       1854 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1855;
      end

       1855 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[607] = localMem[607] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1856;
      end

       1856 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1358;
      end

       1857 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1858;
      end

       1858 :
      begin                                                                     // assert
if (0) begin
  $display("AAAA %4d %4d assert", steps, ip);
end
            ip = 1859;
      end

       1859 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1860;
      end

       1860 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1861;
      end

       1861 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1862;
      end

       1862 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[835] = heapMem[localMem[476]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1863;
      end

       1863 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[836] = heapMem[localMem[476]*7 + 1];
              updateArrayLength(2, 0, 0);
              ip = 1864;
      end

       1864 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[837] = heapMem[localMem[476]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1865;
      end

       1865 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[836] != 1 ? 1869 : 1866;
      end

       1866 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[838] = heapMem[localMem[835]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1867;
      end

       1867 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[838]*7 + localMem[837]] = 22;
              updateArrayLength(1, localMem[838], localMem[837]);
              ip = 1868;
      end

       1868 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 2115;
      end

       1869 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1870;
      end

       1870 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[836] != 2 ? 1878 : 1871;
      end

       1871 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[839] = localMem[837] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1872;
      end

       1872 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[840] = heapMem[localMem[835]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1873;
      end

       1873 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[840] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[839], localMem[840], arraySizes[localMem[840]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[839] && i <= arraySizes[localMem[840]]) begin
                  heapMem[NArea * localMem[840] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[840] + localMem[839]] = 2;                                    // Insert new value
              arraySizes[localMem[840]] = arraySizes[localMem[840]] + 1;                              // Increase array size
              ip = 1874;
      end

       1874 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[841] = heapMem[localMem[835]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1875;
      end

       1875 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[841] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[839], localMem[841], arraySizes[localMem[841]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[839] && i <= arraySizes[localMem[841]]) begin
                  heapMem[NArea * localMem[841] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[841] + localMem[839]] = 22;                                    // Insert new value
              arraySizes[localMem[841]] = arraySizes[localMem[841]] + 1;                              // Increase array size
              ip = 1876;
      end

       1876 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[835]*7 + 0] = heapMem[localMem[835]*7 + 0] + 1;
              updateArrayLength(1, localMem[835], 0);
              ip = 1877;
      end

       1877 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1884;
      end

       1878 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1879;
      end

       1879 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[842] = heapMem[localMem[835]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1880;
      end

       1880 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[842] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[837], localMem[842], arraySizes[localMem[842]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[837] && i <= arraySizes[localMem[842]]) begin
                  heapMem[NArea * localMem[842] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[842] + localMem[837]] = 2;                                    // Insert new value
              arraySizes[localMem[842]] = arraySizes[localMem[842]] + 1;                              // Increase array size
              ip = 1881;
      end

       1881 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[843] = heapMem[localMem[835]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1882;
      end

       1882 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[843] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[837], localMem[843], arraySizes[localMem[843]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[837] && i <= arraySizes[localMem[843]]) begin
                  heapMem[NArea * localMem[843] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[843] + localMem[837]] = 22;                                    // Insert new value
              arraySizes[localMem[843]] = arraySizes[localMem[843]] + 1;                              // Increase array size
              ip = 1883;
      end

       1883 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[835]*7 + 0] = heapMem[localMem[835]*7 + 0] + 1;
              updateArrayLength(1, localMem[835], 0);
              ip = 1884;
      end

       1884 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1885;
      end

       1885 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[0]*7 + 0] = heapMem[localMem[0]*7 + 0] + 1;
              updateArrayLength(1, localMem[0], 0);
              ip = 1886;
      end

       1886 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1887;
      end

       1887 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[845] = heapMem[localMem[835]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1888;
      end

       1888 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[846] = heapMem[localMem[835]*7 + 3];
              updateArrayLength(2, 0, 0);
              ip = 1889;
      end

       1889 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[847] = heapMem[localMem[846]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1890;
      end

       1890 :
      begin                                                                     // jLt
if (0) begin
  $display("AAAA %4d %4d jLt", steps, ip);
end
              ip = localMem[845] <  localMem[847] ? 2110 : 1891;
      end

       1891 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[848] = localMem[847];
              updateArrayLength(2, 0, 0);
              ip = 1892;
      end

       1892 :
      begin                                                                     // shiftRight
if (0) begin
  $display("AAAA %4d %4d shiftRight", steps, ip);
end
              localMem[848] = localMem[848] >> 1;
              ip = 1893;
      end

       1893 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[849] = localMem[848] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1894;
      end

       1894 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[850] = heapMem[localMem[835]*7 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1895;
      end

       1895 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[850] == 0 ? 1992 : 1896;
      end

       1896 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[851] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[851] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[851]] = 0;
              ip = 1897;
      end

       1897 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[851]*7 + 0] = localMem[848];
              updateArrayLength(1, localMem[851], 0);
              ip = 1898;
      end

       1898 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[851]*7 + 2] = 0;
              updateArrayLength(1, localMem[851], 2);
              ip = 1899;
      end

       1899 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[852] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[852] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[852]] = 0;
              ip = 1900;
      end

       1900 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[851]*7 + 4] = localMem[852];
              updateArrayLength(1, localMem[851], 4);
              ip = 1901;
      end

       1901 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[853] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[853] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[853]] = 0;
              ip = 1902;
      end

       1902 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[851]*7 + 5] = localMem[853];
              updateArrayLength(1, localMem[851], 5);
              ip = 1903;
      end

       1903 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[851]*7 + 6] = 0;
              updateArrayLength(1, localMem[851], 6);
              ip = 1904;
      end

       1904 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[851]*7 + 3] = localMem[846];
              updateArrayLength(1, localMem[851], 3);
              ip = 1905;
      end

       1905 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[846]*7 + 1] = heapMem[localMem[846]*7 + 1] + 1;
              updateArrayLength(1, localMem[846], 1);
              ip = 1906;
      end

       1906 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[851]*7 + 1] = heapMem[localMem[846]*7 + 1];
              updateArrayLength(1, localMem[851], 1);
              ip = 1907;
      end

       1907 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[854] = !heapMem[localMem[835]*7 + 6];
              ip = 1908;
      end

       1908 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[854] != 0 ? 1937 : 1909;
      end

       1909 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[855] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[855] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[855]] = 0;
              ip = 1910;
      end

       1910 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[851]*7 + 6] = localMem[855];
              updateArrayLength(1, localMem[851], 6);
              ip = 1911;
      end

       1911 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[856] = heapMem[localMem[835]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1912;
      end

       1912 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[857] = heapMem[localMem[851]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1913;
      end

       1913 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[848]) begin
                  heapMem[NArea * localMem[857] + 0 + i] = heapMem[NArea * localMem[856] + localMem[849] + i];
                  updateArrayLength(1, localMem[857], 0 + i);
                end
              end
              ip = 1914;
      end

       1914 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[858] = heapMem[localMem[835]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1915;
      end

       1915 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[859] = heapMem[localMem[851]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1916;
      end

       1916 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[848]) begin
                  heapMem[NArea * localMem[859] + 0 + i] = heapMem[NArea * localMem[858] + localMem[849] + i];
                  updateArrayLength(1, localMem[859], 0 + i);
                end
              end
              ip = 1917;
      end

       1917 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[860] = heapMem[localMem[835]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1918;
      end

       1918 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[861] = heapMem[localMem[851]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1919;
      end

       1919 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[862] = localMem[848] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1920;
      end

       1920 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[862]) begin
                  heapMem[NArea * localMem[861] + 0 + i] = heapMem[NArea * localMem[860] + localMem[849] + i];
                  updateArrayLength(1, localMem[861], 0 + i);
                end
              end
              ip = 1921;
      end

       1921 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[863] = heapMem[localMem[851]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1922;
      end

       1922 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[864] = localMem[863] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1923;
      end

       1923 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[865] = heapMem[localMem[851]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1924;
      end

       1924 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1925;
      end

       1925 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[866] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1926;
      end

       1926 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1927;
      end

       1927 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[866] >= localMem[864] ? 1933 : 1928;
      end

       1928 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[867] = heapMem[localMem[865]*7 + localMem[866]];
              updateArrayLength(2, 0, 0);
              ip = 1929;
      end

       1929 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[867]*7 + 2] = localMem[851];
              updateArrayLength(1, localMem[867], 2);
              ip = 1930;
      end

       1930 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1931;
      end

       1931 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[866] = localMem[866] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1932;
      end

       1932 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1926;
      end

       1933 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1934;
      end

       1934 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[868] = heapMem[localMem[835]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1935;
      end

       1935 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[868]] = localMem[849];
              ip = 1936;
      end

       1936 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1944;
      end

       1937 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1938;
      end

       1938 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[869] = heapMem[localMem[835]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1939;
      end

       1939 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[870] = heapMem[localMem[851]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1940;
      end

       1940 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[848]) begin
                  heapMem[NArea * localMem[870] + 0 + i] = heapMem[NArea * localMem[869] + localMem[849] + i];
                  updateArrayLength(1, localMem[870], 0 + i);
                end
              end
              ip = 1941;
      end

       1941 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[871] = heapMem[localMem[835]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1942;
      end

       1942 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[872] = heapMem[localMem[851]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1943;
      end

       1943 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[848]) begin
                  heapMem[NArea * localMem[872] + 0 + i] = heapMem[NArea * localMem[871] + localMem[849] + i];
                  updateArrayLength(1, localMem[872], 0 + i);
                end
              end
              ip = 1944;
      end

       1944 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1945;
      end

       1945 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[835]*7 + 0] = localMem[848];
              updateArrayLength(1, localMem[835], 0);
              ip = 1946;
      end

       1946 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[851]*7 + 2] = localMem[850];
              updateArrayLength(1, localMem[851], 2);
              ip = 1947;
      end

       1947 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[873] = heapMem[localMem[850]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1948;
      end

       1948 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[874] = heapMem[localMem[850]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1949;
      end

       1949 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[875] = heapMem[localMem[874]*7 + localMem[873]];
              updateArrayLength(2, 0, 0);
              ip = 1950;
      end

       1950 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[875] != localMem[835] ? 1969 : 1951;
      end

       1951 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[876] = heapMem[localMem[835]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1952;
      end

       1952 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[877] = heapMem[localMem[876]*7 + localMem[848]];
              updateArrayLength(2, 0, 0);
              ip = 1953;
      end

       1953 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[878] = heapMem[localMem[850]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1954;
      end

       1954 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[878]*7 + localMem[873]] = localMem[877];
              updateArrayLength(1, localMem[878], localMem[873]);
              ip = 1955;
      end

       1955 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[879] = heapMem[localMem[835]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1956;
      end

       1956 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[880] = heapMem[localMem[879]*7 + localMem[848]];
              updateArrayLength(2, 0, 0);
              ip = 1957;
      end

       1957 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[881] = heapMem[localMem[850]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1958;
      end

       1958 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[881]*7 + localMem[873]] = localMem[880];
              updateArrayLength(1, localMem[881], localMem[873]);
              ip = 1959;
      end

       1959 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[882] = heapMem[localMem[835]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1960;
      end

       1960 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[882]] = localMem[848];
              ip = 1961;
      end

       1961 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[883] = heapMem[localMem[835]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1962;
      end

       1962 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[883]] = localMem[848];
              ip = 1963;
      end

       1963 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[884] = localMem[873] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1964;
      end

       1964 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[850]*7 + 0] = localMem[884];
              updateArrayLength(1, localMem[850], 0);
              ip = 1965;
      end

       1965 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[885] = heapMem[localMem[850]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1966;
      end

       1966 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[885]*7 + localMem[884]] = localMem[851];
              updateArrayLength(1, localMem[885], localMem[884]);
              ip = 1967;
      end

       1967 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 2107;
      end

       1968 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1991;
      end

       1969 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1970;
      end

       1970 :
      begin                                                                     // assertNe
if (0) begin
  $display("AAAA %4d %4d assertNe", steps, ip);
end
            ip = 1971;
      end

       1971 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[886] = heapMem[localMem[850]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1972;
      end

       1972 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[887] = 0; k = arraySizes[localMem[886]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[886] * NArea + i] == localMem[835]) localMem[887] = i + 1;
              end
              ip = 1973;
      end

       1973 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[887] = localMem[887] - 1;
              updateArrayLength(2, 0, 0);
              ip = 1974;
      end

       1974 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[888] = heapMem[localMem[835]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1975;
      end

       1975 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[889] = heapMem[localMem[888]*7 + localMem[848]];
              updateArrayLength(2, 0, 0);
              ip = 1976;
      end

       1976 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[890] = heapMem[localMem[835]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1977;
      end

       1977 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[891] = heapMem[localMem[890]*7 + localMem[848]];
              updateArrayLength(2, 0, 0);
              ip = 1978;
      end

       1978 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[892] = heapMem[localMem[835]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1979;
      end

       1979 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[892]] = localMem[848];
              ip = 1980;
      end

       1980 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[893] = heapMem[localMem[835]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1981;
      end

       1981 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[893]] = localMem[848];
              ip = 1982;
      end

       1982 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[894] = heapMem[localMem[850]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1983;
      end

       1983 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[894] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[887], localMem[894], arraySizes[localMem[894]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[887] && i <= arraySizes[localMem[894]]) begin
                  heapMem[NArea * localMem[894] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[894] + localMem[887]] = localMem[889];                                    // Insert new value
              arraySizes[localMem[894]] = arraySizes[localMem[894]] + 1;                              // Increase array size
              ip = 1984;
      end

       1984 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[895] = heapMem[localMem[850]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1985;
      end

       1985 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[895] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[887], localMem[895], arraySizes[localMem[895]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[887] && i <= arraySizes[localMem[895]]) begin
                  heapMem[NArea * localMem[895] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[895] + localMem[887]] = localMem[891];                                    // Insert new value
              arraySizes[localMem[895]] = arraySizes[localMem[895]] + 1;                              // Increase array size
              ip = 1986;
      end

       1986 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[896] = heapMem[localMem[850]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1987;
      end

       1987 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[897] = localMem[887] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1988;
      end

       1988 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[896] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[897], localMem[896], arraySizes[localMem[896]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[897] && i <= arraySizes[localMem[896]]) begin
                  heapMem[NArea * localMem[896] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[896] + localMem[897]] = localMem[851];                                    // Insert new value
              arraySizes[localMem[896]] = arraySizes[localMem[896]] + 1;                              // Increase array size
              ip = 1989;
      end

       1989 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[850]*7 + 0] = heapMem[localMem[850]*7 + 0] + 1;
              updateArrayLength(1, localMem[850], 0);
              ip = 1990;
      end

       1990 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 2107;
      end

       1991 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1992;
      end

       1992 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1993;
      end

       1993 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[898] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[898] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[898]] = 0;
              ip = 1994;
      end

       1994 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[898]*7 + 0] = localMem[848];
              updateArrayLength(1, localMem[898], 0);
              ip = 1995;
      end

       1995 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[898]*7 + 2] = 0;
              updateArrayLength(1, localMem[898], 2);
              ip = 1996;
      end

       1996 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[899] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[899] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[899]] = 0;
              ip = 1997;
      end

       1997 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[898]*7 + 4] = localMem[899];
              updateArrayLength(1, localMem[898], 4);
              ip = 1998;
      end

       1998 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[900] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[900] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[900]] = 0;
              ip = 1999;
      end

       1999 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[898]*7 + 5] = localMem[900];
              updateArrayLength(1, localMem[898], 5);
              ip = 2000;
      end

       2000 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[898]*7 + 6] = 0;
              updateArrayLength(1, localMem[898], 6);
              ip = 2001;
      end

       2001 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[898]*7 + 3] = localMem[846];
              updateArrayLength(1, localMem[898], 3);
              ip = 2002;
      end

       2002 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[846]*7 + 1] = heapMem[localMem[846]*7 + 1] + 1;
              updateArrayLength(1, localMem[846], 1);
              ip = 2003;
      end

       2003 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[898]*7 + 1] = heapMem[localMem[846]*7 + 1];
              updateArrayLength(1, localMem[898], 1);
              ip = 2004;
      end

       2004 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[901] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[901] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[901]] = 0;
              ip = 2005;
      end

       2005 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[901]*7 + 0] = localMem[848];
              updateArrayLength(1, localMem[901], 0);
              ip = 2006;
      end

       2006 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[901]*7 + 2] = 0;
              updateArrayLength(1, localMem[901], 2);
              ip = 2007;
      end

       2007 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[902] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[902] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[902]] = 0;
              ip = 2008;
      end

       2008 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[901]*7 + 4] = localMem[902];
              updateArrayLength(1, localMem[901], 4);
              ip = 2009;
      end

       2009 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[903] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[903] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[903]] = 0;
              ip = 2010;
      end

       2010 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[901]*7 + 5] = localMem[903];
              updateArrayLength(1, localMem[901], 5);
              ip = 2011;
      end

       2011 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[901]*7 + 6] = 0;
              updateArrayLength(1, localMem[901], 6);
              ip = 2012;
      end

       2012 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[901]*7 + 3] = localMem[846];
              updateArrayLength(1, localMem[901], 3);
              ip = 2013;
      end

       2013 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[846]*7 + 1] = heapMem[localMem[846]*7 + 1] + 1;
              updateArrayLength(1, localMem[846], 1);
              ip = 2014;
      end

       2014 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[901]*7 + 1] = heapMem[localMem[846]*7 + 1];
              updateArrayLength(1, localMem[901], 1);
              ip = 2015;
      end

       2015 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[904] = !heapMem[localMem[835]*7 + 6];
              ip = 2016;
      end

       2016 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[904] != 0 ? 2068 : 2017;
      end

       2017 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[905] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[905] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[905]] = 0;
              ip = 2018;
      end

       2018 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[898]*7 + 6] = localMem[905];
              updateArrayLength(1, localMem[898], 6);
              ip = 2019;
      end

       2019 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[906] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[906] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[906]] = 0;
              ip = 2020;
      end

       2020 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[901]*7 + 6] = localMem[906];
              updateArrayLength(1, localMem[901], 6);
              ip = 2021;
      end

       2021 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[907] = heapMem[localMem[835]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2022;
      end

       2022 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[908] = heapMem[localMem[898]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2023;
      end

       2023 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[848]) begin
                  heapMem[NArea * localMem[908] + 0 + i] = heapMem[NArea * localMem[907] + 0 + i];
                  updateArrayLength(1, localMem[908], 0 + i);
                end
              end
              ip = 2024;
      end

       2024 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[909] = heapMem[localMem[835]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2025;
      end

       2025 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[910] = heapMem[localMem[898]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2026;
      end

       2026 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[848]) begin
                  heapMem[NArea * localMem[910] + 0 + i] = heapMem[NArea * localMem[909] + 0 + i];
                  updateArrayLength(1, localMem[910], 0 + i);
                end
              end
              ip = 2027;
      end

       2027 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[911] = heapMem[localMem[835]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2028;
      end

       2028 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[912] = heapMem[localMem[898]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2029;
      end

       2029 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[913] = localMem[848] + 1;
              updateArrayLength(2, 0, 0);
              ip = 2030;
      end

       2030 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[913]) begin
                  heapMem[NArea * localMem[912] + 0 + i] = heapMem[NArea * localMem[911] + 0 + i];
                  updateArrayLength(1, localMem[912], 0 + i);
                end
              end
              ip = 2031;
      end

       2031 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[914] = heapMem[localMem[835]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2032;
      end

       2032 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[915] = heapMem[localMem[901]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2033;
      end

       2033 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[848]) begin
                  heapMem[NArea * localMem[915] + 0 + i] = heapMem[NArea * localMem[914] + localMem[849] + i];
                  updateArrayLength(1, localMem[915], 0 + i);
                end
              end
              ip = 2034;
      end

       2034 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[916] = heapMem[localMem[835]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2035;
      end

       2035 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[917] = heapMem[localMem[901]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2036;
      end

       2036 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[848]) begin
                  heapMem[NArea * localMem[917] + 0 + i] = heapMem[NArea * localMem[916] + localMem[849] + i];
                  updateArrayLength(1, localMem[917], 0 + i);
                end
              end
              ip = 2037;
      end

       2037 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[918] = heapMem[localMem[835]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2038;
      end

       2038 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[919] = heapMem[localMem[901]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2039;
      end

       2039 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[920] = localMem[848] + 1;
              updateArrayLength(2, 0, 0);
              ip = 2040;
      end

       2040 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[920]) begin
                  heapMem[NArea * localMem[919] + 0 + i] = heapMem[NArea * localMem[918] + localMem[849] + i];
                  updateArrayLength(1, localMem[919], 0 + i);
                end
              end
              ip = 2041;
      end

       2041 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[921] = heapMem[localMem[898]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2042;
      end

       2042 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[922] = localMem[921] + 1;
              updateArrayLength(2, 0, 0);
              ip = 2043;
      end

       2043 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[923] = heapMem[localMem[898]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2044;
      end

       2044 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 2045;
      end

       2045 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[924] = 0;
              updateArrayLength(2, 0, 0);
              ip = 2046;
      end

       2046 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 2047;
      end

       2047 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[924] >= localMem[922] ? 2053 : 2048;
      end

       2048 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[925] = heapMem[localMem[923]*7 + localMem[924]];
              updateArrayLength(2, 0, 0);
              ip = 2049;
      end

       2049 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[925]*7 + 2] = localMem[898];
              updateArrayLength(1, localMem[925], 2);
              ip = 2050;
      end

       2050 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 2051;
      end

       2051 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[924] = localMem[924] + 1;
              updateArrayLength(2, 0, 0);
              ip = 2052;
      end

       2052 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 2046;
      end

       2053 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 2054;
      end

       2054 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[926] = heapMem[localMem[901]*7 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2055;
      end

       2055 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[927] = localMem[926] + 1;
              updateArrayLength(2, 0, 0);
              ip = 2056;
      end

       2056 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[928] = heapMem[localMem[901]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2057;
      end

       2057 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 2058;
      end

       2058 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[929] = 0;
              updateArrayLength(2, 0, 0);
              ip = 2059;
      end

       2059 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 2060;
      end

       2060 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[929] >= localMem[927] ? 2066 : 2061;
      end

       2061 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[930] = heapMem[localMem[928]*7 + localMem[929]];
              updateArrayLength(2, 0, 0);
              ip = 2062;
      end

       2062 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[930]*7 + 2] = localMem[901];
              updateArrayLength(1, localMem[930], 2);
              ip = 2063;
      end

       2063 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 2064;
      end

       2064 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[929] = localMem[929] + 1;
              updateArrayLength(2, 0, 0);
              ip = 2065;
      end

       2065 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 2059;
      end

       2066 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 2067;
      end

       2067 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 2083;
      end

       2068 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 2069;
      end

       2069 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[931] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[931] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[931]] = 0;
              ip = 2070;
      end

       2070 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[835]*7 + 6] = localMem[931];
              updateArrayLength(1, localMem[835], 6);
              ip = 2071;
      end

       2071 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[932] = heapMem[localMem[835]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2072;
      end

       2072 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[933] = heapMem[localMem[898]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2073;
      end

       2073 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[848]) begin
                  heapMem[NArea * localMem[933] + 0 + i] = heapMem[NArea * localMem[932] + 0 + i];
                  updateArrayLength(1, localMem[933], 0 + i);
                end
              end
              ip = 2074;
      end

       2074 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[934] = heapMem[localMem[835]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2075;
      end

       2075 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[935] = heapMem[localMem[898]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2076;
      end

       2076 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[848]) begin
                  heapMem[NArea * localMem[935] + 0 + i] = heapMem[NArea * localMem[934] + 0 + i];
                  updateArrayLength(1, localMem[935], 0 + i);
                end
              end
              ip = 2077;
      end

       2077 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[936] = heapMem[localMem[835]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2078;
      end

       2078 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[937] = heapMem[localMem[901]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2079;
      end

       2079 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[848]) begin
                  heapMem[NArea * localMem[937] + 0 + i] = heapMem[NArea * localMem[936] + localMem[849] + i];
                  updateArrayLength(1, localMem[937], 0 + i);
                end
              end
              ip = 2080;
      end

       2080 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[938] = heapMem[localMem[835]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2081;
      end

       2081 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[939] = heapMem[localMem[901]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2082;
      end

       2082 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[848]) begin
                  heapMem[NArea * localMem[939] + 0 + i] = heapMem[NArea * localMem[938] + localMem[849] + i];
                  updateArrayLength(1, localMem[939], 0 + i);
                end
              end
              ip = 2083;
      end

       2083 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 2084;
      end

       2084 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[898]*7 + 2] = localMem[835];
              updateArrayLength(1, localMem[898], 2);
              ip = 2085;
      end

       2085 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[901]*7 + 2] = localMem[835];
              updateArrayLength(1, localMem[901], 2);
              ip = 2086;
      end

       2086 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[940] = heapMem[localMem[835]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2087;
      end

       2087 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[941] = heapMem[localMem[940]*7 + localMem[848]];
              updateArrayLength(2, 0, 0);
              ip = 2088;
      end

       2088 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[942] = heapMem[localMem[835]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2089;
      end

       2089 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[943] = heapMem[localMem[942]*7 + localMem[848]];
              updateArrayLength(2, 0, 0);
              ip = 2090;
      end

       2090 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[944] = heapMem[localMem[835]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2091;
      end

       2091 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[944]*7 + 0] = localMem[941];
              updateArrayLength(1, localMem[944], 0);
              ip = 2092;
      end

       2092 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[945] = heapMem[localMem[835]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2093;
      end

       2093 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[945]*7 + 0] = localMem[943];
              updateArrayLength(1, localMem[945], 0);
              ip = 2094;
      end

       2094 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[946] = heapMem[localMem[835]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2095;
      end

       2095 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[946]*7 + 0] = localMem[898];
              updateArrayLength(1, localMem[946], 0);
              ip = 2096;
      end

       2096 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[947] = heapMem[localMem[835]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2097;
      end

       2097 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[947]*7 + 1] = localMem[901];
              updateArrayLength(1, localMem[947], 1);
              ip = 2098;
      end

       2098 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[835]*7 + 0] = 1;
              updateArrayLength(1, localMem[835], 0);
              ip = 2099;
      end

       2099 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[948] = heapMem[localMem[835]*7 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2100;
      end

       2100 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[948]] = 1;
              ip = 2101;
      end

       2101 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[949] = heapMem[localMem[835]*7 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2102;
      end

       2102 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[949]] = 1;
              ip = 2103;
      end

       2103 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[950] = heapMem[localMem[835]*7 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2104;
      end

       2104 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[950]] = 2;
              ip = 2105;
      end

       2105 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 2107;
      end

       2106 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 2112;
      end

       2107 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 2108;
      end

       2108 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[844] = 1;
              updateArrayLength(2, 0, 0);
              ip = 2109;
      end

       2109 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 2112;
      end

       2110 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 2111;
      end

       2111 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[844] = 0;
              updateArrayLength(2, 0, 0);
              ip = 2112;
      end

       2112 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 2113;
      end

       2113 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 2114;
      end

       2114 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 2115;
      end

       2115 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 2116;
      end

       2116 :
      begin                                                                     // free
if (0) begin
  $display("AAAA %4d %4d free", steps, ip);
end
                                 arraySizes[localMem[476]] = 0;
              freedArrays[freedArraysTop] = localMem[476];
              freedArraysTop = freedArraysTop + 1;
              ip = 2117;
      end
      default: begin
        success  = 1;
        finished = 1;
      end
    endcase
    if (steps <=     64) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
    if (0) begin
      for(i = 0; i < 200; ++i) $write("%2d",   localMem[i]); $display("");
      for(i = 0; i < 200; ++i) $write("%2d",    heapMem[i]); $display("");
      for(i = 0; i < 200; ++i) $write("%2d", arraySizes[i]); $display("");
    end
  end
endmodule
