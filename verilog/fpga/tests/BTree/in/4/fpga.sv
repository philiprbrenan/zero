//-----------------------------------------------------------------------------
// Fpga test
// Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
//------------------------------------------------------------------------------
module fpga                                                                     // Run test programs
 (input  wire run,                                                              // Run - clock at lest once to allow code to be loaded
  output reg  finished,                                                         // Goes high when the program has finished
  output reg  success);                                                         // Goes high on finish if all the tests passed

  parameter integer MemoryElementWidth =  12;                                   // Memory element width

  parameter integer NArea   = 6;                                           // Size of each area on the heap
  parameter integer NArrays = 13;                                         // Maximum number of arrays
  parameter integer NHeap   = 6*13;                                  // Amount of heap memory
  parameter integer NLocal  = 499;                                          // Size of local memory
  parameter integer NOut    =  2000;                                            // Size of output area
  parameter integer NIn            =    21;                                       // Size of input area
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
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 2;
      end

          2 :
      begin                                                                     // inSize
if (0) begin
  $display("AAAA %4d %4d inSize", steps, ip);
end
              localMem[1] = NIn - inMemPos;
              ip = 3;
      end

          3 :
      begin                                                                     // jFalse
if (0) begin
  $display("AAAA %4d %4d jFalse", steps, ip);
end
              ip = localMem[1] == 0 ? 1147 : 4;
      end

          4 :
      begin                                                                     // in
if (0) begin
  $display("AAAA %4d %4d in", steps, ip);
end
              if (inMemPos < NIn) begin
                localMem[2] = inMem[inMemPos];
                inMemPos = inMemPos + 1;
              end
              ip = 5;
      end

          5 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[2] != 0 ? 12 : 6;
      end

          6 :
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
              ip = 7;
      end

          7 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[3]*6 + 2] = 3;
              updateArrayLength(1, localMem[3], 2);
              ip = 8;
      end

          8 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[3]*6 + 3] = 0;
              updateArrayLength(1, localMem[3], 3);
              ip = 9;
      end

          9 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[3]*6 + 0] = 0;
              updateArrayLength(1, localMem[3], 0);
              ip = 10;
      end

         10 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[3]*6 + 1] = 0;
              updateArrayLength(1, localMem[3], 1);
              ip = 11;
      end

         11 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1145;
      end

         12 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 13;
      end

         13 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[2] != 1 ? 1073 : 14;
      end

         14 :
      begin                                                                     // in
if (0) begin
  $display("AAAA %4d %4d in", steps, ip);
end
              if (inMemPos < NIn) begin
                localMem[4] = inMem[inMemPos];
                inMemPos = inMemPos + 1;
              end
              ip = 15;
      end

         15 :
      begin                                                                     // in
if (0) begin
  $display("AAAA %4d %4d in", steps, ip);
end
              if (inMemPos < NIn) begin
                localMem[5] = inMem[inMemPos];
                inMemPos = inMemPos + 1;
              end
              ip = 16;
      end

         16 :
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
              ip = 17;
      end

         17 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 18;
      end

         18 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[7] = heapMem[localMem[3]*6 + 3];
              updateArrayLength(2, 0, 0);
              ip = 19;
      end

         19 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[7] != 0 ? 42 : 20;
      end

         20 :
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
              ip = 21;
      end

         21 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[8]*6 + 0] = 1;
              updateArrayLength(1, localMem[8], 0);
              ip = 22;
      end

         22 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[8]*6 + 2] = 0;
              updateArrayLength(1, localMem[8], 2);
              ip = 23;
      end

         23 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[9] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[9] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[9]] = 0;
              ip = 24;
      end

         24 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[8]*6 + 4] = localMem[9];
              updateArrayLength(1, localMem[8], 4);
              ip = 25;
      end

         25 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[10] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[10] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[10]] = 0;
              ip = 26;
      end

         26 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[8]*6 + 5] = localMem[10];
              updateArrayLength(1, localMem[8], 5);
              ip = 27;
      end

         27 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[8]*6 + 6] = 0;
              updateArrayLength(1, localMem[8], 6);
              ip = 28;
      end

         28 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[8]*6 + 3] = localMem[3];
              updateArrayLength(1, localMem[8], 3);
              ip = 29;
      end

         29 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[3]*6 + 1] = heapMem[localMem[3]*6 + 1] + 1;
              updateArrayLength(1, localMem[3], 1);
              ip = 30;
      end

         30 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[8]*6 + 1] = heapMem[localMem[3]*6 + 1];
              updateArrayLength(1, localMem[8], 1);
              ip = 31;
      end

         31 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[11] = heapMem[localMem[8]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 32;
      end

         32 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[11]*6 + 0] = localMem[4];
              updateArrayLength(1, localMem[11], 0);
              ip = 33;
      end

         33 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[12] = heapMem[localMem[8]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 34;
      end

         34 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[12]*6 + 0] = localMem[5];
              updateArrayLength(1, localMem[12], 0);
              ip = 35;
      end

         35 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[3]*6 + 0] = heapMem[localMem[3]*6 + 0] + 1;
              updateArrayLength(1, localMem[3], 0);
              ip = 36;
      end

         36 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[3]*6 + 3] = localMem[8];
              updateArrayLength(1, localMem[3], 3);
              ip = 37;
      end

         37 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[13] = heapMem[localMem[8]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 38;
      end

         38 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[13]] = 1;
              ip = 39;
      end

         39 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[14] = heapMem[localMem[8]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 40;
      end

         40 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[14]] = 1;
              ip = 41;
      end

         41 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1070;
      end

         42 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 43;
      end

         43 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[15] = heapMem[localMem[7]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 44;
      end

         44 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[16] = heapMem[localMem[3]*6 + 2];
              updateArrayLength(2, 0, 0);
              ip = 45;
      end

         45 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[15] >= localMem[16] ? 81 : 46;
      end

         46 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[17] = heapMem[localMem[7]*6 + 2];
              updateArrayLength(2, 0, 0);
              ip = 47;
      end

         47 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[17] != 0 ? 80 : 48;
      end

         48 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[18] = !heapMem[localMem[7]*6 + 6];
              ip = 49;
      end

         49 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[18] == 0 ? 79 : 50;
      end

         50 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[19] = heapMem[localMem[7]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 51;
      end

         51 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[20] = 0; k = arraySizes[localMem[19]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[19] * NArea + i] == localMem[4]) localMem[20] = i + 1;
              end
              ip = 52;
      end

         52 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[20] == 0 ? 57 : 53;
      end

         53 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[20] = localMem[20] - 1;
              updateArrayLength(2, 0, 0);
              ip = 54;
      end

         54 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[21] = heapMem[localMem[7]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 55;
      end

         55 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[21]*6 + localMem[20]] = localMem[5];
              updateArrayLength(1, localMem[21], localMem[20]);
              ip = 56;
      end

         56 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1070;
      end

         57 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 58;
      end

         58 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[19]] = localMem[15];
              ip = 59;
      end

         59 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[22] = heapMem[localMem[7]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 60;
      end

         60 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[22]] = localMem[15];
              ip = 61;
      end

         61 :
      begin                                                                     // arrayCountGreater
if (0) begin
  $display("AAAA %4d %4d arrayCountGreater", steps, ip);
end
              j = 0; k = arraySizes[localMem[19]];
//$display("AAAAA k=%d  source2=%d", k, localMem[4]);
              for(i = 0; i < NArea; i = i + 1) begin
//$display("AAAAA i=%d  value=%d", i, heapMem[localMem[19] * NArea + i]);
                if (i < k && heapMem[localMem[19] * NArea + i] > localMem[4]) j = j + 1;
              end
              localMem[23] = j;
              ip = 62;
      end

         62 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[23] != 0 ? 70 : 63;
      end

         63 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[24] = heapMem[localMem[7]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 64;
      end

         64 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[24]*6 + localMem[15]] = localMem[4];
              updateArrayLength(1, localMem[24], localMem[15]);
              ip = 65;
      end

         65 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[25] = heapMem[localMem[7]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 66;
      end

         66 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[25]*6 + localMem[15]] = localMem[5];
              updateArrayLength(1, localMem[25], localMem[15]);
              ip = 67;
      end

         67 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[7]*6 + 0] = localMem[15] + 1;
              updateArrayLength(1, localMem[7], 0);
              ip = 68;
      end

         68 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[3]*6 + 0] = heapMem[localMem[3]*6 + 0] + 1;
              updateArrayLength(1, localMem[3], 0);
              ip = 69;
      end

         69 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1070;
      end

         70 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 71;
      end

         71 :
      begin                                                                     // arrayCountLess
if (0) begin
  $display("AAAA %4d %4d arrayCountLess", steps, ip);
