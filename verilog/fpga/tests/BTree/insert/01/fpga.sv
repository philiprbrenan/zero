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
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 2] = heapMem[localMem[0]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 8;
      end

          8 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[2] != 0 ? 31 : 9;
      end

          9 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[3]*10 + 0] = 1;
              updateArrayLength(1, localMem[3], 0);
              ip = 11;
      end

         11 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[3]*10 + 2] = 0;
              updateArrayLength(1, localMem[3], 2);
              ip = 12;
      end

         12 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[3]*10 + 4] = localMem[4];
              updateArrayLength(1, localMem[3], 4);
              ip = 14;
      end

         14 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[3]*10 + 5] = localMem[5];
              updateArrayLength(1, localMem[3], 5);
              ip = 16;
      end

         16 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[3]*10 + 6] = 0;
              updateArrayLength(1, localMem[3], 6);
              ip = 17;
      end

         17 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[3]*10 + 3] = localMem[0];
              updateArrayLength(1, localMem[3], 3);
              ip = 18;
      end

         18 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 1] = heapMem[localMem[0]*10 + 1] + 1;
              ip = 19;
      end

         19 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[3]*10 + 1] = heapMem[localMem[0]*10 + 1];
              updateArrayLength(1, localMem[3], 1);
              ip = 20;
      end

         20 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 6] = heapMem[localMem[3]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 21;
      end

         21 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[6]*10 + 0] = 1;
              updateArrayLength(1, localMem[6], 0);
              ip = 22;
      end

         22 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 7] = heapMem[localMem[3]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 23;
      end

         23 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[7]*10 + 0] = 11;
              updateArrayLength(1, localMem[7], 0);
              ip = 24;
      end

         24 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              ip = 25;
      end

         25 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[0]*10 + 3] = localMem[3];
              updateArrayLength(1, localMem[0], 3);
              ip = 26;
      end

         26 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 8] = heapMem[localMem[3]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 27;
      end

         27 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[8]] = 1;
              ip = 28;
      end

         28 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 9] = heapMem[localMem[3]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 29;
      end

         29 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[9]] = 1;
              ip = 30;
      end

         30 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1059;
      end

         31 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 32;
      end

         32 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 10] = heapMem[localMem[2]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 33;
      end

         33 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 11] = heapMem[localMem[0]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 34;
      end

         34 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[10] >= localMem[11] ? 70 : 35;
      end

         35 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 12] = heapMem[localMem[2]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 36;
      end

         36 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[12] != 0 ? 69 : 37;
      end

         37 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 13] = !heapMem[localMem[2]*10 + 6];
              ip = 38;
      end

         38 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[13] == 0 ? 68 : 39;
      end

         39 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 14] = heapMem[localMem[2]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 40;
      end

         40 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 15] = 0; k = arraySizes[localMem[14]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[14] * NArea + i] == 1) localMem[0 + 15] = i + 1;
              end
              ip = 41;
      end

         41 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[15] == 0 ? 46 : 42;
      end

         42 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 15] = localMem[15] - 1;
              ip = 43;
      end

         43 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 16] = heapMem[localMem[2]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 44;
      end

         44 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[16]*10 + localMem[15]] = 11;
              updateArrayLength(1, localMem[16], localMem[15]);
              ip = 45;
      end

         45 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1059;
      end

         46 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 47;
      end

         47 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[14]] = localMem[10];
              ip = 48;
      end

         48 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 17] = heapMem[localMem[2]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 49;
      end

         49 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[17]] = localMem[10];
              ip = 50;
      end

         50 :
      begin                                                                     // arrayCountGreater
//$display("AAAA %4d %4d arrayCountGreater", steps, ip);
              j = 0; k = arraySizes[localMem[14]];
//$display("AAAAA k=%d  source2=%d", k, 1);
              for(i = 0; i < NArea; i = i + 1) begin
//$display("AAAAA i=%d  value=%d", i, heapMem[localMem[14] * NArea + i]);
                if (i < k && heapMem[localMem[14] * NArea + i] > 1) j = j + 1;
              end
              localMem[0 + 18] = j;
              ip = 51;
      end

         51 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[18] != 0 ? 59 : 52;
      end

         52 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 19] = heapMem[localMem[2]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 53;
      end

         53 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[19]*10 + localMem[10]] = 1;
              updateArrayLength(1, localMem[19], localMem[10]);
              ip = 54;
      end

         54 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 20] = heapMem[localMem[2]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 55;
      end

         55 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[20]*10 + localMem[10]] = 11;
              updateArrayLength(1, localMem[20], localMem[10]);
              ip = 56;
      end

         56 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[2]*10 + 0] = localMem[10] + 1;
              ip = 57;
      end

         57 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              ip = 58;
      end

         58 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1059;
      end

         59 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 60;
      end

         60 :
      begin                                                                     // arrayCountLess
//$display("AAAA %4d %4d arrayCountLess", steps, ip);
              j = 0; k = arraySizes[localMem[14]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[14] * NArea + i] < 1) j = j + 1;
              end
              localMem[0 + 21] = j;
              ip = 61;
      end

         61 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 22] = heapMem[localMem[2]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 62;
      end

         62 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 23] = heapMem[localMem[2]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 64;
      end

         64 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[2]*10 + 0] = heapMem[localMem[2]*10 + 0] + 1;
              ip = 66;
      end

         66 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              ip = 67;
      end

         67 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1059;
      end

         68 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 69;
      end

         69 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 70;
      end

         70 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 71;
      end

         71 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 24] = heapMem[localMem[0]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 72;
      end

         72 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 73;
      end

         73 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 26] = heapMem[localMem[24]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 74;
      end

         74 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 27] = heapMem[localMem[24]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 75;
      end

         75 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 28] = heapMem[localMem[27]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 76;
      end

         76 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[26] <  localMem[28] ? 296 : 77;
      end

         77 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 29] = localMem[28];
              updateArrayLength(2, 0, 0);
              ip = 78;
      end

         78 :
      begin                                                                     // shiftRight