end
              j = 0; k = arraySizes[localMem[19]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[19] * NArea + i] < localMem[4]) j = j + 1;
              end
              localMem[26] = j;
              ip = 72;
      end

         72 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[27] = heapMem[localMem[7]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 73;
      end

         73 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[27] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[26], localMem[27], arraySizes[localMem[27]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[26] && i <= arraySizes[localMem[27]]) begin
                  heapMem[NArea * localMem[27] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[27] + localMem[26]] = localMem[4];                                    // Insert new value
              arraySizes[localMem[27]] = arraySizes[localMem[27]] + 1;                              // Increase array size
              ip = 74;
      end

         74 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[28] = heapMem[localMem[7]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 75;
      end

         75 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[28] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[26], localMem[28], arraySizes[localMem[28]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[26] && i <= arraySizes[localMem[28]]) begin
                  heapMem[NArea * localMem[28] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[28] + localMem[26]] = localMem[5];                                    // Insert new value
              arraySizes[localMem[28]] = arraySizes[localMem[28]] + 1;                              // Increase array size
              ip = 76;
      end

         76 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[7]*6 + 0] = heapMem[localMem[7]*6 + 0] + 1;
              updateArrayLength(1, localMem[7], 0);
              ip = 77;
      end

         77 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[3]*6 + 0] = heapMem[localMem[3]*6 + 0] + 1;
              updateArrayLength(1, localMem[3], 0);
              ip = 78;
      end

         78 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1070;
      end

         79 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 80;
      end

         80 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 81;
      end

         81 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 82;
      end

         82 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[29] = heapMem[localMem[3]*6 + 3];
              updateArrayLength(2, 0, 0);
              ip = 83;
      end

         83 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 84;
      end

         84 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[31] = heapMem[localMem[29]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 85;
      end

         85 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[32] = heapMem[localMem[29]*6 + 3];
              updateArrayLength(2, 0, 0);
              ip = 86;
      end

         86 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[33] = heapMem[localMem[32]*6 + 2];
              updateArrayLength(2, 0, 0);
              ip = 87;
      end

         87 :
      begin                                                                     // jLt
if (0) begin
  $display("AAAA %4d %4d jLt", steps, ip);
end
              ip = localMem[31] <  localMem[33] ? 307 : 88;
      end

         88 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[34] = localMem[33];
              updateArrayLength(2, 0, 0);
              ip = 89;
      end

         89 :
      begin                                                                     // shiftRight
if (0) begin
  $display("AAAA %4d %4d shiftRight", steps, ip);
end
              localMem[34] = localMem[34] >> 1;
              ip = 90;
      end

         90 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[35] = localMem[34] + 1;
              updateArrayLength(2, 0, 0);
              ip = 91;
      end

         91 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[36] = heapMem[localMem[29]*6 + 2];
              updateArrayLength(2, 0, 0);
              ip = 92;
      end

         92 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[36] == 0 ? 189 : 93;
      end

         93 :
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
              ip = 94;
      end

         94 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[37]*6 + 0] = localMem[34];
              updateArrayLength(1, localMem[37], 0);
              ip = 95;
      end

         95 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[37]*6 + 2] = 0;
              updateArrayLength(1, localMem[37], 2);
              ip = 96;
      end

         96 :
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
              ip = 97;
      end

         97 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[37]*6 + 4] = localMem[38];
              updateArrayLength(1, localMem[37], 4);
              ip = 98;
      end

         98 :
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
              ip = 99;
      end

         99 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[37]*6 + 5] = localMem[39];
              updateArrayLength(1, localMem[37], 5);
              ip = 100;
      end

        100 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[37]*6 + 6] = 0;
              updateArrayLength(1, localMem[37], 6);
              ip = 101;
      end

        101 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[37]*6 + 3] = localMem[32];
              updateArrayLength(1, localMem[37], 3);
              ip = 102;
      end

        102 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[32]*6 + 1] = heapMem[localMem[32]*6 + 1] + 1;
              updateArrayLength(1, localMem[32], 1);
              ip = 103;
      end

        103 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[37]*6 + 1] = heapMem[localMem[32]*6 + 1];
              updateArrayLength(1, localMem[37], 1);
              ip = 104;
      end

        104 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[40] = !heapMem[localMem[29]*6 + 6];
              ip = 105;
      end

        105 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[40] != 0 ? 134 : 106;
      end

        106 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[41] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[41] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[41]] = 0;
              ip = 107;
      end

        107 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[37]*6 + 6] = localMem[41];
              updateArrayLength(1, localMem[37], 6);
              ip = 108;
      end

        108 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[42] = heapMem[localMem[29]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 109;
      end

        109 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[43] = heapMem[localMem[37]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 110;
      end

        110 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[34]) begin
                  heapMem[NArea * localMem[43] + 0 + i] = heapMem[NArea * localMem[42] + localMem[35] + i];
                  updateArrayLength(1, localMem[43], 0 + i);
                end
              end
              ip = 111;
      end

        111 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[44] = heapMem[localMem[29]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 112;
      end

        112 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[45] = heapMem[localMem[37]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 113;
      end

        113 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[34]) begin
                  heapMem[NArea * localMem[45] + 0 + i] = heapMem[NArea * localMem[44] + localMem[35] + i];
                  updateArrayLength(1, localMem[45], 0 + i);
                end
              end
              ip = 114;
      end

        114 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[46] = heapMem[localMem[29]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 115;
      end

        115 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[47] = heapMem[localMem[37]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 116;
      end

        116 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[48] = localMem[34] + 1;
              updateArrayLength(2, 0, 0);
              ip = 117;
      end

        117 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[48]) begin
                  heapMem[NArea * localMem[47] + 0 + i] = heapMem[NArea * localMem[46] + localMem[35] + i];
                  updateArrayLength(1, localMem[47], 0 + i);
                end
              end
              ip = 118;
      end

        118 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[49] = heapMem[localMem[37]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 119;
      end

        119 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[50] = localMem[49] + 1;
              updateArrayLength(2, 0, 0);
              ip = 120;
      end

        120 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[51] = heapMem[localMem[37]*6 + 6];
              updateArrayLength(2, 0, 0);
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
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[52] = 0;
              updateArrayLength(2, 0, 0);
              ip = 123;
      end

        123 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 124;
      end

        124 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[52] >= localMem[50] ? 130 : 125;
      end

        125 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[53] = heapMem[localMem[51]*6 + localMem[52]];
              updateArrayLength(2, 0, 0);
              ip = 126;
      end

        126 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[53]*6 + 2] = localMem[37];
              updateArrayLength(1, localMem[53], 2);
              ip = 127;
      end

        127 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 128;
      end

        128 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[52] = localMem[52] + 1;
              updateArrayLength(2, 0, 0);
              ip = 129;
      end

        129 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 123;
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
              localMem[54] = heapMem[localMem[29]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 132;
      end

        132 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[54]] = localMem[35];
              ip = 133;
      end

        133 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 141;
      end

        134 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 135;
      end

        135 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[55] = heapMem[localMem[29]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 136;
      end

        136 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[56] = heapMem[localMem[37]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 137;
      end

        137 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[34]) begin
                  heapMem[NArea * localMem[56] + 0 + i] = heapMem[NArea * localMem[55] + localMem[35] + i];
                  updateArrayLength(1, localMem[56], 0 + i);
                end
              end
              ip = 138;
      end

        138 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[57] = heapMem[localMem[29]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 139;
      end

        139 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[58] = heapMem[localMem[37]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 140;
      end

        140 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[34]) begin
                  heapMem[NArea * localMem[58] + 0 + i] = heapMem[NArea * localMem[57] + localMem[35] + i];
                  updateArrayLength(1, localMem[58], 0 + i);
                end
              end
              ip = 141;
      end

        141 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 142;
      end

        142 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[29]*6 + 0] = localMem[34];
              updateArrayLength(1, localMem[29], 0);
              ip = 143;
      end

        143 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[37]*6 + 2] = localMem[36];
              updateArrayLength(1, localMem[37], 2);
              ip = 144;
      end

        144 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[59] = heapMem[localMem[36]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 145;
      end

        145 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[60] = heapMem[localMem[36]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 146;
      end

        146 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[61] = heapMem[localMem[60]*6 + localMem[59]];
              updateArrayLength(2, 0, 0);
              ip = 147;
      end

        147 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[61] != localMem[29] ? 166 : 148;
      end

        148 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[62] = heapMem[localMem[29]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 149;
      end

        149 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[63] = heapMem[localMem[62]*6 + localMem[34]];
              updateArrayLength(2, 0, 0);
              ip = 150;
      end

        150 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[64] = heapMem[localMem[36]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 151;
      end

        151 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[64]*6 + localMem[59]] = localMem[63];
              updateArrayLength(1, localMem[64], localMem[59]);
              ip = 152;
      end

        152 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[65] = heapMem[localMem[29]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 153;
      end

        153 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[66] = heapMem[localMem[65]*6 + localMem[34]];
              updateArrayLength(2, 0, 0);
              ip = 154;
      end

        154 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[67] = heapMem[localMem[36]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 155;
      end

        155 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[67]*6 + localMem[59]] = localMem[66];
              updateArrayLength(1, localMem[67], localMem[59]);
              ip = 156;
      end

        156 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[68] = heapMem[localMem[29]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 157;
      end

        157 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[68]] = localMem[34];
              ip = 158;
      end

        158 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[69] = heapMem[localMem[29]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 159;
      end

        159 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[69]] = localMem[34];
              ip = 160;
      end

        160 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[70] = localMem[59] + 1;
              updateArrayLength(2, 0, 0);
              ip = 161;
      end

        161 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[36]*6 + 0] = localMem[70];
              updateArrayLength(1, localMem[36], 0);
              ip = 162;
      end

        162 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[71] = heapMem[localMem[36]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 163;
      end

        163 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[71]*6 + localMem[70]] = localMem[37];
              updateArrayLength(1, localMem[71], localMem[70]);
              ip = 164;
      end

        164 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 304;
      end

        165 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 188;
      end

        166 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 167;
      end

        167 :
      begin                                                                     // assertNe
if (0) begin
  $display("AAAA %4d %4d assertNe", steps, ip);
end
            ip = 168;
      end

        168 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[72] = heapMem[localMem[36]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 169;
      end

        169 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[73] = 0; k = arraySizes[localMem[72]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[72] * NArea + i] == localMem[29]) localMem[73] = i + 1;
              end
              ip = 170;
      end

        170 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[73] = localMem[73] - 1;
              updateArrayLength(2, 0, 0);
              ip = 171;
      end

        171 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[74] = heapMem[localMem[29]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 172;
      end

        172 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[75] = heapMem[localMem[74]*6 + localMem[34]];
              updateArrayLength(2, 0, 0);
              ip = 173;
      end

        173 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[76] = heapMem[localMem[29]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 174;
      end

        174 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[77] = heapMem[localMem[76]*6 + localMem[34]];
              updateArrayLength(2, 0, 0);
              ip = 175;
      end

        175 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[78] = heapMem[localMem[29]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 176;
      end

        176 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[78]] = localMem[34];
              ip = 177;
      end

        177 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[79] = heapMem[localMem[29]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 178;
      end

        178 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[79]] = localMem[34];
              ip = 179;
      end

        179 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[80] = heapMem[localMem[36]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 180;
      end

        180 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[80] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[73], localMem[80], arraySizes[localMem[80]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[73] && i <= arraySizes[localMem[80]]) begin
                  heapMem[NArea * localMem[80] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[80] + localMem[73]] = localMem[75];                                    // Insert new value
              arraySizes[localMem[80]] = arraySizes[localMem[80]] + 1;                              // Increase array size
              ip = 181;
      end

        181 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[81] = heapMem[localMem[36]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 182;
      end

        182 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[81] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[73], localMem[81], arraySizes[localMem[81]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[73] && i <= arraySizes[localMem[81]]) begin
                  heapMem[NArea * localMem[81] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[81] + localMem[73]] = localMem[77];                                    // Insert new value
              arraySizes[localMem[81]] = arraySizes[localMem[81]] + 1;                              // Increase array size
              ip = 183;
      end

        183 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[82] = heapMem[localMem[36]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 184;
      end

        184 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[83] = localMem[73] + 1;
              updateArrayLength(2, 0, 0);
              ip = 185;
      end

        185 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[82] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[83], localMem[82], arraySizes[localMem[82]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[83] && i <= arraySizes[localMem[82]]) begin
                  heapMem[NArea * localMem[82] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[82] + localMem[83]] = localMem[37];                                    // Insert new value
              arraySizes[localMem[82]] = arraySizes[localMem[82]] + 1;                              // Increase array size
              ip = 186;
      end

        186 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[36]*6 + 0] = heapMem[localMem[36]*6 + 0] + 1;
              updateArrayLength(1, localMem[36], 0);
              ip = 187;
      end

        187 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 304;
      end

        188 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 189;
      end

        189 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 190;
      end

        190 :
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
              ip = 191;
      end

        191 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[84]*6 + 0] = localMem[34];
              updateArrayLength(1, localMem[84], 0);
              ip = 192;
      end

        192 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[84]*6 + 2] = 0;
              updateArrayLength(1, localMem[84], 2);
              ip = 193;
      end

        193 :
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
              ip = 194;
      end

        194 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[84]*6 + 4] = localMem[85];
              updateArrayLength(1, localMem[84], 4);
              ip = 195;
      end

        195 :
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
              ip = 196;
      end

        196 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[84]*6 + 5] = localMem[86];
              updateArrayLength(1, localMem[84], 5);
              ip = 197;
      end

        197 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[84]*6 + 6] = 0;
              updateArrayLength(1, localMem[84], 6);
              ip = 198;
      end

        198 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[84]*6 + 3] = localMem[32];
              updateArrayLength(1, localMem[84], 3);
              ip = 199;
      end

        199 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[32]*6 + 1] = heapMem[localMem[32]*6 + 1] + 1;
              updateArrayLength(1, localMem[32], 1);
              ip = 200;
      end

        200 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[84]*6 + 1] = heapMem[localMem[32]*6 + 1];
              updateArrayLength(1, localMem[84], 1);
              ip = 201;
      end

        201 :
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
              ip = 202;
      end

        202 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[87]*6 + 0] = localMem[34];
              updateArrayLength(1, localMem[87], 0);
              ip = 203;
      end

        203 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[87]*6 + 2] = 0;
              updateArrayLength(1, localMem[87], 2);
              ip = 204;
      end

        204 :
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
              ip = 205;
      end

        205 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[87]*6 + 4] = localMem[88];
              updateArrayLength(1, localMem[87], 4);
              ip = 206;
      end

        206 :
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
              ip = 207;
      end

        207 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[87]*6 + 5] = localMem[89];
              updateArrayLength(1, localMem[87], 5);
              ip = 208;
      end

        208 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[87]*6 + 6] = 0;
              updateArrayLength(1, localMem[87], 6);
              ip = 209;
      end

        209 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[87]*6 + 3] = localMem[32];
              updateArrayLength(1, localMem[87], 3);
              ip = 210;
      end

        210 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[32]*6 + 1] = heapMem[localMem[32]*6 + 1] + 1;
              updateArrayLength(1, localMem[32], 1);
              ip = 211;
      end

        211 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[87]*6 + 1] = heapMem[localMem[32]*6 + 1];
              updateArrayLength(1, localMem[87], 1);
              ip = 212;
      end

        212 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[90] = !heapMem[localMem[29]*6 + 6];
              ip = 213;
      end

        213 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[90] != 0 ? 265 : 214;
      end

        214 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[91] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[91] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[91]] = 0;
              ip = 215;
      end

        215 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[84]*6 + 6] = localMem[91];
              updateArrayLength(1, localMem[84], 6);
              ip = 216;
      end

        216 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[92] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[92] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[92]] = 0;
              ip = 217;
      end

        217 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[87]*6 + 6] = localMem[92];
              updateArrayLength(1, localMem[87], 6);
              ip = 218;
      end

        218 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[93] = heapMem[localMem[29]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 219;
      end

        219 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[94] = heapMem[localMem[84]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 220;
      end

        220 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[34]) begin
                  heapMem[NArea * localMem[94] + 0 + i] = heapMem[NArea * localMem[93] + 0 + i];
                  updateArrayLength(1, localMem[94], 0 + i);
                end
              end
              ip = 221;
      end

        221 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[95] = heapMem[localMem[29]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 222;
      end

        222 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[96] = heapMem[localMem[84]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 223;
      end

        223 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[34]) begin
                  heapMem[NArea * localMem[96] + 0 + i] = heapMem[NArea * localMem[95] + 0 + i];
                  updateArrayLength(1, localMem[96], 0 + i);
                end
              end
              ip = 224;
      end

        224 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[97] = heapMem[localMem[29]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 225;
      end

        225 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[98] = heapMem[localMem[84]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 226;
      end

        226 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[99] = localMem[34] + 1;
              updateArrayLength(2, 0, 0);
              ip = 227;
      end

        227 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[99]) begin
                  heapMem[NArea * localMem[98] + 0 + i] = heapMem[NArea * localMem[97] + 0 + i];
                  updateArrayLength(1, localMem[98], 0 + i);
                end
              end
              ip = 228;
      end

        228 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[100] = heapMem[localMem[29]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 229;
      end

        229 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[101] = heapMem[localMem[87]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 230;
      end

        230 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[34]) begin
                  heapMem[NArea * localMem[101] + 0 + i] = heapMem[NArea * localMem[100] + localMem[35] + i];
                  updateArrayLength(1, localMem[101], 0 + i);
                end
              end
              ip = 231;
      end

        231 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[102] = heapMem[localMem[29]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 232;
      end

        232 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[103] = heapMem[localMem[87]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 233;
      end

        233 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[34]) begin
                  heapMem[NArea * localMem[103] + 0 + i] = heapMem[NArea * localMem[102] + localMem[35] + i];
                  updateArrayLength(1, localMem[103], 0 + i);
                end
              end
              ip = 234;
      end

        234 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[104] = heapMem[localMem[29]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 235;
      end

        235 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[105] = heapMem[localMem[87]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 236;
      end

        236 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[106] = localMem[34] + 1;
              updateArrayLength(2, 0, 0);
              ip = 237;
      end

        237 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[106]) begin
                  heapMem[NArea * localMem[105] + 0 + i] = heapMem[NArea * localMem[104] + localMem[35] + i];
                  updateArrayLength(1, localMem[105], 0 + i);
                end
              end
              ip = 238;
      end

        238 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[107] = heapMem[localMem[84]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 239;
      end

        239 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[108] = localMem[107] + 1;
              updateArrayLength(2, 0, 0);
              ip = 240;
      end

        240 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[109] = heapMem[localMem[84]*6 + 6];
              updateArrayLength(2, 0, 0);
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
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[110] = 0;
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
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[110] >= localMem[108] ? 250 : 245;
      end

        245 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[111] = heapMem[localMem[109]*6 + localMem[110]];
              updateArrayLength(2, 0, 0);
              ip = 246;
      end

        246 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[111]*6 + 2] = localMem[84];
              updateArrayLength(1, localMem[111], 2);
              ip = 247;
      end

        247 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 248;
      end

        248 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[110] = localMem[110] + 1;
              updateArrayLength(2, 0, 0);
              ip = 249;
      end

        249 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 243;
      end

        250 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 251;
      end

        251 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[112] = heapMem[localMem[87]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 252;
      end

        252 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[113] = localMem[112] + 1;
              updateArrayLength(2, 0, 0);
              ip = 253;
      end

        253 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[114] = heapMem[localMem[87]*6 + 6];
              updateArrayLength(2, 0, 0);
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
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[115] = 0;
              updateArrayLength(2, 0, 0);
              ip = 256;
      end

        256 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 257;
      end

        257 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[115] >= localMem[113] ? 263 : 258;
      end

        258 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[116] = heapMem[localMem[114]*6 + localMem[115]];
              updateArrayLength(2, 0, 0);
              ip = 259;
      end

        259 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[116]*6 + 2] = localMem[87];
              updateArrayLength(1, localMem[116], 2);
              ip = 260;
      end

        260 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 261;
      end

        261 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[115] = localMem[115] + 1;
              updateArrayLength(2, 0, 0);
              ip = 262;
      end

        262 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 256;
      end

        263 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 264;
      end

        264 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 280;
      end

        265 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 266;
      end

        266 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[117] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[117] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[117]] = 0;
              ip = 267;
      end

        267 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[29]*6 + 6] = localMem[117];
              updateArrayLength(1, localMem[29], 6);
              ip = 268;
      end

        268 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[118] = heapMem[localMem[29]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 269;
      end

        269 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[119] = heapMem[localMem[84]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 270;
      end

        270 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[34]) begin
                  heapMem[NArea * localMem[119] + 0 + i] = heapMem[NArea * localMem[118] + 0 + i];
                  updateArrayLength(1, localMem[119], 0 + i);
                end
              end
              ip = 271;
      end

        271 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[120] = heapMem[localMem[29]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 272;
      end

        272 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[121] = heapMem[localMem[84]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 273;
      end

        273 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[34]) begin
                  heapMem[NArea * localMem[121] + 0 + i] = heapMem[NArea * localMem[120] + 0 + i];
                  updateArrayLength(1, localMem[121], 0 + i);
                end
              end
              ip = 274;
      end

        274 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[122] = heapMem[localMem[29]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 275;
      end

        275 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[123] = heapMem[localMem[87]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 276;
      end

        276 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[34]) begin
                  heapMem[NArea * localMem[123] + 0 + i] = heapMem[NArea * localMem[122] + localMem[35] + i];
                  updateArrayLength(1, localMem[123], 0 + i);
                end
              end
              ip = 277;
      end

        277 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[124] = heapMem[localMem[29]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 278;
      end

        278 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[125] = heapMem[localMem[87]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 279;
      end

        279 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[34]) begin
                  heapMem[NArea * localMem[125] + 0 + i] = heapMem[NArea * localMem[124] + localMem[35] + i];
                  updateArrayLength(1, localMem[125], 0 + i);
                end
              end
              ip = 280;
      end

        280 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 281;
      end

        281 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[84]*6 + 2] = localMem[29];
              updateArrayLength(1, localMem[84], 2);
              ip = 282;
      end

        282 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[87]*6 + 2] = localMem[29];
              updateArrayLength(1, localMem[87], 2);
              ip = 283;
      end

        283 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[126] = heapMem[localMem[29]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 284;
      end

        284 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[127] = heapMem[localMem[126]*6 + localMem[34]];
              updateArrayLength(2, 0, 0);
              ip = 285;
      end

        285 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[128] = heapMem[localMem[29]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 286;
      end

        286 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[129] = heapMem[localMem[128]*6 + localMem[34]];
              updateArrayLength(2, 0, 0);
              ip = 287;
      end

        287 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[130] = heapMem[localMem[29]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 288;
      end

        288 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[130]*6 + 0] = localMem[127];
              updateArrayLength(1, localMem[130], 0);
              ip = 289;
      end

        289 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[131] = heapMem[localMem[29]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 290;
      end

        290 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[131]*6 + 0] = localMem[129];
              updateArrayLength(1, localMem[131], 0);
              ip = 291;
      end

        291 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[132] = heapMem[localMem[29]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 292;
      end

        292 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[132]*6 + 0] = localMem[84];
              updateArrayLength(1, localMem[132], 0);
              ip = 293;
      end

        293 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[133] = heapMem[localMem[29]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 294;
      end

        294 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[133]*6 + 1] = localMem[87];
              updateArrayLength(1, localMem[133], 1);
              ip = 295;
      end

        295 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[29]*6 + 0] = 1;
              updateArrayLength(1, localMem[29], 0);
              ip = 296;
      end

        296 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[134] = heapMem[localMem[29]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 297;
      end

        297 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[134]] = 1;
              ip = 298;
      end

        298 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[135] = heapMem[localMem[29]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 299;
      end

        299 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[135]] = 1;
              ip = 300;
      end

        300 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[136] = heapMem[localMem[29]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 301;
      end

        301 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[136]] = 2;
              ip = 302;
      end

        302 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 304;
      end

        303 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 309;
      end

        304 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 305;
      end

        305 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[30] = 1;
              updateArrayLength(2, 0, 0);
              ip = 306;
      end

        306 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 309;
      end

        307 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 308;
      end

        308 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[30] = 0;
              updateArrayLength(2, 0, 0);
              ip = 309;
      end

        309 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 310;
      end

        310 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 311;
      end

        311 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 312;
      end

        312 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[137] = 0;
              updateArrayLength(2, 0, 0);
              ip = 313;
      end

        313 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 314;
      end

        314 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[137] >= 99 ? 812 : 315;
      end

        315 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[138] = heapMem[localMem[29]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 316;
      end

        316 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[139] = localMem[138] - 1;
              updateArrayLength(2, 0, 0);
              ip = 317;
      end

        317 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[140] = heapMem[localMem[29]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 318;
      end

        318 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[141] = heapMem[localMem[140]*6 + localMem[139]];
              updateArrayLength(2, 0, 0);
              ip = 319;
      end

        319 :
      begin                                                                     // jLe
if (0) begin
  $display("AAAA %4d %4d jLe", steps, ip);
end
              ip = localMem[4] <= localMem[141] ? 560 : 320;
      end

        320 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[142] = !heapMem[localMem[29]*6 + 6];
              ip = 321;
      end

        321 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[142] == 0 ? 326 : 322;
      end

        322 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[6]*6 + 0] = localMem[29];
              updateArrayLength(1, localMem[6], 0);
              ip = 323;
      end

        323 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[6]*6 + 1] = 2;
              updateArrayLength(1, localMem[6], 1);
              ip = 324;
      end

        324 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              heapMem[localMem[6]*6 + 2] = localMem[138] - 1;
              updateArrayLength(1, localMem[6], 2);
              ip = 325;
      end

        325 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 816;
      end

        326 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 327;
      end

        327 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[143] = heapMem[localMem[29]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 328;
      end

        328 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[144] = heapMem[localMem[143]*6 + localMem[138]];
              updateArrayLength(2, 0, 0);
              ip = 329;
      end

        329 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 330;
      end

        330 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[146] = heapMem[localMem[144]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 331;
      end

        331 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[147] = heapMem[localMem[144]*6 + 3];
              updateArrayLength(2, 0, 0);
              ip = 332;
      end

        332 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[148] = heapMem[localMem[147]*6 + 2];
              updateArrayLength(2, 0, 0);
              ip = 333;
      end

        333 :
      begin                                                                     // jLt
if (0) begin
  $display("AAAA %4d %4d jLt", steps, ip);
end
              ip = localMem[146] <  localMem[148] ? 553 : 334;
      end

        334 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[149] = localMem[148];
              updateArrayLength(2, 0, 0);
              ip = 335;
      end

        335 :
      begin                                                                     // shiftRight
if (0) begin
  $display("AAAA %4d %4d shiftRight", steps, ip);
end
              localMem[149] = localMem[149] >> 1;
              ip = 336;
      end

        336 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[150] = localMem[149] + 1;
              updateArrayLength(2, 0, 0);
              ip = 337;
      end

        337 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[151] = heapMem[localMem[144]*6 + 2];
              updateArrayLength(2, 0, 0);
              ip = 338;
      end

        338 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[151] == 0 ? 435 : 339;
      end

        339 :
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
              ip = 340;
      end

        340 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[152]*6 + 0] = localMem[149];
              updateArrayLength(1, localMem[152], 0);
              ip = 341;
      end

        341 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[152]*6 + 2] = 0;
              updateArrayLength(1, localMem[152], 2);
              ip = 342;
      end

        342 :
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
              ip = 343;
      end

        343 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[152]*6 + 4] = localMem[153];
              updateArrayLength(1, localMem[152], 4);
              ip = 344;
      end

        344 :
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
              ip = 345;
      end

        345 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[152]*6 + 5] = localMem[154];
              updateArrayLength(1, localMem[152], 5);
              ip = 346;
      end

        346 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[152]*6 + 6] = 0;
              updateArrayLength(1, localMem[152], 6);
              ip = 347;
      end

        347 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[152]*6 + 3] = localMem[147];
              updateArrayLength(1, localMem[152], 3);
              ip = 348;
      end

        348 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[147]*6 + 1] = heapMem[localMem[147]*6 + 1] + 1;
              updateArrayLength(1, localMem[147], 1);
              ip = 349;
      end

        349 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[152]*6 + 1] = heapMem[localMem[147]*6 + 1];
              updateArrayLength(1, localMem[152], 1);
              ip = 350;
      end

        350 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[155] = !heapMem[localMem[144]*6 + 6];
              ip = 351;
      end

        351 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[155] != 0 ? 380 : 352;
      end

        352 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[156] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[156] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[156]] = 0;
              ip = 353;
      end

        353 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[152]*6 + 6] = localMem[156];
              updateArrayLength(1, localMem[152], 6);
              ip = 354;
      end

        354 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[157] = heapMem[localMem[144]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 355;
      end

        355 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[158] = heapMem[localMem[152]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 356;
      end

        356 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[149]) begin
                  heapMem[NArea * localMem[158] + 0 + i] = heapMem[NArea * localMem[157] + localMem[150] + i];
                  updateArrayLength(1, localMem[158], 0 + i);
                end
              end
              ip = 357;
      end

        357 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[159] = heapMem[localMem[144]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 358;
      end

        358 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[160] = heapMem[localMem[152]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 359;
      end

        359 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[149]) begin
                  heapMem[NArea * localMem[160] + 0 + i] = heapMem[NArea * localMem[159] + localMem[150] + i];
                  updateArrayLength(1, localMem[160], 0 + i);
                end
              end
              ip = 360;
      end

        360 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[161] = heapMem[localMem[144]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 361;
      end

        361 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[162] = heapMem[localMem[152]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 362;
      end

        362 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[163] = localMem[149] + 1;
              updateArrayLength(2, 0, 0);
              ip = 363;
      end

        363 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[163]) begin
                  heapMem[NArea * localMem[162] + 0 + i] = heapMem[NArea * localMem[161] + localMem[150] + i];
                  updateArrayLength(1, localMem[162], 0 + i);
                end
              end
              ip = 364;
      end

        364 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[164] = heapMem[localMem[152]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 365;
      end

        365 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[165] = localMem[164] + 1;
              updateArrayLength(2, 0, 0);
              ip = 366;
      end

        366 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[166] = heapMem[localMem[152]*6 + 6];
              updateArrayLength(2, 0, 0);
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
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[167] = 0;
              updateArrayLength(2, 0, 0);
              ip = 369;
      end

        369 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 370;
      end

        370 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[167] >= localMem[165] ? 376 : 371;
      end

        371 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[168] = heapMem[localMem[166]*6 + localMem[167]];
              updateArrayLength(2, 0, 0);
              ip = 372;
      end

        372 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[168]*6 + 2] = localMem[152];
              updateArrayLength(1, localMem[168], 2);
              ip = 373;
      end

        373 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 374;
      end

        374 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[167] = localMem[167] + 1;
              updateArrayLength(2, 0, 0);
              ip = 375;
      end

        375 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 369;
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
              localMem[169] = heapMem[localMem[144]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 378;
      end

        378 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[169]] = localMem[150];
              ip = 379;
      end

        379 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 387;
      end

        380 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 381;
      end

        381 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[170] = heapMem[localMem[144]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 382;
      end

        382 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[171] = heapMem[localMem[152]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 383;
      end

        383 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[149]) begin
                  heapMem[NArea * localMem[171] + 0 + i] = heapMem[NArea * localMem[170] + localMem[150] + i];
                  updateArrayLength(1, localMem[171], 0 + i);
                end
              end
              ip = 384;
      end

        384 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[172] = heapMem[localMem[144]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 385;
      end

        385 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[173] = heapMem[localMem[152]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 386;
      end

        386 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[149]) begin
                  heapMem[NArea * localMem[173] + 0 + i] = heapMem[NArea * localMem[172] + localMem[150] + i];
                  updateArrayLength(1, localMem[173], 0 + i);
                end
              end
              ip = 387;
      end

        387 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 388;
      end

        388 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[144]*6 + 0] = localMem[149];
              updateArrayLength(1, localMem[144], 0);
              ip = 389;
      end

        389 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[152]*6 + 2] = localMem[151];
              updateArrayLength(1, localMem[152], 2);
              ip = 390;
      end

        390 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[174] = heapMem[localMem[151]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 391;
      end

        391 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[175] = heapMem[localMem[151]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 392;
      end

        392 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[176] = heapMem[localMem[175]*6 + localMem[174]];
              updateArrayLength(2, 0, 0);
              ip = 393;
      end

        393 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[176] != localMem[144] ? 412 : 394;
      end

        394 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[177] = heapMem[localMem[144]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 395;
      end

        395 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[178] = heapMem[localMem[177]*6 + localMem[149]];
              updateArrayLength(2, 0, 0);
              ip = 396;
      end

        396 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[179] = heapMem[localMem[151]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 397;
      end

        397 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[179]*6 + localMem[174]] = localMem[178];
              updateArrayLength(1, localMem[179], localMem[174]);
              ip = 398;
      end

        398 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[180] = heapMem[localMem[144]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 399;
      end

        399 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[181] = heapMem[localMem[180]*6 + localMem[149]];
              updateArrayLength(2, 0, 0);
              ip = 400;
      end

        400 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[182] = heapMem[localMem[151]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 401;
      end

        401 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[182]*6 + localMem[174]] = localMem[181];
              updateArrayLength(1, localMem[182], localMem[174]);
              ip = 402;
      end

        402 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[183] = heapMem[localMem[144]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 403;
      end

        403 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[183]] = localMem[149];
              ip = 404;
      end

        404 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[184] = heapMem[localMem[144]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 405;
      end

        405 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[184]] = localMem[149];
              ip = 406;
      end

        406 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[185] = localMem[174] + 1;
              updateArrayLength(2, 0, 0);
              ip = 407;
      end

        407 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[151]*6 + 0] = localMem[185];
              updateArrayLength(1, localMem[151], 0);
              ip = 408;
      end

        408 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[186] = heapMem[localMem[151]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 409;
      end

        409 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[186]*6 + localMem[185]] = localMem[152];
              updateArrayLength(1, localMem[186], localMem[185]);
              ip = 410;
      end

        410 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 550;
      end

        411 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 434;
      end

        412 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 413;
      end

        413 :
      begin                                                                     // assertNe
if (0) begin
  $display("AAAA %4d %4d assertNe", steps, ip);
end
            ip = 414;
      end

        414 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[187] = heapMem[localMem[151]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 415;
      end

        415 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[188] = 0; k = arraySizes[localMem[187]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[187] * NArea + i] == localMem[144]) localMem[188] = i + 1;
              end
              ip = 416;
      end

        416 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[188] = localMem[188] - 1;
              updateArrayLength(2, 0, 0);
              ip = 417;
      end

        417 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[189] = heapMem[localMem[144]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 418;
      end

        418 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[190] = heapMem[localMem[189]*6 + localMem[149]];
              updateArrayLength(2, 0, 0);
              ip = 419;
      end

        419 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[191] = heapMem[localMem[144]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 420;
      end

        420 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[192] = heapMem[localMem[191]*6 + localMem[149]];
              updateArrayLength(2, 0, 0);
              ip = 421;
      end

        421 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[193] = heapMem[localMem[144]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 422;
      end

        422 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[193]] = localMem[149];
              ip = 423;
      end

        423 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[194] = heapMem[localMem[144]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 424;
      end

        424 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[194]] = localMem[149];
              ip = 425;
      end

        425 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[195] = heapMem[localMem[151]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 426;
      end

        426 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[195] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[188], localMem[195], arraySizes[localMem[195]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[188] && i <= arraySizes[localMem[195]]) begin
                  heapMem[NArea * localMem[195] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[195] + localMem[188]] = localMem[190];                                    // Insert new value
              arraySizes[localMem[195]] = arraySizes[localMem[195]] + 1;                              // Increase array size
              ip = 427;
      end

        427 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[196] = heapMem[localMem[151]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 428;
      end

        428 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[196] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[188], localMem[196], arraySizes[localMem[196]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[188] && i <= arraySizes[localMem[196]]) begin
                  heapMem[NArea * localMem[196] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[196] + localMem[188]] = localMem[192];                                    // Insert new value
              arraySizes[localMem[196]] = arraySizes[localMem[196]] + 1;                              // Increase array size
              ip = 429;
      end

        429 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[197] = heapMem[localMem[151]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 430;
      end

        430 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[198] = localMem[188] + 1;
              updateArrayLength(2, 0, 0);
              ip = 431;
      end

        431 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[197] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[198], localMem[197], arraySizes[localMem[197]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[198] && i <= arraySizes[localMem[197]]) begin
                  heapMem[NArea * localMem[197] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[197] + localMem[198]] = localMem[152];                                    // Insert new value
              arraySizes[localMem[197]] = arraySizes[localMem[197]] + 1;                              // Increase array size
              ip = 432;
      end

        432 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[151]*6 + 0] = heapMem[localMem[151]*6 + 0] + 1;
              updateArrayLength(1, localMem[151], 0);
              ip = 433;
      end

        433 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 550;
      end

        434 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 435;
      end

        435 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 436;
      end

        436 :
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
              ip = 437;
      end

        437 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[199]*6 + 0] = localMem[149];
              updateArrayLength(1, localMem[199], 0);
              ip = 438;
      end

        438 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[199]*6 + 2] = 0;
              updateArrayLength(1, localMem[199], 2);
              ip = 439;
      end

        439 :
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
              ip = 440;
      end

        440 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[199]*6 + 4] = localMem[200];
              updateArrayLength(1, localMem[199], 4);
              ip = 441;
      end

        441 :
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
              ip = 442;
      end

        442 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[199]*6 + 5] = localMem[201];
              updateArrayLength(1, localMem[199], 5);
              ip = 443;
      end

        443 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[199]*6 + 6] = 0;
              updateArrayLength(1, localMem[199], 6);
              ip = 444;
      end

        444 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[199]*6 + 3] = localMem[147];
              updateArrayLength(1, localMem[199], 3);
              ip = 445;
      end

        445 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[147]*6 + 1] = heapMem[localMem[147]*6 + 1] + 1;
              updateArrayLength(1, localMem[147], 1);
              ip = 446;
      end

        446 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[199]*6 + 1] = heapMem[localMem[147]*6 + 1];
              updateArrayLength(1, localMem[199], 1);
              ip = 447;
      end

        447 :
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
              ip = 448;
      end

        448 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[202]*6 + 0] = localMem[149];
              updateArrayLength(1, localMem[202], 0);
              ip = 449;
      end

        449 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[202]*6 + 2] = 0;
              updateArrayLength(1, localMem[202], 2);
              ip = 450;
      end

        450 :
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
              ip = 451;
      end

        451 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[202]*6 + 4] = localMem[203];
              updateArrayLength(1, localMem[202], 4);
              ip = 452;
      end

        452 :
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
              ip = 453;
      end

        453 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[202]*6 + 5] = localMem[204];
              updateArrayLength(1, localMem[202], 5);
              ip = 454;
      end

        454 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[202]*6 + 6] = 0;
              updateArrayLength(1, localMem[202], 6);
              ip = 455;
      end

        455 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[202]*6 + 3] = localMem[147];
              updateArrayLength(1, localMem[202], 3);
              ip = 456;
      end

        456 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[147]*6 + 1] = heapMem[localMem[147]*6 + 1] + 1;
              updateArrayLength(1, localMem[147], 1);
              ip = 457;
      end

        457 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[202]*6 + 1] = heapMem[localMem[147]*6 + 1];
              updateArrayLength(1, localMem[202], 1);
              ip = 458;
      end

        458 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[205] = !heapMem[localMem[144]*6 + 6];
              ip = 459;
      end

        459 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[205] != 0 ? 511 : 460;
      end

        460 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[206] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[206] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[206]] = 0;
              ip = 461;
      end

        461 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[199]*6 + 6] = localMem[206];
              updateArrayLength(1, localMem[199], 6);
              ip = 462;
      end

        462 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[207] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[207] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[207]] = 0;
              ip = 463;
      end

        463 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[202]*6 + 6] = localMem[207];
              updateArrayLength(1, localMem[202], 6);
              ip = 464;
      end

        464 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[208] = heapMem[localMem[144]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 465;
      end

        465 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[209] = heapMem[localMem[199]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 466;
      end

        466 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[149]) begin
                  heapMem[NArea * localMem[209] + 0 + i] = heapMem[NArea * localMem[208] + 0 + i];
                  updateArrayLength(1, localMem[209], 0 + i);
                end
              end
              ip = 467;
      end

        467 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[210] = heapMem[localMem[144]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 468;
      end

        468 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[211] = heapMem[localMem[199]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 469;
      end

        469 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[149]) begin
                  heapMem[NArea * localMem[211] + 0 + i] = heapMem[NArea * localMem[210] + 0 + i];
                  updateArrayLength(1, localMem[211], 0 + i);
                end
              end
              ip = 470;
      end

        470 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[212] = heapMem[localMem[144]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 471;
      end

        471 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[213] = heapMem[localMem[199]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 472;
      end

        472 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[214] = localMem[149] + 1;
              updateArrayLength(2, 0, 0);
              ip = 473;
      end

        473 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[214]) begin
                  heapMem[NArea * localMem[213] + 0 + i] = heapMem[NArea * localMem[212] + 0 + i];
                  updateArrayLength(1, localMem[213], 0 + i);
                end
              end
              ip = 474;
      end

        474 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[215] = heapMem[localMem[144]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 475;
      end

        475 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[216] = heapMem[localMem[202]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 476;
      end

        476 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[149]) begin
                  heapMem[NArea * localMem[216] + 0 + i] = heapMem[NArea * localMem[215] + localMem[150] + i];
                  updateArrayLength(1, localMem[216], 0 + i);
                end
              end
              ip = 477;
      end

        477 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[217] = heapMem[localMem[144]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 478;
      end

        478 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[218] = heapMem[localMem[202]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 479;
      end

        479 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[149]) begin
                  heapMem[NArea * localMem[218] + 0 + i] = heapMem[NArea * localMem[217] + localMem[150] + i];
                  updateArrayLength(1, localMem[218], 0 + i);
                end
              end
              ip = 480;
      end

        480 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[219] = heapMem[localMem[144]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 481;
      end

        481 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[220] = heapMem[localMem[202]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 482;
      end

        482 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[221] = localMem[149] + 1;
              updateArrayLength(2, 0, 0);
              ip = 483;
      end

        483 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[221]) begin
                  heapMem[NArea * localMem[220] + 0 + i] = heapMem[NArea * localMem[219] + localMem[150] + i];
                  updateArrayLength(1, localMem[220], 0 + i);
                end
              end
              ip = 484;
      end

        484 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[222] = heapMem[localMem[199]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 485;
      end

        485 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[223] = localMem[222] + 1;
              updateArrayLength(2, 0, 0);
              ip = 486;
      end

        486 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[224] = heapMem[localMem[199]*6 + 6];
              updateArrayLength(2, 0, 0);
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
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[225] = 0;
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
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[225] >= localMem[223] ? 496 : 491;
      end

        491 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[226] = heapMem[localMem[224]*6 + localMem[225]];
              updateArrayLength(2, 0, 0);
              ip = 492;
      end

        492 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[226]*6 + 2] = localMem[199];
              updateArrayLength(1, localMem[226], 2);
              ip = 493;
      end

        493 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 494;
      end

        494 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[225] = localMem[225] + 1;
              updateArrayLength(2, 0, 0);
              ip = 495;
      end

        495 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 489;
      end

        496 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 497;
      end

        497 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[227] = heapMem[localMem[202]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 498;
      end

        498 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[228] = localMem[227] + 1;
              updateArrayLength(2, 0, 0);
              ip = 499;
      end

        499 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[229] = heapMem[localMem[202]*6 + 6];
              updateArrayLength(2, 0, 0);
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
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[230] = 0;
              updateArrayLength(2, 0, 0);
              ip = 502;
      end

        502 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 503;
      end

        503 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[230] >= localMem[228] ? 509 : 504;
      end

        504 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[231] = heapMem[localMem[229]*6 + localMem[230]];
              updateArrayLength(2, 0, 0);
              ip = 505;
      end

        505 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[231]*6 + 2] = localMem[202];
              updateArrayLength(1, localMem[231], 2);
              ip = 506;
      end

        506 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 507;
      end

        507 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[230] = localMem[230] + 1;
              updateArrayLength(2, 0, 0);
              ip = 508;
      end

        508 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 502;
      end

        509 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 510;
      end

        510 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 526;
      end

        511 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 512;
      end

        512 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[232] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[232] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[232]] = 0;
              ip = 513;
      end

        513 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[144]*6 + 6] = localMem[232];
              updateArrayLength(1, localMem[144], 6);
              ip = 514;
      end

        514 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[233] = heapMem[localMem[144]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 515;
      end

        515 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[234] = heapMem[localMem[199]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 516;
      end

        516 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[149]) begin
                  heapMem[NArea * localMem[234] + 0 + i] = heapMem[NArea * localMem[233] + 0 + i];
                  updateArrayLength(1, localMem[234], 0 + i);
                end
              end
              ip = 517;
      end

        517 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[235] = heapMem[localMem[144]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 518;
      end

        518 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[236] = heapMem[localMem[199]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 519;
      end

        519 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[149]) begin
                  heapMem[NArea * localMem[236] + 0 + i] = heapMem[NArea * localMem[235] + 0 + i];
                  updateArrayLength(1, localMem[236], 0 + i);
                end
              end
              ip = 520;
      end

        520 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[237] = heapMem[localMem[144]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 521;
      end

        521 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[238] = heapMem[localMem[202]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 522;
      end

        522 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[149]) begin
                  heapMem[NArea * localMem[238] + 0 + i] = heapMem[NArea * localMem[237] + localMem[150] + i];
                  updateArrayLength(1, localMem[238], 0 + i);
                end
              end
              ip = 523;
      end

        523 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[239] = heapMem[localMem[144]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 524;
      end

        524 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[240] = heapMem[localMem[202]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 525;
      end

        525 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[149]) begin
                  heapMem[NArea * localMem[240] + 0 + i] = heapMem[NArea * localMem[239] + localMem[150] + i];
                  updateArrayLength(1, localMem[240], 0 + i);
                end
              end
              ip = 526;
      end

        526 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 527;
      end

        527 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[199]*6 + 2] = localMem[144];
              updateArrayLength(1, localMem[199], 2);
              ip = 528;
      end

        528 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[202]*6 + 2] = localMem[144];
              updateArrayLength(1, localMem[202], 2);
              ip = 529;
      end

        529 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[241] = heapMem[localMem[144]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 530;
      end

        530 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[242] = heapMem[localMem[241]*6 + localMem[149]];
              updateArrayLength(2, 0, 0);
              ip = 531;
      end

        531 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[243] = heapMem[localMem[144]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 532;
      end

        532 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[244] = heapMem[localMem[243]*6 + localMem[149]];
              updateArrayLength(2, 0, 0);
              ip = 533;
      end

        533 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[245] = heapMem[localMem[144]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 534;
      end

        534 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[245]*6 + 0] = localMem[242];
              updateArrayLength(1, localMem[245], 0);
              ip = 535;
      end

        535 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[246] = heapMem[localMem[144]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 536;
      end

        536 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[246]*6 + 0] = localMem[244];
              updateArrayLength(1, localMem[246], 0);
              ip = 537;
      end

        537 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[247] = heapMem[localMem[144]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 538;
      end

        538 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[247]*6 + 0] = localMem[199];
              updateArrayLength(1, localMem[247], 0);
              ip = 539;
      end

        539 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[248] = heapMem[localMem[144]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 540;
      end

        540 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[248]*6 + 1] = localMem[202];
              updateArrayLength(1, localMem[248], 1);
              ip = 541;
      end

        541 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[144]*6 + 0] = 1;
              updateArrayLength(1, localMem[144], 0);
              ip = 542;
      end

        542 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[249] = heapMem[localMem[144]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 543;
      end

        543 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[249]] = 1;
              ip = 544;
      end

        544 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[250] = heapMem[localMem[144]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 545;
      end

        545 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[250]] = 1;
              ip = 546;
      end

        546 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[251] = heapMem[localMem[144]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 547;
      end

        547 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[251]] = 2;
              ip = 548;
      end

        548 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 550;
      end

        549 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 555;
      end

        550 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 551;
      end

        551 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[145] = 1;
              updateArrayLength(2, 0, 0);
              ip = 552;
      end

        552 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 555;
      end

        553 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 554;
      end

        554 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[145] = 0;
              updateArrayLength(2, 0, 0);
              ip = 555;
      end

        555 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 556;
      end

        556 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[145] != 0 ? 558 : 557;
      end

        557 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[29] = localMem[144];
              updateArrayLength(2, 0, 0);
              ip = 558;
      end

        558 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 559;
      end

        559 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 809;
      end

        560 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 561;
      end

        561 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[252] = heapMem[localMem[29]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 562;
      end

        562 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[253] = 0; k = arraySizes[localMem[252]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[252] * NArea + i] == localMem[4]) localMem[253] = i + 1;
              end
              ip = 563;
      end

        563 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[253] == 0 ? 568 : 564;
      end

        564 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[6]*6 + 0] = localMem[29];
              updateArrayLength(1, localMem[6], 0);
              ip = 565;
      end

        565 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[6]*6 + 1] = 1;
              updateArrayLength(1, localMem[6], 1);
              ip = 566;
      end

        566 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              heapMem[localMem[6]*6 + 2] = localMem[253] - 1;
              updateArrayLength(1, localMem[6], 2);
              ip = 567;
      end

        567 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 816;
      end

        568 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 569;
      end

        569 :
      begin                                                                     // arrayCountLess
if (0) begin
  $display("AAAA %4d %4d arrayCountLess", steps, ip);
end
              j = 0; k = arraySizes[localMem[252]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[252] * NArea + i] < localMem[4]) j = j + 1;
              end
              localMem[254] = j;
              ip = 570;
      end

        570 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[255] = !heapMem[localMem[29]*6 + 6];
              ip = 571;
      end

        571 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[255] == 0 ? 576 : 572;
      end

        572 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[6]*6 + 0] = localMem[29];
              updateArrayLength(1, localMem[6], 0);
              ip = 573;
      end

        573 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[6]*6 + 1] = 0;
              updateArrayLength(1, localMem[6], 1);
              ip = 574;
      end

        574 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[6]*6 + 2] = localMem[254];
              updateArrayLength(1, localMem[6], 2);
              ip = 575;
      end

        575 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 816;
      end

        576 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 577;
      end

        577 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[256] = heapMem[localMem[29]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 578;
      end

        578 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[257] = heapMem[localMem[256]*6 + localMem[254]];
              updateArrayLength(2, 0, 0);
              ip = 579;
      end

        579 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 580;
      end

        580 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[259] = heapMem[localMem[257]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 581;
      end

        581 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[260] = heapMem[localMem[257]*6 + 3];
              updateArrayLength(2, 0, 0);
              ip = 582;
      end

        582 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[261] = heapMem[localMem[260]*6 + 2];
              updateArrayLength(2, 0, 0);
              ip = 583;
      end

        583 :
      begin                                                                     // jLt
if (0) begin
  $display("AAAA %4d %4d jLt", steps, ip);
end
              ip = localMem[259] <  localMem[261] ? 803 : 584;
      end

        584 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[262] = localMem[261];
              updateArrayLength(2, 0, 0);
              ip = 585;
      end

        585 :
      begin                                                                     // shiftRight
if (0) begin
  $display("AAAA %4d %4d shiftRight", steps, ip);
end
              localMem[262] = localMem[262] >> 1;
              ip = 586;
      end

        586 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[263] = localMem[262] + 1;
              updateArrayLength(2, 0, 0);
              ip = 587;
      end

        587 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[264] = heapMem[localMem[257]*6 + 2];
              updateArrayLength(2, 0, 0);
              ip = 588;
      end

        588 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[264] == 0 ? 685 : 589;
      end

        589 :
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
              ip = 590;
      end

        590 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[265]*6 + 0] = localMem[262];
              updateArrayLength(1, localMem[265], 0);
              ip = 591;
      end

        591 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[265]*6 + 2] = 0;
              updateArrayLength(1, localMem[265], 2);
              ip = 592;
      end

        592 :
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
              ip = 593;
      end

        593 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[265]*6 + 4] = localMem[266];
              updateArrayLength(1, localMem[265], 4);
              ip = 594;
      end

        594 :
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
              ip = 595;
      end

        595 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[265]*6 + 5] = localMem[267];
              updateArrayLength(1, localMem[265], 5);
              ip = 596;
      end

        596 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[265]*6 + 6] = 0;
              updateArrayLength(1, localMem[265], 6);
              ip = 597;
      end

        597 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[265]*6 + 3] = localMem[260];
              updateArrayLength(1, localMem[265], 3);
              ip = 598;
      end

        598 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[260]*6 + 1] = heapMem[localMem[260]*6 + 1] + 1;
              updateArrayLength(1, localMem[260], 1);
              ip = 599;
      end

        599 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[265]*6 + 1] = heapMem[localMem[260]*6 + 1];
              updateArrayLength(1, localMem[265], 1);
              ip = 600;
      end

        600 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[268] = !heapMem[localMem[257]*6 + 6];
              ip = 601;
      end

        601 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[268] != 0 ? 630 : 602;
      end

        602 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[269] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[269] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[269]] = 0;
              ip = 603;
      end

        603 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[265]*6 + 6] = localMem[269];
              updateArrayLength(1, localMem[265], 6);
              ip = 604;
      end

        604 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[270] = heapMem[localMem[257]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 605;
      end

        605 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[271] = heapMem[localMem[265]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 606;
      end

        606 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[262]) begin
                  heapMem[NArea * localMem[271] + 0 + i] = heapMem[NArea * localMem[270] + localMem[263] + i];
                  updateArrayLength(1, localMem[271], 0 + i);
                end
              end
              ip = 607;
      end

        607 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[272] = heapMem[localMem[257]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 608;
      end

        608 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[273] = heapMem[localMem[265]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 609;
      end

        609 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[262]) begin
                  heapMem[NArea * localMem[273] + 0 + i] = heapMem[NArea * localMem[272] + localMem[263] + i];
                  updateArrayLength(1, localMem[273], 0 + i);
                end
              end
              ip = 610;
      end

        610 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[274] = heapMem[localMem[257]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 611;
      end

        611 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[275] = heapMem[localMem[265]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 612;
      end

        612 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[276] = localMem[262] + 1;
              updateArrayLength(2, 0, 0);
              ip = 613;
      end

        613 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[276]) begin
                  heapMem[NArea * localMem[275] + 0 + i] = heapMem[NArea * localMem[274] + localMem[263] + i];
                  updateArrayLength(1, localMem[275], 0 + i);
                end
              end
              ip = 614;
      end

        614 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[277] = heapMem[localMem[265]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 615;
      end

        615 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[278] = localMem[277] + 1;
              updateArrayLength(2, 0, 0);
              ip = 616;
      end

        616 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[279] = heapMem[localMem[265]*6 + 6];
              updateArrayLength(2, 0, 0);
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
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[280] = 0;
              updateArrayLength(2, 0, 0);
              ip = 619;
      end

        619 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 620;
      end

        620 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[280] >= localMem[278] ? 626 : 621;
      end

        621 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[281] = heapMem[localMem[279]*6 + localMem[280]];
              updateArrayLength(2, 0, 0);
              ip = 622;
      end

        622 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[281]*6 + 2] = localMem[265];
              updateArrayLength(1, localMem[281], 2);
              ip = 623;
      end

        623 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 624;
      end

        624 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[280] = localMem[280] + 1;
              updateArrayLength(2, 0, 0);
              ip = 625;
      end

        625 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 619;
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
              localMem[282] = heapMem[localMem[257]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 628;
      end

        628 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[282]] = localMem[263];
              ip = 629;
      end

        629 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 637;
      end

        630 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 631;
      end

        631 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[283] = heapMem[localMem[257]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 632;
      end

        632 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[284] = heapMem[localMem[265]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 633;
      end

        633 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[262]) begin
                  heapMem[NArea * localMem[284] + 0 + i] = heapMem[NArea * localMem[283] + localMem[263] + i];
                  updateArrayLength(1, localMem[284], 0 + i);
                end
              end
              ip = 634;
      end

        634 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[285] = heapMem[localMem[257]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 635;
      end

        635 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[286] = heapMem[localMem[265]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 636;
      end

        636 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[262]) begin
                  heapMem[NArea * localMem[286] + 0 + i] = heapMem[NArea * localMem[285] + localMem[263] + i];
                  updateArrayLength(1, localMem[286], 0 + i);
                end
              end
              ip = 637;
      end

        637 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 638;
      end

        638 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[257]*6 + 0] = localMem[262];
              updateArrayLength(1, localMem[257], 0);
              ip = 639;
      end

        639 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[265]*6 + 2] = localMem[264];
              updateArrayLength(1, localMem[265], 2);
              ip = 640;
      end

        640 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[287] = heapMem[localMem[264]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 641;
      end

        641 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[288] = heapMem[localMem[264]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 642;
      end

        642 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[289] = heapMem[localMem[288]*6 + localMem[287]];
              updateArrayLength(2, 0, 0);
              ip = 643;
      end

        643 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[289] != localMem[257] ? 662 : 644;
      end

        644 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[290] = heapMem[localMem[257]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 645;
      end

        645 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[291] = heapMem[localMem[290]*6 + localMem[262]];
              updateArrayLength(2, 0, 0);
              ip = 646;
      end

        646 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[292] = heapMem[localMem[264]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 647;
      end

        647 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[292]*6 + localMem[287]] = localMem[291];
              updateArrayLength(1, localMem[292], localMem[287]);
              ip = 648;
      end

        648 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[293] = heapMem[localMem[257]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 649;
      end

        649 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[294] = heapMem[localMem[293]*6 + localMem[262]];
              updateArrayLength(2, 0, 0);
              ip = 650;
      end

        650 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[295] = heapMem[localMem[264]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 651;
      end

        651 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[295]*6 + localMem[287]] = localMem[294];
              updateArrayLength(1, localMem[295], localMem[287]);
              ip = 652;
      end

        652 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[296] = heapMem[localMem[257]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 653;
      end

        653 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[296]] = localMem[262];
              ip = 654;
      end

        654 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[297] = heapMem[localMem[257]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 655;
      end

        655 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[297]] = localMem[262];
              ip = 656;
      end

        656 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[298] = localMem[287] + 1;
              updateArrayLength(2, 0, 0);
              ip = 657;
      end

        657 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[264]*6 + 0] = localMem[298];
              updateArrayLength(1, localMem[264], 0);
              ip = 658;
      end

        658 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[299] = heapMem[localMem[264]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 659;
      end

        659 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[299]*6 + localMem[298]] = localMem[265];
              updateArrayLength(1, localMem[299], localMem[298]);
              ip = 660;
      end

        660 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 800;
      end

        661 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 684;
      end

        662 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 663;
      end

        663 :
      begin                                                                     // assertNe
if (0) begin
  $display("AAAA %4d %4d assertNe", steps, ip);
end
            ip = 664;
      end

        664 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[300] = heapMem[localMem[264]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 665;
      end

        665 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[301] = 0; k = arraySizes[localMem[300]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[300] * NArea + i] == localMem[257]) localMem[301] = i + 1;
              end
              ip = 666;
      end

        666 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[301] = localMem[301] - 1;
              updateArrayLength(2, 0, 0);
              ip = 667;
      end

        667 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[302] = heapMem[localMem[257]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 668;
      end

        668 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[303] = heapMem[localMem[302]*6 + localMem[262]];
              updateArrayLength(2, 0, 0);
              ip = 669;
      end

        669 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[304] = heapMem[localMem[257]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 670;
      end

        670 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[305] = heapMem[localMem[304]*6 + localMem[262]];
              updateArrayLength(2, 0, 0);
              ip = 671;
      end

        671 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[306] = heapMem[localMem[257]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 672;
      end

        672 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[306]] = localMem[262];
              ip = 673;
      end

        673 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[307] = heapMem[localMem[257]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 674;
      end

        674 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[307]] = localMem[262];
              ip = 675;
      end

        675 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[308] = heapMem[localMem[264]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 676;
      end

        676 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[308] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[301], localMem[308], arraySizes[localMem[308]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[301] && i <= arraySizes[localMem[308]]) begin
                  heapMem[NArea * localMem[308] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[308] + localMem[301]] = localMem[303];                                    // Insert new value
              arraySizes[localMem[308]] = arraySizes[localMem[308]] + 1;                              // Increase array size
              ip = 677;
      end

        677 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[309] = heapMem[localMem[264]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 678;
      end

        678 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[309] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[301], localMem[309], arraySizes[localMem[309]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[301] && i <= arraySizes[localMem[309]]) begin
                  heapMem[NArea * localMem[309] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[309] + localMem[301]] = localMem[305];                                    // Insert new value
              arraySizes[localMem[309]] = arraySizes[localMem[309]] + 1;                              // Increase array size
              ip = 679;
      end

        679 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[310] = heapMem[localMem[264]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 680;
      end

        680 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[311] = localMem[301] + 1;
              updateArrayLength(2, 0, 0);
              ip = 681;
      end

        681 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[310] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[311], localMem[310], arraySizes[localMem[310]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[311] && i <= arraySizes[localMem[310]]) begin
                  heapMem[NArea * localMem[310] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[310] + localMem[311]] = localMem[265];                                    // Insert new value
              arraySizes[localMem[310]] = arraySizes[localMem[310]] + 1;                              // Increase array size
              ip = 682;
      end

        682 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[264]*6 + 0] = heapMem[localMem[264]*6 + 0] + 1;
              updateArrayLength(1, localMem[264], 0);
              ip = 683;
      end

        683 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 800;
      end

        684 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 685;
      end

        685 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 686;
      end

        686 :
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
              ip = 687;
      end

        687 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[312]*6 + 0] = localMem[262];
              updateArrayLength(1, localMem[312], 0);
              ip = 688;
      end

        688 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[312]*6 + 2] = 0;
              updateArrayLength(1, localMem[312], 2);
              ip = 689;
      end

        689 :
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
              ip = 690;
      end

        690 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[312]*6 + 4] = localMem[313];
              updateArrayLength(1, localMem[312], 4);
              ip = 691;
      end

        691 :
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
              ip = 692;
      end

        692 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[312]*6 + 5] = localMem[314];
              updateArrayLength(1, localMem[312], 5);
              ip = 693;
      end

        693 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[312]*6 + 6] = 0;
              updateArrayLength(1, localMem[312], 6);
              ip = 694;
      end

        694 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[312]*6 + 3] = localMem[260];
              updateArrayLength(1, localMem[312], 3);
              ip = 695;
      end

        695 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[260]*6 + 1] = heapMem[localMem[260]*6 + 1] + 1;
              updateArrayLength(1, localMem[260], 1);
              ip = 696;
      end

        696 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[312]*6 + 1] = heapMem[localMem[260]*6 + 1];
              updateArrayLength(1, localMem[312], 1);
              ip = 697;
      end

        697 :
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
              ip = 698;
      end

        698 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[315]*6 + 0] = localMem[262];
              updateArrayLength(1, localMem[315], 0);
              ip = 699;
      end

        699 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[315]*6 + 2] = 0;
              updateArrayLength(1, localMem[315], 2);
              ip = 700;
      end

        700 :
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
              ip = 701;
      end

        701 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[315]*6 + 4] = localMem[316];
              updateArrayLength(1, localMem[315], 4);
              ip = 702;
      end

        702 :
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
              ip = 703;
      end

        703 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[315]*6 + 5] = localMem[317];
              updateArrayLength(1, localMem[315], 5);
              ip = 704;
      end

        704 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[315]*6 + 6] = 0;
              updateArrayLength(1, localMem[315], 6);
              ip = 705;
      end

        705 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[315]*6 + 3] = localMem[260];
              updateArrayLength(1, localMem[315], 3);
              ip = 706;
      end

        706 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[260]*6 + 1] = heapMem[localMem[260]*6 + 1] + 1;
              updateArrayLength(1, localMem[260], 1);
              ip = 707;
      end

        707 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[315]*6 + 1] = heapMem[localMem[260]*6 + 1];
              updateArrayLength(1, localMem[315], 1);
              ip = 708;
      end

        708 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[318] = !heapMem[localMem[257]*6 + 6];
              ip = 709;
      end

        709 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[318] != 0 ? 761 : 710;
      end

        710 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[319] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[319] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[319]] = 0;
              ip = 711;
      end

        711 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[312]*6 + 6] = localMem[319];
              updateArrayLength(1, localMem[312], 6);
              ip = 712;
      end

        712 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[320] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[320] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[320]] = 0;
              ip = 713;
      end

        713 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[315]*6 + 6] = localMem[320];
              updateArrayLength(1, localMem[315], 6);
              ip = 714;
      end

        714 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[321] = heapMem[localMem[257]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 715;
      end

        715 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[322] = heapMem[localMem[312]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 716;
      end

        716 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[262]) begin
                  heapMem[NArea * localMem[322] + 0 + i] = heapMem[NArea * localMem[321] + 0 + i];
                  updateArrayLength(1, localMem[322], 0 + i);
                end
              end
              ip = 717;
      end

        717 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[323] = heapMem[localMem[257]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 718;
      end

        718 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[324] = heapMem[localMem[312]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 719;
      end

        719 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[262]) begin
                  heapMem[NArea * localMem[324] + 0 + i] = heapMem[NArea * localMem[323] + 0 + i];
                  updateArrayLength(1, localMem[324], 0 + i);
                end
              end
              ip = 720;
      end

        720 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[325] = heapMem[localMem[257]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 721;
      end

        721 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[326] = heapMem[localMem[312]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 722;
      end

        722 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[327] = localMem[262] + 1;
              updateArrayLength(2, 0, 0);
              ip = 723;
      end

        723 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[327]) begin
                  heapMem[NArea * localMem[326] + 0 + i] = heapMem[NArea * localMem[325] + 0 + i];
                  updateArrayLength(1, localMem[326], 0 + i);
                end
              end
              ip = 724;
      end

        724 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[328] = heapMem[localMem[257]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 725;
      end

        725 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[329] = heapMem[localMem[315]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 726;
      end

        726 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[262]) begin
                  heapMem[NArea * localMem[329] + 0 + i] = heapMem[NArea * localMem[328] + localMem[263] + i];
                  updateArrayLength(1, localMem[329], 0 + i);
                end
              end
              ip = 727;
      end

        727 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[330] = heapMem[localMem[257]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 728;
      end

        728 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[331] = heapMem[localMem[315]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 729;
      end

        729 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[262]) begin
                  heapMem[NArea * localMem[331] + 0 + i] = heapMem[NArea * localMem[330] + localMem[263] + i];
                  updateArrayLength(1, localMem[331], 0 + i);
                end
              end
              ip = 730;
      end

        730 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[332] = heapMem[localMem[257]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 731;
      end

        731 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[333] = heapMem[localMem[315]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 732;
      end

        732 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[334] = localMem[262] + 1;
              updateArrayLength(2, 0, 0);
              ip = 733;
      end

        733 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[334]) begin
                  heapMem[NArea * localMem[333] + 0 + i] = heapMem[NArea * localMem[332] + localMem[263] + i];
                  updateArrayLength(1, localMem[333], 0 + i);
                end
              end
              ip = 734;
      end

        734 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[335] = heapMem[localMem[312]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 735;
      end

        735 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[336] = localMem[335] + 1;
              updateArrayLength(2, 0, 0);
              ip = 736;
      end

        736 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[337] = heapMem[localMem[312]*6 + 6];
              updateArrayLength(2, 0, 0);
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
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[338] = 0;
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
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[338] >= localMem[336] ? 746 : 741;
      end

        741 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[339] = heapMem[localMem[337]*6 + localMem[338]];
              updateArrayLength(2, 0, 0);
              ip = 742;
      end

        742 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[339]*6 + 2] = localMem[312];
              updateArrayLength(1, localMem[339], 2);
              ip = 743;
      end

        743 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 744;
      end

        744 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[338] = localMem[338] + 1;
              updateArrayLength(2, 0, 0);
              ip = 745;
      end

        745 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 739;
      end

        746 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 747;
      end

        747 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[340] = heapMem[localMem[315]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 748;
      end

        748 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[341] = localMem[340] + 1;
              updateArrayLength(2, 0, 0);
              ip = 749;
      end

        749 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[342] = heapMem[localMem[315]*6 + 6];
              updateArrayLength(2, 0, 0);
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
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[343] = 0;
              updateArrayLength(2, 0, 0);
              ip = 752;
      end

        752 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 753;
      end

        753 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[343] >= localMem[341] ? 759 : 754;
      end

        754 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[344] = heapMem[localMem[342]*6 + localMem[343]];
              updateArrayLength(2, 0, 0);
              ip = 755;
      end

        755 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[344]*6 + 2] = localMem[315];
              updateArrayLength(1, localMem[344], 2);
              ip = 756;
      end

        756 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 757;
      end

        757 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[343] = localMem[343] + 1;
              updateArrayLength(2, 0, 0);
              ip = 758;
      end

        758 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 752;
      end

        759 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 760;
      end

        760 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 776;
      end

        761 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 762;
      end

        762 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[345] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[345] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[345]] = 0;
              ip = 763;
      end

        763 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[257]*6 + 6] = localMem[345];
              updateArrayLength(1, localMem[257], 6);
              ip = 764;
      end

        764 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[346] = heapMem[localMem[257]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 765;
      end

        765 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[347] = heapMem[localMem[312]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 766;
      end

        766 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[262]) begin
                  heapMem[NArea * localMem[347] + 0 + i] = heapMem[NArea * localMem[346] + 0 + i];
                  updateArrayLength(1, localMem[347], 0 + i);
                end
              end
              ip = 767;
      end

        767 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[348] = heapMem[localMem[257]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 768;
      end

        768 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[349] = heapMem[localMem[312]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 769;
      end

        769 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[262]) begin
                  heapMem[NArea * localMem[349] + 0 + i] = heapMem[NArea * localMem[348] + 0 + i];
                  updateArrayLength(1, localMem[349], 0 + i);
                end
              end
              ip = 770;
      end

        770 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[350] = heapMem[localMem[257]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 771;
      end

        771 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[351] = heapMem[localMem[315]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 772;
      end

        772 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[262]) begin
                  heapMem[NArea * localMem[351] + 0 + i] = heapMem[NArea * localMem[350] + localMem[263] + i];
                  updateArrayLength(1, localMem[351], 0 + i);
                end
              end
              ip = 773;
      end

        773 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[352] = heapMem[localMem[257]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 774;
      end

        774 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[353] = heapMem[localMem[315]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 775;
      end

        775 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[262]) begin
                  heapMem[NArea * localMem[353] + 0 + i] = heapMem[NArea * localMem[352] + localMem[263] + i];
                  updateArrayLength(1, localMem[353], 0 + i);
                end
              end
              ip = 776;
      end

        776 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 777;
      end

        777 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[312]*6 + 2] = localMem[257];
              updateArrayLength(1, localMem[312], 2);
              ip = 778;
      end

        778 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[315]*6 + 2] = localMem[257];
              updateArrayLength(1, localMem[315], 2);
              ip = 779;
      end

        779 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[354] = heapMem[localMem[257]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 780;
      end

        780 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[355] = heapMem[localMem[354]*6 + localMem[262]];
              updateArrayLength(2, 0, 0);
              ip = 781;
      end

        781 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[356] = heapMem[localMem[257]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 782;
      end

        782 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[357] = heapMem[localMem[356]*6 + localMem[262]];
              updateArrayLength(2, 0, 0);
              ip = 783;
      end

        783 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[358] = heapMem[localMem[257]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 784;
      end

        784 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[358]*6 + 0] = localMem[355];
              updateArrayLength(1, localMem[358], 0);
              ip = 785;
      end

        785 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[359] = heapMem[localMem[257]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 786;
      end

        786 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[359]*6 + 0] = localMem[357];
              updateArrayLength(1, localMem[359], 0);
              ip = 787;
      end

        787 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[360] = heapMem[localMem[257]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 788;
      end

        788 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[360]*6 + 0] = localMem[312];
              updateArrayLength(1, localMem[360], 0);
              ip = 789;
      end

        789 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[361] = heapMem[localMem[257]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 790;
      end

        790 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[361]*6 + 1] = localMem[315];
              updateArrayLength(1, localMem[361], 1);
              ip = 791;
      end

        791 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[257]*6 + 0] = 1;
              updateArrayLength(1, localMem[257], 0);
              ip = 792;
      end

        792 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[362] = heapMem[localMem[257]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 793;
      end

        793 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[362]] = 1;
              ip = 794;
      end

        794 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[363] = heapMem[localMem[257]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 795;
      end

        795 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[363]] = 1;
              ip = 796;
      end

        796 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[364] = heapMem[localMem[257]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 797;
      end

        797 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[364]] = 2;
              ip = 798;
      end

        798 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 800;
      end

        799 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 805;
      end

        800 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 801;
      end

        801 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[258] = 1;
              updateArrayLength(2, 0, 0);
              ip = 802;
      end

        802 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 805;
      end

        803 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 804;
      end

        804 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[258] = 0;
              updateArrayLength(2, 0, 0);
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
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[258] != 0 ? 808 : 807;
      end

        807 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[29] = localMem[257];
              updateArrayLength(2, 0, 0);
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
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[137] = localMem[137] + 1;
              updateArrayLength(2, 0, 0);
              ip = 811;
      end

        811 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 313;
      end

        812 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 813;
      end

        813 :
      begin                                                                     // assert
if (0) begin
  $display("AAAA %4d %4d assert", steps, ip);
end
            ip = 814;
      end

        814 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 815;
      end

        815 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 816;
      end

        816 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 817;
      end

        817 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[365] = heapMem[localMem[6]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 818;
      end

        818 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[366] = heapMem[localMem[6]*6 + 1];
              updateArrayLength(2, 0, 0);
              ip = 819;
      end

        819 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[367] = heapMem[localMem[6]*6 + 2];
              updateArrayLength(2, 0, 0);
              ip = 820;
      end

        820 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[366] != 1 ? 824 : 821;
      end

        821 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[368] = heapMem[localMem[365]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 822;
      end

        822 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[368]*6 + localMem[367]] = localMem[5];
              updateArrayLength(1, localMem[368], localMem[367]);
              ip = 823;
      end

        823 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1070;
      end

        824 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 825;
      end

        825 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[366] != 2 ? 833 : 826;
      end

        826 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[369] = localMem[367] + 1;
              updateArrayLength(2, 0, 0);
              ip = 827;
      end

        827 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[370] = heapMem[localMem[365]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 828;
      end

        828 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[370] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[369], localMem[370], arraySizes[localMem[370]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[369] && i <= arraySizes[localMem[370]]) begin
                  heapMem[NArea * localMem[370] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[370] + localMem[369]] = localMem[4];                                    // Insert new value
              arraySizes[localMem[370]] = arraySizes[localMem[370]] + 1;                              // Increase array size
              ip = 829;
      end

        829 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[371] = heapMem[localMem[365]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 830;
      end

        830 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[371] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[369], localMem[371], arraySizes[localMem[371]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[369] && i <= arraySizes[localMem[371]]) begin
                  heapMem[NArea * localMem[371] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[371] + localMem[369]] = localMem[5];                                    // Insert new value
              arraySizes[localMem[371]] = arraySizes[localMem[371]] + 1;                              // Increase array size
              ip = 831;
      end

        831 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[365]*6 + 0] = heapMem[localMem[365]*6 + 0] + 1;
              updateArrayLength(1, localMem[365], 0);
              ip = 832;
      end

        832 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 839;
      end

        833 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 834;
      end

        834 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[372] = heapMem[localMem[365]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 835;
      end

        835 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[372] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[367], localMem[372], arraySizes[localMem[372]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[367] && i <= arraySizes[localMem[372]]) begin
                  heapMem[NArea * localMem[372] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[372] + localMem[367]] = localMem[4];                                    // Insert new value
              arraySizes[localMem[372]] = arraySizes[localMem[372]] + 1;                              // Increase array size
              ip = 836;
      end

        836 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[373] = heapMem[localMem[365]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 837;
      end

        837 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[373] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[367], localMem[373], arraySizes[localMem[373]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[367] && i <= arraySizes[localMem[373]]) begin
                  heapMem[NArea * localMem[373] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[373] + localMem[367]] = localMem[5];                                    // Insert new value
              arraySizes[localMem[373]] = arraySizes[localMem[373]] + 1;                              // Increase array size
              ip = 838;
      end

        838 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[365]*6 + 0] = heapMem[localMem[365]*6 + 0] + 1;
              updateArrayLength(1, localMem[365], 0);
              ip = 839;
      end

        839 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 840;
      end

        840 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[3]*6 + 0] = heapMem[localMem[3]*6 + 0] + 1;
              updateArrayLength(1, localMem[3], 0);
              ip = 841;
      end

        841 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 842;
      end

        842 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[375] = heapMem[localMem[365]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 843;
      end

        843 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[376] = heapMem[localMem[365]*6 + 3];
              updateArrayLength(2, 0, 0);
              ip = 844;
      end

        844 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[377] = heapMem[localMem[376]*6 + 2];
              updateArrayLength(2, 0, 0);
              ip = 845;
      end

        845 :
      begin                                                                     // jLt
if (0) begin
  $display("AAAA %4d %4d jLt", steps, ip);
end
              ip = localMem[375] <  localMem[377] ? 1065 : 846;
      end

        846 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[378] = localMem[377];
              updateArrayLength(2, 0, 0);
              ip = 847;
      end

        847 :
      begin                                                                     // shiftRight
if (0) begin
  $display("AAAA %4d %4d shiftRight", steps, ip);
end
              localMem[378] = localMem[378] >> 1;
              ip = 848;
      end

        848 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[379] = localMem[378] + 1;
              updateArrayLength(2, 0, 0);
              ip = 849;
      end

        849 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[380] = heapMem[localMem[365]*6 + 2];
              updateArrayLength(2, 0, 0);
              ip = 850;
      end

        850 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[380] == 0 ? 947 : 851;
      end

        851 :
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
              ip = 852;
      end

        852 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[381]*6 + 0] = localMem[378];
              updateArrayLength(1, localMem[381], 0);
              ip = 853;
      end

        853 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[381]*6 + 2] = 0;
              updateArrayLength(1, localMem[381], 2);
              ip = 854;
      end

        854 :
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
              ip = 855;
      end

        855 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[381]*6 + 4] = localMem[382];
              updateArrayLength(1, localMem[381], 4);
              ip = 856;
      end

        856 :
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
              ip = 857;
      end

        857 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[381]*6 + 5] = localMem[383];
              updateArrayLength(1, localMem[381], 5);
              ip = 858;
      end

        858 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[381]*6 + 6] = 0;
              updateArrayLength(1, localMem[381], 6);
              ip = 859;
      end

        859 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[381]*6 + 3] = localMem[376];
              updateArrayLength(1, localMem[381], 3);
              ip = 860;
      end

        860 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[376]*6 + 1] = heapMem[localMem[376]*6 + 1] + 1;
              updateArrayLength(1, localMem[376], 1);
              ip = 861;
      end

        861 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[381]*6 + 1] = heapMem[localMem[376]*6 + 1];
              updateArrayLength(1, localMem[381], 1);
              ip = 862;
      end

        862 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[384] = !heapMem[localMem[365]*6 + 6];
              ip = 863;
      end

        863 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[384] != 0 ? 892 : 864;
      end

        864 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[385] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[385] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[385]] = 0;
              ip = 865;
      end

        865 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[381]*6 + 6] = localMem[385];
              updateArrayLength(1, localMem[381], 6);
              ip = 866;
      end

        866 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[386] = heapMem[localMem[365]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 867;
      end

        867 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[387] = heapMem[localMem[381]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 868;
      end

        868 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[378]) begin
                  heapMem[NArea * localMem[387] + 0 + i] = heapMem[NArea * localMem[386] + localMem[379] + i];
                  updateArrayLength(1, localMem[387], 0 + i);
                end
              end
              ip = 869;
      end

        869 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[388] = heapMem[localMem[365]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 870;
      end

        870 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[389] = heapMem[localMem[381]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 871;
      end

        871 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[378]) begin
                  heapMem[NArea * localMem[389] + 0 + i] = heapMem[NArea * localMem[388] + localMem[379] + i];
                  updateArrayLength(1, localMem[389], 0 + i);
                end
              end
              ip = 872;
      end

        872 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[390] = heapMem[localMem[365]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 873;
      end

        873 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[391] = heapMem[localMem[381]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 874;
      end

        874 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[392] = localMem[378] + 1;
              updateArrayLength(2, 0, 0);
              ip = 875;
      end

        875 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[392]) begin
                  heapMem[NArea * localMem[391] + 0 + i] = heapMem[NArea * localMem[390] + localMem[379] + i];
                  updateArrayLength(1, localMem[391], 0 + i);
                end
              end
              ip = 876;
      end

        876 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[393] = heapMem[localMem[381]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 877;
      end

        877 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[394] = localMem[393] + 1;
              updateArrayLength(2, 0, 0);
              ip = 878;
      end

        878 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[395] = heapMem[localMem[381]*6 + 6];
              updateArrayLength(2, 0, 0);
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
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[396] = 0;
              updateArrayLength(2, 0, 0);
              ip = 881;
      end

        881 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 882;
      end

        882 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[396] >= localMem[394] ? 888 : 883;
      end

        883 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[397] = heapMem[localMem[395]*6 + localMem[396]];
              updateArrayLength(2, 0, 0);
              ip = 884;
      end

        884 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[397]*6 + 2] = localMem[381];
              updateArrayLength(1, localMem[397], 2);
              ip = 885;
      end

        885 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 886;
      end

        886 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[396] = localMem[396] + 1;
              updateArrayLength(2, 0, 0);
              ip = 887;
      end

        887 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 881;
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
              localMem[398] = heapMem[localMem[365]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 890;
      end

        890 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[398]] = localMem[379];
              ip = 891;
      end

        891 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 899;
      end

        892 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 893;
      end

        893 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[399] = heapMem[localMem[365]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 894;
      end

        894 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[400] = heapMem[localMem[381]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 895;
      end

        895 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[378]) begin
                  heapMem[NArea * localMem[400] + 0 + i] = heapMem[NArea * localMem[399] + localMem[379] + i];
                  updateArrayLength(1, localMem[400], 0 + i);
                end
              end
              ip = 896;
      end

        896 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[401] = heapMem[localMem[365]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 897;
      end

        897 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[402] = heapMem[localMem[381]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 898;
      end

        898 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[378]) begin
                  heapMem[NArea * localMem[402] + 0 + i] = heapMem[NArea * localMem[401] + localMem[379] + i];
                  updateArrayLength(1, localMem[402], 0 + i);
                end
              end
              ip = 899;
      end

        899 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 900;
      end

        900 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[365]*6 + 0] = localMem[378];
              updateArrayLength(1, localMem[365], 0);
              ip = 901;
      end

        901 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[381]*6 + 2] = localMem[380];
              updateArrayLength(1, localMem[381], 2);
              ip = 902;
      end

        902 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[403] = heapMem[localMem[380]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 903;
      end

        903 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[404] = heapMem[localMem[380]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 904;
      end

        904 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[405] = heapMem[localMem[404]*6 + localMem[403]];
              updateArrayLength(2, 0, 0);
              ip = 905;
      end

        905 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[405] != localMem[365] ? 924 : 906;
      end

        906 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[406] = heapMem[localMem[365]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 907;
      end

        907 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[407] = heapMem[localMem[406]*6 + localMem[378]];
              updateArrayLength(2, 0, 0);
              ip = 908;
      end

        908 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[408] = heapMem[localMem[380]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 909;
      end

        909 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[408]*6 + localMem[403]] = localMem[407];
              updateArrayLength(1, localMem[408], localMem[403]);
              ip = 910;
      end

        910 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[409] = heapMem[localMem[365]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 911;
      end

        911 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[410] = heapMem[localMem[409]*6 + localMem[378]];
              updateArrayLength(2, 0, 0);
              ip = 912;
      end

        912 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[411] = heapMem[localMem[380]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 913;
      end

        913 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[411]*6 + localMem[403]] = localMem[410];
              updateArrayLength(1, localMem[411], localMem[403]);
              ip = 914;
      end

        914 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[412] = heapMem[localMem[365]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 915;
      end

        915 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[412]] = localMem[378];
              ip = 916;
      end

        916 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[413] = heapMem[localMem[365]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 917;
      end

        917 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[413]] = localMem[378];
              ip = 918;
      end

        918 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[414] = localMem[403] + 1;
              updateArrayLength(2, 0, 0);
              ip = 919;
      end

        919 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[380]*6 + 0] = localMem[414];
              updateArrayLength(1, localMem[380], 0);
              ip = 920;
      end

        920 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[415] = heapMem[localMem[380]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 921;
      end

        921 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[415]*6 + localMem[414]] = localMem[381];
              updateArrayLength(1, localMem[415], localMem[414]);
              ip = 922;
      end

        922 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1062;
      end

        923 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 946;
      end

        924 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 925;
      end

        925 :
      begin                                                                     // assertNe
if (0) begin
  $display("AAAA %4d %4d assertNe", steps, ip);
end
            ip = 926;
      end

        926 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[416] = heapMem[localMem[380]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 927;
      end

        927 :
      begin                                                                     // arrayIndex
if (0) begin
  $display("AAAA %4d %4d arrayIndex", steps, ip);
end
              localMem[417] = 0; k = arraySizes[localMem[416]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[416] * NArea + i] == localMem[365]) localMem[417] = i + 1;
              end
              ip = 928;
      end

        928 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[417] = localMem[417] - 1;
              updateArrayLength(2, 0, 0);
              ip = 929;
      end

        929 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[418] = heapMem[localMem[365]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 930;
      end

        930 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[419] = heapMem[localMem[418]*6 + localMem[378]];
              updateArrayLength(2, 0, 0);
              ip = 931;
      end

        931 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[420] = heapMem[localMem[365]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 932;
      end

        932 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[421] = heapMem[localMem[420]*6 + localMem[378]];
              updateArrayLength(2, 0, 0);
              ip = 933;
      end

        933 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[422] = heapMem[localMem[365]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 934;
      end

        934 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[422]] = localMem[378];
              ip = 935;
      end

        935 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[423] = heapMem[localMem[365]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 936;
      end

        936 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[423]] = localMem[378];
              ip = 937;
      end

        937 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[424] = heapMem[localMem[380]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 938;
      end

        938 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[424] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[417], localMem[424], arraySizes[localMem[424]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[417] && i <= arraySizes[localMem[424]]) begin
                  heapMem[NArea * localMem[424] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[424] + localMem[417]] = localMem[419];                                    // Insert new value
              arraySizes[localMem[424]] = arraySizes[localMem[424]] + 1;                              // Increase array size
              ip = 939;
      end

        939 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[425] = heapMem[localMem[380]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 940;
      end

        940 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[425] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[417], localMem[425], arraySizes[localMem[425]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[417] && i <= arraySizes[localMem[425]]) begin
                  heapMem[NArea * localMem[425] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[425] + localMem[417]] = localMem[421];                                    // Insert new value
              arraySizes[localMem[425]] = arraySizes[localMem[425]] + 1;                              // Increase array size
              ip = 941;
      end

        941 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[426] = heapMem[localMem[380]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 942;
      end

        942 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[427] = localMem[417] + 1;
              updateArrayLength(2, 0, 0);
              ip = 943;
      end

        943 :
      begin                                                                     // shiftUp
if (0) begin
  $display("AAAA %4d %4d shiftUp", steps, ip);
end
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[426] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[427], localMem[426], arraySizes[localMem[426]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[427] && i <= arraySizes[localMem[426]]) begin
                  heapMem[NArea * localMem[426] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[426] + localMem[427]] = localMem[381];                                    // Insert new value
              arraySizes[localMem[426]] = arraySizes[localMem[426]] + 1;                              // Increase array size
              ip = 944;
      end

        944 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[380]*6 + 0] = heapMem[localMem[380]*6 + 0] + 1;
              updateArrayLength(1, localMem[380], 0);
              ip = 945;
      end

        945 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1062;
      end

        946 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 947;
      end

        947 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 948;
      end

        948 :
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
              ip = 949;
      end

        949 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[428]*6 + 0] = localMem[378];
              updateArrayLength(1, localMem[428], 0);
              ip = 950;
      end

        950 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[428]*6 + 2] = 0;
              updateArrayLength(1, localMem[428], 2);
              ip = 951;
      end

        951 :
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
              ip = 952;
      end

        952 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[428]*6 + 4] = localMem[429];
              updateArrayLength(1, localMem[428], 4);
              ip = 953;
      end

        953 :
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
              ip = 954;
      end

        954 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[428]*6 + 5] = localMem[430];
              updateArrayLength(1, localMem[428], 5);
              ip = 955;
      end

        955 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[428]*6 + 6] = 0;
              updateArrayLength(1, localMem[428], 6);
              ip = 956;
      end

        956 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[428]*6 + 3] = localMem[376];
              updateArrayLength(1, localMem[428], 3);
              ip = 957;
      end

        957 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[376]*6 + 1] = heapMem[localMem[376]*6 + 1] + 1;
              updateArrayLength(1, localMem[376], 1);
              ip = 958;
      end

        958 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[428]*6 + 1] = heapMem[localMem[376]*6 + 1];
              updateArrayLength(1, localMem[428], 1);
              ip = 959;
      end

        959 :
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
              ip = 960;
      end

        960 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[431]*6 + 0] = localMem[378];
              updateArrayLength(1, localMem[431], 0);
              ip = 961;
      end

        961 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[431]*6 + 2] = 0;
              updateArrayLength(1, localMem[431], 2);
              ip = 962;
      end

        962 :
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
              ip = 963;
      end

        963 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[431]*6 + 4] = localMem[432];
              updateArrayLength(1, localMem[431], 4);
              ip = 964;
      end

        964 :
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
              ip = 965;
      end

        965 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[431]*6 + 5] = localMem[433];
              updateArrayLength(1, localMem[431], 5);
              ip = 966;
      end

        966 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[431]*6 + 6] = 0;
              updateArrayLength(1, localMem[431], 6);
              ip = 967;
      end

        967 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[431]*6 + 3] = localMem[376];
              updateArrayLength(1, localMem[431], 3);
              ip = 968;
      end

        968 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              heapMem[localMem[376]*6 + 1] = heapMem[localMem[376]*6 + 1] + 1;
              updateArrayLength(1, localMem[376], 1);
              ip = 969;
      end

        969 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[431]*6 + 1] = heapMem[localMem[376]*6 + 1];
              updateArrayLength(1, localMem[431], 1);
              ip = 970;
      end

        970 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[434] = !heapMem[localMem[365]*6 + 6];
              ip = 971;
      end

        971 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[434] != 0 ? 1023 : 972;
      end

        972 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[435] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[435] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[435]] = 0;
              ip = 973;
      end

        973 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[428]*6 + 6] = localMem[435];
              updateArrayLength(1, localMem[428], 6);
              ip = 974;
      end

        974 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[436] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[436] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[436]] = 0;
              ip = 975;
      end

        975 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[431]*6 + 6] = localMem[436];
              updateArrayLength(1, localMem[431], 6);
              ip = 976;
      end

        976 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[437] = heapMem[localMem[365]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 977;
      end

        977 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[438] = heapMem[localMem[428]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 978;
      end

        978 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[378]) begin
                  heapMem[NArea * localMem[438] + 0 + i] = heapMem[NArea * localMem[437] + 0 + i];
                  updateArrayLength(1, localMem[438], 0 + i);
                end
              end
              ip = 979;
      end

        979 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[439] = heapMem[localMem[365]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 980;
      end

        980 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[440] = heapMem[localMem[428]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 981;
      end

        981 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[378]) begin
                  heapMem[NArea * localMem[440] + 0 + i] = heapMem[NArea * localMem[439] + 0 + i];
                  updateArrayLength(1, localMem[440], 0 + i);
                end
              end
              ip = 982;
      end

        982 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[441] = heapMem[localMem[365]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 983;
      end

        983 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[442] = heapMem[localMem[428]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 984;
      end

        984 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[443] = localMem[378] + 1;
              updateArrayLength(2, 0, 0);
              ip = 985;
      end

        985 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[443]) begin
                  heapMem[NArea * localMem[442] + 0 + i] = heapMem[NArea * localMem[441] + 0 + i];
                  updateArrayLength(1, localMem[442], 0 + i);
                end
              end
              ip = 986;
      end

        986 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[444] = heapMem[localMem[365]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 987;
      end

        987 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[445] = heapMem[localMem[431]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 988;
      end

        988 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[378]) begin
                  heapMem[NArea * localMem[445] + 0 + i] = heapMem[NArea * localMem[444] + localMem[379] + i];
                  updateArrayLength(1, localMem[445], 0 + i);
                end
              end
              ip = 989;
      end

        989 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[446] = heapMem[localMem[365]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 990;
      end

        990 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[447] = heapMem[localMem[431]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 991;
      end

        991 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[378]) begin
                  heapMem[NArea * localMem[447] + 0 + i] = heapMem[NArea * localMem[446] + localMem[379] + i];
                  updateArrayLength(1, localMem[447], 0 + i);
                end
              end
              ip = 992;
      end

        992 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[448] = heapMem[localMem[365]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 993;
      end

        993 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[449] = heapMem[localMem[431]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 994;
      end

        994 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[450] = localMem[378] + 1;
              updateArrayLength(2, 0, 0);
              ip = 995;
      end

        995 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[450]) begin
                  heapMem[NArea * localMem[449] + 0 + i] = heapMem[NArea * localMem[448] + localMem[379] + i];
                  updateArrayLength(1, localMem[449], 0 + i);
                end
              end
              ip = 996;
      end

        996 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[451] = heapMem[localMem[428]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 997;
      end

        997 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[452] = localMem[451] + 1;
              updateArrayLength(2, 0, 0);
              ip = 998;
      end

        998 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[453] = heapMem[localMem[428]*6 + 6];
              updateArrayLength(2, 0, 0);
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
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[454] = 0;
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
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[454] >= localMem[452] ? 1008 : 1003;
      end

       1003 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[455] = heapMem[localMem[453]*6 + localMem[454]];
              updateArrayLength(2, 0, 0);
              ip = 1004;
      end

       1004 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[455]*6 + 2] = localMem[428];
              updateArrayLength(1, localMem[455], 2);
              ip = 1005;
      end

       1005 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1006;
      end

       1006 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[454] = localMem[454] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1007;
      end

       1007 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1001;
      end

       1008 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1009;
      end

       1009 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[456] = heapMem[localMem[431]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1010;
      end

       1010 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[457] = localMem[456] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1011;
      end

       1011 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[458] = heapMem[localMem[431]*6 + 6];
              updateArrayLength(2, 0, 0);
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
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[459] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1014;
      end

       1014 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1015;
      end

       1015 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[459] >= localMem[457] ? 1021 : 1016;
      end

       1016 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[460] = heapMem[localMem[458]*6 + localMem[459]];
              updateArrayLength(2, 0, 0);
              ip = 1017;
      end

       1017 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[460]*6 + 2] = localMem[431];
              updateArrayLength(1, localMem[460], 2);
              ip = 1018;
      end

       1018 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1019;
      end

       1019 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[459] = localMem[459] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1020;
      end

       1020 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1014;
      end

       1021 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1022;
      end

       1022 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1038;
      end

       1023 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1024;
      end

       1024 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[461] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[461] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[461]] = 0;
              ip = 1025;
      end

       1025 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[365]*6 + 6] = localMem[461];
              updateArrayLength(1, localMem[365], 6);
              ip = 1026;
      end

       1026 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[462] = heapMem[localMem[365]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1027;
      end

       1027 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[463] = heapMem[localMem[428]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1028;
      end

       1028 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[378]) begin
                  heapMem[NArea * localMem[463] + 0 + i] = heapMem[NArea * localMem[462] + 0 + i];
                  updateArrayLength(1, localMem[463], 0 + i);
                end
              end
              ip = 1029;
      end

       1029 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[464] = heapMem[localMem[365]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1030;
      end

       1030 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[465] = heapMem[localMem[428]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1031;
      end

       1031 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[378]) begin
                  heapMem[NArea * localMem[465] + 0 + i] = heapMem[NArea * localMem[464] + 0 + i];
                  updateArrayLength(1, localMem[465], 0 + i);
                end
              end
              ip = 1032;
      end

       1032 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[466] = heapMem[localMem[365]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1033;
      end

       1033 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[467] = heapMem[localMem[431]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1034;
      end

       1034 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[378]) begin
                  heapMem[NArea * localMem[467] + 0 + i] = heapMem[NArea * localMem[466] + localMem[379] + i];
                  updateArrayLength(1, localMem[467], 0 + i);
                end
              end
              ip = 1035;
      end

       1035 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[468] = heapMem[localMem[365]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1036;
      end

       1036 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[469] = heapMem[localMem[431]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1037;
      end

       1037 :
      begin                                                                     // moveLong
if (0) begin
  $display("AAAA %4d %4d moveLong", steps, ip);
end
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[378]) begin
                  heapMem[NArea * localMem[469] + 0 + i] = heapMem[NArea * localMem[468] + localMem[379] + i];
                  updateArrayLength(1, localMem[469], 0 + i);
                end
              end
              ip = 1038;
      end

       1038 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1039;
      end

       1039 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[428]*6 + 2] = localMem[365];
              updateArrayLength(1, localMem[428], 2);
              ip = 1040;
      end

       1040 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[431]*6 + 2] = localMem[365];
              updateArrayLength(1, localMem[431], 2);
              ip = 1041;
      end

       1041 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[470] = heapMem[localMem[365]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1042;
      end

       1042 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[471] = heapMem[localMem[470]*6 + localMem[378]];
              updateArrayLength(2, 0, 0);
              ip = 1043;
      end

       1043 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[472] = heapMem[localMem[365]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1044;
      end

       1044 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[473] = heapMem[localMem[472]*6 + localMem[378]];
              updateArrayLength(2, 0, 0);
              ip = 1045;
      end

       1045 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[474] = heapMem[localMem[365]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1046;
      end

       1046 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[474]*6 + 0] = localMem[471];
              updateArrayLength(1, localMem[474], 0);
              ip = 1047;
      end

       1047 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[475] = heapMem[localMem[365]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1048;
      end

       1048 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[475]*6 + 0] = localMem[473];
              updateArrayLength(1, localMem[475], 0);
              ip = 1049;
      end

       1049 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[476] = heapMem[localMem[365]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1050;
      end

       1050 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[476]*6 + 0] = localMem[428];
              updateArrayLength(1, localMem[476], 0);
              ip = 1051;
      end

       1051 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[477] = heapMem[localMem[365]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1052;
      end

       1052 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[477]*6 + 1] = localMem[431];
              updateArrayLength(1, localMem[477], 1);
              ip = 1053;
      end

       1053 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[365]*6 + 0] = 1;
              updateArrayLength(1, localMem[365], 0);
              ip = 1054;
      end

       1054 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[478] = heapMem[localMem[365]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1055;
      end

       1055 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[478]] = 1;
              ip = 1056;
      end

       1056 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[479] = heapMem[localMem[365]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1057;
      end

       1057 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[479]] = 1;
              ip = 1058;
      end

       1058 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[480] = heapMem[localMem[365]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1059;
      end

       1059 :
      begin                                                                     // resize
if (0) begin
  $display("AAAA %4d %4d resize", steps, ip);
end
              arraySizes[localMem[480]] = 2;
              ip = 1060;
      end

       1060 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1062;
      end

       1061 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1067;
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
              localMem[374] = 1;
              updateArrayLength(2, 0, 0);
              ip = 1064;
      end

       1064 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1067;
      end

       1065 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1066;
      end

       1066 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[374] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1067;
      end

       1067 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1068;
      end

       1068 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1069;
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
      begin                                                                     // free
if (0) begin
  $display("AAAA %4d %4d free", steps, ip);
end
                                 arraySizes[localMem[6]] = 0;
              freedArrays[freedArraysTop] = localMem[6];
              freedArraysTop = freedArraysTop + 1;
              ip = 1072;
      end

       1072 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1145;
      end

       1073 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1074;
      end

       1074 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[2] != 2 ? 1143 : 1075;
      end

       1075 :
      begin                                                                     // in
if (0) begin
  $display("AAAA %4d %4d in", steps, ip);
end
              if (inMemPos < NIn) begin
                localMem[481] = inMem[inMemPos];
                inMemPos = inMemPos + 1;
              end
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
              localMem[482] = heapMem[localMem[3]*6 + 3];
              updateArrayLength(2, 0, 0);
              ip = 1078;
      end

       1078 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[482] != 0 ? 1083 : 1079;
      end

       1079 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[0]*6 + 0] = localMem[482];
              updateArrayLength(1, localMem[0], 0);
              ip = 1080;
      end

       1080 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[0]*6 + 1] = 3;
              updateArrayLength(1, localMem[0], 1);
              ip = 1081;
      end

       1081 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[0]*6 + 2] = 0;
              updateArrayLength(1, localMem[0], 2);
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
              localMem[483] = 0;
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
              ip = localMem[483] >= 99 ? 1125 : 1088;
      end

       1088 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              localMem[484] = heapMem[localMem[482]*6 + 0] - 1;
              updateArrayLength(2, 0, 0);
              ip = 1089;
      end

       1089 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[485] = heapMem[localMem[482]*6 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1090;
      end

       1090 :
      begin                                                                     // jLe
if (0) begin
  $display("AAAA %4d %4d jLe", steps, ip);
end
              ip = localMem[481] <= heapMem[localMem[485]*6 + localMem[484]] ? 1103 : 1091;
      end

       1091 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[486] = localMem[484] + 1;
              updateArrayLength(2, 0, 0);
              ip = 1092;
      end

       1092 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[487] = !heapMem[localMem[482]*6 + 6];
              ip = 1093;
      end

       1093 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[487] == 0 ? 1098 : 1094;
      end

       1094 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[0]*6 + 0] = localMem[482];
              updateArrayLength(1, localMem[0], 0);
              ip = 1095;
      end

       1095 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[0]*6 + 1] = 2;
              updateArrayLength(1, localMem[0], 1);
              ip = 1096;
      end

       1096 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[0]*6 + 2] = localMem[486];
              updateArrayLength(1, localMem[0], 2);
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
              localMem[488] = heapMem[localMem[482]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1100;
      end

       1100 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[489] = heapMem[localMem[488]*6 + localMem[486]];
              updateArrayLength(2, 0, 0);
              ip = 1101;
      end

       1101 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[482] = localMem[489];
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
              localMem[490] = 0; k = arraySizes[localMem[485]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[485] * NArea + i] == localMem[481]) localMem[490] = i + 1;
              end
              ip = 1105;
      end

       1105 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[490] == 0 ? 1110 : 1106;
      end

       1106 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[0]*6 + 0] = localMem[482];
              updateArrayLength(1, localMem[0], 0);
              ip = 1107;
      end

       1107 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[0]*6 + 1] = 1;
              updateArrayLength(1, localMem[0], 1);
              ip = 1108;
      end

       1108 :
      begin                                                                     // subtract
if (0) begin
  $display("AAAA %4d %4d subtract", steps, ip);
end
              heapMem[localMem[0]*6 + 2] = localMem[490] - 1;
              updateArrayLength(1, localMem[0], 2);
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
              j = 0; k = arraySizes[localMem[485]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[485] * NArea + i] < localMem[481]) j = j + 1;
              end
              localMem[491] = j;
              ip = 1112;
      end

       1112 :
      begin                                                                     // not