//$display("AAAA %4d %4d shiftRight", steps, ip);
              localMem[0 + 29] = localMem[29] >> 1;
              ip = 79;
      end

         79 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 30] = localMem[29] + 1;
              ip = 80;
      end

         80 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 31] = heapMem[localMem[24]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 81;
      end

         81 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[31] == 0 ? 178 : 82;
      end

         82 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 32] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 32] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 32]] = 0;
              ip = 83;
      end

         83 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[32]*10 + 0] = localMem[29];
              updateArrayLength(1, localMem[32], 0);
              ip = 84;
      end

         84 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[32]*10 + 2] = 0;
              updateArrayLength(1, localMem[32], 2);
              ip = 85;
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
              heapMem[localMem[32]*10 + 4] = localMem[33];
              updateArrayLength(1, localMem[32], 4);
              ip = 87;
      end

         87 :
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
              ip = 88;
      end

         88 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[32]*10 + 5] = localMem[34];
              updateArrayLength(1, localMem[32], 5);
              ip = 89;
      end

         89 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[32]*10 + 6] = 0;
              updateArrayLength(1, localMem[32], 6);
              ip = 90;
      end

         90 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[32]*10 + 3] = localMem[27];
              updateArrayLength(1, localMem[32], 3);
              ip = 91;
      end

         91 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[27]*10 + 1] = heapMem[localMem[27]*10 + 1] + 1;
              ip = 92;
      end

         92 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[32]*10 + 1] = heapMem[localMem[27]*10 + 1];
              updateArrayLength(1, localMem[32], 1);
              ip = 93;
      end

         93 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 35] = !heapMem[localMem[24]*10 + 6];
              ip = 94;
      end

         94 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[35] != 0 ? 123 : 95;
      end

         95 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 36] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 36] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 36]] = 0;
              ip = 96;
      end

         96 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[32]*10 + 6] = localMem[36];
              updateArrayLength(1, localMem[32], 6);
              ip = 97;
      end

         97 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 37] = heapMem[localMem[24]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 98;
      end

         98 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 38] = heapMem[localMem[32]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 99;
      end

         99 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 39] = heapMem[localMem[24]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 101;
      end

        101 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 40] = heapMem[localMem[32]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 102;
      end

        102 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 41] = heapMem[localMem[24]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 104;
      end

        104 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 42] = heapMem[localMem[32]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 105;
      end

        105 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 43] = localMem[29] + 1;
              ip = 106;
      end

        106 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 44] = heapMem[localMem[32]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 108;
      end

        108 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 45] = localMem[44] + 1;
              ip = 109;
      end

        109 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 46] = heapMem[localMem[32]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 110;
      end

        110 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 111;
      end

        111 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 47] = 0;
              updateArrayLength(2, 0, 0);
              ip = 112;
      end

        112 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 113;
      end

        113 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[47] >= localMem[45] ? 119 : 114;
      end

        114 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 48] = heapMem[localMem[46]*10 + localMem[47]];
              updateArrayLength(2, 0, 0);
              ip = 115;
      end

        115 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[48]*10 + 2] = localMem[32];
              updateArrayLength(1, localMem[48], 2);
              ip = 116;
      end

        116 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 117;
      end

        117 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 47] = localMem[47] + 1;
              ip = 118;
      end

        118 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 112;
      end

        119 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 120;
      end

        120 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 49] = heapMem[localMem[24]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 121;
      end

        121 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[49]] = localMem[30];
              ip = 122;
      end

        122 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 130;
      end

        123 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 124;
      end

        124 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 50] = heapMem[localMem[24]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 125;
      end

        125 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 51] = heapMem[localMem[32]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 126;
      end

        126 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 52] = heapMem[localMem[24]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 128;
      end

        128 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 53] = heapMem[localMem[32]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 129;
      end

        129 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d label", steps, ip);
              ip = 131;
      end

        131 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[24]*10 + 0] = localMem[29];
              updateArrayLength(1, localMem[24], 0);
              ip = 132;
      end

        132 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[32]*10 + 2] = localMem[31];
              updateArrayLength(1, localMem[32], 2);
              ip = 133;
      end

        133 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 54] = heapMem[localMem[31]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 134;
      end

        134 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 55] = heapMem[localMem[31]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 135;
      end

        135 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 56] = heapMem[localMem[55]*10 + localMem[54]];
              updateArrayLength(2, 0, 0);
              ip = 136;
      end

        136 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[56] != localMem[24] ? 155 : 137;
      end

        137 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 57] = heapMem[localMem[24]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 138;
      end

        138 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 58] = heapMem[localMem[57]*10 + localMem[29]];
              updateArrayLength(2, 0, 0);
              ip = 139;
      end

        139 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 59] = heapMem[localMem[31]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 140;
      end

        140 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[59]*10 + localMem[54]] = localMem[58];
              updateArrayLength(1, localMem[59], localMem[54]);
              ip = 141;
      end

        141 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 60] = heapMem[localMem[24]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 142;
      end

        142 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 61] = heapMem[localMem[60]*10 + localMem[29]];
              updateArrayLength(2, 0, 0);
              ip = 143;
      end

        143 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 62] = heapMem[localMem[31]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 144;
      end

        144 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[62]*10 + localMem[54]] = localMem[61];
              updateArrayLength(1, localMem[62], localMem[54]);
              ip = 145;
      end

        145 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 63] = heapMem[localMem[24]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 146;
      end

        146 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[63]] = localMem[29];
              ip = 147;
      end

        147 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 64] = heapMem[localMem[24]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 148;
      end

        148 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[64]] = localMem[29];
              ip = 149;
      end

        149 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 65] = localMem[54] + 1;
              ip = 150;
      end

        150 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[31]*10 + 0] = localMem[65];
              updateArrayLength(1, localMem[31], 0);
              ip = 151;
      end

        151 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 66] = heapMem[localMem[31]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 152;
      end

        152 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[66]*10 + localMem[65]] = localMem[32];
              updateArrayLength(1, localMem[66], localMem[65]);
              ip = 153;
      end

        153 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 293;
      end

        154 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 177;
      end

        155 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 156;
      end

        156 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 157;
      end

        157 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 67] = heapMem[localMem[31]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 158;
      end

        158 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 68] = 0; k = arraySizes[localMem[67]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[67] * NArea + i] == localMem[24]) localMem[0 + 68] = i + 1;
              end
              ip = 159;
      end

        159 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 68] = localMem[68] - 1;
              ip = 160;
      end

        160 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 69] = heapMem[localMem[24]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 161;
      end

        161 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 70] = heapMem[localMem[69]*10 + localMem[29]];
              updateArrayLength(2, 0, 0);
              ip = 162;
      end

        162 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 71] = heapMem[localMem[24]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 163;
      end

        163 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 72] = heapMem[localMem[71]*10 + localMem[29]];
              updateArrayLength(2, 0, 0);
              ip = 164;
      end

        164 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 73] = heapMem[localMem[24]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 165;
      end

        165 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[73]] = localMem[29];
              ip = 166;
      end

        166 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 74] = heapMem[localMem[24]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 167;
      end

        167 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[74]] = localMem[29];
              ip = 168;
      end

        168 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 75] = heapMem[localMem[31]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 169;
      end

        169 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 76] = heapMem[localMem[31]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 171;
      end

        171 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 77] = heapMem[localMem[31]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 173;
      end

        173 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 78] = localMem[68] + 1;
              ip = 174;
      end

        174 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[31]*10 + 0] = heapMem[localMem[31]*10 + 0] + 1;
              ip = 176;
      end

        176 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 293;
      end

        177 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 178;
      end

        178 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 179;
      end

        179 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 79] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 79] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 79]] = 0;
              ip = 180;
      end

        180 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[79]*10 + 0] = localMem[29];
              updateArrayLength(1, localMem[79], 0);
              ip = 181;
      end

        181 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[79]*10 + 2] = 0;
              updateArrayLength(1, localMem[79], 2);
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
              heapMem[localMem[79]*10 + 4] = localMem[80];
              updateArrayLength(1, localMem[79], 4);
              ip = 184;
      end

        184 :
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
              ip = 185;
      end

        185 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[79]*10 + 5] = localMem[81];
              updateArrayLength(1, localMem[79], 5);
              ip = 186;
      end

        186 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[79]*10 + 6] = 0;
              updateArrayLength(1, localMem[79], 6);
              ip = 187;
      end

        187 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[79]*10 + 3] = localMem[27];
              updateArrayLength(1, localMem[79], 3);
              ip = 188;
      end

        188 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[27]*10 + 1] = heapMem[localMem[27]*10 + 1] + 1;
              ip = 189;
      end

        189 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[79]*10 + 1] = heapMem[localMem[27]*10 + 1];
              updateArrayLength(1, localMem[79], 1);
              ip = 190;
      end

        190 :
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
              ip = 191;
      end

        191 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[82]*10 + 0] = localMem[29];
              updateArrayLength(1, localMem[82], 0);
              ip = 192;
      end

        192 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[82]*10 + 2] = 0;
              updateArrayLength(1, localMem[82], 2);
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
              heapMem[localMem[82]*10 + 4] = localMem[83];
              updateArrayLength(1, localMem[82], 4);
              ip = 195;
      end

        195 :
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
              ip = 196;
      end

        196 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[82]*10 + 5] = localMem[84];
              updateArrayLength(1, localMem[82], 5);
              ip = 197;
      end

        197 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[82]*10 + 6] = 0;
              updateArrayLength(1, localMem[82], 6);
              ip = 198;
      end

        198 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[82]*10 + 3] = localMem[27];
              updateArrayLength(1, localMem[82], 3);
              ip = 199;
      end

        199 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[27]*10 + 1] = heapMem[localMem[27]*10 + 1] + 1;
              ip = 200;
      end

        200 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[82]*10 + 1] = heapMem[localMem[27]*10 + 1];
              updateArrayLength(1, localMem[82], 1);
              ip = 201;
      end

        201 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 85] = !heapMem[localMem[24]*10 + 6];
              ip = 202;
      end

        202 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[85] != 0 ? 254 : 203;
      end

        203 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 86] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 86] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 86]] = 0;
              ip = 204;
      end

        204 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[79]*10 + 6] = localMem[86];
              updateArrayLength(1, localMem[79], 6);
              ip = 205;
      end

        205 :
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
              ip = 206;
      end

        206 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[82]*10 + 6] = localMem[87];
              updateArrayLength(1, localMem[82], 6);
              ip = 207;
      end

        207 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 88] = heapMem[localMem[24]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 208;
      end

        208 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 89] = heapMem[localMem[79]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 209;
      end

        209 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 90] = heapMem[localMem[24]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 211;
      end

        211 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 91] = heapMem[localMem[79]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 212;
      end

        212 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 92] = heapMem[localMem[24]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 214;
      end

        214 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 93] = heapMem[localMem[79]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 215;
      end

        215 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 94] = localMem[29] + 1;
              ip = 216;
      end

        216 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 95] = heapMem[localMem[24]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 218;
      end

        218 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 96] = heapMem[localMem[82]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 219;
      end

        219 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 97] = heapMem[localMem[24]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 221;
      end

        221 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 98] = heapMem[localMem[82]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 222;
      end

        222 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 99] = heapMem[localMem[24]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 224;
      end

        224 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 100] = heapMem[localMem[82]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 225;
      end

        225 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 101] = localMem[29] + 1;
              ip = 226;
      end

        226 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 102] = heapMem[localMem[79]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 228;
      end

        228 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 103] = localMem[102] + 1;
              ip = 229;
      end

        229 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 104] = heapMem[localMem[79]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 230;
      end

        230 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 231;
      end

        231 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 105] = 0;
              updateArrayLength(2, 0, 0);
              ip = 232;
      end

        232 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 233;
      end

        233 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[105] >= localMem[103] ? 239 : 234;
      end

        234 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 106] = heapMem[localMem[104]*10 + localMem[105]];
              updateArrayLength(2, 0, 0);
              ip = 235;
      end

        235 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[106]*10 + 2] = localMem[79];
              updateArrayLength(1, localMem[106], 2);
              ip = 236;
      end

        236 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 237;
      end

        237 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 105] = localMem[105] + 1;
              ip = 238;
      end

        238 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 232;
      end

        239 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 240;
      end

        240 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 107] = heapMem[localMem[82]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 241;
      end

        241 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 108] = localMem[107] + 1;
              ip = 242;
      end

        242 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 109] = heapMem[localMem[82]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 243;
      end

        243 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 244;
      end

        244 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 110] = 0;
              updateArrayLength(2, 0, 0);
              ip = 245;
      end

        245 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 246;
      end

        246 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[110] >= localMem[108] ? 252 : 247;
      end

        247 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 111] = heapMem[localMem[109]*10 + localMem[110]];
              updateArrayLength(2, 0, 0);
              ip = 248;
      end

        248 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[111]*10 + 2] = localMem[82];
              updateArrayLength(1, localMem[111], 2);
              ip = 249;
      end

        249 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 250;
      end

        250 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 110] = localMem[110] + 1;
              ip = 251;
      end

        251 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 245;
      end

        252 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 253;
      end

        253 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 269;
      end

        254 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 255;
      end

        255 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 112] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 112] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 112]] = 0;
              ip = 256;
      end

        256 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[24]*10 + 6] = localMem[112];
              updateArrayLength(1, localMem[24], 6);
              ip = 257;
      end

        257 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 113] = heapMem[localMem[24]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 258;
      end

        258 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 114] = heapMem[localMem[79]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 259;
      end

        259 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 115] = heapMem[localMem[24]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 261;
      end

        261 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 116] = heapMem[localMem[79]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 262;
      end

        262 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 117] = heapMem[localMem[24]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 264;
      end

        264 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 118] = heapMem[localMem[82]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 265;
      end

        265 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 119] = heapMem[localMem[24]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 267;
      end

        267 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 120] = heapMem[localMem[82]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 268;
      end

        268 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d label", steps, ip);
              ip = 270;
      end

        270 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[79]*10 + 2] = localMem[24];
              updateArrayLength(1, localMem[79], 2);
              ip = 271;
      end

        271 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[82]*10 + 2] = localMem[24];
              updateArrayLength(1, localMem[82], 2);
              ip = 272;
      end

        272 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 121] = heapMem[localMem[24]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 273;
      end

        273 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 122] = heapMem[localMem[121]*10 + localMem[29]];
              updateArrayLength(2, 0, 0);
              ip = 274;
      end

        274 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 123] = heapMem[localMem[24]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 275;
      end

        275 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 124] = heapMem[localMem[123]*10 + localMem[29]];
              updateArrayLength(2, 0, 0);
              ip = 276;
      end

        276 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 125] = heapMem[localMem[24]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 277;
      end

        277 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[125]*10 + 0] = localMem[122];
              updateArrayLength(1, localMem[125], 0);
              ip = 278;
      end

        278 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 126] = heapMem[localMem[24]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 279;
      end

        279 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[126]*10 + 0] = localMem[124];
              updateArrayLength(1, localMem[126], 0);
              ip = 280;
      end

        280 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 127] = heapMem[localMem[24]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 281;
      end

        281 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[127]*10 + 0] = localMem[79];
              updateArrayLength(1, localMem[127], 0);
              ip = 282;
      end

        282 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 128] = heapMem[localMem[24]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 283;
      end

        283 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[128]*10 + 1] = localMem[82];
              updateArrayLength(1, localMem[128], 1);
              ip = 284;
      end

        284 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[24]*10 + 0] = 1;
              updateArrayLength(1, localMem[24], 0);
              ip = 285;
      end

        285 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 129] = heapMem[localMem[24]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 286;
      end

        286 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[129]] = 1;
              ip = 287;
      end

        287 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 130] = heapMem[localMem[24]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 288;
      end

        288 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[130]] = 1;
              ip = 289;
      end

        289 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 131] = heapMem[localMem[24]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 290;
      end

        290 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[131]] = 2;
              ip = 291;
      end

        291 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 293;
      end

        292 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 298;
      end

        293 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 294;
      end

        294 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 25] = 1;
              updateArrayLength(2, 0, 0);
              ip = 295;
      end

        295 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 298;
      end

        296 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 297;
      end

        297 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 25] = 0;
              updateArrayLength(2, 0, 0);
              ip = 298;
      end

        298 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 299;
      end

        299 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 300;
      end

        300 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 301;
      end

        301 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 132] = 0;
              updateArrayLength(2, 0, 0);
              ip = 302;
      end

        302 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 303;
      end

        303 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[132] >= 99 ? 801 : 304;
      end

        304 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 133] = heapMem[localMem[24]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 305;
      end

        305 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 134] = localMem[133] - 1;
              ip = 306;
      end

        306 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 135] = heapMem[localMem[24]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 307;
      end

        307 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 136] = heapMem[localMem[135]*10 + localMem[134]];
              updateArrayLength(2, 0, 0);
              ip = 308;
      end

        308 :
      begin                                                                     // jLe
//$display("AAAA %4d %4d jLe", steps, ip);
              ip = 1 <= localMem[136] ? 549 : 309;
      end

        309 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 137] = !heapMem[localMem[24]*10 + 6];
              ip = 310;
      end

        310 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[137] == 0 ? 315 : 311;
      end

        311 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 0] = localMem[24];
              updateArrayLength(1, localMem[1], 0);
              ip = 312;
      end

        312 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 1] = 2;
              updateArrayLength(1, localMem[1], 1);
              ip = 313;
      end

        313 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              heapMem[localMem[1]*10 + 2] = localMem[133] - 1;
              ip = 314;
      end

        314 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 805;
      end

        315 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 316;
      end

        316 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 138] = heapMem[localMem[24]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 317;
      end

        317 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 139] = heapMem[localMem[138]*10 + localMem[133]];
              updateArrayLength(2, 0, 0);
              ip = 318;
      end

        318 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 319;
      end

        319 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 141] = heapMem[localMem[139]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 320;
      end

        320 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 142] = heapMem[localMem[139]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 321;
      end

        321 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 143] = heapMem[localMem[142]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 322;
      end

        322 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[141] <  localMem[143] ? 542 : 323;
      end

        323 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 144] = localMem[143];
              updateArrayLength(2, 0, 0);
              ip = 324;
      end

        324 :
      begin                                                                     // shiftRight