if (0) begin
  $display("AAAA %4d %4d not", steps, ip);
end
              localMem[492] = !heapMem[localMem[482]*6 + 6];
              ip = 1113;
      end

       1113 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = localMem[492] == 0 ? 1118 : 1114;
      end

       1114 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[0]*6 + 0] = localMem[482];
              updateArrayLength(1, localMem[0], 0);
              ip = 1115;
      end

       1115 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[0]*6 + 1] = 0;
              updateArrayLength(1, localMem[0], 1);
              ip = 1116;
      end

       1116 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[0]*6 + 2] = localMem[491];
              updateArrayLength(1, localMem[0], 2);
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
              localMem[493] = heapMem[localMem[482]*6 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1120;
      end

       1120 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[494] = heapMem[localMem[493]*6 + localMem[491]];
              updateArrayLength(2, 0, 0);
              ip = 1121;
      end

       1121 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[482] = localMem[494];
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
              localMem[483] = localMem[483] + 1;
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
              localMem[495] = heapMem[localMem[0]*6 + 1];
              updateArrayLength(2, 0, 0);
              ip = 1131;
      end

       1131 :
      begin                                                                     // jNe
if (0) begin
  $display("AAAA %4d %4d jNe", steps, ip);
end
              ip = localMem[495] != 1 ? 1139 : 1132;
      end

       1132 :
      begin                                                                     // out
if (0) begin
  $display("AAAA %4d %4d out", steps, ip);
end
              outMem[outMemPos] = 1;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 1133;
      end

       1133 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[496] = heapMem[localMem[0]*6 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1134;
      end

       1134 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[497] = heapMem[localMem[0]*6 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1135;
      end

       1135 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[498] = heapMem[localMem[496]*6 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1136;
      end

       1136 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[499] = heapMem[localMem[498]*6 + localMem[497]];
              updateArrayLength(2, 0, 0);
              ip = 1137;
      end

       1137 :
      begin                                                                     // out
if (0) begin
  $display("AAAA %4d %4d out", steps, ip);
end
              outMem[outMemPos] = localMem[499];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 1138;
      end

       1138 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1141;
      end

       1139 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1140;
      end

       1140 :
      begin                                                                     // out
if (0) begin
  $display("AAAA %4d %4d out", steps, ip);
end
              outMem[outMemPos] = 0;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 1141;
      end

       1141 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1142;
      end

       1142 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1145;
      end

       1143 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1144;
      end

       1144 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1147;
      end

       1145 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1146;
      end

       1146 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 1;
      end

       1147 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1148;
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
    if (steps <=    523) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
    if (0) begin
      for(i = 0; i < 200; ++i) $write("%2d",   localMem[i]); $display("");
      for(i = 0; i < 200; ++i) $write("%2d",    heapMem[i]); $display("");
      for(i = 0; i < 200; ++i) $write("%2d", arraySizes[i]); $display("");
    end
  end
endmodule