//$display("AAAA %4d %4d shiftRight", steps, ip);
              localMem[0 + 144] = localMem[144] >> 1;
              ip = 325;
      end

        325 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 145] = localMem[144] + 1;
              ip = 326;
      end

        326 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 146] = heapMem[localMem[139]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 327;
      end

        327 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[146] == 0 ? 424 : 328;
      end

        328 :
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
              ip = 329;
      end

        329 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[147]*10 + 0] = localMem[144];
              updateArrayLength(1, localMem[147], 0);
              ip = 330;
      end

        330 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[147]*10 + 2] = 0;
              updateArrayLength(1, localMem[147], 2);
              ip = 331;
      end

        331 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 148] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 148] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 148]] = 0;
              ip = 332;
      end

        332 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[147]*10 + 4] = localMem[148];
              updateArrayLength(1, localMem[147], 4);
              ip = 333;
      end

        333 :
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
              ip = 334;
      end

        334 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[147]*10 + 5] = localMem[149];
              updateArrayLength(1, localMem[147], 5);
              ip = 335;
      end

        335 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[147]*10 + 6] = 0;
              updateArrayLength(1, localMem[147], 6);
              ip = 336;
      end

        336 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[147]*10 + 3] = localMem[142];
              updateArrayLength(1, localMem[147], 3);
              ip = 337;
      end

        337 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[142]*10 + 1] = heapMem[localMem[142]*10 + 1] + 1;
              ip = 338;
      end

        338 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[147]*10 + 1] = heapMem[localMem[142]*10 + 1];
              updateArrayLength(1, localMem[147], 1);
              ip = 339;
      end

        339 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 150] = !heapMem[localMem[139]*10 + 6];
              ip = 340;
      end

        340 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[150] != 0 ? 369 : 341;
      end

        341 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 151] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 151] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 151]] = 0;
              ip = 342;
      end

        342 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[147]*10 + 6] = localMem[151];
              updateArrayLength(1, localMem[147], 6);
              ip = 343;
      end

        343 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 152] = heapMem[localMem[139]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 344;
      end

        344 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 153] = heapMem[localMem[147]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 345;
      end

        345 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 154] = heapMem[localMem[139]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 347;
      end

        347 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 155] = heapMem[localMem[147]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 348;
      end

        348 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 156] = heapMem[localMem[139]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 350;
      end

        350 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 157] = heapMem[localMem[147]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 351;
      end

        351 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 158] = localMem[144] + 1;
              ip = 352;
      end

        352 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 159] = heapMem[localMem[147]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 354;
      end

        354 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 160] = localMem[159] + 1;
              ip = 355;
      end

        355 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 161] = heapMem[localMem[147]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 356;
      end

        356 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 357;
      end

        357 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 162] = 0;
              updateArrayLength(2, 0, 0);
              ip = 358;
      end

        358 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 359;
      end

        359 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[162] >= localMem[160] ? 365 : 360;
      end

        360 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 163] = heapMem[localMem[161]*10 + localMem[162]];
              updateArrayLength(2, 0, 0);
              ip = 361;
      end

        361 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[163]*10 + 2] = localMem[147];
              updateArrayLength(1, localMem[163], 2);
              ip = 362;
      end

        362 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 363;
      end

        363 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 162] = localMem[162] + 1;
              ip = 364;
      end

        364 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 358;
      end

        365 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 366;
      end

        366 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 164] = heapMem[localMem[139]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 367;
      end

        367 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[164]] = localMem[145];
              ip = 368;
      end

        368 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 376;
      end

        369 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 370;
      end

        370 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 165] = heapMem[localMem[139]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 371;
      end

        371 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 166] = heapMem[localMem[147]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 372;
      end

        372 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 167] = heapMem[localMem[139]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 374;
      end

        374 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 168] = heapMem[localMem[147]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 375;
      end

        375 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d label", steps, ip);
              ip = 377;
      end

        377 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[139]*10 + 0] = localMem[144];
              updateArrayLength(1, localMem[139], 0);
              ip = 378;
      end

        378 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[147]*10 + 2] = localMem[146];
              updateArrayLength(1, localMem[147], 2);
              ip = 379;
      end

        379 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 169] = heapMem[localMem[146]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 380;
      end

        380 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 170] = heapMem[localMem[146]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 381;
      end

        381 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 171] = heapMem[localMem[170]*10 + localMem[169]];
              updateArrayLength(2, 0, 0);
              ip = 382;
      end

        382 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[171] != localMem[139] ? 401 : 383;
      end

        383 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 172] = heapMem[localMem[139]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 384;
      end

        384 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 173] = heapMem[localMem[172]*10 + localMem[144]];
              updateArrayLength(2, 0, 0);
              ip = 385;
      end

        385 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 174] = heapMem[localMem[146]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 386;
      end

        386 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[174]*10 + localMem[169]] = localMem[173];
              updateArrayLength(1, localMem[174], localMem[169]);
              ip = 387;
      end

        387 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 175] = heapMem[localMem[139]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 388;
      end

        388 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 176] = heapMem[localMem[175]*10 + localMem[144]];
              updateArrayLength(2, 0, 0);
              ip = 389;
      end

        389 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 177] = heapMem[localMem[146]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 390;
      end

        390 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[177]*10 + localMem[169]] = localMem[176];
              updateArrayLength(1, localMem[177], localMem[169]);
              ip = 391;
      end

        391 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 178] = heapMem[localMem[139]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 392;
      end

        392 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[178]] = localMem[144];
              ip = 393;
      end

        393 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 179] = heapMem[localMem[139]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 394;
      end

        394 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[179]] = localMem[144];
              ip = 395;
      end

        395 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 180] = localMem[169] + 1;
              ip = 396;
      end

        396 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[146]*10 + 0] = localMem[180];
              updateArrayLength(1, localMem[146], 0);
              ip = 397;
      end

        397 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 181] = heapMem[localMem[146]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 398;
      end

        398 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[181]*10 + localMem[180]] = localMem[147];
              updateArrayLength(1, localMem[181], localMem[180]);
              ip = 399;
      end

        399 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 539;
      end

        400 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 423;
      end

        401 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 402;
      end

        402 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 403;
      end

        403 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 182] = heapMem[localMem[146]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 404;
      end

        404 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 183] = 0; k = arraySizes[localMem[182]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[182] * NArea + i] == localMem[139]) localMem[0 + 183] = i + 1;
              end
              ip = 405;
      end

        405 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 183] = localMem[183] - 1;
              ip = 406;
      end

        406 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 184] = heapMem[localMem[139]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 407;
      end

        407 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 185] = heapMem[localMem[184]*10 + localMem[144]];
              updateArrayLength(2, 0, 0);
              ip = 408;
      end

        408 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 186] = heapMem[localMem[139]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 409;
      end

        409 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 187] = heapMem[localMem[186]*10 + localMem[144]];
              updateArrayLength(2, 0, 0);
              ip = 410;
      end

        410 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 188] = heapMem[localMem[139]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 411;
      end

        411 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[188]] = localMem[144];
              ip = 412;
      end

        412 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 189] = heapMem[localMem[139]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 413;
      end

        413 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[189]] = localMem[144];
              ip = 414;
      end

        414 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 190] = heapMem[localMem[146]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 415;
      end

        415 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 191] = heapMem[localMem[146]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 417;
      end

        417 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 192] = heapMem[localMem[146]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 419;
      end

        419 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 193] = localMem[183] + 1;
              ip = 420;
      end

        420 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[146]*10 + 0] = heapMem[localMem[146]*10 + 0] + 1;
              ip = 422;
      end

        422 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 539;
      end

        423 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 424;
      end

        424 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 425;
      end

        425 :
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
              ip = 426;
      end

        426 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[194]*10 + 0] = localMem[144];
              updateArrayLength(1, localMem[194], 0);
              ip = 427;
      end

        427 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[194]*10 + 2] = 0;
              updateArrayLength(1, localMem[194], 2);
              ip = 428;
      end

        428 :
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
              ip = 429;
      end

        429 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[194]*10 + 4] = localMem[195];
              updateArrayLength(1, localMem[194], 4);
              ip = 430;
      end

        430 :
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
              ip = 431;
      end

        431 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[194]*10 + 5] = localMem[196];
              updateArrayLength(1, localMem[194], 5);
              ip = 432;
      end

        432 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[194]*10 + 6] = 0;
              updateArrayLength(1, localMem[194], 6);
              ip = 433;
      end

        433 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[194]*10 + 3] = localMem[142];
              updateArrayLength(1, localMem[194], 3);
              ip = 434;
      end

        434 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[142]*10 + 1] = heapMem[localMem[142]*10 + 1] + 1;
              ip = 435;
      end

        435 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[194]*10 + 1] = heapMem[localMem[142]*10 + 1];
              updateArrayLength(1, localMem[194], 1);
              ip = 436;
      end

        436 :
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
              ip = 437;
      end

        437 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[197]*10 + 0] = localMem[144];
              updateArrayLength(1, localMem[197], 0);
              ip = 438;
      end

        438 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[197]*10 + 2] = 0;
              updateArrayLength(1, localMem[197], 2);
              ip = 439;
      end

        439 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 198] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 198] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 198]] = 0;
              ip = 440;
      end

        440 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[197]*10 + 4] = localMem[198];
              updateArrayLength(1, localMem[197], 4);
              ip = 441;
      end

        441 :
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
              ip = 442;
      end

        442 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[197]*10 + 5] = localMem[199];
              updateArrayLength(1, localMem[197], 5);
              ip = 443;
      end

        443 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[197]*10 + 6] = 0;
              updateArrayLength(1, localMem[197], 6);
              ip = 444;
      end

        444 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[197]*10 + 3] = localMem[142];
              updateArrayLength(1, localMem[197], 3);
              ip = 445;
      end

        445 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[142]*10 + 1] = heapMem[localMem[142]*10 + 1] + 1;
              ip = 446;
      end

        446 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[197]*10 + 1] = heapMem[localMem[142]*10 + 1];
              updateArrayLength(1, localMem[197], 1);
              ip = 447;
      end

        447 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 200] = !heapMem[localMem[139]*10 + 6];
              ip = 448;
      end

        448 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[200] != 0 ? 500 : 449;
      end

        449 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 201] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 201] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 201]] = 0;
              ip = 450;
      end

        450 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[194]*10 + 6] = localMem[201];
              updateArrayLength(1, localMem[194], 6);
              ip = 451;
      end

        451 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 202] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 202] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 202]] = 0;
              ip = 452;
      end

        452 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[197]*10 + 6] = localMem[202];
              updateArrayLength(1, localMem[197], 6);
              ip = 453;
      end

        453 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 203] = heapMem[localMem[139]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 454;
      end

        454 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 204] = heapMem[localMem[194]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 455;
      end

        455 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 205] = heapMem[localMem[139]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 457;
      end

        457 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 206] = heapMem[localMem[194]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 458;
      end

        458 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 207] = heapMem[localMem[139]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 460;
      end

        460 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 208] = heapMem[localMem[194]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 461;
      end

        461 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 209] = localMem[144] + 1;
              ip = 462;
      end

        462 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 210] = heapMem[localMem[139]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 464;
      end

        464 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 211] = heapMem[localMem[197]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 465;
      end

        465 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 212] = heapMem[localMem[139]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 467;
      end

        467 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 213] = heapMem[localMem[197]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 468;
      end

        468 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 214] = heapMem[localMem[139]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 470;
      end

        470 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 215] = heapMem[localMem[197]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 471;
      end

        471 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 216] = localMem[144] + 1;
              ip = 472;
      end

        472 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 217] = heapMem[localMem[194]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 474;
      end

        474 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 218] = localMem[217] + 1;
              ip = 475;
      end

        475 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 219] = heapMem[localMem[194]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 476;
      end

        476 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 477;
      end

        477 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 220] = 0;
              updateArrayLength(2, 0, 0);
              ip = 478;
      end

        478 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 479;
      end

        479 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[220] >= localMem[218] ? 485 : 480;
      end

        480 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 221] = heapMem[localMem[219]*10 + localMem[220]];
              updateArrayLength(2, 0, 0);
              ip = 481;
      end

        481 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[221]*10 + 2] = localMem[194];
              updateArrayLength(1, localMem[221], 2);
              ip = 482;
      end

        482 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 483;
      end

        483 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 220] = localMem[220] + 1;
              ip = 484;
      end

        484 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 478;
      end

        485 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 486;
      end

        486 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 222] = heapMem[localMem[197]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 487;
      end

        487 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 223] = localMem[222] + 1;
              ip = 488;
      end

        488 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 224] = heapMem[localMem[197]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 489;
      end

        489 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 490;
      end

        490 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 225] = 0;
              updateArrayLength(2, 0, 0);
              ip = 491;
      end

        491 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 492;
      end

        492 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[225] >= localMem[223] ? 498 : 493;
      end

        493 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 226] = heapMem[localMem[224]*10 + localMem[225]];
              updateArrayLength(2, 0, 0);
              ip = 494;
      end

        494 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[226]*10 + 2] = localMem[197];
              updateArrayLength(1, localMem[226], 2);
              ip = 495;
      end

        495 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 496;
      end

        496 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 225] = localMem[225] + 1;
              ip = 497;
      end

        497 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 491;
      end

        498 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 499;
      end

        499 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 515;
      end

        500 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 501;
      end

        501 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 227] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 227] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 227]] = 0;
              ip = 502;
      end

        502 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[139]*10 + 6] = localMem[227];
              updateArrayLength(1, localMem[139], 6);
              ip = 503;
      end

        503 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 228] = heapMem[localMem[139]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 504;
      end

        504 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 229] = heapMem[localMem[194]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 505;
      end

        505 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 230] = heapMem[localMem[139]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 507;
      end

        507 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 231] = heapMem[localMem[194]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 508;
      end

        508 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 232] = heapMem[localMem[139]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 510;
      end

        510 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 233] = heapMem[localMem[197]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 511;
      end

        511 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 234] = heapMem[localMem[139]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 513;
      end

        513 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 235] = heapMem[localMem[197]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 514;
      end

        514 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d label", steps, ip);
              ip = 516;
      end

        516 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[194]*10 + 2] = localMem[139];
              updateArrayLength(1, localMem[194], 2);
              ip = 517;
      end

        517 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[197]*10 + 2] = localMem[139];
              updateArrayLength(1, localMem[197], 2);
              ip = 518;
      end

        518 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 236] = heapMem[localMem[139]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 519;
      end

        519 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 237] = heapMem[localMem[236]*10 + localMem[144]];
              updateArrayLength(2, 0, 0);
              ip = 520;
      end

        520 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 238] = heapMem[localMem[139]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 521;
      end

        521 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 239] = heapMem[localMem[238]*10 + localMem[144]];
              updateArrayLength(2, 0, 0);
              ip = 522;
      end

        522 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 240] = heapMem[localMem[139]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 523;
      end

        523 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[240]*10 + 0] = localMem[237];
              updateArrayLength(1, localMem[240], 0);
              ip = 524;
      end

        524 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 241] = heapMem[localMem[139]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 525;
      end

        525 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[241]*10 + 0] = localMem[239];
              updateArrayLength(1, localMem[241], 0);
              ip = 526;
      end

        526 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 242] = heapMem[localMem[139]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 527;
      end

        527 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[242]*10 + 0] = localMem[194];
              updateArrayLength(1, localMem[242], 0);
              ip = 528;
      end

        528 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 243] = heapMem[localMem[139]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 529;
      end

        529 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[243]*10 + 1] = localMem[197];
              updateArrayLength(1, localMem[243], 1);
              ip = 530;
      end

        530 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[139]*10 + 0] = 1;
              updateArrayLength(1, localMem[139], 0);
              ip = 531;
      end

        531 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 244] = heapMem[localMem[139]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 532;
      end

        532 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[244]] = 1;
              ip = 533;
      end

        533 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 245] = heapMem[localMem[139]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 534;
      end

        534 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[245]] = 1;
              ip = 535;
      end

        535 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 246] = heapMem[localMem[139]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 536;
      end

        536 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[246]] = 2;
              ip = 537;
      end

        537 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 539;
      end

        538 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 544;
      end

        539 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 540;
      end

        540 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 140] = 1;
              updateArrayLength(2, 0, 0);
              ip = 541;
      end

        541 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 544;
      end

        542 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 543;
      end

        543 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 140] = 0;
              updateArrayLength(2, 0, 0);
              ip = 544;
      end

        544 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 545;
      end

        545 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[140] != 0 ? 547 : 546;
      end

        546 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 24] = localMem[139];
              updateArrayLength(2, 0, 0);
              ip = 547;
      end

        547 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 548;
      end

        548 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 798;
      end

        549 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 550;
      end

        550 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 247] = heapMem[localMem[24]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 551;
      end

        551 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 248] = 0; k = arraySizes[localMem[247]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[247] * NArea + i] == 1) localMem[0 + 248] = i + 1;
              end
              ip = 552;
      end

        552 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[248] == 0 ? 557 : 553;
      end

        553 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 0] = localMem[24];
              updateArrayLength(1, localMem[1], 0);
              ip = 554;
      end

        554 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 1] = 1;
              updateArrayLength(1, localMem[1], 1);
              ip = 555;
      end

        555 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              heapMem[localMem[1]*10 + 2] = localMem[248] - 1;
              ip = 556;
      end

        556 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 805;
      end

        557 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 558;
      end

        558 :
      begin                                                                     // arrayCountLess
//$display("AAAA %4d %4d arrayCountLess", steps, ip);
              j = 0; k = arraySizes[localMem[247]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[247] * NArea + i] < 1) j = j + 1;
              end
              localMem[0 + 249] = j;
              ip = 559;
      end

        559 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 250] = !heapMem[localMem[24]*10 + 6];
              ip = 560;
      end

        560 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[250] == 0 ? 565 : 561;
      end

        561 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 0] = localMem[24];
              updateArrayLength(1, localMem[1], 0);
              ip = 562;
      end

        562 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 1] = 0;
              updateArrayLength(1, localMem[1], 1);
              ip = 563;
      end

        563 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1]*10 + 2] = localMem[249];
              updateArrayLength(1, localMem[1], 2);
              ip = 564;
      end

        564 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 805;
      end

        565 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 566;
      end

        566 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 251] = heapMem[localMem[24]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 567;
      end

        567 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 252] = heapMem[localMem[251]*10 + localMem[249]];
              updateArrayLength(2, 0, 0);
              ip = 568;
      end

        568 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 569;
      end

        569 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 254] = heapMem[localMem[252]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 570;
      end

        570 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 255] = heapMem[localMem[252]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 571;
      end

        571 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 256] = heapMem[localMem[255]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 572;
      end

        572 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[254] <  localMem[256] ? 792 : 573;
      end

        573 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 257] = localMem[256];
              updateArrayLength(2, 0, 0);
              ip = 574;
      end

        574 :
      begin                                                                     // shiftRight
//$display("AAAA %4d %4d shiftRight", steps, ip);
              localMem[0 + 257] = localMem[257] >> 1;
              ip = 575;
      end

        575 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 258] = localMem[257] + 1;
              ip = 576;
      end

        576 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 259] = heapMem[localMem[252]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 577;
      end

        577 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[259] == 0 ? 674 : 578;
      end

        578 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 260] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 260] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 260]] = 0;
              ip = 579;
      end

        579 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[260]*10 + 0] = localMem[257];
              updateArrayLength(1, localMem[260], 0);
              ip = 580;
      end

        580 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[260]*10 + 2] = 0;
              updateArrayLength(1, localMem[260], 2);
              ip = 581;
      end

        581 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 261] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 261] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 261]] = 0;
              ip = 582;
      end

        582 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[260]*10 + 4] = localMem[261];
              updateArrayLength(1, localMem[260], 4);
              ip = 583;
      end

        583 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 262] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 262] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 262]] = 0;
              ip = 584;
      end

        584 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[260]*10 + 5] = localMem[262];
              updateArrayLength(1, localMem[260], 5);
              ip = 585;
      end

        585 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[260]*10 + 6] = 0;
              updateArrayLength(1, localMem[260], 6);
              ip = 586;
      end

        586 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[260]*10 + 3] = localMem[255];
              updateArrayLength(1, localMem[260], 3);
              ip = 587;
      end

        587 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[255]*10 + 1] = heapMem[localMem[255]*10 + 1] + 1;
              ip = 588;
      end

        588 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[260]*10 + 1] = heapMem[localMem[255]*10 + 1];
              updateArrayLength(1, localMem[260], 1);
              ip = 589;
      end

        589 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 263] = !heapMem[localMem[252]*10 + 6];
              ip = 590;
      end

        590 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[263] != 0 ? 619 : 591;
      end

        591 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 264] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 264] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 264]] = 0;
              ip = 592;
      end

        592 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[260]*10 + 6] = localMem[264];
              updateArrayLength(1, localMem[260], 6);
              ip = 593;
      end

        593 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 265] = heapMem[localMem[252]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 594;
      end

        594 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 266] = heapMem[localMem[260]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 595;
      end

        595 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 267] = heapMem[localMem[252]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 597;
      end

        597 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 268] = heapMem[localMem[260]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 598;
      end

        598 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 269] = heapMem[localMem[252]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 600;
      end

        600 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 270] = heapMem[localMem[260]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 601;
      end

        601 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 271] = localMem[257] + 1;
              ip = 602;
      end

        602 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 272] = heapMem[localMem[260]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 604;
      end

        604 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 273] = localMem[272] + 1;
              ip = 605;
      end

        605 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 274] = heapMem[localMem[260]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 606;
      end

        606 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 607;
      end

        607 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 275] = 0;
              updateArrayLength(2, 0, 0);
              ip = 608;
      end

        608 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 609;
      end

        609 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[275] >= localMem[273] ? 615 : 610;
      end

        610 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 276] = heapMem[localMem[274]*10 + localMem[275]];
              updateArrayLength(2, 0, 0);
              ip = 611;
      end

        611 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[276]*10 + 2] = localMem[260];
              updateArrayLength(1, localMem[276], 2);
              ip = 612;
      end

        612 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 613;
      end

        613 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 275] = localMem[275] + 1;
              ip = 614;
      end

        614 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 608;
      end

        615 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 616;
      end

        616 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 277] = heapMem[localMem[252]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 617;
      end

        617 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[277]] = localMem[258];
              ip = 618;
      end

        618 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 626;
      end

        619 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 620;
      end

        620 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 278] = heapMem[localMem[252]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 621;
      end

        621 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 279] = heapMem[localMem[260]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 622;
      end

        622 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 280] = heapMem[localMem[252]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 624;
      end

        624 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 281] = heapMem[localMem[260]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 625;
      end

        625 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d label", steps, ip);
              ip = 627;
      end

        627 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[252]*10 + 0] = localMem[257];
              updateArrayLength(1, localMem[252], 0);
              ip = 628;
      end

        628 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[260]*10 + 2] = localMem[259];
              updateArrayLength(1, localMem[260], 2);
              ip = 629;
      end

        629 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 282] = heapMem[localMem[259]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 630;
      end

        630 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 283] = heapMem[localMem[259]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 631;
      end

        631 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 284] = heapMem[localMem[283]*10 + localMem[282]];
              updateArrayLength(2, 0, 0);
              ip = 632;
      end

        632 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[284] != localMem[252] ? 651 : 633;
      end

        633 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 285] = heapMem[localMem[252]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 634;
      end

        634 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 286] = heapMem[localMem[285]*10 + localMem[257]];
              updateArrayLength(2, 0, 0);
              ip = 635;
      end

        635 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 287] = heapMem[localMem[259]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 636;
      end

        636 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[287]*10 + localMem[282]] = localMem[286];
              updateArrayLength(1, localMem[287], localMem[282]);
              ip = 637;
      end

        637 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 288] = heapMem[localMem[252]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 638;
      end

        638 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 289] = heapMem[localMem[288]*10 + localMem[257]];
              updateArrayLength(2, 0, 0);
              ip = 639;
      end

        639 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 290] = heapMem[localMem[259]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 640;
      end

        640 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[290]*10 + localMem[282]] = localMem[289];
              updateArrayLength(1, localMem[290], localMem[282]);
              ip = 641;
      end

        641 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 291] = heapMem[localMem[252]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 642;
      end

        642 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[291]] = localMem[257];
              ip = 643;
      end

        643 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 292] = heapMem[localMem[252]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 644;
      end

        644 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[292]] = localMem[257];
              ip = 645;
      end

        645 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 293] = localMem[282] + 1;
              ip = 646;
      end

        646 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[259]*10 + 0] = localMem[293];
              updateArrayLength(1, localMem[259], 0);
              ip = 647;
      end

        647 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 294] = heapMem[localMem[259]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 648;
      end

        648 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[294]*10 + localMem[293]] = localMem[260];
              updateArrayLength(1, localMem[294], localMem[293]);
              ip = 649;
      end

        649 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 789;
      end

        650 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 673;
      end

        651 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 652;
      end

        652 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 653;
      end

        653 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 295] = heapMem[localMem[259]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 654;
      end

        654 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 296] = 0; k = arraySizes[localMem[295]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[295] * NArea + i] == localMem[252]) localMem[0 + 296] = i + 1;
              end
              ip = 655;
      end

        655 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 296] = localMem[296] - 1;
              ip = 656;
      end

        656 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 297] = heapMem[localMem[252]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 657;
      end

        657 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 298] = heapMem[localMem[297]*10 + localMem[257]];
              updateArrayLength(2, 0, 0);
              ip = 658;
      end

        658 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 299] = heapMem[localMem[252]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 659;
      end

        659 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 300] = heapMem[localMem[299]*10 + localMem[257]];
              updateArrayLength(2, 0, 0);
              ip = 660;
      end

        660 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 301] = heapMem[localMem[252]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 661;
      end

        661 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[301]] = localMem[257];
              ip = 662;
      end

        662 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 302] = heapMem[localMem[252]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 663;
      end

        663 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[302]] = localMem[257];
              ip = 664;
      end

        664 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 303] = heapMem[localMem[259]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 665;
      end

        665 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 304] = heapMem[localMem[259]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 667;
      end

        667 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 305] = heapMem[localMem[259]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 669;
      end

        669 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 306] = localMem[296] + 1;
              ip = 670;
      end

        670 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[259]*10 + 0] = heapMem[localMem[259]*10 + 0] + 1;
              ip = 672;
      end

        672 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 789;
      end

        673 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 674;
      end

        674 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 675;
      end

        675 :
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
              ip = 676;
      end

        676 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[307]*10 + 0] = localMem[257];
              updateArrayLength(1, localMem[307], 0);
              ip = 677;
      end

        677 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[307]*10 + 2] = 0;
              updateArrayLength(1, localMem[307], 2);
              ip = 678;
      end

        678 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 308] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 308] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 308]] = 0;
              ip = 679;
      end

        679 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[307]*10 + 4] = localMem[308];
              updateArrayLength(1, localMem[307], 4);
              ip = 680;
      end

        680 :
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
              ip = 681;
      end

        681 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[307]*10 + 5] = localMem[309];
              updateArrayLength(1, localMem[307], 5);
              ip = 682;
      end

        682 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[307]*10 + 6] = 0;
              updateArrayLength(1, localMem[307], 6);
              ip = 683;
      end

        683 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[307]*10 + 3] = localMem[255];
              updateArrayLength(1, localMem[307], 3);
              ip = 684;
      end

        684 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[255]*10 + 1] = heapMem[localMem[255]*10 + 1] + 1;
              ip = 685;
      end

        685 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[307]*10 + 1] = heapMem[localMem[255]*10 + 1];
              updateArrayLength(1, localMem[307], 1);
              ip = 686;
      end

        686 :
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
              ip = 687;
      end

        687 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[310]*10 + 0] = localMem[257];
              updateArrayLength(1, localMem[310], 0);
              ip = 688;
      end

        688 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[310]*10 + 2] = 0;
              updateArrayLength(1, localMem[310], 2);
              ip = 689;
      end

        689 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 311] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 311] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 311]] = 0;
              ip = 690;
      end

        690 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[310]*10 + 4] = localMem[311];
              updateArrayLength(1, localMem[310], 4);
              ip = 691;
      end

        691 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 312] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 312] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 312]] = 0;
              ip = 692;
      end

        692 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[310]*10 + 5] = localMem[312];
              updateArrayLength(1, localMem[310], 5);
              ip = 693;
      end

        693 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[310]*10 + 6] = 0;
              updateArrayLength(1, localMem[310], 6);
              ip = 694;
      end

        694 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[310]*10 + 3] = localMem[255];
              updateArrayLength(1, localMem[310], 3);
              ip = 695;
      end

        695 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[255]*10 + 1] = heapMem[localMem[255]*10 + 1] + 1;
              ip = 696;
      end

        696 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[310]*10 + 1] = heapMem[localMem[255]*10 + 1];
              updateArrayLength(1, localMem[310], 1);
              ip = 697;
      end

        697 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 313] = !heapMem[localMem[252]*10 + 6];
              ip = 698;
      end

        698 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[313] != 0 ? 750 : 699;
      end

        699 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 314] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 314] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 314]] = 0;
              ip = 700;
      end

        700 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[307]*10 + 6] = localMem[314];
              updateArrayLength(1, localMem[307], 6);
              ip = 701;
      end

        701 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 315] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 315] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 315]] = 0;
              ip = 702;
      end

        702 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[310]*10 + 6] = localMem[315];
              updateArrayLength(1, localMem[310], 6);
              ip = 703;
      end

        703 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 316] = heapMem[localMem[252]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 704;
      end

        704 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 317] = heapMem[localMem[307]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 705;
      end

        705 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 318] = heapMem[localMem[252]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 707;
      end

        707 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 319] = heapMem[localMem[307]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 708;
      end

        708 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 320] = heapMem[localMem[252]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 710;
      end

        710 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 321] = heapMem[localMem[307]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 711;
      end

        711 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 322] = localMem[257] + 1;
              ip = 712;
      end

        712 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 323] = heapMem[localMem[252]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 714;
      end

        714 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 324] = heapMem[localMem[310]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 715;
      end

        715 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 325] = heapMem[localMem[252]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 717;
      end

        717 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 326] = heapMem[localMem[310]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 718;
      end

        718 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 327] = heapMem[localMem[252]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 720;
      end

        720 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 328] = heapMem[localMem[310]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 721;
      end

        721 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 329] = localMem[257] + 1;
              ip = 722;
      end

        722 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 330] = heapMem[localMem[307]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 724;
      end

        724 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 331] = localMem[330] + 1;
              ip = 725;
      end

        725 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 332] = heapMem[localMem[307]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 726;
      end

        726 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 727;
      end

        727 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 333] = 0;
              updateArrayLength(2, 0, 0);
              ip = 728;
      end

        728 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 729;
      end

        729 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[333] >= localMem[331] ? 735 : 730;
      end

        730 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 334] = heapMem[localMem[332]*10 + localMem[333]];
              updateArrayLength(2, 0, 0);
              ip = 731;
      end

        731 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[334]*10 + 2] = localMem[307];
              updateArrayLength(1, localMem[334], 2);
              ip = 732;
      end

        732 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 733;
      end

        733 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 333] = localMem[333] + 1;
              ip = 734;
      end

        734 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 728;
      end

        735 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 736;
      end

        736 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 335] = heapMem[localMem[310]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 737;
      end

        737 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 336] = localMem[335] + 1;
              ip = 738;
      end

        738 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 337] = heapMem[localMem[310]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 739;
      end

        739 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 740;
      end

        740 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 338] = 0;
              updateArrayLength(2, 0, 0);
              ip = 741;
      end

        741 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 742;
      end

        742 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[338] >= localMem[336] ? 748 : 743;
      end

        743 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 339] = heapMem[localMem[337]*10 + localMem[338]];
              updateArrayLength(2, 0, 0);
              ip = 744;
      end

        744 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[339]*10 + 2] = localMem[310];
              updateArrayLength(1, localMem[339], 2);
              ip = 745;
      end

        745 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 746;
      end

        746 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 338] = localMem[338] + 1;
              ip = 747;
      end

        747 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 741;
      end

        748 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 749;
      end

        749 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 765;
      end

        750 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 751;
      end

        751 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 340] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 340] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 340]] = 0;
              ip = 752;
      end

        752 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[252]*10 + 6] = localMem[340];
              updateArrayLength(1, localMem[252], 6);
              ip = 753;
      end

        753 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 341] = heapMem[localMem[252]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 754;
      end

        754 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 342] = heapMem[localMem[307]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 755;
      end

        755 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 343] = heapMem[localMem[252]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 757;
      end

        757 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 344] = heapMem[localMem[307]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 758;
      end

        758 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 345] = heapMem[localMem[252]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 760;
      end

        760 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 346] = heapMem[localMem[310]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 761;
      end

        761 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 347] = heapMem[localMem[252]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 763;
      end

        763 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 348] = heapMem[localMem[310]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 764;
      end

        764 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d label", steps, ip);
              ip = 766;
      end

        766 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[307]*10 + 2] = localMem[252];
              updateArrayLength(1, localMem[307], 2);
              ip = 767;
      end

        767 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[310]*10 + 2] = localMem[252];
              updateArrayLength(1, localMem[310], 2);
              ip = 768;
      end

        768 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 349] = heapMem[localMem[252]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 769;
      end

        769 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 350] = heapMem[localMem[349]*10 + localMem[257]];
              updateArrayLength(2, 0, 0);
              ip = 770;
      end

        770 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 351] = heapMem[localMem[252]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 771;
      end

        771 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 352] = heapMem[localMem[351]*10 + localMem[257]];
              updateArrayLength(2, 0, 0);
              ip = 772;
      end

        772 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 353] = heapMem[localMem[252]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 773;
      end

        773 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[353]*10 + 0] = localMem[350];
              updateArrayLength(1, localMem[353], 0);
              ip = 774;
      end

        774 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 354] = heapMem[localMem[252]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 775;
      end

        775 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[354]*10 + 0] = localMem[352];
              updateArrayLength(1, localMem[354], 0);
              ip = 776;
      end

        776 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 355] = heapMem[localMem[252]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 777;
      end

        777 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[355]*10 + 0] = localMem[307];
              updateArrayLength(1, localMem[355], 0);
              ip = 778;
      end

        778 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 356] = heapMem[localMem[252]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 779;
      end

        779 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[356]*10 + 1] = localMem[310];
              updateArrayLength(1, localMem[356], 1);
              ip = 780;
      end

        780 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[252]*10 + 0] = 1;
              updateArrayLength(1, localMem[252], 0);
              ip = 781;
      end

        781 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 357] = heapMem[localMem[252]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 782;
      end

        782 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[357]] = 1;
              ip = 783;
      end

        783 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 358] = heapMem[localMem[252]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 784;
      end

        784 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[358]] = 1;
              ip = 785;
      end

        785 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 359] = heapMem[localMem[252]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 786;
      end

        786 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[359]] = 2;
              ip = 787;
      end

        787 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 789;
      end

        788 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 794;
      end

        789 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 790;
      end

        790 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 253] = 1;
              updateArrayLength(2, 0, 0);
              ip = 791;
      end

        791 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 794;
      end

        792 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 793;
      end

        793 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 253] = 0;
              updateArrayLength(2, 0, 0);
              ip = 794;
      end

        794 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 795;
      end

        795 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[253] != 0 ? 797 : 796;
      end

        796 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 24] = localMem[252];
              updateArrayLength(2, 0, 0);
              ip = 797;
      end

        797 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 798;
      end

        798 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 799;
      end

        799 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 132] = localMem[132] + 1;
              ip = 800;
      end

        800 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 302;
      end

        801 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 802;
      end

        802 :
      begin                                                                     // assert
//$display("AAAA %4d %4d assert", steps, ip);
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
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 806;
      end

        806 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 360] = heapMem[localMem[1]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 807;
      end

        807 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 361] = heapMem[localMem[1]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 808;
      end

        808 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 362] = heapMem[localMem[1]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 809;
      end

        809 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[361] != 1 ? 813 : 810;
      end

        810 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 363] = heapMem[localMem[360]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 811;
      end

        811 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[363]*10 + localMem[362]] = 11;
              updateArrayLength(1, localMem[363], localMem[362]);
              ip = 812;
      end

        812 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1059;
      end

        813 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 814;
      end

        814 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[361] != 2 ? 822 : 815;
      end

        815 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 364] = localMem[362] + 1;
              ip = 816;
      end

        816 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 365] = heapMem[localMem[360]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 817;
      end

        817 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 366] = heapMem[localMem[360]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 819;
      end

        819 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[360]*10 + 0] = heapMem[localMem[360]*10 + 0] + 1;
              ip = 821;
      end

        821 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 828;
      end

        822 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 823;
      end

        823 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 367] = heapMem[localMem[360]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 824;
      end

        824 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 368] = heapMem[localMem[360]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 826;
      end

        826 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[360]*10 + 0] = heapMem[localMem[360]*10 + 0] + 1;
              ip = 828;
      end

        828 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 829;
      end

        829 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              ip = 830;
      end

        830 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 831;
      end

        831 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 370] = heapMem[localMem[360]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 832;
      end

        832 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 371] = heapMem[localMem[360]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 833;
      end

        833 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 372] = heapMem[localMem[371]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 834;
      end

        834 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[370] <  localMem[372] ? 1054 : 835;
      end

        835 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 373] = localMem[372];
              updateArrayLength(2, 0, 0);
              ip = 836;
      end

        836 :
      begin                                                                     // shiftRight
//$display("AAAA %4d %4d shiftRight", steps, ip);
              localMem[0 + 373] = localMem[373] >> 1;
              ip = 837;
      end

        837 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 374] = localMem[373] + 1;
              ip = 838;
      end

        838 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 375] = heapMem[localMem[360]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 839;
      end

        839 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[375] == 0 ? 936 : 840;
      end

        840 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 376] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 376] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 376]] = 0;
              ip = 841;
      end

        841 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[376]*10 + 0] = localMem[373];
              updateArrayLength(1, localMem[376], 0);
              ip = 842;
      end

        842 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[376]*10 + 2] = 0;
              updateArrayLength(1, localMem[376], 2);
              ip = 843;
      end

        843 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 377] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 377] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 377]] = 0;
              ip = 844;
      end

        844 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[376]*10 + 4] = localMem[377];
              updateArrayLength(1, localMem[376], 4);
              ip = 845;
      end

        845 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 378] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 378] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 378]] = 0;
              ip = 846;
      end

        846 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[376]*10 + 5] = localMem[378];
              updateArrayLength(1, localMem[376], 5);
              ip = 847;
      end

        847 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[376]*10 + 6] = 0;
              updateArrayLength(1, localMem[376], 6);
              ip = 848;
      end

        848 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[376]*10 + 3] = localMem[371];
              updateArrayLength(1, localMem[376], 3);
              ip = 849;
      end

        849 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[371]*10 + 1] = heapMem[localMem[371]*10 + 1] + 1;
              ip = 850;
      end

        850 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[376]*10 + 1] = heapMem[localMem[371]*10 + 1];
              updateArrayLength(1, localMem[376], 1);
              ip = 851;
      end

        851 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 379] = !heapMem[localMem[360]*10 + 6];
              ip = 852;
      end

        852 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[379] != 0 ? 881 : 853;
      end

        853 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 380] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 380] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 380]] = 0;
              ip = 854;
      end

        854 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[376]*10 + 6] = localMem[380];
              updateArrayLength(1, localMem[376], 6);
              ip = 855;
      end

        855 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 381] = heapMem[localMem[360]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 856;
      end

        856 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 382] = heapMem[localMem[376]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 857;
      end

        857 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 383] = heapMem[localMem[360]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 859;
      end

        859 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 384] = heapMem[localMem[376]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 860;
      end

        860 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 385] = heapMem[localMem[360]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 862;
      end

        862 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 386] = heapMem[localMem[376]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 863;
      end

        863 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 387] = localMem[373] + 1;
              ip = 864;
      end

        864 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 388] = heapMem[localMem[376]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 866;
      end

        866 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 389] = localMem[388] + 1;
              ip = 867;
      end

        867 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 390] = heapMem[localMem[376]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 868;
      end

        868 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 869;
      end

        869 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 391] = 0;
              updateArrayLength(2, 0, 0);
              ip = 870;
      end

        870 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 871;
      end

        871 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[391] >= localMem[389] ? 877 : 872;
      end

        872 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 392] = heapMem[localMem[390]*10 + localMem[391]];
              updateArrayLength(2, 0, 0);
              ip = 873;
      end

        873 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[392]*10 + 2] = localMem[376];
              updateArrayLength(1, localMem[392], 2);
              ip = 874;
      end

        874 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 875;
      end

        875 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 391] = localMem[391] + 1;
              ip = 876;
      end

        876 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 870;
      end

        877 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 878;
      end

        878 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 393] = heapMem[localMem[360]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 879;
      end

        879 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[393]] = localMem[374];
              ip = 880;
      end

        880 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 888;
      end

        881 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 882;
      end

        882 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 394] = heapMem[localMem[360]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 883;
      end

        883 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 395] = heapMem[localMem[376]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 884;
      end

        884 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 396] = heapMem[localMem[360]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 886;
      end

        886 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 397] = heapMem[localMem[376]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 887;
      end

        887 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d label", steps, ip);
              ip = 889;
      end

        889 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[360]*10 + 0] = localMem[373];
              updateArrayLength(1, localMem[360], 0);
              ip = 890;
      end

        890 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[376]*10 + 2] = localMem[375];
              updateArrayLength(1, localMem[376], 2);
              ip = 891;
      end

        891 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 398] = heapMem[localMem[375]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 892;
      end

        892 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 399] = heapMem[localMem[375]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 893;
      end

        893 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 400] = heapMem[localMem[399]*10 + localMem[398]];
              updateArrayLength(2, 0, 0);
              ip = 894;
      end

        894 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[400] != localMem[360] ? 913 : 895;
      end

        895 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 401] = heapMem[localMem[360]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 896;
      end

        896 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 402] = heapMem[localMem[401]*10 + localMem[373]];
              updateArrayLength(2, 0, 0);
              ip = 897;
      end

        897 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 403] = heapMem[localMem[375]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 898;
      end

        898 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[403]*10 + localMem[398]] = localMem[402];
              updateArrayLength(1, localMem[403], localMem[398]);
              ip = 899;
      end

        899 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 404] = heapMem[localMem[360]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 900;
      end

        900 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 405] = heapMem[localMem[404]*10 + localMem[373]];
              updateArrayLength(2, 0, 0);
              ip = 901;
      end

        901 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 406] = heapMem[localMem[375]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 902;
      end

        902 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[406]*10 + localMem[398]] = localMem[405];
              updateArrayLength(1, localMem[406], localMem[398]);
              ip = 903;
      end

        903 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 407] = heapMem[localMem[360]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 904;
      end

        904 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[407]] = localMem[373];
              ip = 905;
      end

        905 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 408] = heapMem[localMem[360]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 906;
      end

        906 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[408]] = localMem[373];
              ip = 907;
      end

        907 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 409] = localMem[398] + 1;
              ip = 908;
      end

        908 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[375]*10 + 0] = localMem[409];
              updateArrayLength(1, localMem[375], 0);
              ip = 909;
      end

        909 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 410] = heapMem[localMem[375]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 910;
      end

        910 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[410]*10 + localMem[409]] = localMem[376];
              updateArrayLength(1, localMem[410], localMem[409]);
              ip = 911;
      end

        911 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1051;
      end

        912 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 935;
      end

        913 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 914;
      end

        914 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 915;
      end

        915 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 411] = heapMem[localMem[375]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 916;
      end

        916 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 412] = 0; k = arraySizes[localMem[411]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[411] * NArea + i] == localMem[360]) localMem[0 + 412] = i + 1;
              end
              ip = 917;
      end

        917 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 412] = localMem[412] - 1;
              ip = 918;
      end

        918 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 413] = heapMem[localMem[360]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 919;
      end

        919 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 414] = heapMem[localMem[413]*10 + localMem[373]];
              updateArrayLength(2, 0, 0);
              ip = 920;
      end

        920 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 415] = heapMem[localMem[360]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 921;
      end

        921 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 416] = heapMem[localMem[415]*10 + localMem[373]];
              updateArrayLength(2, 0, 0);
              ip = 922;
      end

        922 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 417] = heapMem[localMem[360]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 923;
      end

        923 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[417]] = localMem[373];
              ip = 924;
      end

        924 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 418] = heapMem[localMem[360]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 925;
      end

        925 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[418]] = localMem[373];
              ip = 926;
      end

        926 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 419] = heapMem[localMem[375]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 927;
      end

        927 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 420] = heapMem[localMem[375]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 929;
      end

        929 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 421] = heapMem[localMem[375]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 931;
      end

        931 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 422] = localMem[412] + 1;
              ip = 932;
      end

        932 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[375]*10 + 0] = heapMem[localMem[375]*10 + 0] + 1;
              ip = 934;
      end

        934 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1051;
      end

        935 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 936;
      end

        936 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 937;
      end

        937 :
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
              ip = 938;
      end

        938 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[423]*10 + 0] = localMem[373];
              updateArrayLength(1, localMem[423], 0);
              ip = 939;
      end

        939 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[423]*10 + 2] = 0;
              updateArrayLength(1, localMem[423], 2);
              ip = 940;
      end

        940 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 424] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 424] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 424]] = 0;
              ip = 941;
      end

        941 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[423]*10 + 4] = localMem[424];
              updateArrayLength(1, localMem[423], 4);
              ip = 942;
      end

        942 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 425] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 425] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 425]] = 0;
              ip = 943;
      end

        943 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[423]*10 + 5] = localMem[425];
              updateArrayLength(1, localMem[423], 5);
              ip = 944;
      end

        944 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[423]*10 + 6] = 0;
              updateArrayLength(1, localMem[423], 6);
              ip = 945;
      end

        945 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[423]*10 + 3] = localMem[371];
              updateArrayLength(1, localMem[423], 3);
              ip = 946;
      end

        946 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[371]*10 + 1] = heapMem[localMem[371]*10 + 1] + 1;
              ip = 947;
      end

        947 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[423]*10 + 1] = heapMem[localMem[371]*10 + 1];
              updateArrayLength(1, localMem[423], 1);
              ip = 948;
      end

        948 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 426] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 426] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 426]] = 0;
              ip = 949;
      end

        949 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[426]*10 + 0] = localMem[373];
              updateArrayLength(1, localMem[426], 0);
              ip = 950;
      end

        950 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[426]*10 + 2] = 0;
              updateArrayLength(1, localMem[426], 2);
              ip = 951;
      end

        951 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 427] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 427] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 427]] = 0;
              ip = 952;
      end

        952 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[426]*10 + 4] = localMem[427];
              updateArrayLength(1, localMem[426], 4);
              ip = 953;
      end

        953 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 428] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 428] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 428]] = 0;
              ip = 954;
      end

        954 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[426]*10 + 5] = localMem[428];
              updateArrayLength(1, localMem[426], 5);
              ip = 955;
      end

        955 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[426]*10 + 6] = 0;
              updateArrayLength(1, localMem[426], 6);
              ip = 956;
      end

        956 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[426]*10 + 3] = localMem[371];
              updateArrayLength(1, localMem[426], 3);
              ip = 957;
      end

        957 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[371]*10 + 1] = heapMem[localMem[371]*10 + 1] + 1;
              ip = 958;
      end

        958 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[426]*10 + 1] = heapMem[localMem[371]*10 + 1];
              updateArrayLength(1, localMem[426], 1);
              ip = 959;
      end

        959 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 429] = !heapMem[localMem[360]*10 + 6];
              ip = 960;
      end

        960 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[429] != 0 ? 1012 : 961;
      end

        961 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 430] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 430] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 430]] = 0;
              ip = 962;
      end

        962 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[423]*10 + 6] = localMem[430];
              updateArrayLength(1, localMem[423], 6);
              ip = 963;
      end

        963 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 431] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 431] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 431]] = 0;
              ip = 964;
      end

        964 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[426]*10 + 6] = localMem[431];
              updateArrayLength(1, localMem[426], 6);
              ip = 965;
      end

        965 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 432] = heapMem[localMem[360]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 966;
      end

        966 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 433] = heapMem[localMem[423]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 967;
      end

        967 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 434] = heapMem[localMem[360]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 969;
      end

        969 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 435] = heapMem[localMem[423]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 970;
      end

        970 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 436] = heapMem[localMem[360]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 972;
      end

        972 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 437] = heapMem[localMem[423]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 973;
      end

        973 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 438] = localMem[373] + 1;
              ip = 974;
      end

        974 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 439] = heapMem[localMem[360]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 976;
      end

        976 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 440] = heapMem[localMem[426]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 977;
      end

        977 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 441] = heapMem[localMem[360]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 979;
      end

        979 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 442] = heapMem[localMem[426]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 980;
      end

        980 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 443] = heapMem[localMem[360]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 982;
      end

        982 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 444] = heapMem[localMem[426]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 983;
      end

        983 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 445] = localMem[373] + 1;
              ip = 984;
      end

        984 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 446] = heapMem[localMem[423]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 986;
      end

        986 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 447] = localMem[446] + 1;
              ip = 987;
      end

        987 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 448] = heapMem[localMem[423]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 988;
      end

        988 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 989;
      end

        989 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 449] = 0;
              updateArrayLength(2, 0, 0);
              ip = 990;
      end

        990 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 991;
      end

        991 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[449] >= localMem[447] ? 997 : 992;
      end

        992 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 450] = heapMem[localMem[448]*10 + localMem[449]];
              updateArrayLength(2, 0, 0);
              ip = 993;
      end

        993 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[450]*10 + 2] = localMem[423];
              updateArrayLength(1, localMem[450], 2);
              ip = 994;
      end

        994 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 995;
      end

        995 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 449] = localMem[449] + 1;
              ip = 996;
      end

        996 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 990;
      end

        997 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 998;
      end

        998 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 451] = heapMem[localMem[426]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 999;
      end

        999 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 452] = localMem[451] + 1;
              ip = 1000;
      end

       1000 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 453] = heapMem[localMem[426]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1001;
      end

       1001 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1002;
      end

       1002 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 454] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1003;
      end

       1003 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1004;
      end

       1004 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[454] >= localMem[452] ? 1010 : 1005;
      end

       1005 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 455] = heapMem[localMem[453]*10 + localMem[454]];
              updateArrayLength(2, 0, 0);
              ip = 1006;
      end

       1006 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[455]*10 + 2] = localMem[426];
              updateArrayLength(1, localMem[455], 2);
              ip = 1007;
      end

       1007 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1008;
      end

       1008 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 454] = localMem[454] + 1;
              ip = 1009;
      end

       1009 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1003;
      end

       1010 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1011;
      end

       1011 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1027;
      end

       1012 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1013;
      end

       1013 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 456] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 456] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 456]] = 0;
              ip = 1014;
      end

       1014 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[360]*10 + 6] = localMem[456];
              updateArrayLength(1, localMem[360], 6);
              ip = 1015;
      end

       1015 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 457] = heapMem[localMem[360]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1016;
      end

       1016 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 458] = heapMem[localMem[423]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1017;
      end

       1017 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 459] = heapMem[localMem[360]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1019;
      end

       1019 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 460] = heapMem[localMem[423]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1020;
      end

       1020 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 461] = heapMem[localMem[360]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1022;
      end

       1022 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 462] = heapMem[localMem[426]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1023;
      end

       1023 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 463] = heapMem[localMem[360]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1025;
      end

       1025 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 464] = heapMem[localMem[426]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1026;
      end

       1026 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1028;
      end

       1028 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[423]*10 + 2] = localMem[360];
              updateArrayLength(1, localMem[423], 2);
              ip = 1029;
      end

       1029 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[426]*10 + 2] = localMem[360];
              updateArrayLength(1, localMem[426], 2);
              ip = 1030;
      end

       1030 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 465] = heapMem[localMem[360]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1031;
      end

       1031 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 466] = heapMem[localMem[465]*10 + localMem[373]];
              updateArrayLength(2, 0, 0);
              ip = 1032;
      end

       1032 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 467] = heapMem[localMem[360]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1033;
      end

       1033 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 468] = heapMem[localMem[467]*10 + localMem[373]];
              updateArrayLength(2, 0, 0);
              ip = 1034;
      end

       1034 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 469] = heapMem[localMem[360]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1035;
      end

       1035 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[469]*10 + 0] = localMem[466];
              updateArrayLength(1, localMem[469], 0);
              ip = 1036;
      end

       1036 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 470] = heapMem[localMem[360]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1037;
      end

       1037 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[470]*10 + 0] = localMem[468];
              updateArrayLength(1, localMem[470], 0);
              ip = 1038;
      end

       1038 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 471] = heapMem[localMem[360]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1039;
      end

       1039 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[471]*10 + 0] = localMem[423];
              updateArrayLength(1, localMem[471], 0);
              ip = 1040;
      end

       1040 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 472] = heapMem[localMem[360]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1041;
      end

       1041 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[472]*10 + 1] = localMem[426];
              updateArrayLength(1, localMem[472], 1);
              ip = 1042;
      end

       1042 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[360]*10 + 0] = 1;
              updateArrayLength(1, localMem[360], 0);
              ip = 1043;
      end

       1043 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 473] = heapMem[localMem[360]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1044;
      end

       1044 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[473]] = 1;
              ip = 1045;
      end

       1045 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 474] = heapMem[localMem[360]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1046;
      end

       1046 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[474]] = 1;
              ip = 1047;
      end

       1047 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 475] = heapMem[localMem[360]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1048;
      end

       1048 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[475]] = 2;
              ip = 1049;
      end

       1049 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1051;
      end

       1050 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1056;
      end

       1051 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1052;
      end

       1052 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 369] = 1;
              updateArrayLength(2, 0, 0);
              ip = 1053;
      end

       1053 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1056;
      end

       1054 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1055;
      end

       1055 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 369] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1056;
      end

       1056 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1057;
      end

       1057 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1058;
      end

       1058 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1059;
      end

       1059 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1060;
      end

       1060 :
      begin                                                                     // free
//$display("AAAA %4d %4d free", steps, ip);
              freedArrays[freedArraysTop] = localMem[1];
              freedArraysTop = freedArraysTop + 1;
              ip = 1061;
      end
      default: begin
        success  = 1;
        finished = 1;
      end
    endcase
    if (steps <=     34) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
//for(i = 0; i < 200; ++i) $write("%4d",   localMem[i]); $display("");
//for(i = 0; i < 200; ++i) $write("%4d",    heapMem[i]); $display("");
//for(i = 0; i < 200; ++i) $write("%4d", arraySizes[i]); $display("");
  end
endmodule
